var App = Ember.Application.create();

App.Router.map(function() {
  this.resource('servers', { path: '/' })
});


App.Server = DS.Model.extend({
  name: DS.attr('string'),
  ip_address: DS.attr('string'),
});

App.IndexRoute = Ember.Route.extend({
  model: function() {
    return this.store.find('server');
  }
});

App.ServersController = Ember.Controller.extend({
  actions: {
    lock: function(server) {
      // TODO: lock server and sync with db
    }
  }
})

App.ServersRoute = Ember.Route.extend({
  model: function() {
    return this.store.find('server');
  }
});

