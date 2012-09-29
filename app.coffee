# Express
express = require("express")

# Create an app variable for express
app = express()
app.set 'view engine', 'jade'


app.configure 'development', ->
  app.locals.pretty = true


####################################
# ExpressJS Routes
####################################
app.get "/", (req, res) ->
    res.render 'index'

# Listen to port
app.listen 3000
