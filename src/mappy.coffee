# Mappy
class Mappy

    init: (@socket) ->
        # Get redis
        @redis = require('./../lib/redis.coffee')

        $self = @

        # Listen for the position update and call required functions
        @socket.on "position update", (data) ->
            $self.pushLocation(data.latitude,data.longitude,data.sid)

        @socket.on "request colour", (data) ->
            $self.getColour(data.sid)

        @socket.on "request pin", (data) ->
            $self.getPin(data.sid)


    pushLocation: (lat,long,sid) ->
        # Timestamp
        time = Math.round(+new Date()/1000)

        # Create the point array
        point =
            lat: lat
            long: long
            timestamp: time

        # Store it in redis
        @add(sid, point)

        # Emit it to socket.io
        @socket.emit "new point",
            log: long
            lat: lat
            sid: sid

    createTracker: (sid, name, colour, pin) ->
        @redis.hset "tracks:"+sid, "name", name
        @redis.hset "tracks:"+sid, "colour", colour
        @redis.hset "tracks:"+sid, "pin", pin

    getColour: (sid) ->
        return @redis.hget "tracks:"+sid, "colour"

    getPin: (sid) ->
        return @redis.hget "tracks:"+sid, "pin"

    add: (sid, point) ->
        # Add point to end of redis for sid
        return @redis.rpush "points:"+sid, JSON.stringify(point)

    clear: (sid) ->
        # Delete all points for a sid (and from redis)
        return @redis.del "tracks:"+sid
        return @redis.del "points:"+sid


module.exports = new Mappy