$(function()
{
    $("form select").change(function(e)
    {
        var val  = $(this).val();
        var name = $(this).prop("name");
        
        console.log(name + " -> " + val);
        
        $.ajax("/trackers", {
            type: "POST",
            data: {
                "id":  name,
                "pin": val
            }
        });
        
    });
});
