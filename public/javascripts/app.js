var App = Ember.Application.create();

App.Router.map(function() {
  // put your routes here
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
