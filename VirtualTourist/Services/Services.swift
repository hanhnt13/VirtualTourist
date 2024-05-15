//
//  Services.swift
//  VirtualTourist
//
//  Created by admin on 14/5/24.
//

import UIKit

import Foundation

enum APIType {
    case udacity
    case none
}

enum Method: String {
    case post = "POST"
    case put = "PUT"
    case get = "GET"
    case delete = "DELETE"
}

class Services {
    
    static let shared = Services()
    
    static let apiKey = "6dbfc3a7af64568fe06795dfa3be200b"
    
    enum Endpoints {
        static let base = "https://www.flickr.com/services/rest/?api_key=\(Services.apiKey)&&format=json&nojsoncallback=1&"
        
        case searchPhoto(String)
        case getSource(String)

        var stringValue: String {
            switch self {
            case .searchPhoto(let parameters):
                return Endpoints.base + "method=flickr.photos.search&per_page=12&" + parameters
            case .getSource(let parameters):
                return Endpoints.base + "method=flickr.photos.getSizes&" + parameters
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?)->Void ) {
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }

            do {
                let responseObject = try JSONDecoder().decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }

            }
        }
        task.resume()
    }
    
    func searchPhoto(lat: Double, lon: Double, page: Int, completion: @escaping (SearchPhotoResponse?, Error?)->Void ) {
        taskForGETRequest(url: Endpoints.searchPhoto("lat=\(lat)&lon=\(lon)&page=\(page)").url, responseType: SearchPhotoResponse.self) { (response, error) in
            guard let response = response else {
                completion(nil, error)
                return
            }
            
            completion(response, nil)
        }
    }
    
    func getSource(photoID: String, completion: @escaping (SizesResponse?, Error?) -> Void) {
        taskForGETRequest(url: Endpoints.getSource("photo_id=\(photoID)").url, responseType: SizesResponse.self) { (response, error) in
            if let response = response {
                completion(response, nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
    func downloadImage(url: URL, completion: @escaping (Data?, Error?) -> Void) {
        let download = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            DispatchQueue.main.async {
                completion(data, nil)
            }
        }
        download.resume()
    }
    
}
