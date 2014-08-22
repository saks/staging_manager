app     = require "#{APP_ROOT}/app"
request = require 'supertest'

describe 'vision heartbeat api', ->
  describe 'when requesting resource /heartbeat', ->
    it 'should respond with 200', (done) ->
      request app
        .get('/heartbeat')
        .expect('Content-Type', /json/)
        .expect(200, done)
