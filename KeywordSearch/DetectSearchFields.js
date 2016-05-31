
function findSearchFields() {

    // Get an array of all the search boxes on the page
    var inputs = document.getElementsByTagName('input');
    var searchFields = [];
    for (var i = 0; i < inputs.length; i++) {
        var inputType = inputs[i].type.toLowerCase();
        if (inputType == 'text' || inputType == 'search') {
            searchFields.push(inputs[i]);
        }
    }
    
    // Let the app know how many we found
    webkit.messageHandlers.SearchField.postMessage("There is/are " + searchFields.length + " search field(s) on this page");

    for (var i = 0; i < searchFields.length; i++) {
        
        var field = searchFields[i];
    
        // TODO: Make the search fields pulsate
        // For now, just make it blue so we know this is working.
        field.style.backgroundColor = "blue";

        // When the search field is selected, send the destination URL back to Swift to be handled
        
        // Detect when field is selected
        field.onclick = function() {
            
            field.style.backgroundColor = "yellow";
            webkit.messageHandlers.SearchField.postMessage("You clicked on a search field");
        
        }

    }
    
}

findSearchFields();

/*
 Example for JavaScript animation, I modified it from here: http://www.w3schools.com/jquery/tryit.asp?filename=tryjquery_animation1_multicss
 Note: to get CONTINUOUS ANIMATION, you don't use "while (true)" (never do that), but rather recursion. Google 'javascript continuous animation' for examples.
 NOTE: This is Jquery. Not sure if you can just use it, or if I have to import it, or if the webpage has to have it already...for now, just go with plain JavaScript.
 
 <!DOCTYPE html>
 <html>
 <head>
 <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.12.2/jquery.min.js"></script>
 <script>
 $(document).ready(function(){
    $("button").click(function(){
    var i = 0
    while (i < 10) {
        $("div").animate({
            opacity: '0.5',
            });
        $("div").animate({
            opacity: '1',
            });
        i++;
        }
    });
 });
 </script>
 </head>
 <body>
 
 <button>Start Animation</button>
 
 <p>By default, all HTML elements have a static position, and cannot be moved. To manipulate the position, remember to first set the CSS position property of the element to relative, fixed, or absolute!</p>
 
 <div style="background:#98bf21;height:100px;width:100px;position:absolute;"></div>
 
 </body>
 </html>
 


*/