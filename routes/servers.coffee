express  = require 'express'
router   = express.Router()
mongoose = require 'mongoose'
Server   = mongoose.model 'Server'

# GET home page.
router.get '/', (request, response) ->
  Server.allAsJson (document) ->
    response.json document

module.exports = router
