var express = require('express');

var app = express();
app.set('views', __dirname + '/views');
app.set('view engine', 'jade');



var server = app.listen(8000);
console.log('Server listening at http://127.0.0.1:8000/');

// Routes
app.get('/', function(req, res) {
    res.render('index');
});

