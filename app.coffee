# Express
express = require("express")

# Create an app variable for express
app = express()

# Redis variable
if process.env.REDISTOGO_URL
    # production
    rtg = require("url").parse(process.env.REDISTOGO_URL)
    redis = require("redis").createClient(rtg.port, rtg.hostname)
    redis.auth rtg.auth.split(":")[1]
else
    # local
    redis = require("redis").createClient()

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
app.post "/update", (req, res) ->
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
