//
//  Model.swift
//  FlickrGallery
//
//  Created by Abbas Angouti on 6/12/18.
//  Copyright © 2018 Abbas Angouti. All rights reserved.
//

import Foundation


protocol APIResult {
    
}

// we are not using all fields for this particular app
struct Photo: Codable {
//    let id: String
//    let owner: String
//    let secret: String
//    let server: String
//    let farm: Int
    let title: String
//    let isPublic: Int
//    let isFriend: Int
//    let isFamily: Int
    let url: String // url_s
//    let height: String // height_s
//    let width: String // width_s
    
    private enum CodingKeys: String, CodingKey {
//        case id
//        case owner
//        case secret
//        case server
//        case farm
        case title
//        case isPublic = "ispublic"
//        case isFriend = "isfriend"
//        case isFamily = "isfamily"
        case url = "url_s"
//        case height = "height_s"
//        case width = "width_s"
    }
}

struct Photos: Codable, APIResult {
    let page: Int
    let pages: Int
    let perPage: Int
    let total: String
    var photoArray: [Photo] {
        didSet {
            print(photoArray)
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case page
        case pages
        case perPage = "perpage"
        case total
        case photoArray = "photo"
    }
}

struct SearchApiResponse: Codable {
    let stat: String
    let photos: Photos
}
