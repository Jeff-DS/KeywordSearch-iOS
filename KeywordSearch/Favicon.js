// Adapted from: https://github.com/mozilla-mobile/firefox-ios/blob/master/Client/Assets/Favicons.js

/*
 This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */


if (!window.__firefox__) {
    window.__firefox__ = {};
}

// sets favicons property of whatever as this function. will have to change this
window.__firefox__.favicons = function() {
    // These integers should be kept in sync with the IconType raw-values
    var ICON = 0;
    var APPLE = 1;
    var APPLE_PRECOMPOSED = 2;
    var GUESS = 3;
    
    // Dictionary of strings to integers??
    var selectors = { "link[rel~='icon']": ICON,
        "link[rel='apple-touch-icon']": APPLE,
        "link[rel='apple-touch-icon-precomposed']": APPLE_PRECOMPOSED
    };
    
    // Function that outputs a dictionary of
    function getAll() {
        
        // create empty dictionary
        var favicons = {};
        
        // for item in dict of strings to integers
        for (var selector in selectors) {
            // get all the elements matching the string
            var icons = document.head.querySelectorAll(selector);
            // for each of them, create an entry in favicons dictionary of its URL:number
            for (var i = 0; i < icons.length; i++) {
                var href = icons[i].href;
                favicons[href] = selectors[selector];
            }
        }
        
        // If we didn't find anything in the page, look to see if a favicon.ico file exists for the domain
        if (Object.keys(favicons).length === 0) {
            var href = document.location.origin + "/favicon.ico";
            favicons[href] = GUESS;
        }
        
        // return the favicons dictionary
        return favicons;
    }
    
    // send favicons dictionary back to the app
    function getFavicons() {
        var favicons = getAll();
        webkit.messageHandlers.faviconsMessageHandler.postMessage(favicons);
    }
    
    // why the colon?
    return {
        getFavicons : getFavicons
    };
    
}();
