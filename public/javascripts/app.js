//--- start of woof messages:
Ember.Application.initializer({
  name: "registerWoofMessages",

  initialize: function(container, application) {
    application.register('woof:main', Ember.Woof);
  }
});

Ember.Woof = Ember.ArrayProxy.extend({
  content: Ember.A(),
  timeout: 5000,
  currentMessage: function() {
    return this.get('firstObject')
  },
  pushObject: function(object) {
    this.clear();
    object.typeClass = 'alert-' + object.type;
    this._super(object);
  },
  danger: function(message) {
    this.pushObject({
      type: 'danger',
      message: message
    });
  },
  warning: function(message) {
    this.pushObject({
      type: 'warning',
      message: message
    });
  },
  info: function(message) {
    this.pushObject({
      type: 'info',
      message: message
    });
  },
  success: function(message) {
    this.pushObject({
      type: 'success',
      message: message
    });
  },
  permanent: function(message) {
    this.pushObject({
      type: 'danger',
      permanent: true,
      message: message
    });
  }
});

Ember.Application.initializer({
  name: "injectWoofMessages",

  initialize: function(container, application) {
    application.inject('controller', 'woof', 'woof:main');
    application.inject('component',  'woof', 'woof:main');
    application.inject('route',      'woof', 'woof:main');
  }
});

// --- end of woof messages ---

Ember.Handlebars.registerBoundHelper('formatDate', function(date) {
  return moment(date).format('lll')
});


var App = Ember.Application.create();

// woof again:
App.XWoofComponent = Ember.Component.extend({
  classNames: 'woof-messages',
  messages: Ember.computed.alias('woof')
});

App.XWoofMessageComponent = Ember.Component.extend({
  classNames: ['x-woof-message-container'],
  classNameBindings: ['insertState'],
  insertState: 'pre-insert',
  didInsertElement: function() {
    var self = this;
    self.$().bind('webkitTransitionEnd', function(event) {
      if (self.get('insertState') === 'destroyed') {
        self.woof.removeObject(self.get('message'));
      }
    });
    Ember.run.later(function() {
      self.set('insertState', 'inserted');
    }, 250);

    if (self.woof.timeout && !self.woof.currentMessage().permanent) {
      Ember.run.later(function() {
        if (self._state === 'destroying') return;
        self.woof.clear()
      }, self.woof.timeout);
    }
  },

  click: function() {
    if (!this.woof.currentMessage().permanent) {
      this.woof.clear()
    }
  }
});
// end of woof



var $currentUserField = $('[name=current-user]');
if ($currentUserField.length > 0) {
  App.currentUser = $.parseJSON($currentUserField.attr('content'));
};


App.ApplicationView = Ember.View.extend({
  classNames: [],
});

App.Router.map(function() {
  this.resource('index', { path: '/' })
  this.resource('servers')
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
});

App.Server = DS.Model.extend({
  name      : DS.attr('string'),
  ip_address: DS.attr('string'),
  locked    : DS.attr('boolean'),
  locked_by_id : DS.attr('string'),
  locked_by_name : DS.attr('string'),
  locked_at : DS.attr('date'),
});

App.ServersController = Ember.Controller.extend({
  actions: {
    lock: function(server) {
      woof = this.woof
      currentUser = App.currentUser;

      server.set('locked', true);

      server.save().then(function(server) {
        if (server.get('locked_by_id') == currentUser.id) {
          woof.success('Server ' + server.get('name') + ' was successfully locked.');
        } else {
          woof.permanent('Cannot lock <strong>' + server.get('name') +
              '</strong>! Server was locked by <strong>' + server.get('locked_by_name') +
              '</strong> earlier!');
        }
      })
    },
    unlock: function(server) {
      woof = this.woof

      server.set('locked', false);
      server.set('locked_by_id', null);
      server.set('locked_by_name', null);
      server.save().then(function(server) {
        woof.success('Server ' + server.get('name') + ' was successfully unlocked.')
      })
    },
  }
})

App.ServersRoute = Ember.Route.extend({
  model: function() {
    return this.store.find('server');
  }
});

App.ApplicationRoute = Ember.Route.extend({
  activate: function() {
    // this.woof.info('Welcome! Click me to dismiss or I will disappear in 5 seconds.');
  }
});
