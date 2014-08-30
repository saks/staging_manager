express  = require('express')
router   = express.Router()


# POST create deployment
router.post '/deployment', (request, response) ->
  # session = request.session
  #
  # User.current session, (err, currentUser) ->
  #   response.render 'index', title: 'Express', currentUser: currentUser


module.exports = router
