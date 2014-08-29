express = require 'express'
router  = express.Router()
SMAuth  = require './../lib/smauth'


# Initial page redirecting to Github
router.get '/signin', (req, res) ->
  session = req.session
  if session.user_id
    res.redirect '/'
  else
    res.redirect SMAuth.authorization_uri

router.get '/signout', (req, res) ->
  delete req.session.user_id
  res.redirect '/'

# Callback service parsing the authorization token and asking for the access token
router.get '/callback', (req, res) ->
  session = req.session
  code = req.query.code

  new SMAuth code, (error, user) ->
    session.user_id = user.id unless error
    res.redirect '/'


module.exports = router
