//
//  Tools.swift
//  DHJsonToModel
//
//  Created by 候东辉 on 2019/9/23.
//  Copyright © 2019 候东辉. All rights reserved.
//

import Cocoa

class Tools: NSObject {
    
    public func isjsonString(json: String) -> Bool {
        let jsondata = json.data(using: .utf8)
        do {
            try JSONSerialization.jsonObject(with: jsondata!, options: .mutableContainers)
            return true
        } catch  {
            return false
        }
    }
    
}
