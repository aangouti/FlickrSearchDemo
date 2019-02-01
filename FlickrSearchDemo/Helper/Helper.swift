//
//  Helper.swift
//  FlickrGallery
//
//  Created by Abbas Angouti on 6/12/18.
//  Copyright © 2018 Abbas Angouti. All rights reserved.
//

import Foundation

struct Helper {
    static func makeUrl(querystringParameters: [String: AnyObject]) -> URL?{
        var urlString = Constants.URLs.baseURL
        let escapedParameters = encodeQueryParameters(querystringParameters)
        if !escapedParameters.isEmpty {
            urlString = "\(Constants.URLs.baseURL)?\(escapedParameters)"
        }
        
        return URL(string: urlString)
    }
    
    
    static func encodeQueryParameters(_ parameters: [String: AnyObject]) -> String {
        if parameters.isEmpty {
            return ""
        }
        
        var keyValuePairs = Set<String>()
        for (key, value) in parameters {
            // make sure the value is a string
            let stringValue = "\(value)"
            
            // encode it
            let encodedValue = stringValue.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics)
            
            // append it
            keyValuePairs.insert(key + "=" + "\(encodedValue!)")
        }
        
        return "\(keyValuePairs.joined(separator: "&"))"
    }
}
