request  = require('supertest')
app      = require(__dirname + './../app')
Factory  = require('factory-lady')
mongoose = require('mongoose')
Server   = mongoose.model('Server')

describe 'GET /servers', ->
  it 'should return json with servers', (done) ->
    request(app).get('/servers').expect /Hello, Express!/, done
