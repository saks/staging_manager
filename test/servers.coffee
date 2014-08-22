request  = require('supertest')
expect   = require 'expect.js'
app      = require(__dirname + './../app')
Factory  = require('factory-lady')
mongoose = require('mongoose')
Server   = mongoose.model('Server')


Factory.define 'server', Server,
  name: 'staging 1',
  ip_address: '8.8.8.8',

describe 'GET /servers', ->
  beforeEach (done) ->
    Server.collection.drop()
    Factory.create('server', -> done() )

  it 'should return json with servers', (done) ->
    request(app)
      .get '/servers'
      .expect 'Content-Type', /json/
      .expect 200
      .expect (res) ->
        servers = res.body.servers
        server  = servers[0]

        expect(servers.length).to.eql 1

        expect(server.id).to.be.ok()
        expect(server.id.length).to.eql 24
        expect(server.name).to.eql 'staging 1'
        expect(server.ip_address).to.eql '8.8.8.8'

        return
      .end done
