nock     = require 'nock'
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
            expect(unlockedServer.locked_by_id).to.be.undefined
            expect(unlockedServer.locked_by_name).to.be.undefined
            expect(unlockedServer.locked_at).to.be.undefined

            done()


  it 'should lock free server', (done) ->
    Factory.create 'server', (server) ->
      Factory.create 'user', (user) ->

        expect(server.locked).to.be.false
        expect(server.locked_by_id).to.not.exist
        expect(server.locked_by_name).to.not.exist

        options = id: server.id, locked: true, user: user

        Server.toggleLock options, (lockError, server) ->
          expect(lockError).to.not.exist
          expect(server.locked).to.exist

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

            expect(lockError).to.not.exist
            expect(updatedServer.locked).to.eql                  initialAttrs.locked
            expect(updatedServer.locked_by_id.toString()).to.eql initialAttrs.locked_by_id.toString()
            expect(updatedServer.locked_by_name).to.eql          initialAttrs.locked_by_name

          done()

  it 'should return error if cannot find server', (done) ->
    Server.toggleLock id: 123, locked: true, (error, server) ->
      expect(error).to.exist
      expect(server).to.not.exist

      done()


  it 'should return servers list as correct json', (done) ->
    Factory.create 'server', ->
      Factory.create 'server', ->
        Server.find (err, models) ->
          json    = JSON.stringify models
          servers = JSON.parse json
          server  = servers[0]

          expect(servers).to.exist
          expect(servers.length).to.eql 2

          expect(server.name).to.eql 'staging 1'
          expect(server.ip_address).to.exist

      done()

  it 'should record deployment', (done) ->
    githubUser =
      id:    123
      name:  'user-name'
      email: 'user@email.com'
      login: 'user-login'

    nock 'https://api.github.com'
      .get "/users/#{githubUser.name}"
      .reply 200, githubUser

    host   = 'foo.bar.buz'
    params =
      host:             host
      branch:           'master'
      deployed_by_name: githubUser.name
      deployed_at:      new Date()

    initialServerState = host: host, branch: null, revision: null, deployed_by_name: null
    Factory.create 'server', initialServerState, (server) ->
      expect(server.host).to.eql host
      expect(server.branch).to.not.be.ok
      expect(server.revision).to.not.be.ok
      expect(server.deployed_by_name).to.not.be.ok

      Server.recordDeployment params, (error) ->
        Server.findById server.id, (findError, server) ->
          expect(error).to.not.exist

          expect(server.branch).to.eql params.branch
          expect(server.deployed_by_name).to.eql params.deployed_by_name
          expect(server.deployed_at).to.equalDate params.deployed_at

          done()
