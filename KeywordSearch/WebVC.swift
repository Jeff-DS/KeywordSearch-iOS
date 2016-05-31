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
        
        }
    
    // Print any messages received from JavaScript
    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        
        print("JavaScript sends a message.\nMessage name: \(message.name) \nMessage body: \(message.body)\n\n")
        
    }
    
}
