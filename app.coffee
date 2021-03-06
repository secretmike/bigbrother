# Express
express = require("express")

# Redis Variable
redis = require './lib/redis.coffee'
#RedisSessionStore = require('connect-redis')(express)

# Create an app variable for express
app = express()

# Get mappy
map = require './src/mappy.coffee'

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
#app.use express.session(store: new RedisSessionStore({ttl: 60 * 30}),
#                         secret: "BadWolf")
app.use express.session(
#  store: new RedisSessionStore(ttl: 60 * 30)
  secret: "BadWolf"
)

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
    map.setPin("test", "green")

app.post "/trackers/colour", (req, res) ->
    # TODO:  Client sends the fields: id (the session id), colour (the colour)

# Update URL for adding new data
app.all "/update", (req, res) ->
#{ latitude: '44.64505358596971',
#  longitude: '-63.572418104813146',
#  accuracy: '20.0',
#  altitude: '28.0',
#  provider: 'gps',
#  bearing: '258.228',
#  speed: '0.56682956',
#  time: '2012-09-29T22:47:01.00Z',
#  battlevel: '63',
#  charging: '0',
#  deviceid: '355266040354407',
#  subscriberid: '302220300261101' }
    console.log "UPDATE", req.query, req.body
    io.sockets.emit "position update",
        sid: req.body.deviceid
        timestamp: req.body.time
        accuracy: req.body.accuracy
        longitude: req.body.longitude
        latitude: req.body.latitude
    res.send "OK"

# HTML5 geolocation page for trackers
app.get "/webtracker", (req, res) ->
    res.render "webtracker",
        sid: req.sessionID

# Listen to port
port = process.env.PORT || 3000
listener = app.listen port, ->
    console.log "Server running on " + port

# Socket IO
socket = require("socket.io")
io = socket.listen(listener)
io.set "log level", 2

# Connect to Socket IO
io.sockets.on "connection", (socket) ->
    # Start mappy for tracker
    mappy = map.init socket

    # Push locations
    map.pushLocation(44.643987,-63.572903, "track:0001")

    map.createTracker('0001', 'billy', 'ff0000', 'male')

    map.setPin("0001", "green")
