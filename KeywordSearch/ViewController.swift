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


class ViewController: UIViewController, SFSafariViewControllerDelegate, WebVCDelegate,UICollectionViewDelegate, UICollectionViewDataSource {

    // MARK: Properties
    @IBOutlet weak var addSearchButton: UIButton!
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var searchTypesCollectionView: UICollectionView!
    
    var defaults: UserDefaults?
    var searchTypesArray: [SearchType] = []
    let imageClient = ImageClient()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set self as delegate for the collection view
        searchTypesCollectionView.delegate = self
        searchTypesCollectionView.dataSource = self
        
        // Get the search types array from UserDefaults and unarchive it
        defaults = UserDefaults.standard
        if let searchTypesArrayObject = defaults?.object(forKey: "searchTypesArray") as? Data {
            
            searchTypesArray = NSKeyedUnarchiver.unarchiveObject(with: searchTypesArrayObject) as! [SearchType]
            
            // Run this method the first time the app is opened. (The user hasn't added any search types yet, so it adds Google as a default.)
            if searchTypesArray.isEmpty {
                firstRun()
            }
            
        }
        
        // For testing: populate the search types array with a specific set of search types.
        // CAREFUL: this will obliterate all existing search types. Go to this method and comment that part out if this is not desired.
//         useTestData()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Register for notification when keyboard shows
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardFrameChanges(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillChangeFrame,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(disableAnimations(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(enableAnimations(notification:)),
                                               name: NSNotification.Name.UIKeyboardDidShow,
                                               object: nil)
        
        // Make keyboard open immediately
        searchField.becomeFirstResponder()
        
    }

    //MARK: Collection view delegate methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchTypesArray.count
    }
    
    // Populate cells
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // Dequeue cell
        let cell = searchTypesCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! SearchTypeCollectionViewCell
        
        // Get search type
        let searchType = searchTypesArray[indexPath.row]
        
        // Set text label
        cell.titleLabel.text = searchType.name
        
        // If search type doesn't have a favicon yet, but there's a list of URLs, get the image from each URL (if any), take the largest, and set it to the favicon property
        
        if let list = searchType.faviconUrlList, searchType.favicon == nil {
            self.imageClient.getLargestFavicon(from: list) { (favicon) in
                
                // Set search type's favicon property to the returned UIImage
                searchType.favicon = favicon
                
                // Update searchTypesArray property and update UserDefaults to persist the change to the favicon property
                self.searchTypesArray[indexPath.row] = searchType
                let updatedArray = NSKeyedArchiver.archivedData(withRootObject: self.searchTypesArray)
                self.defaults!.set(updatedArray, forKey: "searchTypesArray")
                
                // Reload cell
                DispatchQueue.main.async {
                    self.searchTypesCollectionView.reloadItems(at: [indexPath])
                }
            }
        }
        
        // Set cell background to the favicon
        if let favicon = searchType.favicon {
            cell.avatarView.image = favicon
        }
        
        return cell
    }
    
    // Handle tap
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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
    
    // MARK: other methods
    
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
        
        // Reload the tableview with the new search
        searchTypesCollectionView.reloadData()
        
    }
    
    // Create an initial set of search types for testing
    func useTestData() {
        
        // Create a few sample search types
        // TODO: get the favicons for these
        let dictionary = SearchType(name: "Dictionary.com", URLPartOne: "http://www.dictionary.com/browse/", URLPartTwo: "?s=ts", faviconUrlList: [])
        let etymonline = SearchType(name: "Etymonline", URLPartOne: "http://www.etymonline.com/index.php?allowed_in_frame=0&search=", URLPartTwo: "&searchmode=none", faviconUrlList: [])
        let amazon = SearchType(name: "Amazon", URLPartOne: "http://smile.amazon.com/s/ref=smi_www_rcol_go_smi?ie=UTF8&field-keywords=", URLPartTwo: "&url=search-alias%3Daps&x=0&y=0", faviconUrlList: [])
        
        // Add them to the array
        searchTypesArray = [dictionary, etymonline, amazon]
        
        // COMMENT OUT THE FOLLOWING if you don't want to lose all other existing search types.
        let updatedArray = NSKeyedArchiver.archivedData(withRootObject: self.searchTypesArray)
        self.defaults!.set(updatedArray, forKey: "searchTypesArray")
        
    }
    
    // To run when the search types list is empty
    func firstRun() -> Void {
        
        // Create search type
        let google = SearchType(name: "Google", URLPartOne: "https://www.google.com/search?q=", URLPartTwo: "", faviconUrlList: ["https://www.google.com/favicon.ico"])
        
        // Add to searchTypesArray and archive
        searchTypesArray.append(google)
        let updatedArray = NSKeyedArchiver.archivedData(withRootObject: self.searchTypesArray)
        self.defaults!.set(updatedArray, forKey: "searchTypesArray")
        
        // Update collection view
        DispatchQueue.main.async {
            self.searchTypesCollectionView.reloadData()
        }
        
        
    }
    
    func keyboardFrameChanges(notification:Notification) -> Void {
        
        // Get the keyboard's new frame
        guard let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { print("keyboard error"); return }
        
        //TODO: should this be animated? Or should the search field be invisible until after the keyboard fully shows? Ideally, the keyboard and field would already be in the correct places. That depends on being able to have the keyboard open without animating.
        
        // Constrain the search field to be 10 points above the keyboard
        createOrUpdateConstraint(for: keyboardFrame)
        
    }
    
    // Disable animations so keyboard appears immediately rather than animating in
    func disableAnimations(notification:Notification) -> Void {
        UIView.setAnimationsEnabled(false)
    }
    
    // Reenable animations after keyboard shows
    func enableAnimations(notification:Notification) -> Void {
        UIView.setAnimationsEnabled(true)
    }
    
    func createOrUpdateConstraint(for keyboardFrame: CGRect)  {
        
        // height of search field should be:
        let searchFieldHeight = keyboardFrame.size.height + 10
        
        // If the constraint already exists, just update its constant.
        var constraintAlreadyExists = false
        for index in 0..<view.constraints.count where view.constraints[index].identifier == "constraint" {
            
            constraintAlreadyExists = true
            view.constraints[index].constant = searchFieldHeight * -1
            
        }
        
        // Otherwise, create the constraint
        if !constraintAlreadyExists {
            
            let constraint: NSLayoutConstraint = self.searchField.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: searchFieldHeight * -1)
            constraint.identifier = "constraint"
            constraint.isActive = true
            
        }
        
        // Update layout
        DispatchQueue.main.async {
            self.view.updateConstraintsIfNeeded()
            self.view.layoutIfNeeded()
        }
        
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
 Trello: https://trello.com/b/DU2zwrow/keywordsearch
 
 What this app is
 
 Keyword search: app to do Chrome’s keyword search.
 - You’d have a big text field and below it a grid of squares representing websites (looking like a home screen full of apps).
 - You type your search term, tap to select a search (your most frequent is selected by default), and hit go/enter.
 - To add a search type, you go to the “Add search” section of the app, which opens a web view. Go to the website, and tap on the search bar. The app will automatically add this to the search list. Under the hood, it does this by entering a random search term and submitting the form, then using the resulting page’s URL to figure out the frame URL and where to put the search term in.
 - IMPLEMENTATION:
 - See the part at this page on putting .js scripts in an app and accessing them by replacing init() on a view controller for a web view... http://www.appcoda.com/webkit-framework-tutorial/
 - In the HTML, find the text input boxes by looking for <input type="text" ...> tags. I want to animate text boxes to blink in colors so they're noticeable; see bottom of this page for an example script.
 */
