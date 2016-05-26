//
//  WebVC.swift
//  KeywordSearch
//
//  Created by Jeff Spingeld on 5/6/16.
//  Copyright © 2016 Jeff Spingeld. All rights reserved.
//

import UIKit
import WebKit

class WebVC: UIViewController, WKScriptMessageHandler {
    
    var URLString = ""
    var webView = WKWebView()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        /*
         Summary of how to run a JavaScript script on a web page
         Create each of these:
         1. A WKUserScript, which contains the JavaScript code.
         2. A userContentController. (Add the user script to this)
         3. A WKWebViewConfiguration. (The contentController is a property of this.)
         4. A WKWebView. (One of the arguments in its initializer is the configuration.)
         */

        
        // Get the JavaScript script out of the resources bundle
        let mainBundle = NSBundle.mainBundle()
        let script:String? = mainBundle.pathForResource("DetectSearchFields", ofType: "js")
        
        // ISSUE ///////
        // The script variable is a string containing the PATH of the .js file, not the JS code itself.
        // The "source:" parameter of the WKUserScript method takes a string containing JS code.
        //////////
        // Let's try getting the actual string of the text:
        var scriptText:String = ""
        do {
            scriptText = try String(contentsOfFile: script!)
        } catch {
            print("error caught or something")
        }
        // Create a userScript and add it to the content controller
        let userScript = WKUserScript(
            source: scriptText, //script!,
            injectionTime: WKUserScriptInjectionTime.AtDocumentEnd,
            forMainFrameOnly: true
        )

        // Create a content controller, and add the userScript to it
        let contentController = WKUserContentController()
        contentController.addUserScript(userScript)
        contentController.addScriptMessageHandler(self, name: "SearchField")
        // Create a configuration and set its contentController property to the one we just created
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        // Initialize the WKWebView with this configuration
        let newSearchView: WKWebView = WKWebView(frame: CGRect(), configuration: config)
        webView = newSearchView
        // Add it as a subview
        view.addSubview(newSearchView)
        
        // Constrain the web view to its superview
        newSearchView.heightAnchor.constraintEqualToAnchor(view.heightAnchor).active = true
        newSearchView.widthAnchor.constraintEqualToAnchor(view.widthAnchor).active = true
        newSearchView.topAnchor.constraintEqualToAnchor(view.topAnchor)
        newSearchView.leftAnchor.constraintEqualToAnchor(view.leftAnchor)
        newSearchView.translatesAutoresizingMaskIntoConstraints = false
        
        // Load page
        let URL: NSURL = NSURL(string: "\(URLString)")!
        let request = NSURLRequest(URL: URL)
        newSearchView.loadRequest(request)
        
        // Do the JavaScript thing
//        webView.evaluateJavaScript("document.getElementsByClassName('foreign')") { (result, error) in
        webView.evaluateJavaScript("webkit.messageHandlers.SearchField.postMessage({body: 'Yo babe'});") { (result, error) in
            print("\nThe error is: \n\(error)")
            print("\nThe result is: \n\(result)")
        }
        
        // Try evaluating the script as JavaScript....
        
        // This is returning nil and not posting a handler message. I think the problem may be that the page hasn't loaded yet. Looking up how to make this run only after the page has loaded. Some horrible KVO stuff. or navigation delegate?? which is better?
        
        // Either FIGURE THIS OUT FROM THE SOURCES or MAKE A STACK OVERFLOW POST
        
        /*
         Option 1: KVO (key-value observing).
         - Add the VC as an observer of the estimatedProgress keypath on the webView.
         - Implement observeValueForKeyPath() method. Presumably it would detect when the progress == 1, and then call the method that runs the JavaScript.
         
         Option 2: ?
         - I have injectionTime as 'at document end', which means it should run "when the body of the HTML page has been loaded" (kinderas.com), so why isn't that sufficient?
        
        
        */
            webView.evaluateJavaScript(scriptText) { (result, error) in
                print("\n\nSCRIPT THING\n")
                print("\nThe error is: \n\(error)")
                print("\nThe result is: \n\(result)")

        }
        
    }
    
    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {

//        if (message.name == "searchField") {
        
            print("JavaScript sends the following message: \(message.body)")
        
//        }
        
    }
    
}
