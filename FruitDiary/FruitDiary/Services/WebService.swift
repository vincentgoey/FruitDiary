//
//  WebService.swift
//  FruitDiary
//
//  Created by Kai Xuan on 10/02/2020.
//  Copyright © 2020 Kai Xuan. All rights reserved.
//

import Foundation

struct Resource<T> {
    let url: URL
    let parse: (Data) -> T?
}

final class Webservice {
    
    func load<T>(resource: Resource<T>, completion: @escaping (T?) -> ()){
        URLSession.shared.dataTask(with: resource.url) { data, response, error in
            if let data = data {
                DispatchQueue.main.async {
                    completion(resource.parse(data))
                }
            } else{
                completion(nil)
            }
        }.resume()
    }
    
    func postMethod<T>(resource: Resource<T>, body: [String:Any], completion: @escaping (T?) -> ()) {
        
//        guard let url = URL(string: resource.url) else { return }
        
        var urlRequest = URLRequest(url: resource.url)
        urlRequest.httpMethod = "POST"
        
        let params = body
        
        do {
            let data = try JSONSerialization.data(withJSONObject: params, options: .init())
            urlRequest.httpBody = data
            urlRequest.setValue("application/json", forHTTPHeaderField: "content-type")
            
            URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                if let data = data {
                    DispatchQueue.main.async {
                        completion(resource.parse(data))
                    }
                } else{
                    completion(nil)
                }
            }.resume()
            
        } catch {
            completion(nil)
        }
        
    }
    
    func deleteMethod(url: URL, completion: @escaping (Error?) -> ()) {
        
        //Api Return 200 as long as params pass as numberic
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                completion(error)
                return
            }
            completion(nil)
        }.resume()

    }
    
}
