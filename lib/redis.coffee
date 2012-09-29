# Redis variable
if process.env.REDISTOGO_URL
    # production
    rtg = require("url").parse(process.env.REDISTOGO_URL)
    redis = require("redis").createClient(rtg.port, rtg.hostname)
    redis.auth rtg.auth.split(":")[1]
else
    # local
    redis = require("redis").createClient()

module.exports = redis

# Requiring this file by a variable will assign redis to that variable
#
# Example
#
# var redis = require('./lib/redis.coffee')