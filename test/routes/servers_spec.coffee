request  = require 'supertest'
app      = require "#{APP_ROOT}/app"
mongoose = require 'mongoose'
Server   = mongoose.model 'Server'

describe '/servers route', ->
  describe 'GET #show', ->
    it 'should return 404 if not exist', (done) ->
      request(app)
        .get '/servers/123'
        .expect 404
        .end done

    it 'should return server by id', (done) ->
      Factory.create 'server', (server) ->
        request(app)
          .get "/servers/#{server.id}"
          .expect 200
          .expect (res) ->
            expect(res.body).to.have.property 'server'

            server = res.body.server
            expect(server).to.have.property 'id'
            expect(server).to.have.property('branch').and.eql server.branch

            return
          .end done

  describe 'PUT #update', ->
    it 'should return 406 if not exist', (done) ->
      request(app)
        .put '/servers/123'
        .expect 406
        .end done

    it 'should lock server', (done) ->
      Factory.create 'user', (user) ->
        Factory.create 'server', (server) ->
          expect(server.locked).to.be.false
          expect(server.locked_by_id).to.not.exist
          expect(server.locked_by_name).to.not.exist
          expect(server.locked_by_login).to.not.exist


          request(app)
            .put("/servers/#{server.id}")
            .send(server: { locked: true })
            .expect(200)
            .expect (res) ->

              expect(res.body.server.locked).to.be.true
              expect(res.body.server.locked_by_id).to.eql user.id
              expect(res.body.server.locked_by_name).to.eql user.verboseName()
              expect(res.body.server.locked_by_login).to.eql user.login

              Server.findById server.id, (err, updatedServer) ->
                expect(updatedServer.locked).to.be.true
                expect(updatedServer.locked_by_id.toString()).to.eql user.id
                expect(updatedServer.locked_by_name).to.eql user.verboseName()
                expect(updatedServer.locked_by_login).to.eql user.login

              return

            .end(done)


  describe 'GET #index', ->
    it 'should return enpty array if no servers in db', (done) ->
      request(app)
        .get '/servers'
        .expect 200
        .expect (res) ->
          expect(res.body.servers).to.be.empty
          return
        .end done

    it 'should return json with servers', (done) ->
      Factory.create 'server', ->
        request(app)
          .get '/servers'
          .expect 'Content-Type', /json/
          .expect 200
          .expect (res) ->
            servers = res.body.servers
            server  = servers[0]

            expect(servers.length).to.eql 1
            [
              'name', 'ip_address', 'locked', 'locked_at', 'host', 'locked_by_id', 'locked_by_name',
              'branch', 'revision', 'deployed_at', 'deployed_by_id', 'deployed_by_name',
              'deployed_by_login', 'locked_by_login'
            ].forEach (attrName) ->
              expect(server).to.have.property attrName


            expect(server.id.length).to.eql 24
            expect(server.name).to.eql 'staging 1'
            expect(server.ip_address).to.eql '8.8.8.8'
            return

          .end done
