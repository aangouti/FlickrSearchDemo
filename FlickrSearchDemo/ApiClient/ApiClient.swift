//
//  ApiClient.swift
//  FlickrGallery
//
//  Created by Abbas Angouti on 6/12/18.
//  Copyright © 2018 Abbas Angouti. All rights reserved.
//

import Foundation
import UIKit

class ApiClient {
    static let shared = ApiClient()
    
    enum DataFetchError: Error {
        case invalidURL
        case networkError(message: String)
        case invalidResponse
        case serverError
        case nilResult
        case invalidDataFormat
        case jsonError(message: String)
        case invalideDataType(message: String)
        case unknownError
    }
    
    enum ResultType {
        case success(r: APIResult)
        case error(e: DataFetchError)
    }
    
    private init() {}

    
    func getPhotos(for keyword: String, page: Int, completion: @escaping (_ result: ResultType) -> Void)  {
        var querystringParameters: [String: AnyObject] = ["method": Constants.Methods.searchPhotos as AnyObject,
                                                          "api_key": Constants.Keys.APIKey as AnyObject,
                                                          "text": keyword as AnyObject,
                                                          "format": "json" as AnyObject,
                                                          "nojsoncallback": 1 as AnyObject,
                                                          "page": page as AnyObject]
        querystringParameters["extras"] = "url_s" as AnyObject
        
        guard let url = Helper.makeUrl(querystringParameters: querystringParameters) else {
            completion(ResultType.error(e: DataFetchError.invalidURL))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            /* GUARD: Was there an error? */
            guard error == nil else {
                completion(ResultType.error(e: DataFetchError.networkError(message: error!.localizedDescription)))
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                completion(ResultType.error(e: DataFetchError.invalidResponse))
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                completion(ResultType.error(e: DataFetchError.nilResult))
                return
            }
            
            do {
                let apiResult = try JSONDecoder().decode(SearchApiResponse.self, from: data)
                if apiResult.stat.lowercased() == "OK".lowercased() {
                    completion(ResultType.success(r: apiResult.photos))
                } else {
                    completion(ResultType.error(e: DataFetchError.invalidDataFormat))
                }
            } catch let parseError {
                completion(ResultType.error(e: DataFetchError.jsonError(message: parseError.localizedDescription)))
            }
        }
        
        task.resume()
    }
    
    
    func downloadImageTask(url: URL, completion: @escaping (_ result: ResultType) -> Void) -> URLSessionDataTask? {
        // search local cache first
        if let imageData = UserDefaults.standard.object(forKey: url.absoluteString) as? Data {
            if let image = UIImage(data: imageData) {
                completion(ResultType.success(r: image))
            } else {
                completion(ResultType.error(e: DataFetchError.invalideDataType(message: "not a valid image data")))
            }
            return nil
        }

        let session = URLSession.shared
        let task = session.dataTask(with: url) { (data, response, error) in
            /* GUARD: Was there an error? */
            guard error == nil else {
                completion(ResultType.error(e: DataFetchError.networkError(message: error!.localizedDescription)))
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                completion(ResultType.error(e: DataFetchError.invalidResponse))
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                completion(ResultType.error(e: DataFetchError.nilResult))
                return
            }
            
            if let image = UIImage(data: data) {
                UserDefaults.standard.set(data, forKey: url.absoluteString)
                completion(ResultType.success(r: image))
            } else {
                completion(ResultType.error(e: DataFetchError.invalideDataType(message: "not a valid image data")))
            }
        }
        
//        task.resume()
        return task
    }
    
}


extension UIImage: APIResult {}

