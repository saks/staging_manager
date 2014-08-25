var App = Ember.Application.create();

App.Router.map(function() {
  this.resource('servers', { path: '/' })
});


App.Server = DS.Model.extend({
  name      : DS.attr('string'),
  ip_address: DS.attr('string'),
  locked    : DS.attr('boolean'),
});

App.IndexRoute = Ember.Route.extend({
  model: function() {
    return this.store.find('server');
  }
});

App.ServersController = Ember.Controller.extend({
  actions: {
    lock: function(server) {
      server.set('locked', true);
      server.save().catch(function() {
        alert('Server was locked by somebody before!')
      })
    },
    unlock: function(server) {
      server.set('locked', false);
      server.save();
    },
  }
})

App.ServersRoute = Ember.Route.extend({
  model: function() {
    return this.store.find('server');
  }
});

