express  = require('express')
router   = express.Router()
mongoose = require 'mongoose'
User     = mongoose.model 'User'
SMAuth   = require './../lib/smauth'


# GET home page.
router.get '/', (request, response) ->
  session = request.session

  User.current session, (err, currentUser) ->
    response.render 'index', title: 'Express', currentUser: currentUser

# GET heartbeat
router.get '/heartbeat', (request, response) ->
  response.json 200, 'OK'


module.exports = router
