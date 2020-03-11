//
//  Convertable.swift
//  YTKSwift
//
//  Created by jinaiyuan on 2020/3/11.
//  Copyright © 2020 jinaiyuan. All rights reserved.
//

import Foundation

/// Use Codable for JSON - Model convert
public protocol Convertable: Codable {
}

extension Convertable {
    private static var decoder: JSONDecoder { return JSONDecoder() }

    static func convert(value: Any) -> Self? {
        switch value {
        case let json as String:
            return convertString2Model(json: json)
        case let data as Data:
            return convertData2Model(data: data)
        case let dictionary as [String: Any]:
            return covertDictionary2Model(dictionary: dictionary)
        default:
            return nil
        }
    }
    
    static func covertDictionary2Model(dictionary: [String: Any]) -> Self? {
        if let data = try? JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted) {
            return try? decoder.decode(Self.self, from: data)
        }
        
        return nil
    }
    
    static func convertString2Model(json: String) -> Self? {
        if let data = json.data(using: .utf8) {
            return try? decoder.decode(Self.self, from: data)
        }
        return nil
    }
    
    static func convertData2Model(data: Data) -> Self? {
        return try? decoder.decode(Self.self, from: data)
    }
}
