mongoose = require 'mongoose'

Server = new mongoose.Schema({
  name:       String,
  ip_address: String,
})

module.exports = mongoose.model 'Server', Server
