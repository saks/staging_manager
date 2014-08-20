var mongoose = require('mongoose');
var Schema   = mongoose.Schema;

var Server = new Schema({
  name: String,
  ip_address: String,
});

mongoose.model('Server', Server);
mongoose.connect('mongodb://localhost/staging_manager');
