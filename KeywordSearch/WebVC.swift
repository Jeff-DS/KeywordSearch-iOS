//
//  WebVC.swift
//  KeywordSearch
//
//  Created by Jeff Spingeld on 5/6/16.
//  Copyright © 2016 Jeff Spingeld. All rights reserved.
//

import UIKit
import WebKit

protocol WebVCDelegate: class {
    func addNewSearchType(searchType: SearchType)
}

class WebVC: UIViewController, WKScriptMessageHandler {
    
    var URLString = ""
    var webView = WKWebView()
    weak var delegate: WebVCDelegate?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
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
    
    // Respond to messages received from JavaScript.
    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        
        // If the message contains our dummy string, then add a new search to the list.
        if message.body is String {
            let body = message.body as! String

            if body.rangeOfString("ads8923jadsnj7y82bhjsdfnjky78") != nil {
                // Add a search--need to send this over to ViewController.
                
                // TODO: delete this print statement when no longer needed--just a test
                print("GOT THE URL BACK: \(body)")
                
                // create a searchType:
                // - using dummy title for now
                // - get a message back with the page title and use that
                // - final stage: page title suggested as default; user can modify/replace if they wish
                let urlParts = body.componentsSeparatedByString("ads8923jadsnj7y82bhjsdfnjky78")
                let newSearch = SearchType(name: "REPLACE-THIS", URLPartOne: urlParts[0], URLPartTwo: urlParts[1])
                // Send this search type over to the View Controller
                delegate?.addNewSearchType(newSearch)
                
            }

            print("JavaScript sends a message.\nMessage name: \(message.name) \nMessage body: \(message.body)\n\n")
            
        }
        
    }
    
}
