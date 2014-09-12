IO = null


Ember.Application.initializer({
  name: 'namedInitializer',
  initialize: (container, application) ->
    IO = io.connect()

    IO.on '/servers/update', (data) ->
      Ember.Instrumentation.instrument('signal.servers.update', data)

    IO.on '/servers/index', (data) ->
      Ember.Instrumentation.instrument('signal.servers.index', data)

    IO.on '/error', (data) ->
      document.location.reload()
})



App = Ember.Application.create()

## Models:
attr = DS.attr


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


    Ember.Instrumentation.subscribe('signal.servers.update', {
      before: (name, timestamp, payload) ->
        routeObject.store.push 'Server', payload.server

        controller._subControllers.forEach (controller) ->
          controller.send('update', payload)
      after: ->
    })

    Ember.Instrumentation.subscribe('signal.servers.index', {
      before: (name, timestamp, payload) ->
        controller.send 'loadModels', payload
      after: ->
    })



  model: -> @store.all 'server'
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
  changeAttempt: null

  branchName: (-> @get('branch') or 'n/a'          ).property 'branch'

  deployedAt: (-> @get('deployed_at') or 'n/a'     ).property 'deployed_at'

  deployedBy: (-> @get('deployed_by_name') or 'n/a').property 'deployed_by_name'

  lockedByCurrentUser: lockedByCurrentUser.property 'locked_by_id'

  wasChangedByMe: ->
    changeAttempt = @get 'changeAttempt'
    (changeAttempt.serverId is @model.get('id')) and (changeAttempt.userId is @model.get('locked_by_id'))

  tryingToChangeServer: ->
    !!@get('changeAttempt')

  startAttemptToChange: ->
    @set 'isLoading', true
    @set 'changeAttempt', serverId: @model.get('id'), userId: App.currentUser.id

  actions:
    update: (context) ->
      controllerObject = @
      model            = @model
      woof             = @woof

      if model.get('id') is context.server.id
        @set 'isLoading', true
        Ember.run.later (->
          controllerObject.set 'isLoading', false

          if model.get('locked')
            if controllerObject.tryingToChangeServer()
              if controllerObject.wasChangedByMe()
                woof.success "Server <strong>#{model.get 'name'}</strong> was successfully locked."
              else
                woof.permanent "Cannot lock <strong>#{model.get 'name'}</strong>! " +
                  "Server was locked by <strong>#{model.get 'locked_by_name'}</strong> earlier!"
              controllerObject.set 'changeAttempt', null

            else
              woof.info "Server <strong>#{model.get 'name'}</strong> was locked."
          else
            if controllerObject.tryingToChangeServer()
              woof.success "Server <strong>#{model.get 'name'}</strong> was successfully unlocked."
              controllerObject.set 'changeAttempt', null
            else
              woof.info "Server <strong>#{model.get 'name'}</strong> was unlocked."

        ), 200

    lock: (server) ->
      @startAttemptToChange()
      IO.emit '/servers/lock', id: server.get('id')

    unlock: (server) ->
      @send 'closeModal' # in the case it was opened
      @startAttemptToChange()
      IO.emit '/servers/unlock', id: @model.get('id')
)
App.ServersController = Ember.ArrayController.extend(
  itemController: 'server'
  actions:
    loadModels: (pushData) ->
      @store.pushPayload 'server', pushData
)
App.ApplicationRoute = Ember.Route.extend(
  actions:
    closeModal: -> @disconnectOutlet outlet: 'modal', parentView: 'application'
)
