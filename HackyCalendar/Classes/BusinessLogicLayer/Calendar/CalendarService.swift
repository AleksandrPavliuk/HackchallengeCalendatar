//
//  CalendarService.swift
//  HackyCalendar
//
//  Created by Aleksandr Pavliuk on 5/22/19.
//  Copyright © 2019 aporganization. All rights reserved.
//

import EventKit

protocol CalendarServiceProtocol {
    func requestAccess(completion: @escaping (Result<Void, CalendarServiceError>) -> Void)
    var isCalendarAuthorized: Bool { get }
    func getEvents() -> [CalendarServiceEntity]?
    func getEvent(with identifier: String) -> CalendarServiceEntity?
}

protocol CalendarAlarmServiceProtocol {
    func cancelEventAlarm(identifier: String) throws
    func doesEventHasAlarm(identifier: String) -> Bool
}

enum CalendarServiceError: Error {
    case restricted
    case denied
    case eventKit(Error)
    case unknown
}

final class CalendarService: CalendarServiceProtocol, CalendarAlarmServiceProtocol {
    
    private struct Constants {
        static let entityTypeNeeded: EKEntityType = .event
    }
    
    private let store = EKEventStore()
}

// MARK: CalendarEventsServiceProtocol
extension CalendarService {
    func getEvents() -> [CalendarServiceEntity]? {
        let calendar = Calendar.current

        var oneDayAgoComponents = DateComponents()
        oneDayAgoComponents.day = -1
        let oneDayAgo = calendar.date(byAdding: oneDayAgoComponents, to: Date())

        var oneDayFromNowComponents = DateComponents()
        oneDayFromNowComponents.day = 1
        let oneDayFromNow = calendar.date(byAdding: oneDayFromNowComponents, to: Date())

        var predicate: NSPredicate? = nil
        if let anAgo = oneDayAgo, let aNow = oneDayFromNow {
            predicate = store.predicateForEvents(withStart: anAgo, end: aNow, calendars: nil)
        }

        return predicate
            .flatMap { store.events(matching: $0) }?
            .map { map(event: $0) }
    }

    func cancelEventAlarm(identifier: String) throws {
        guard let event = store.event(withIdentifier: identifier) else {
            return
        }
        event.alarms = nil
        return try store.save(event, span: .thisEvent, commit: true)
    }

    func doesEventHasAlarm(identifier: String) -> Bool {
        guard let alarms = store.event(withIdentifier: identifier)?.alarms else {
            return false
        }

        return !alarms.isEmpty
    }

    func getEvent(with identifier: String) -> CalendarServiceEntity? {
        guard let event = store.event(withIdentifier: identifier) else { return nil }
        return map(event: event)
    }
}

// MARK: CalendarServiceProtocol
extension CalendarService {
    func requestAccess(completion: @escaping (Result<Void, CalendarServiceError>) -> Void) {
        
        switch EKEventStore.authorizationStatus(for: Constants.entityTypeNeeded) {
        case .notDetermined:
            request(completion: completion)
        case .restricted:
            completion(.failure(.restricted))
        case .denied:
            completion(.failure(.denied))
        case .authorized:
            completion(.success(()))
        @unknown default:
            completion(.failure(.unknown))
        }
    }

    var isCalendarAuthorized: Bool {
        guard case .authorized = EKEventStore.authorizationStatus(for: Constants.entityTypeNeeded) else {
            return false
        }
        return true
    }
}

// MARK: Private methods
private extension CalendarService {
    func request(completion: @escaping (Result<Void, CalendarServiceError>) -> Void) {
        store.requestAccess(to: Constants.entityTypeNeeded) { (success, error) in
            if let error = error {
                completion(.failure(.eventKit(error)))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func map(event: EKEvent) -> CalendarServiceEntity {
        let attendeesURLs = event.attendees?.map { $0.url }
        let isAlarmExist = event.alarms?.first != nil

        return CalendarServiceEntity(
            title: event.title,
            notes: event.notes,
            attendeesURLs: attendeesURLs,
            eventIdentifier: event.eventIdentifier,
            isAlarmExist: isAlarmExist,
            startDate: event.startDate
        )
    }
}
