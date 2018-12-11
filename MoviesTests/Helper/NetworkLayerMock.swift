//
//  NetworkLayerMock.swift
//  MoviesTests
//
//  Created by khaled mohamed el morabea on 12/11/18.
//  Copyright © 2018 Instabug. All rights reserved.
//

import UIKit
import Movies

class NetworkLayerMock: Network {

    private let mockedData: [[String:String]]
    
    init(mockedData:[[String:String]]) {
        self.mockedData = mockedData
    }

    override func executeGETRequest(api:String, completionBlock:@escaping (Data?) -> Void)  {
        let data = toJSONString(mockedData: self.mockedData)
        completionBlock(data)
    }
    
    func toJSONString(mockedData:[[String:String]]?) -> Data? {
        if let arr = mockedData {
            let dat = try? JSONSerialization.data(withJSONObject: arr, options: .prettyPrinted)
            return dat
        }
        return nil
    }
}
