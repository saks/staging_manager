App = Ember.Application.create()

## Models:
attr = DS.attr
socket = io.connect()

socket.on 'servers/update', (data) ->
  Ember.Instrumentation.instrument("signalr.notificationOccured", data)




App.Server = DS.Model.extend
  name:           attr('string')
  ip_address:     attr('string')
  locked:         attr('boolean')
  locked_at:      attr('date')
  host:           attr('string')
  locked_by_id:   attr('string')
  locked_by_name: attr('string')
  branch:         attr('string')
  revision:       attr('string')
  deployed_at:    attr('date')
  deployed_by_id: attr('string')
  deployed_by_name:  attr('string')
  deployed_by_login: attr('string')


# woof again:
App.XWoofComponent = Ember.Component.extend(
  classNames: 'woof-messages'
  messages: Ember.computed.alias('woof')
)
App.XWoofMessageComponent = Ember.Component.extend(
  classNames:        ['x-woof-message-container']
  classNameBindings: ['insertState']
  insertState:       'pre-insert'
  didInsertElement: ->
    self = this
    self.$().bind 'webkitTransitionEnd', (event) ->
      self.woof.removeObject self.get('message') if self.get('insertState') is 'destroyed'

    Ember.run.later (-> self.set 'insertState', 'inserted'), 250

    if self.woof.timeout and not self.woof.currentMessage().permanent
      Ember.run.later (->
        return if self._state is 'destroying'
        self.woof.clear()
      ), self.woof.timeout

  click: ->
    @woof.clear()  unless @woof.currentMessage().permanent
)

# end of woof
$currentUserField = $('[name=current-user]')
App.currentUser = $.parseJSON($currentUserField.attr('content'))  if $currentUserField.length > 0


App.ApplicationView = Ember.View.extend(classNames: [])
App.Router.map ->
  @resource 'index', path: '/'
  @resource 'servers'


## Routes
App.IndexRoute = Ember.Route.extend(
  renderTemplate: ->
    if App.currentUser
      @transitionTo 'servers'
    else
      @render 'login'
)
App.ServersRoute = Ember.Route.extend(
  setupController: (controller, model) ->
    routeObject = @
    @_super(controller, model)


    Ember.Instrumentation.subscribe("signalr.notificationOccured", {
      before: (name, timestamp, payload) ->
        routeObject.store.push 'Server', payload.server

        controller._subControllers.forEach (controller) ->
          controller.send('signalrNotificationOccured', payload)
      after: ->
    })


  model: -> @store.find 'server'
  actions:
    tryUnlock: (server, controller) ->
      @render 'confirmUnlock',
        into: 'application'
        outlet: 'modal'
        model: server
        controller: controller

      setTimeout(->
        $('#confirmUnlock').modal()
      , 100)
)

## Controllers:
lockedByCurrentUser = -> @get('locked_by_id') is App.currentUser.id
App.ServerController = Ember.ObjectController.extend(
  isLoading: false
  branchName: (->
    @get('branch') or 'n/a'
  ).property 'branch'
  deployedAt: (->
    @get('deployed_at') or 'n/a'
  ).property 'deployed_at'
  deployedBy: (->
    @get('deployed_by_name') or 'n/a'
  ).property 'deployed_by_name'
  lockedByCurrentUser: lockedByCurrentUser.property 'locked_by_id'

  actions:
    signalrNotificationOccured: (context) ->
      controllerObject = @
      if @model.get('id') is context.server.id
        @set 'isLoading', true
        Ember.run.later -> controllerObject.set 'isLoading', false
        , 200

    lock: (server) ->
      woof       = @woof
      controller = @
      @set 'isLoading', true
      socket.emit '/servers/lock', id: server.get('id')

      # server.set 'locked', true
      # server.save().then (server) ->
      #   controller.set 'isLoading', false
      #   if server.get('locked_by_id') is App.currentUser.id
      #     woof.success "Server <strong>#{server.get 'name'}</strong> was successfully locked."
      #   else
      #     woof.permanent "Cannot lock <strong>#{server.get 'name'}</strong>! " +
      #       "Server was locked by <strong>#{server.get 'locked_by_name'}</strong> earlier!"

    unlock: (server) ->
      @send 'closeModal' # in the case it was opened
      woof       = @woof
      controller = @

      wasLockedBy = server.get 'locked_by_id'
      @set 'isLoading', true
      socket.emit '/servers/unlock', id: server.get('id')
      # server.reload().then (server) ->
      #   # if somebody updated server before
      #   if server.get('locked_by_id') isnt wasLockedBy
      #     woof.warning 'Somebody changes server settigns before you.'
      #     controller.set 'isLoading', false
      #     return
      #
      #   server.set 'locked', false
      #   server.save().then (server) ->
      #     controller.set 'isLoading', false
      #     woof.success "Server <strong>#{server.get 'name'}</strong> was successfully unlocked."
)
App.ServersController = Ember.ArrayController.extend(
  itemController: 'server'
)
App.ApplicationRoute = Ember.Route.extend(
  actions:
    closeModal: -> @disconnectOutlet outlet: 'modal', parentView: 'application'
)
