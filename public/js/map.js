$(function()
{
    var lastPoint = null;
    var trackers  = {};
    
    //
    // Map
    //
    var map            = new OpenLayers.Map("map");
    map.addLayer(new OpenLayers.Layer.OSM());
    var mapnik         = new OpenLayers.Layer.OSM();
    var fromProjection = new OpenLayers.Projection("EPSG:4326");
    var toProjection   = new OpenLayers.Projection("EPSG:900913");
    var position       = new OpenLayers.LonLat(-63.572903, 44.643987).transform
                                               (fromProjection, toProjection);
    var zoom           = 15;
    var markers        = new OpenLayers.Layer.Markers("Markers");
    map.addLayer(markers);
    
    var lines          = new OpenLayers.Layer.Vector("Lines");
    map.addLayer(lines);

    map.addLayer(mapnik);
    map.setCenter(position, zoom);
    
    
    //
    // Sockets
    //
    var socket = io.connect();

    socket.on("connect", function(e) {
        
    });
    
    socket.on("reconnect", function(e) {
        trackers = {};
        markers.clearMarkers();
        lines.removeAllFeatures(); 
    });

    socket.on("disconnect", function(e) {
       console.log("Lost server connection");
    });
    
    //
    // Point receive
    //
    socket.on("new point", function(e) {
        console.log(e);
        var sid = e.sid;
        provisionSid(sid);
        
        var marker = addMarker(e.log, e.lat);
        
        var markerPosition = getPosition(e.log, e.lat);
        map.setCenter(markerPosition, zoom);
        
        if (trackers[sid].last.point == null)
        {
            trackers[sid].last.point = e;
            trackers[sid].last.marker = marker;
            requestPin(sid);
            return;
        }
        
        removeMarker(trackers[sid].last.marker);
        var line = addLine([
            e,
            trackers[sid].last.point
        ]);
        
        trackers[sid].lines.unprocessed.push(line);
        
        trackers[sid].last.point = e;
        trackers[sid].last.marker = marker;
        requestLines(sid);
        requestPin(sid);
    });
    
    //
    // Provision SID
    //
    var provisionSid = function(sid)
    {
        if (sid in trackers) {
            return;
        }
        trackers[sid] = {
            last: {
                point: null,
                marker: null
            },
            lines: {
               unprocessed: [],
               processed: new Array()
            },
            colour: null,
            pin: null
        };
    };
    
    //
    // Pins
    //
    var requestPin = function(sid)
    {
        if(trackers[sid].pin != null)
        {
            return;
        }
        socket.emit("request pin", {"sid": sid});
    };
    
    var setMarkerPin = function(sid)
    {
        if (trackers[sid].last.marker == null)
        {
            return;
        }
        var pin = trackers[sid].pin;
        
        trackers[sid].last.marker.setUrl(pin + ".png");
    };
    
    socket.on("pin", function(e) {
        trackers[e.sid].pin = e.pin;
        setMarkerPin(e.sid);
    });
    
    //
    // Colors
    //
    var requestLines = function(sid)
    {
        if(trackers[sid].colour != null)
        {
            processLines();
            return;
        }
        socket.emit("request colour", {"sid": sid});
    };
    
    socket.on("colour", function(e)
    {
       trackers[e.sid].colour = "#" + e.colour;
       processLines(e.sid);
    });
    
    var processLines = function(sid)
    {
        var colour = trackers[sid].colour;
        while(trackers[sid].lines.unprocessed.length)
        {
            var line = trackers[sid].lines.unprocessed.pop();
            line.style.strokeColor = colour;
            lines.drawFeature(line);
            
            trackers[sid].lines.processed.push(line);
        }
    };
    
    //
    // Lines
    //
    var addLine = function(points)
    {
        points = new Array(
            new OpenLayers.Geometry.Point(points[0].log, points[0].lat),
            new OpenLayers.Geometry.Point(points[1].log, points[1].lat)
        );
        
        for(var i = 0; i < points.length; i++)
        {
            points[i].transform(new OpenLayers.Projection("EPSG:4326"),
                                map.getProjectionObject());
        }
        var line = new OpenLayers.Geometry.LineString(points);
        
        var style = { 
          strokeColor: '#0000ff', 
          strokeOpacity: 0.5,
          strokeWidth: 5
        };
        
        var lineFeature = new OpenLayers.Feature.Vector(line, null, style);
        lines.addFeatures([lineFeature]);
        
        return lineFeature;
    };
    
    //
    // Position
    //
    var getPosition = function(lon, lat) {
        return new OpenLayers.LonLat(lon, lat).transform(fromProjection,
                                                         toProjection);
    };
    
    //
    // Markers
    //
    var addMarker = function(lon, lat) {
        var pos = getPosition(lon, lat);
        var marker = new OpenLayers.Marker(pos);
        markers.addMarker(marker);
        return marker;
    };
    
    var removeMarker = function(marker) {
        markers.removeMarker(marker);
    };
    
    
    //
    // Map Size
    //
    var updateMapSize = function() {        
        var newMapHeight = Math.max($(window).height() - $("header").height()
            - 10, 0);
        $("#map").css("height", newMapHeight + "px");
        map.updateSize();
    };
    updateMapSize();
    $(window).resize(updateMapSize);
    
    
});
