//
//  ApplicationCoordinator.swift
//  HackyCalendar
//
//  Created by Aleksandr Pavliuk on 5/22/19.
//  Copyright © 2019 aporganization. All rights reserved.
//

import Foundation
import UIKit

protocol ApplicationCoordinatorProtocol: CoordinatorProtocol {
    func navigateAfterUserTapOnNotification(with identifier: String)
}

final class ApplicationCoordinator: ApplicationCoordinatorProtocol {

    let window: UIWindow

    private var mainFlowCoordinator: MainFlowCoordinatorProtocol?

    init(window: UIWindow) {
        self.window = window
    }
}


// MARK: CoordinatorProtocol
extension ApplicationCoordinator {
    func start() {
        mainFlowCoordinator = MainFlowCoordinator(window: window)
        mainFlowCoordinator?.start()
    }
}

// MARK: ApplicationCoordinatorProtocol
extension ApplicationCoordinator {
    func navigateAfterUserTapOnNotification(with identifier: String) {
        mainFlowCoordinator?.showCalendarEventDetailsView(for: identifier)
    }
}
