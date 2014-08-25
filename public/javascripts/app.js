var App = Ember.Application.create();

Ember.OAuth2.config = {
  github: {
    clientId:    '172930e2f1537d803337',
    authBaseUri: 'https://github.com/login/oauth/authorize',
    redirectUri: 'http://localhost:3000/#/oauth-callback',
    scope:       'user:email',
  }
}
Ember.MyOAuth2 = Ember.OAuth2.extend({
  handleRedirect: function (callbackLocation) {
    var callbackParams = this.parseCallback(callbackLocation.search);

    console.log(callbackParams.code)
    // $.post('http://github.com/login/oauth/access_token', {
    //   client_id:     this.get('clientId'),
    //   client_secret: '8323940a33c2aff4c0461eeb594854f9af9b482d',
    //   code:          callbackParams.code,
    // }, function() {
    //   debugger
    // }, 'json')
  }
});

App.oauth = Ember.MyOAuth2.create({providerId: 'github'});

App.ApplicationView = Ember.View.extend({
  classNames: ['site-wrapper'],
});



App.Router.map(function() {
  this.resource('index', { path: '/' })
  this.resource('servers')
  this.route('oauth-callback')
});

App.OauthCallbackRoute = Ember.Route.extend({
  activate: function() {
    window.opener.App.oauth.onRedirect(window.location);
    // window.close()
    // params = document.location.search
    // code   = params.slice(1, params.length).split('&')[0].split('=')[1]
    // alert(params, code)
  }
});

App.IndexRoute = Ember.Route.extend({
  renderTemplate: function() {
    if (false) {
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
