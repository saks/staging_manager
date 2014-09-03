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
  deployed_at:    attr('date')
  deployed_by_id: attr('string')
  deployed_by_name: attr('string')


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
  model: -> @store.find 'server'
)


## Controllers:
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


  actions:
    lock: (server) ->
      woof       = @woof
      controller = @
      @set 'isLoading', true

      server.set 'locked', true
      server.save().then (server) ->
        controller.set 'isLoading', false
        if server.get('locked_by_id') is App.currentUser.id
          woof.success "Server #{server.get 'name'} was successfully locked."
        else
          woof.permanent "Cannot lock <strong>#{server.get 'name'}</strong>! " +
            "Server was locked by <strong>#{server.get 'locked_by_name'}</strong> earlier!"

    unlock: (server) ->
      woof       = @woof
      controller = @
      confirmationText = "Are you sure you want to unlock server that was locked by #{server.get 'locked_by_name'} ?"
      lockedByThisUser = server.get('locked_by_id') is App.currentUser.id

      if (not lockedByThisUser and confirm(confirmationText)) or lockedByThisUser
        @set 'isLoading', true
        server.set 'locked', false
        server.save().then (server) ->
          controller.set 'isLoading', false
          woof.success "Server #{server.get 'name'} was successfully unlocked."
)
App.ServersController = Ember.ArrayController.extend(
  itemController: 'server'
)
