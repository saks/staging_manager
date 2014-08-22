mongoose = require('mongoose')
uristring = process.env.MONGOLAB_URI or process.env.MONGOHQ_URL or 'mongodb://localhost/staging_manager'

# Makes connection asynchronously.  Mongoose will queue up database
# operations and release them when the connection is complete.
mongoose.connect uristring, (err, res) ->
  if err
    console.log 'ERROR connecting to: ' + uristring + '. ' + err
  else
    console.log 'Succeeded connected to: ' + uristring
  return
