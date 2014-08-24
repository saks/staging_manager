app      = require "#{APP_ROOT}/app"
require "#{APP_ROOT}/app/models/server"
mongoose = require 'mongoose'
Server   = mongoose.model 'Server'

describe 'Server model', ->
  beforeEach (done) ->
    Server.collection.remove -> done()

  it 'should return servers list as correct json', (done) ->
    Factory.create 'server', ->
      Factory.create 'server', ->
        Server.find (err, models) ->
          json    = JSON.stringify models
          servers = JSON.parse json
          server  = servers[0]

          expect(servers).to.be.ok()
          expect(servers.length).to.eql 2

          expect(server.name).to.eql 'staging 1'
          expect(server.ip_address).to.be.ok()

      done()
