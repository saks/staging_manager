express  = require('express')
router   = express.Router()

# GET home page.
router.get '/', (request, response) ->
  response.render 'index', title: 'Staging Manager', currentUser: request.user

# GET heartbeat
router.get '/heartbeat', (request, response) ->
  response.json 200, 'OK'

module.exports = router
