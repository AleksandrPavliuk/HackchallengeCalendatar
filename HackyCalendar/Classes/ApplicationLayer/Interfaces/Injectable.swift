//
//  Injectable.swift
//  HackyCalendar
//
//  Created by Aleksandr Pavliuk on 5/22/19.
//  Copyright © 2019 aporganization. All rights reserved.
//

import Foundation

protocol Injectable {
    associatedtype Dependencies
}

protocol InitializeInjectable: Injectable {
    init(dependencies: Dependencies)
}

protocol SetInjectable: Injectable {
    func inject(dependencies: Dependencies)
}

