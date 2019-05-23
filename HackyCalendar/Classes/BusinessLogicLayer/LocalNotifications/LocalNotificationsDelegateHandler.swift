//
//  LocalNotificationsDelegateHandler.swift
//  HackyCalendar
//
//  Created by Aleksandr Pavliuk on 5/23/19.
//  Copyright © 2019 aporganization. All rights reserved.
//

import Foundation
import UserNotifications

final class LocalNotificationsDelegateHandler: NSObject, UNUserNotificationCenterDelegate, SetInjectable {

    private let notificationCenter: UNUserNotificationCenter = UNUserNotificationCenter.current()
    private weak var applicationCoordinator: ApplicationCoordinatorProtocol?

    override init() {
        super.init()
        notificationCenter.delegate = self
    }
}

// MARK: SetInjectable
extension LocalNotificationsDelegateHandler {
    func inject(dependencies: LocalNotificationsDelegateHandler.Dependencies) {
        (applicationCoordinator) = (dependencies)
    }

    typealias Dependencies = (ApplicationCoordinatorProtocol?)

}

// MARK: UNUserNotificationCenterDelegate
extension LocalNotificationsDelegateHandler {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        applicationCoordinator?.navigateAfterUserTapOnNotification(with: response.notification.request.identifier)
    }
}
