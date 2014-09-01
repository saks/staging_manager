mongoose = require 'mongoose'
require "#{APP_ROOT}/app/models/server"
require "#{APP_ROOT}/app/models/user"
Server   = mongoose.model 'Server'
User     = mongoose.model 'User'

Factory.define 'server', Server,
  name: 'staging 1',
  ip_address: '8.8.8.8',

Factory.define 'user', User,
  name: 'foo-bar-user-name',
