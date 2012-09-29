# Express
express = require("express")

# Create an app variable for express
app = express()

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

#app.use(flash());
app.use app.router
app.use express.static(__dirname + "/public")

####################################
# ExpressJS Routes
####################################
app.get "/", (req, res) ->
    res.render "index"

# Update URL for adding new data
app.get "/update", (req, res) ->
    console.log req.params
    res.send "OK"

# Listen to port
port = process.env.PORT || 3000
app.listen port, ->
    console.log "Server running on " + port
