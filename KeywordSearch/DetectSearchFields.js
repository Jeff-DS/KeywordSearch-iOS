var dummySearch = "ads8923jadsnj7y82bhjsdfnjky78"

// If the current page has the dummy search term in it, tell the app to add a new search type
if (document.URL.includes(dummySearch)) {
    
    var dict = {
        "messageType": "new search",
        "message": document.URL
    }
    
    sendMessage(dict)
    
}

// Find all search fields on the page, and if user clicks on one, tell the app the destination URL
findSearchFields();

// --------- Function definitions ---------

// Post a message back to the app
function sendMessage(message) {
    webkit.messageHandlers.WebVCMessageHandler.postMessage(message);
}

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

    // Turn them blue to bring them to the user's attention. And set up the onclick function.
    for (var i = 0; i < searchFields.length; i++) {
        
        var field = searchFields[i];
    
        // TODO: Make the search fields pulsate. Test if Jquery works; if not, do it w/regular JS.
        // For now, just make it blue so we know this is working.
        field.style.backgroundColor = "blue";

        // When the search field is selected, send the destination URL back to Swift to be handled
        
        // Detect when field is clicked.
        field.onclick = function() {
            
            field.style.backgroundColor = "yellow"; //TODO: this only sometimes works (fails on Merriam-Webster. Why does making it blue work, but making it yellow not work? I think the 'you clicked' message still shows up, so onclick is working.)
            //sendMessage("You clicked on a search field");
            
            // Put in some random text as the query string
            field.value = dummySearch;
            
            // Submit form
            field.parentNode.parentNode.submit();
            // QUESTION: will the <form> always be the grandparent node of the search box? If not, how to reliably submit the form?
            //TODO: this only sometimes works. Working examples: Bing, DuckDuckGo. Doesn't work: Stack Overflow, Wikipedia, Twitter. Check the source on those sites and see what's up.
        
        }

    }
    
}


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
