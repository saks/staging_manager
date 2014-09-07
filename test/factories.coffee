mongoose = require 'mongoose'
require "#{APP_ROOT}/app/models/server"
require "#{APP_ROOT}/app/models/user"
Server   = mongoose.model 'Server'
User     = mongoose.model 'User'

Factory.define 'server', Server,
  name:              'staging 1'
  ip_address:        '8.8.8.8'
  locked:            false
  locked_at:         null
  host:              'staging1.net'
  locked_by_id:      null
  locked_by_name:    null
  branch:            'master'
  revision:          '123'
  deployed_at:       new Date()
  deployed_by_id:    null
  deployed_by_name:  'user name'
  deployed_by_login: 'user login'

Factory.define 'user', User,
  name: 'user-name'
  email: 'user@email.com'
  login: 'user-login'
