//
//  Constants.swift
//  FlickrGallery
//
//  Created by Abbas Angouti on 6/12/18.
//  Copyright © 2018 Abbas Angouti. All rights reserved.
//

import Foundation

struct Constants {
    
    enum SizeSuffix: String {
        case s, q, t, m, n, z, c, b, h, k, o
    }
    
    
    struct URLs {
        static let baseURL = "https://api.flickr.com/services/rest/"
    }
    
    
    struct Keys {
        static let APIKey = "abba1bedab825b688a296067e3d0ea0d"
    }
    
    
    struct Methods {
        static let searchPhotos = "flickr.photos.search"
    }
}

