//
//  Network.swift
//  Movies
//
//  Created by khaled mohamed el morabea on 12/9/18.
//  Copyright © 2018 Instabug. All rights reserved.
//

import UIKit

open class Network: NSObject {
    open func executeGETRequest(api: String, completionBlock: @escaping (Data?) -> Void) {
        let environment = ProcessInfo.processInfo.environment

        if environment["isUITest"] != nil, let baseUrl = environment["BASEURL"] {
            guard let url = URL(string: baseUrl + api) else {
                completionBlock(nil)
                return
            }
            let session = URLSession(configuration: URLSessionConfiguration.default)
            let dataTask = session.dataTask(with: url) { (data, _, error) in
                if let err = error {
                    print("Network error:", err)
                }
                completionBlock(data)
            }
            dataTask.resume()
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            let data = NSDataAsset(name: "movies")?.data
            completionBlock(data)
        }
    }
}
