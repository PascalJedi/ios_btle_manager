//
//  Array.swift
//  btleManager
//
//  Created by Randal Erman on 3/10/19.
//  Copyright © 2019 Randal Erman. All rights reserved.
//

import Foundation

extension Array where Element: Equatable{
    mutating func remove (element: Element) {
        if let i = self.index(of: element) {
            self.remove(at: i)
        }
    }
}
