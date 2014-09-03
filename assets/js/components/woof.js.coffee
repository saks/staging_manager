Ember.Application.initializer(
  name: 'registerWoofMessages',

  initialize: (container, application) ->
    application.register 'woof:main', Ember.Woof
)

Ember.Application.initializer(
  name: 'injectWoofMessages',

  initialize: (container, application) ->
    application.inject 'controller', 'woof', 'woof:main'
    application.inject 'component',  'woof', 'woof:main'
    application.inject 'route',      'woof', 'woof:main'

)

Ember.Woof = Ember.ArrayProxy.extend(
  content: Ember.A()
  timeout: 5000
  currentMessage: ->
    @get "firstObject"

  pushObject: (object) ->
    @clear()
    object.typeClass = "alert-" + object.type
    @_super object

  danger: (message) ->
    @pushObject
      type: "danger"
      message: message

  warning: (message) ->
    @pushObject
      type: "warning"
      message: message

  info: (message) ->
    @pushObject
      type: "info"
      message: message

  success: (message) ->
    @pushObject
      type: "success"
      message: message

  permanent: (message) ->
    @pushObject
      type: "danger"
      permanent: true
      message: message
)
