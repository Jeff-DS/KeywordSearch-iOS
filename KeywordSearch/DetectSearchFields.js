
function findSearchFields() {

    // Get an array of the search fields

    // Just for testing: get the 'foreign' class things
    var searchFields = document.getElementsByClassName('foreign');

    try {
        webkit.messageHandlers.SearchField.postMessage("Hi from the JavaScript file");
    } catch(error) {
        console.log("Had an error");
        webkit.messageHandlers.SearchField.postMessage("Hi from the error block");

    }
}

findSearchFields();

