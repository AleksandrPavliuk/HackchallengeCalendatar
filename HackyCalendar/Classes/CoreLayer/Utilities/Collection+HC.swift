//
//  Collection+HC.swift
//  HackyCalendar
//
//  Created by Aleksandr Pavliuk on 5/22/19.
//  Copyright © 2019 aporganization. All rights reserved.
//

import Foundation

extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
