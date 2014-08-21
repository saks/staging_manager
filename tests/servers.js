var request = require('supertest')
  , app = require(__dirname + '/../app')

var Factory = require('factory-lady');

var mongoose = require('mongoose');
var Server   = mongoose.model('Server');

describe('GET /servers', function () {
  it('should return json with servers', function (done) {
     request(app)
       .get('/servers')
       .expect(/Hello, Express!/, done)
  })
})
