//
//  JSONDecoder+Utils.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/10/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import Foundation


extension JSONDecoder {
    
    /// Safely instantiates type from data
    func safeDecode<T>(_ type: T.Type, from data: Data) -> T? where T : Decodable {
        do {
            return try decode(type, from: data)
        } catch {
            print("\nDecode error:\n\(error)\n")
            return nil
        }
    }
}
