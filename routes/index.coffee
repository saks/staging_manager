express = require('express')
router = express.Router()

# GET home page.
router.get '/', (req, res) ->
  res.render 'index',
    title: 'Express'

  return

# GET heartbeat
router.get '/heartbeat', (request, response) ->
  response.json 200, 'OK'

module.exports = router
