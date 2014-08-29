var App = Ember.Application.create();

var $currentUserField = $('[name=current-user]');
if ($currentUserField.length > 0) {
  App.currentUser = $.parseJSON($currentUserField.attr('content'));
};


App.ApplicationView = Ember.View.extend({
  classNames: ['site-wrapper'],
});

App.Router.map(function() {
  this.resource('index', { path: '/' })
  this.resource('servers')
  this.route('oauth-callback')
});

App.IndexRoute = Ember.Route.extend({
  renderTemplate: function() {
    if (App.currentUser) {
      this.transitionTo('servers');
    } else {
      this.render('login');
    }
  },
  setupController: function(controller, model) {
    controller.set('errorMessage', null);
  },
  actions: {
    login: function() {
      App.oauth.authorize();
    },
    sessionAuthenticationFailed: function(error) {
      this.controller.set('errorMessage', error);
    },
  },
});

App.Server = DS.Model.extend({
  name      : DS.attr('string'),
  ip_address: DS.attr('string'),
  locked    : DS.attr('boolean'),
  locked_by_id : DS.attr('number'),
  locked_by_name : DS.attr('string'),
});

App.ServersController = Ember.Controller.extend({
  actions: {
    lock: function(server) {
      currentUser = App.currentUser;

      server.set('locked', true);
      server.set('locked_by_id', currentUser.github_user_id);
      server.set('locked_by_name', currentUser.name || currentUser.login);
      server.save().then(function(server) {
        if (server.get('locked_by_id') != currentUser.github_user_id) {
          alert('Cannot lock! Server was locked by ' + server.get('locked_by_name') + ' earlier!')
        }
      })
    },
    unlock: function(server) {
      server.set('locked', false);
      server.set('locked_by_id', null);
      server.set('locked_by_name', null);
      server.save();
    },
  }
})

App.ServersRoute = Ember.Route.extend({
  model: function() {
    return this.store.find('server');
  }
});
