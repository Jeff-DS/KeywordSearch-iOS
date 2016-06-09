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


class ViewController: UIViewController, SFSafariViewControllerDelegate, WebVCDelegate {
    
    // MARK: Properties
    @IBOutlet weak var addSearchButton: UIButton!
    @IBOutlet weak var searchField: UITextField!
    
    var defaults: NSUserDefaults?
    
    // The following two properties will be populated from NSUserDefaults in viewDidAppear
    // Array of search types
    var searchTypesArray: [SearchType] = []
    // A dictionary linking each button to the search it represents
    var buttonDictionary: [UIButton: SearchType] = [:]

    var firstAppearanceOfView: Bool = true
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewDidAppear(animated)

        // If not the first time view appears, don't set up buttons (otherwise you get duplicates)
        // TODO: but what if you need to add new buttons? When you come back from adding a button, the view is appearing again, and it does need to update. (Could have it get rid of all the buttons and add them from scratch every time the view appears.)
        if !firstAppearanceOfView {
            return
        }
        
        // Get the search types array from NSUserDefaults and unarchive it
        defaults = NSUserDefaults.standardUserDefaults()
        if let searchTypesArrayObject = defaults?.objectForKey("searchTypesArray") as? NSData {
          
            searchTypesArray = NSKeyedUnarchiver.unarchiveObjectWithData(searchTypesArrayObject) as! [SearchType]
            
        }
        
        // Under the search bar, add a button for each search type.
        // (Later, will replace these with a pretty grid (stackview) of icons)
        // TODO: a better interim solution is a tableview. See the tutorial Jim sent? https://realm.io/news/tryswift-chris-eidhof-table-view-controllers-swift/
        for type in searchTypesArray {
            addButtonForSearchType(type)
        }
        
        firstAppearanceOfView = false
        
        // ----------------------------------           (TESTING)
        // Some test searches that the program populates the buttons from the array
        
        // Create a few sample search types
        let dictionary = SearchType(name: "Dictionary.com", URLPartOne: "http://www.dictionary.com/browse/", URLPartTwo: "?s=ts")
        let etymonline = SearchType(name: "Etymonline", URLPartOne: "http://www.etymonline.com/index.php?allowed_in_frame=0&search=", URLPartTwo: "&searchmode=none")
        let amazon = SearchType(name: "Amazon", URLPartOne: "http://smile.amazon.com/s/ref=smi_www_rcol_go_smi?ie=UTF8&field-keywords=", URLPartTwo: "&url=search-alias%3Daps&x=0&y=0")
      
        // Add them to an array
        let searchTypesArrayTest = [dictionary, etymonline, amazon]
        
        // Create buttons for them
        for type in searchTypesArrayTest {
            addButtonForSearchType(type)
        }
        view.layoutIfNeeded()
        
        // -------------------------------
        
    }
    
    // For a given search type: create a button, put it in the right place, and add it to the button:searchType dictionary
    func addButtonForSearchType(type: SearchType) {
        
        // Create button and connect it to the right search
        let button = UIButton()
        view.addSubview(button)
        button.addTarget(self, action: #selector(performSearch), forControlEvents: .TouchUpInside)
        button.setTitle(type.name, forState: .Normal)
        button.setTitleColor(UIColor.blueColor(), forState: .Normal)
        
        // Height, width, left anchor
        button.heightAnchor.constraintEqualToConstant(30).active = true
        button.widthAnchor.constraintEqualToConstant(200).active = true
        button.leftAnchor.constraintEqualToAnchor(view.leftAnchor, constant: 30).active = true
        
        // Top anchor: the first button must be constrained to the bottom of the search field. Each subsequent button is constrained to the bottom of the button immediately preceding it.
        let heightOfEachButton = 30
        let spaceBetweenButtons = 20
        let topAnchorConstant = CGFloat(spaceBetweenButtons) + ((CGFloat(heightOfEachButton) + CGFloat(spaceBetweenButtons)) * CGFloat(searchTypesArray.indexOf(type)!)) // error here because the test data aren't in searchTypesArray, but searchTypesTest array.
        button.topAnchor.constraintEqualToAnchor(searchField.bottomAnchor, constant: topAnchorConstant).active = true
        
        button.translatesAutoresizingMaskIntoConstraints = false
        view.layoutIfNeeded()
        
        // Add button to the button:searchType dictionary.
        buttonDictionary[button] = type
        
    }
    
    // Search for the search term using the relevant search engine
    func performSearch(sender: UIButton) {
     
        let searchType = buttonDictionary[sender]
        let searchTerm = searchField.text?.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())
        let finalURL = searchType!.URLPartOne + searchTerm! + searchType!.URLPartTwo
        openWebPage(finalURL)
        
    }
    
    // Function to open a web page in a Safari view controller
    func openWebPage(URLString: String) {
        
        let thing = NSURL(string: URLString)
        let safariVC = SFSafariViewController(URL: thing!)
        safariVC.delegate = self
        presentViewController(safariVC, animated: true, completion: nil)
        
    }
    
    // Implementation of delegate method. When WebVC sends over a new search type, add it.
    func addNewSearchType(searchType: SearchType) {
        
        // Add the new search type to the array
        searchTypesArray.append(searchType)
        
        // Update NSUserDefaults: archive updated searchTypesArray to an NSData object and save
        let savedArray = NSKeyedArchiver.archivedDataWithRootObject(searchTypesArray)
        defaults!.setObject(savedArray, forKey: "searchTypesArray")

        // Call addButtonForSearchType on it so a button appears
        addButtonForSearchType(searchType)
        
    }
    
    // MARK: Actions
    @IBAction func addSearchButtonTapped(sender: UIButton) {
        
        // Open Google in a webview
        
//        openWebPage("https://www.google.com/")
        
        // Create a view controller
        let webVC: WebVC = WebVC()
        webVC.URLString = "http://www.etymonline.com/index.php?allowed_in_frame=0&search=gold&searchmode=none"  //"https://www.google.com/"
        // Set ourself as the WebVC's delegate
        webVC.delegate = self
        // Present it
        presentViewController(webVC, animated: true, completion: nil)
    
    }
    
}

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
 - Like Chrome, show a URL on the clipboard, if any
 - Allow searching multiple sites at once in tabs. E.g., search a bunch of dictionaries for the same word, or a bunch of e-commerce sites for the same product.
 - Could add option to get results from an API rather than web search?
 - Include Google, so this app could be someone’s default web browser.
 - Are there any sites where the search term is NOT included as a query in the URL? In that case, have to have the app actually type it into the search field and hit enter.
 - Account for things like searching Google for search term + "site:reddit.com". And doing this with multiple sites (e.g., "site:reddit.com OR site:quora.com")
 
 */