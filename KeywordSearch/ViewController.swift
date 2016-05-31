//
//  ViewController.swift
//  KeywordSearch
//
//  Created by Jeff Spingeld on 5/5/16.
//  Copyright © 2016 Jeff Spingeld. All rights reserved.
//

import UIKit
import WebKit
import SafariServices

/*
 What this app is
 
 Keyword search: app to do Chrome’s keyword search.
 - You’d have a big text field and below it a grid of squares representing websites (looking like a home screen full of apps).
 - You type your search term, tap to select a search (your most frequent is selected by default), and hit go/enter.
 - To add a search type, you go to the “Add search” section of the app, which is a browser. Go to the website, and tap on the right search bar. The app will automatically add this to the search list. Under the hood, it does this by entering a random search term and clicking Enter (or letting you click if Enter doesn’t work), then using the resulting page’s URL to figure out the frame URL and where to put the search term in.
  - IMPLEMENTATION:
    - See the part at this page on putting .js scripts in an app and accessing them by replacing init() on a view controller for a web view... http://www.appcoda.com/webkit-framework-tutorial/
    - In the HTML, find the text input boxes by looking for <input type="text" ...> tags. I want to animate text boxes to blink in colors so they're noticeable; see bottom of this page for an example script.
    - Then use something like this (http://stackoverflow.com/questions/5700471/set-value-of-input-using-javascript-function or http://stackoverflow.com/questions/7609130/set-the-value-of-a-input-field-with-javascript) to automatically set what the text is. JavaScript? jQuery? Some helpful stuff here: http://www.w3schools.com/jquery/jquery_examples.asp
    - Then click/tap.
 
 FEATURES TO DO
 - FIX THE SPACE THING: see http://www.w3schools.com/tags/ref_urlencode.asp (right now, app crashes if search term contains space.)
 - Like Chrome, show a URL on the clipboard, if any
 - Could add option to get results from an API rather than web search?
 - Also, include Google, so this app could be someone’s default web browser.
 - Also, are there any sites where the search term is NOT included as a query in the URL? In that case, have to have the app actually type it into the search field and hit enter.
 - Also account for things like searching Google for search term + "site:reddit.com". And doing this with multiple sites (e.g., "site:reddit.com OR site:quora.com")

 webkit tutorial: http://www.appcoda.com/webkit-framework-intro/
 
*/

class ViewController: UIViewController, SFSafariViewControllerDelegate {
    
    // MARK: Properties
    @IBOutlet weak var addSearchButton: UIButton!
    @IBOutlet weak var searchField: UITextField!
    
    var firstAppearanceOfView: Bool = true
    
    // Populate the following two properties from Core Data or something
    var searchTypesArray: [SearchType] = []
    // A dictionary linking each button to the search it represents
    var buttonDictionary: [UIButton: SearchType] = [:]
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
        // If not the first time view appears, don't set up buttons (otherwise you get duplicates)
        if !firstAppearanceOfView {
            return
        }
        
        // TESTING STUFF-------------------------------
        // (1) Testing sample search
        // Google search: just for testing. Delete this once the above is working.
        //        let googleButton = UIButton()
        //        view.addSubview(googleButton)
        //        googleButton.addTarget(self, action: #selector(ViewController.googleButtonTapped), forControlEvents: .TouchUpInside)
        //
        //        googleButton.setTitle("Google", forState: .Normal)
        //        googleButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
        //        googleButton.translatesAutoresizingMaskIntoConstraints = false
        //        googleButton.heightAnchor.constraintEqualToConstant(30).active = true
        //        googleButton.widthAnchor.constraintEqualToConstant(200).active = true
        //        googleButton.topAnchor.constraintEqualToAnchor(searchField.bottomAnchor, constant: 20).active = true
        //        googleButton.leftAnchor.constraintEqualToAnchor(view.leftAnchor, constant: 30).active = true
        
