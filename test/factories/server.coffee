Factory  = require('factory-lady')
mongoose = require('mongoose')
Server   = mongoose.model('Server')

Factory.define 'server', Server,
  name: 'staging 1',
  ip_address: '8.8.8.8',
