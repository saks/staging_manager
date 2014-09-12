express = require 'express'
router  = express.Router()
SMAuth  = require './../lib/smauth'
mongoose = require 'mongoose'
User     = mongoose.model 'User'


# Initial page redirecting to Github
router.get '/signin', (req, res) ->
  if req.session.passport
    User.current req.session.passport.user.id, (error, currentUser) ->
      if error or not currentUser
        res.redirect SMAuth.authorization_uri
      else
        res.redirect '/'
  else
    res.redirect SMAuth.authorization_uri

router.get '/signout', (req, res) ->
  delete req.session
  res.redirect '/'

# Callback service parsing the authorization token and asking for the access token
router.get '/callback', (req, res) ->
  session = req.session
  code = req.query.code

  new SMAuth code, (error, user) ->
    unless error
      session.passport = { user: { id: user.id } }
    res.redirect '/'


module.exports = router
