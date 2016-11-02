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

        // Create WKWebView the size of the main view
        webView = WKWebView(frame: view.frame)
        
        // Set self to receive messages
        self.webView.configuration.userContentController.add(self, name: "WebVCMessageHandler")
        
        // Add the user scripts that detect search fields and find a page's favicon
        self.webView.configuration.userContentController.addUserScript(UserScript(named: "DetectSearchFields"))
        self.webView.configuration.userContentController.addUserScript(UserScript(named: "Favicon"))
        
        // Add web view as a subview
        view.addSubview(webView)
        
        // Enable swipe to navigate
        webView.allowsBackForwardNavigationGestures = true
        
        // Load page
        let URL: Foundation.URL = Foundation.URL(string: "\(URLString)")!
        let request = URLRequest(url: URL)
        webView.load(request)
        
        }
    
    // Handle messages received from JavaScript.
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        //TODO: delete after testing
        print("JavaScript sends a message.\nMessage name: \(message.name) \nMessage body: \(message.body)\n\n")
        
        // Cast the incoming JSON to NSDictionary and thence to Dictionary. 
        guard let bodyNSDict = message.body as? NSDictionary
            else { print("Error: message body could not be converted to NSDictionary"); return }
        guard let body = bodyNSDict as? [String:AnyObject]
            else { print("Error: the NSDictionary could not be converted to Dictionary"); return }
        guard let messageType = body["messageType"] as? String
            else { print("messageType not a string"); return }
        
        switch messageType {
        case "favicon":
            //TODO: download the favicon from the URL and do appropriate stuff with it
            print("hi")
            
        case "new search":
            let alertController = newSearchAlertController(for: body["message"])
            DispatchQueue.main.async {
                alertController.view.layoutIfNeeded() // otherwise this happens: http://stackoverflow.com/questions/30685379/swift-getting-snapshotting-a-view-that-has-not-been-rendered-error-when-try/33943731
                self.present(alertController, animated: true, completion: nil)
            }
            
        default:
            print("hi")
            //TODO: default?
        }
        
    }
    
    // Create a UIAlert for a new search type that lets the user either cancel or name and add the new search type, and then either close the WebVC to return to the home screen, or stay in the WebVC to continue adding searches.
    func newSearchAlertController(for message: Any) -> UIAlertController {
        
        guard let messageString = message as? String
            else {print("message isn't string"); return UIAlertController() }
        
        print("GOT THE URL BACK: \(messageString)")
        
        if messageString.range(of: "ads8923jadsnj7y82bhjsdfnjky78") == nil {
            print("The search term is not in the URL. Cannot create a search type.")
            return UIAlertController()
        }
        
        // Create a new searchType (initialize it with a placeholder name for now)
        let urlParts = messageString.components(separatedBy: "ads8923jadsnj7y82bhjsdfnjky78")
        let newSearch = SearchType(name: "", URLPartOne: urlParts[0], URLPartTwo: urlParts[1])
        
        // Create the alert
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
        
        return alert
        
    }

    // Helper method to make a WKUserScript
    func UserScript(named scriptName: String) -> WKUserScript {
        
        let mainBundle = Bundle.main
        let file:String? = mainBundle.path(forResource: scriptName, ofType: "js")
        var scriptText:String = ""
        
        do {
            scriptText = try String(contentsOfFile: file!)
        } catch {
            print("Error converting script '\(scriptName)' to string.")
        }
        let script = WKUserScript(source: scriptText,
                                  injectionTime: WKUserScriptInjectionTime.atDocumentEnd,
                                  forMainFrameOnly: true)
        
        return script
        
    }
    
    // Turn a JSON object into a Dictionary
    func dictionaryFrom(JSONObject: Any) -> [String: Any] {
        //TODO: implement
        return ["fake": "fake"]
    }
    
}
