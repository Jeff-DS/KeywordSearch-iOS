//
//  SearchType.swift
//  KeywordSearch
//
//  Created by Jeff Spingeld on 5/7/16.
//  Copyright © 2016 Jeff Spingeld. All rights reserved.
//

import UIKit

class SearchType: NSObject, NSCoding {

    // At some point, also want properties for frequency of use and for the icon to use.
    var name: String
    var URLPartOne: String
    var URLPartTwo: String
    
    init(name: String, URLPartOne: String, URLPartTwo: String) {
        self.name = name
        self.URLPartOne = URLPartOne
        self.URLPartTwo = URLPartTwo
    }
    
    // NSCoding implementation ------------------------------
    required init(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObjectForKey("name") as! String
        URLPartOne = aDecoder.decodeObjectForKey("URLPartOne") as! String
        URLPartTwo = aDecoder.decodeObjectForKey("URLPartTwo") as! String
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(URLPartOne, forKey: "URLPartOne")
        aCoder.encodeObject(URLPartTwo, forKey: "URLPartTwo")
    }
    // --------------------------------
    
    
    
    
}
