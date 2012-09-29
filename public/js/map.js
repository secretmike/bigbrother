$(function()
{
    var lastPoint = null;
    
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
        lastPoint = null;
        markers.clearMarkers();
        lines.removeAllFeatures(); 
    });

    socket.on("disconnect", function(e) {
       console.log("Lost server connection");
    });
    
    /*
    socket.on("new line", function(e) {
        console.log(e);
        addLine(e);
    });
    */
    
    //
    // Point receive
    //
    socket.on("new point", function(e) {
        console.log(e);
        
        var marker = addMarker(e.log, e.lat);
        
        if (lastPoint == null)
        {
            lastPoint = {"point": e, "marker": marker};
            return;
        }
        
        removeMarker(lastPoint.marker);
        addLine([
            e,
            lastPoint.point
        ]);
        
        lastPoint = {"point": e, "marker": marker};
    });
    
    
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
    };
    
    
    //
    // Markers
    //
    var addMarker = function(lon, lat) {
        var pos = new OpenLayers.LonLat(lon, lat).transform(fromProjection,
                                                            toProjection);
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
