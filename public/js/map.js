$(function()
{
    //
    // Map
    //
    var map = new OpenLayers.Map("map");
    map.addLayer(new OpenLayers.Layer.OSM());
    var mapnik         = new OpenLayers.Layer.OSM();
    var fromProjection = new OpenLayers.Projection("EPSG:4326");   // Transform from WGS 1984
    var toProjection   = new OpenLayers.Projection("EPSG:900913"); // to Spherical Mercator Projection
    var position       = new OpenLayers.LonLat(-63.572903,44.643987).transform( fromProjection, toProjection);
    var zoom           = 15;

    map.addLayer(mapnik);
    map.setCenter(position, zoom);

    //
    // Sockets
    //
    var socket = io.connect();

    socket.on("connect", function(e) {
        console.log(e);
    });

    socket.on("disconnect", function(e) {
       console.log("Lost server connection"); 
    });
    
    
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
