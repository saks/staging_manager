mongoose = require('mongoose')

defaultUri ="mongodb://localhost/staging_manager#{if process.env.NODE_ENV then "_#{process.env.NODE_ENV}"}"

uristring = process.env.MONGOLAB_URI or process.env.MONGOHQ_URL or defaultUri

# Makes connection asynchronously.  Mongoose will queue up database
# operations and release them when the connection is complete.
mongoose.connect uristring, (err, res) ->
  if err
    console.log 'ERROR connecting to: ' + uristring + '. ' + err
  else
    console.log 'Succeeded connected to: ' + uristring
  return
