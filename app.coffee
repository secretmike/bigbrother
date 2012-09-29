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

# Update URL for adding new data
app.all "/update", (req, res) ->
    console.log "HELLOOOOO"
    console.log req.query, req.body
    res.send "OK"

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
    
    socket.emit "new point",
        log: -63.572903
        lat: 44.643987
    
    socket.emit "new line", [
        log: -63.572903
        lat: 44.643987
    ,
        log: -63.579791
        lat: 44.647895
    ]
    
    # TODOs:  send redis data to client
