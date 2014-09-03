Ember.Handlebars.registerBoundHelper 'formatDate', (date) ->
  moment(date).format 'lll'

Ember.Handlebars.registerBoundHelper 'linkToServer', (server) ->
  href   = "https://#{server.get 'host'}"
  text   = server.get 'name'
  icon   = '<span class="glyphicon glyphicon-new-window"></span>'
  string = "<a href='#{href}' class='open-site' target='_blank'>#{text}#{icon}</a>"
  new Handlebars.SafeString string
