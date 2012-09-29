# Express
express = require("express")

# Create an app variable for express
app = express()

# Redis Variable
redis = require './lib/redis.coffee'

# Jade Configuration
app.set "views", __dirname + "/views"
app.set "view engine", "jade"
app.configure "development", ->
    app.locals.pretty = true

# Set up middleware
app.use express.responseTime()
app.use express.logger()
app.use express.cookieParser()
app.use express.bodyParser()
app.use express.session(secret: "BadWolf")

# Express Static and Router
app.use app.router
app.use express.static(__dirname + "/public")

####################################
# ExpressJS Routes
####################################
app.get "/", (req, res) ->
    res.render "index"

# Tracker configuration
app.get "/trackers", (req, res) ->
    res.render "trackers" # TODO:  fetch from redis

app.post "/trackers/pin", (req, res) ->
    # TODO:  Client sends the fields: id (the session id), pin (the pin)
    
app.post "/trackers/colour", (req, res) ->
    # TODO:  Client sends the fields: id (the session id), colour (the colour)

# Update URL for adding new data
app.all "/update", (req, res) ->
    console.log "HELLOOOOO"
    console.log req.query, req.body
    res.send "OK"

# HTML5 geolocation page for trackers
app.get "/webtracker", (req, res) ->
    res.render "webtracker",
        sid: req.sessionID

# Listen to port
port = process.env.PORT || 3000
listener = app.listen port, ->
    console.log "Server running on " + port

###
# Socket.IO
###
socket = require("socket.io")
io = socket.listen(listener)
io.sockets.on "connection", (socket) ->
    console.log "SocketIO Connection"
    
    socket.on "request colour", (data) ->
        console.log data
        #TODO:  GET FROM REDIS
        socket.emit "colour",
            sid: data.sid,
            colour: "ff0000"
    
    socket.on "request pin", (data) ->
        console.log data
        #TODO: GET FROM REDIS
        socket.emit "pin",
            sid: data.sid
            pin: "male"

    socket.on "position update", (data) ->
        console.log data
        socket.broadcast.emit "new point",
            sid: data.sid
            log: data.longitude
            lat: data.latitude

    socket.emit "new point",
        sid: "test"
        log: -63.572903
        lat: 44.643987

    socket.emit "new point",
        sid: "test"
        log: -63.579791
        lat: 44.647895

    socket.emit "new point",
        sid: "test"
        log: -63.587880
        lat: 44.644872

    # TODOs:  send redis data to client
