//
//  LocalNotificationsService.swift
//  HackyCalendar
//
//  Created by Aleksandr Pavliuk on 5/23/19.
//  Copyright © 2019 aporganization. All rights reserved.
//

import Foundation
import UserNotifications

protocol LocalNotificationsServiceProtocol: class {
    func requestAccess(completion: @escaping (Result<Void, LocalNotificationsServiceError>) -> Void)
    func verifyNotificationCenterAuthorized(completion: @escaping (Bool) -> Void)
    func setReminder(for entity: LocalNotificationServiceEntity)
}

struct LocalNotificationServiceEntity {
    let title: String
    let body: String
    let date: Date
    let id: String
}

enum LocalNotificationsServiceError: Error {
    case denied
    case provisional
    case notifCenter(Error)
    case unknown
}

class LocalNotificationsService: LocalNotificationsServiceProtocol {

    private let notificationCenter: UNUserNotificationCenter = UNUserNotificationCenter.current()
    private let options: UNAuthorizationOptions = [.alert, .sound, .badge]

}

// MARK: LocalReminderServiceProtocol
extension LocalNotificationsService {
    func requestAccess(completion: @escaping (Result<Void, LocalNotificationsServiceError>) -> Void) {
        notificationCenter.getNotificationSettings { (settings) in
            switch settings.authorizationStatus {
            case .notDetermined:
                self.request(completion: completion)
            case .denied:
                completion(.failure(.denied))
            case .authorized:
                completion(.success(()))
            case .provisional:
                completion(.failure(.provisional))
            @unknown default:
                completion(.failure(.unknown))
            }
        }
    }

    func verifyNotificationCenterAuthorized(completion: @escaping (Bool) -> Void) {
        notificationCenter.getNotificationSettings { (settings) in
            switch settings.authorizationStatus {
            case .authorized:
                completion(true)
            default:
                completion(false)
            }
        }
    }

    func setReminder(for entity: LocalNotificationServiceEntity) {
        let triggerDate = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: entity.date
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

        let content = UNMutableNotificationContent()
        content.title =
        """
        Event "\(entity.title)" is starting now
        """
        content.body = entity.body
        content.sound = UNNotificationSound.default

        let request = UNNotificationRequest(identifier: entity.id, content: content, trigger: trigger)
        self.notificationCenter.add(request)
    }
}

// MARK: Private methods
private extension LocalNotificationsService {
    func request(completion: @escaping (Result<Void, LocalNotificationsServiceError>) -> Void) {
        notificationCenter.requestAuthorization(options: options) { (success, error) in
            if let error = error {
                completion(.failure(.notifCenter(error)))
            } else {
                completion(.success(()))
            }
        }
    }
    
}
