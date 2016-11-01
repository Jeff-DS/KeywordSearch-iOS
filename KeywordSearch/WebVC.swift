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
    func addNewSearchType(_ searchType: SearchType)
}

class WebVC: UIViewController, WKScriptMessageHandler {
    
    var URLString = ""
    var webView = WKWebView()
    weak var delegate: WebVCDelegate?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Get the JavaScript script out of the resources bundle
        let mainBundle = Bundle.main
        let script:String? = mainBundle.path(forResource: "DetectSearchFields", ofType: "js")
        
        var scriptText:String = ""
        do {
            scriptText = try String(contentsOfFile: script!)
        } catch {
            print("error caught or something")
        }
        // Create a userScript
        let userScript = WKUserScript(source: scriptText,
                                      injectionTime: WKUserScriptInjectionTime.atDocumentEnd,
                                      forMainFrameOnly: true)

        // Create a content controller, and add the userScript to it
        let contentController = WKUserContentController()
        contentController.addUserScript(userScript)
        contentController.add(self, name: "SearchField")
        
        // Create a configuration and set its contentController property to the one we just created
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        // Initialize the WKWebView with this configuration
        let newSearchView: WKWebView = WKWebView(frame: CGRect(),
                                                 configuration: config)
        webView = newSearchView
        // Add it as a subview
        view.addSubview(newSearchView)
        
        // Constrain the web view to its superview
        newSearchView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        newSearchView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        newSearchView.topAnchor.constraint(equalTo: view.topAnchor)
        newSearchView.leftAnchor.constraint(equalTo: view.leftAnchor)
        newSearchView.translatesAutoresizingMaskIntoConstraints = false
        
        // Enable swipe to navigate
        webView.allowsBackForwardNavigationGestures = true
        
        // Load page
        let URL: Foundation.URL = Foundation.URL(string: "\(URLString)")!
        let request = URLRequest(url: URL)
        newSearchView.load(request)
        
        }
    
    // Respond to messages received from JavaScript.
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        // If the message contains our dummy string, then add a new search to the list.
        if message.body is String {
            let body = message.body as! String

            if body.range(of: "ads8923jadsnj7y82bhjsdfnjky78") != nil {
                // Add a search--need to send this over to ViewController.
                
                // TODO: delete this print statement when no longer needed--just a test
                print("GOT THE URL BACK: \(body)")
                
                // Create a new searchType (initialize it with a placeholder name for now)
                let urlParts = body.components(separatedBy: "ads8923jadsnj7y82bhjsdfnjky78")
                let newSearch = SearchType(name: "", URLPartOne: urlParts[0], URLPartTwo: urlParts[1])
                
                // Present a UIAlert that lets the user name the new search type and then either close the WebVC to return to the home screen, or stay in the WebVC to continue adding searches.
                let alert = UIAlertController(title: "Add new search",
                                              message: "Give your new search a name, and then return to the home screen or continue adding searches.",
                                              preferredStyle: UIAlertControllerStyle.alert)
                
                // Create textfield for the name of the search type
                alert.addTextField(configurationHandler: { (nameField: UITextField) in
                    // Use page title as default
                    nameField.text = self.webView.title
                    nameField.clearButtonMode = .always
                })
                
                // Action for dismissing the webview
                let goHomeAction = UIAlertAction(title: "Home",
                                                 style: .default,
                                                 handler: {(action: UIAlertAction!) in
                                                    // Set search's name to the textfield value
                                                    newSearch.name = (alert.textFields![0] as UITextField!).text!
                                                    // Send this search type over to the home View Controller
                                                    self.delegate?.addNewSearchType(newSearch)
                                                    // Close the WebVC
                                                    self.dismiss(animated: true, completion: nil)
                })
                alert.addAction(goHomeAction)
                
                // Action for staying in the webview
                let keepAddingAction = UIAlertAction(title: "Add more",
                                                     style: .default,
                                                     handler: {(action: UIAlertAction!) in
                                                        // Set name
                                                        newSearch.name = (alert.textFields![0] as UITextField!).text!
                                                        // Send search type to home VC
                                                        self.delegate?.addNewSearchType(newSearch)
                    })
                alert.addAction(keepAddingAction)
                
                //Action for cancelling
                let cancelAction = UIAlertAction(title: "Cancel",
                                                 style: .cancel,
                                                 handler: nil)
                alert.addAction(cancelAction)
                
                // Present alert
                present(alert, animated: true, completion: nil)

                

                
            }

            print("JavaScript sends a message.\nMessage name: \(message.name) \nMessage body: \(message.body)\n\n")
            
        }
        
        
    }
    
}
