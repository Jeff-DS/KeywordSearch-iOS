//
//  ImageClient.swift
//  KeywordSearch
//
//  Created by Jeff Spingeld on 11/3/16.
//  Copyright © 2016 Jeff Spingeld. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class ImageClient: NSObject {
    
    // Take an array of URL strings, download the image (if any) at each URL, and pass the largest of the resulting images back to the caller
    func getLargestFavicon(from array: [String], completion: @escaping (UIImage) -> Void ) {
        
        // Get all the images
        var images = [UIImage]
        for url in array {
            getImage(at: url, completion: { (image) in
                images.append(image)
                
                // When all the images are in, find the biggest image
                var biggest:UIImage?
                if images.count == array.count {
                    for image in images {
                        if biggest {
                            if image.size.height > biggest?.size.height {
                                biggest = image
                            }
                        } else {
                            biggest = image
                        }
                    }
                    // Call the completion block on it
                    completion(biggest)
                }
            })
        }
    }
    
    func getImage(at url: String, completion: @escaping (UIImage) -> Void) {
        
        Alamofire.request(url).responseImage { response in
            
            // Convert to UIImage
            guard let image = response.result.value as UIImage! else {
                print("Could not convert response at \(url) into UIImage")
                completion(UIImage())
            }
            
            completion(image)
            
        }

        
    }
}