        // (2) Testing that the program populates the buttons from the array
        let dictionary = SearchType(name: "Dictionary.com", URLPartOne: "http://www.dictionary.com/browse/", URLPartTwo: "?s=ts")
        let etymonline = SearchType(name: "Etymonline", URLPartOne: "http://www.etymonline.com/index.php?allowed_in_frame=0&search=", URLPartTwo: "&searchmode=none")
        let amazon = SearchType(name: "Amazon", URLPartOne: "http://smile.amazon.com/s/ref=smi_www_rcol_go_smi?ie=UTF8&field-keywords=", URLPartTwo: "&url=search-alias%3Daps&x=0&y=0")
        searchTypesArray += [dictionary, etymonline, amazon]

        
        // -------------------------------
        
        // Under the search bar, add a button for each search type.
        // (Later, will replace these with a pretty grid (stackview) of icons)
        for type in searchTypesArray {
            addButtonForSearchType(type)
        }
        
        view.layoutIfNeeded()
        
        
        firstAppearanceOfView = false
        
    }
    
    // Make a button that searches for the current search term in the right search engine.
    func addButtonForSearchType(type: SearchType) {
        
        let button = UIButton()
        view.addSubview(button)
        button.addTarget(self, action: #selector(performSearch), forControlEvents: .TouchUpInside)
        
        button.setTitle(type.name, forState: .Normal)
        button.setTitleColor(UIColor.blueColor(), forState: .Normal)
        button.heightAnchor.constraintEqualToConstant(30).active = true
        button.widthAnchor.constraintEqualToConstant(200).active = true
        button.leftAnchor.constraintEqualToAnchor(view.leftAnchor, constant: 30).active = true
        
        // Each button's top must be constrained to the bottom of the previous button, unless it's the first one, in which case it's constrained to the search field.
        let heightOfEachButton = 30
        let spaceBetweenButtons = 20
        let topAnchorConstant = CGFloat(spaceBetweenButtons) + ((CGFloat(heightOfEachButton) + CGFloat(spaceBetweenButtons)) * CGFloat(searchTypesArray.indexOf(type)!))
        button.topAnchor.constraintEqualToAnchor(searchField.bottomAnchor, constant: topAnchorConstant).active = true
        
        button.translatesAutoresizingMaskIntoConstraints = false
        view.layoutIfNeeded()
        
        // Add button to the button:searchType dictionary
        buttonDictionary[button] = type
        
    }
    
    // Search for the search term with the relevant search engine
    func performSearch(sender: UIButton) {
     
        let searchType = buttonDictionary[sender]
        let searchTerm = searchField.text
        let finalURL = searchType!.URLPartOne + searchTerm! + searchType!.URLPartTwo
        openWebPage(finalURL)
        
    }
    
    // This is just an example; delete it once the general function is working
    func googleButtonTapped() {
        
        print("Google button tapped")
        
        // Create the right URL
        let bareURL = "https://www.google.com/?gws_rd=ssl#safe=off&q="
        let searchTerm = searchField.text
        let finalURL = bareURL + searchTerm!
        
        // Open a web view with this URL
        openWebPage(finalURL)
        
    }
    
    // MARK: Actions
    @IBAction func addSearchButtonTapped(sender: UIButton) {
        
        // Open Google in a webview
        
//        openWebPage("https://www.google.com/")
        
        // Create a view controller
        let webVC: WebVC = WebVC()
        webVC.URLString = "http://www.etymonline.com/index.php?allowed_in_frame=0&search=gold&searchmode=none"  //"https://www.google.com/"
        // Present it
        presentViewController(webVC, animated: true, completion: nil)
    
    }

    func openWebPage(URLString: String) {
        
        let thing = NSURL(string: URLString)
        let safariVC = SFSafariViewController(URL: thing!)
        safariVC.delegate = self
        presentViewController(safariVC, animated: true, completion: nil)
        
        
    }
}