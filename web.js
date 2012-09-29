var express = require('express');


// Configure app
var app = express();
app.set('views', __dirname + '/views');
app.set('view engine', 'jade');

app.configure('development', function() {
  app.locals.pretty = true;
});

// Set up middleware
app.use(express.responseTime());
app.use(express.logger());
app.use(express.favicon());
app.use(express.cookieParser());
app.use(express.bodyParser());
app.use(express.session({"secret": "BadWolf"}));
//app.use(flash());
app.use(app.router);
app.use(express.static(__dirname + '/public'));

// Start listening
var port = process.env.PORT || 5000;
var server = app.listen(port, function(){
    console.log("Server listening on " + port);
});




app.get('/', function(request, response) {
  response.render('index')
});

