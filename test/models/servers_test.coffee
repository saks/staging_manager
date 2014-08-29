app      = require "#{APP_ROOT}/app"
require "#{APP_ROOT}/app/models/server"
mongoose = require 'mongoose'
Server   = mongoose.model 'Server'

describe 'Server model', ->
  beforeEach (done) ->
    Server.collection.remove -> done()

  it 'should lock free server', (done) ->
    Factory.create 'server', (server) ->
      attrs = locked: true, locked_by_id: 123, locked_by_name: 'foo'

      expect(server.locked).to.not.be.ok()
      expect(server.locked_by_id).to.not.be.ok()
      expect(server.locked_by_name).to.not.be.ok()

      Server.toggleLock server.id, attrs, (lockError, server) ->
        expect(lockError).to.not.be.ok()
        expect(server.locked).to.be.ok()

        expect(server.locked).to.eql         attrs.locked
        expect(server.locked_by_id).to.eql   attrs.locked_by_id
        expect(server.locked_by_name).to.eql attrs.locked_by_name

        done()

  it 'should not lock already locked server', (done) ->
    attrs = locked: true, locked_by_id: 123, locked_by_name: 'foo'

    Factory.create 'server', attrs, (server) ->
      expect(server.locked).to.eql         attrs.locked
      expect(server.locked_by_id).to.eql   attrs.locked_by_id
      expect(server.locked_by_name).to.eql attrs.locked_by_name

      newAttrs = locked: true, locked_by_id: 321, locked_by_name: 'bar'
      Server.toggleLock server.id, newAttrs, (lockError, server) ->
        expect(lockError).to.not.be.ok()
        expect(server.locked).to.eql         attrs.locked
        expect(server.locked_by_id).to.eql   attrs.locked_by_id
        expect(server.locked_by_name).to.eql attrs.locked_by_name

        done()

  it 'should return error if cannot find server', (done) ->
    Server.toggleLock 123, locked: true, (error, server) ->
      expect(error).to.be.ok()
      expect(server).to.not.be.ok()

      done()


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
