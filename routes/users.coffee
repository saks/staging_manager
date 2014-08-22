express = require('express')
router = express.Router()

# GET users listing.
router.get '/', (req, res) ->
  res.send 'respond users with a resource'
  return

module.exports = router
