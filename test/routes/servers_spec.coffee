request  = require 'supertest'
app      = require "#{APP_ROOT}/app"
mongoose = require 'mongoose'
Server   = mongoose.model 'Server'

describe '/servers route', ->
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
              'deployed_by_login'
            ].forEach (attrName) ->
              expect(server).to.have.property attrName


            expect(server.id.length).to.eql 24
            expect(server.name).to.eql 'staging 1'
            expect(server.ip_address).to.eql '8.8.8.8'
            return

          .end done
