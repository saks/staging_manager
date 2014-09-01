app      = require "#{APP_ROOT}/app"
require "#{APP_ROOT}/app/models/server"
mongoose = require 'mongoose'
Server   = mongoose.model 'Server'

describe 'Server model', ->
  beforeEach (done) ->
    Server.collection.remove -> done()

  it 'should unlock server if requested', (done) ->
    Factory.create 'server', (server) ->
      Factory.create 'user', (user) ->
        lockOptions = id: server.id, locked: true, user: user
        Server.toggleLock lockOptions, (lockError, lockedServer) ->
          expect(lockedServer.locked).to.eql true

          unlockOptions = id: lockedServer.id, locked: false, user: user
          Server.toggleLock unlockOptions, (lockError, unlockedServer) ->
            expect(unlockedServer.locked).to.eql false
            expect(unlockedServer.locked_by_id).to.be undefined
            expect(unlockedServer.locked_by_name).to.be undefined
            expect(unlockedServer.locked_at).to.be undefined

            done()


  it 'should lock free server', (done) ->
    Factory.create 'server', (server) ->
      Factory.create 'user', (user) ->

        expect(server.locked).to.not.be.ok()
        expect(server.locked_by_id).to.not.be.ok()
        expect(server.locked_by_name).to.not.be.ok()

        options = id: server.id, locked: true, user: user

        Server.toggleLock options, (lockError, server) ->
          expect(lockError).to.not.be.ok()
          expect(server.locked).to.be.ok()

          expect(server.locked).to.eql                  options.locked
          expect(server.locked_by_name).to.eql          user.verboseName()
          expect(server.locked_by_id.toString()).to.eql user.id.toString()
          expect(server.locked_at.toString()).to.eql    new Date().toString()

          done()

  it 'should not lock already locked server', (done) ->
    Factory.create 'user', (alreadyLockedByUser) ->
      Factory.create 'user', (user) ->

        initialAttrs = locked: true, locked_by_id: alreadyLockedByUser.id, locked_by_name: 'foo'
        Factory.create 'server', initialAttrs, (server) ->
          expect(server.locked).to.eql         initialAttrs.locked
          expect(server.locked_by_id.toString()).to.eql   initialAttrs.locked_by_id.toString()
          expect(server.locked_by_name).to.eql initialAttrs.locked_by_name

          options = id: server.id, locked: true, user: user
          Server.toggleLock options, (lockError, updatedServer) ->

            expect(lockError).to.not.be.ok()
            expect(updatedServer.locked).to.eql                  initialAttrs.locked
            expect(updatedServer.locked_by_id.toString()).to.eql initialAttrs.locked_by_id.toString()
            expect(updatedServer.locked_by_name).to.eql          initialAttrs.locked_by_name

          done()

  it 'should return error if cannot find server', (done) ->
    Server.toggleLock id: 123, locked: true, (error, server) ->
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
