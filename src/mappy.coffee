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
            $self.getColor(data.sid)

        @socket.on "request pin", (data) ->
            $self.getPin(data.sid)


    pushLocation: (lat,long,sid) ->
        # Timestamp
        time = Math.round(+new Date()/1000)

        # Create the point array
        point = {"lat": lat, "long": long, "timestamp": time}

        # Store it in redis
        @add(sid, point)

        # Emit it to socket.io
        @socket.emit "new point",
            log: long
            lat: lat
            sid: sid

    createTracker: (sid, data) ->
        return @redis.hmset sid, data

    getColor: (sid) ->
        return @redis.hget sid, "colour"

    getPin: (sid) ->
        return @redis.hget sid, "pin"

    add: (sid, point) ->
        # Add point to end of redis for sid
        return @redis.rpush sid, JSON.stringify(point)

    clear: (sid) ->
        # Delete all points for a sid (and from redis)
        return @redis.del sid


module.exports = new Mappy