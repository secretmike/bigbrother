# Mappy
class Mappy
    constructor: (@tracker) ->
        # Get redis
        @redis = require('./lib/redis.coffee')

    add: (point) ->
        # Add point to end of redis for tracker
        return @redis.rpush @tracker, point

    getAll: ->
        # Get all points in an array from tracker
        return @redis.lrange @tracker, 0, -1

    clear: ->
        # Delete all points for a tracker (and from redis)
        return @redis.del @tracker