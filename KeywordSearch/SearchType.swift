//
//  SearchType.swift
//  KeywordSearch
//
//  Created by Jeff Spingeld on 5/7/16.
//  Copyright © 2016 Jeff Spingeld. All rights reserved.
//

import UIKit

class SearchType: NSObject {

    // At some point, also want properties for frequency of use and for the icon to use.
    var name: String
    var URLPartOne: String
    var URLPartTwo: String
    
    init(name: String, URLPartOne: String, URLPartTwo: String) {
        self.name = name
        self.URLPartOne = URLPartOne
        self.URLPartTwo = URLPartTwo
    }
    
    
    
}
