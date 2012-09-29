$(function()
{
    //
    // Pin
    //
    $("form select.pin").change(function(e)
    {
        var val  = $(this).val();
        var name = $(this).prop("name").split("_")[0];
        
        console.log(name + " -> " + val);
        
        $.ajax("/trackers/pin", {
            type: "POST",
            data: {
                "id":  name,
                "pin": val
            }
        });
    });
    
    //
    // Color
    //
    $("form input.color").change(function(e)
    {
        var val  = $(this).val();
        var name = $(this).prop("name").split("_")[0];
        
        console.log(name + " -> " + val);
        
        $.ajax("/trackers/colour", {
            type: "POST",
            data: {
                "id":  name,
                "colour": val
            }
        });
    });
});
