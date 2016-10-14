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


class ViewController: UIViewController, SFSafariViewControllerDelegate, WebVCDelegate, UITableViewDelegate, UITableViewDataSource {

    // MARK: Properties
    @IBOutlet weak var addSearchButton: UIButton!
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var searchTypesTableView: UITableView!
    
    var defaults: UserDefaults?
    var searchTypesArray: [SearchType] = []
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        searchTypesTableView.delegate = self
        self.searchTypesTableView.dataSource = self
        
        // Get the search types array from NSUserDefaults and unarchive it
        defaults = UserDefaults.standard
        if let searchTypesArrayObject = defaults?.object(forKey: "searchTypesArray") as? Data {
          
            searchTypesArray = NSKeyedUnarchiver.unarchiveObject(with: searchTypesArrayObject) as! [SearchType]
            
        }
        
        // ----------------------------------           (TESTING)
        // An initial set of search types for testing
        
        // Create a few sample search types
        let dictionary = SearchType(name: "Dictionary.com", URLPartOne: "http://www.dictionary.com/browse/", URLPartTwo: "?s=ts")
        let etymonline = SearchType(name: "Etymonline", URLPartOne: "http://www.etymonline.com/index.php?allowed_in_frame=0&search=", URLPartTwo: "&searchmode=none")
        let amazon = SearchType(name: "Amazon", URLPartOne: "http://smile.amazon.com/s/ref=smi_www_rcol_go_smi?ie=UTF8&field-keywords=", URLPartTwo: "&url=search-alias%3Daps&x=0&y=0")
      
        // Add them to an array
//        searchTypesArray = [dictionary, etymonline, amazon]
        
        // -------------------------------
        
    }
    
    // Tableview delegate methods

    // One section
    func numberOfSectionsInTableView(tableview: UITableView) -> Int {
        return 0
    }
    
    // Number of rows
    @available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchTypesArray.count
    }
    
    // Populate cells
    @available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue cell
        let cell:UITableViewCell = self.searchTypesTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath)
        // Change text label
        cell.textLabel?.text = self.searchTypesArray[indexPath.row].name
        return cell
    }
    
    // Handle tap
    func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath)
    {
        performSearch(indexPath.row)
    }
    
    // Search for the search term using the relevant search engine
    func performSearch(_ searchTypeIndex: Int) {
        
        // Get the right search type
        let searchType: SearchType? = searchTypesArray[searchTypeIndex]
        // Use the text in the search field, and do percent encoding
        let searchTerm = searchField.text?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        // Construct the final URL
        let finalURL = searchType!.URLPartOne + searchTerm! + searchType!.URLPartTwo
        // Open a web view with that URL
        openWebPage(finalURL)
        
    }
    
    // Function to open a web page in a Safari view controller
    func openWebPage(_ URLString: String) {
        
        let thing = URL(string: URLString)
        let safariVC = SFSafariViewController(url: thing!)
        safariVC.delegate = self
        present(safariVC, animated: true, completion: nil)
        
    }
    
    // Implementation of delegate method. When WebVC sends over a new search type, add it.
    func addNewSearchType(_ searchType: SearchType) {
        
        // Add the new search type to the array
        searchTypesArray.append(searchType)
        
        // Update UserDefaults: archive updated searchTypesArray to a Data object and save
        let savedArray = NSKeyedArchiver.archivedData(withRootObject: searchTypesArray)
        defaults!.set(savedArray, forKey: "searchTypesArray")
        
        //TODO: test if this successfully adds the new search to tableview
        searchTypesTableView.reloadData()
        
    }
    
    // MARK: Actions
    @IBAction func addSearchButtonTapped(_ sender: UIButton) {
        
        // Create a view controller
        let webVC: WebVC = WebVC()
        webVC.URLString = "https://www.google.com/" // "http://www.etymonline.com/index.php?allowed_in_frame=0&search=gold&searchmode=none"
        // Set ourself as the WebVC's delegate
        webVC.delegate = self
        // Present it
        present(webVC, animated: true, completion: nil)
    
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
 
 BUGS/FIXES
 - Placeholder text appears when tableview cell selected
 
 FEATURES TO DO
 - Replace tableview with a pretty grid (stackview) of icons
 - Like Chrome, show a URL on the clipboard, if any
 - Allow searching multiple sites at once in tabs. E.g., search a bunch of dictionaries for the same word, or a bunch of e-commerce sites for the same product. After typing your search term, you tap the 'multiple searches' button, select all the search engines you want to use, then tap the button again to search. (Also need an escape button to cancel.)
   - Should be able to add a multiple-search set to the tableview. E.g., say I regularly want to search a bunch of dictionaries for the same word. I should be able to set this up once and use it later.
 - Could add option to get results from an API rather than web search?
 - Include Google, so this app could be someone’s default web browser.
 - Are there any sites where the search term is NOT included as a query in the URL? In that case, have to have the app actually type it into the search field and hit enter.
 - Account for things like searching Google for search term + "site:reddit.com". And doing this with multiple sites (e.g., "site:reddit.com OR site:quora.com")
 
 */
