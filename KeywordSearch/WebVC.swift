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
        
        // Add user script (to detect search fields, find favicons, send data to app, etc.)
        self.webView.configuration.userContentController.addUserScript(UserScript(named: "DetectSearchFields"))
        
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
        
        // Turn the incoming JSON to into a Dictionary [String:Any].
        let messageDict = dictionaryFrom(JSONObject: message.body)
        guard let messageType = messageDict["messageType"] as? String
            else { print("messageType not a string"); return }
        
        if messageType == "new search" {
            
            // Here, download all the pictures and use the biggest one. Or maybe do it as a dictionary and if there's an iPhone one available, use that one.
            
            //TODO: download the favicon from the URL and do appropriate stuff with it
            
            let alertController = newSearchAlertController(for: messageDict)
            DispatchQueue.main.async {
                alertController.view.layoutIfNeeded() // otherwise this happens: http://stackoverflow.com/questions/30685379/swift-getting-snapshotting-a-view-that-has-not-been-rendered-error-when-try/33943731
                self.present(alertController, animated: true, completion: nil)
            }
            
        }
        
    }
    
    // Create a UIAlert for a new search type that lets the user either cancel or name and add the new search type, and then either close the WebVC to return to the home screen, or stay in the WebVC to continue adding searches.
    func newSearchAlertController(for message: [String:Any]) -> UIAlertController {
        
        /* TODO:
         One weird thing: currently getting the page title through the self.webView property. If I could do that, then I could get the URL (and maybe even the HTML to find the favicons?) through that property too, and wouldn't have to pass stuff back by posting a message. If I can't/shouldn't be doing that, then I should have the user script pass back the page title too. Do so after removing the dummy string: one, because then only the JS (not the app) needs to know about the dummy string at all. Two, because it's probably easier to remove a substring in JS than Swift.
        */
        
        // URL stuff
        guard let urlString = message["URL"] as? String
            else {print("Error: the URL is not a string"); return UIAlertController() }
        let urlParts = urlString.components(separatedBy: "ads8923jadsnj7y82bhjsdfnjky78")
        
        // Favicons stuff
        
        guard let faviconsArray = message["favicons"] as? [String] //TODO: make sure this works; might have to convert through NSArray first
            else { print("Favicons couldn't be converted to array"); return UIAlertController() }

        // Create a new searchType (initialize it with a placeholder name for now)
        let newSearch = SearchType(name: "",
                                   URLPartOne: urlParts[0],
                                   URLPartTwo: urlParts[1],
                                   faviconUrlList: faviconsArray)
        
        
        // Create the alert
        let alert = UIAlertController(title: "Add new search",
                                      message: "Give your new search a name, and then return to the home screen or continue adding searches.",
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        // Create textfield for the name of the search type
        alert.addTextField(configurationHandler: { (nameField: UITextField) in
            // Use page title, minus dummy string, as default
            if var title = self.webView.title {
                title = self.remove(substring: "ads8923jadsnj7y82bhjsdfnjky78", from: title)
                nameField.text = title
            }
            
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
        
        let failDict = ["fail": "fail"]
        
        guard let nsDict = JSONObject as? NSDictionary
            else { print("Error: cast to NSDictionary failed"); return failDict}
        guard let dict = nsDict as? [String:AnyObject]
            else { print("Error: cast to [String:Any] (Dictionary) failed"); return failDict}
        
        return dict
    }
    
    func remove(substring: String, from string: String) -> String {
        var newString = string
        if let range = string.range(of: substring) {
            newString.removeSubrange(range)
            return newString
        }
        return string
    }
    
}
