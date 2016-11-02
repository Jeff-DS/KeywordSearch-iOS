// Adapted from: https://github.com/mozilla-mobile/firefox-ios/blob/master/Client/Assets/Favicons.js

/*
 This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */


/*
 Notes to self since I don't know JavaScript/CSS/web dev:
 
 This...        document.head.querySelectorAll("link[rel~='icon']")         ...means:
 
 'in the webpage source (HTML? CSS?), find all the "link" tags where the value of the "rel" attribute contains the word "icon" (i.e., the entire word either alone or separated from other words by spaces--does NOT just check if the string contains "icon" at some point).
 
 E.g., it would find this:          <link rel="this says icon somewhere lol">
 
 */

// Create an array of favicon URLs and send it back to the app

// Create empty array for the URLs
var favicons = []

// CSS attribute selectors that might find the favicon (https://css-tricks.com/attribute-selectors/)
var possibleSelectors = ["link[rel~='icon']", // matches "icon" or "shortcut icon"
                         "link[rel~='apple-touch-icon']", // e.g., SO has "apple-touch-icon image_src"
                         "link[rel='apple-touch-icon-precomposed']"]

// For each selector, search for it, get its href value (the URL), and add that to the favicons array
for (var selector in possibleSelectors) {
    var string = possibleSelectors[selector]
    var elements = document.head.querySelectorAll(string)
    for (var element in elements) {
        var url = elements[element].href
        if (url) {
            favicons.push(url)
        }
    }
}

// If page doesn't have favicon, look to see if a favicon.ico file exists for the domain
if (favicons.length === 0) {
    var lastHope = document.location.origin + "/favicon.ico";
    favicons.push(lastHope)
}

var dict = {
    "messageType": "favicon",
    "message": favicons
}

// Send the favicons URLs back to the app
webkit.messageHandlers.WebVCMessageHandler.postMessage(dict);

//TODO: copy the other message handler, make the relevant changes, and have it print the message so we can see what's actually in the array. Or try it in Chrome console.
