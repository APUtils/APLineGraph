//
//  Data+Utils.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/10/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import Foundation


extension Data {
    
    // ******************************* MARK: - Initialization
    
    /// Safely instantiates data from file URL
    init?(safeContentsOf url: URL) {
        do {
            try self.init(contentsOf: url)
        } catch {
            print("\nFile open error:\n\(error)\n")
            return nil
        }
    }
}
