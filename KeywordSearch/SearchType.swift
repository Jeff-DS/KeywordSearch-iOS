//
//  SearchType.swift
//  KeywordSearch
//
//  Created by Jeff Spingeld on 5/7/16.
//  Copyright © 2016 Jeff Spingeld. All rights reserved.
//

import UIKit

class SearchType: NSObject, NSCoding {

    var name: String
    var URLPartOne: String
    var URLPartTwo: String
    var favicon: UIImage
    
    init(name: String, URLPartOne: String, URLPartTwo: String, favicon: UIImage) {
        self.name = name
        self.URLPartOne = URLPartOne
        self.URLPartTwo = URLPartTwo
        self.favicon = favicon
    }
    
    // NSCoding implementation ------------------------------
    required init(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObject(forKey: "name") as! String
        URLPartOne = aDecoder.decodeObject(forKey: "URLPartOne") as! String
        URLPartTwo = aDecoder.decodeObject(forKey: "URLPartTwo") as! String
        favicon = aDecoder.decodeObject(forKey: "favicon") as! UIImage
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(URLPartOne, forKey: "URLPartOne")
        aCoder.encode(URLPartTwo, forKey: "URLPartTwo")
        aCoder.encode(favicon, forKey: "favicon")
    }
    // --------------------------------
    
    
    
    
}
