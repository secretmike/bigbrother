# Express
express = require("express")

# Create an app variable for express
app = express()

####################################
# ExpressJS Routes
####################################
app.get "/", (req, res) ->
    res.send "Hello world"

# Listen to port
app.listen 3000