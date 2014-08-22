# request  = require('supertest')
# expect   = require 'expect.js'
# app      = require(__dirname + './../app')
# Factory  = require('factory-lady')
# mongoose = require('mongoose')
# Server   = mongoose.model('Server')
#
# Factory.define 'server', Server,
#   name: 'staging 1',
#   ip_address: '8.8.8.8',

# describe 'Server model', ->
#   beforeEach (done) ->
#     Server.collection.drop()
#     Factory.create('server', -> done() )
#
#   it 'should have class method listAsJSON', (done) ->
#     expect(1).to.eql 1
#     done()
