require "#{APP_ROOT}/db"
require "#{APP_ROOT}/app/models/server"
require "#{APP_ROOT}/app/models/user"

nock     = require 'nock'
mongoose = require 'mongoose'

User   = mongoose.model 'User'
Server = mongoose.model 'Server'

beforeEach (done) ->
  User.collection.remove ->
    Server.collection.remove ->
      done()
