//
//  ReminderScheduler.swift
//  HackyCalendar
//
//  Created by Aleksandr Pavliuk on 5/23/19.
//  Copyright © 2019 aporganization. All rights reserved.
//

import Foundation

protocol ReminderSchedulerProtocol: class {
    func reScheduleReminders()
}

class ReminderScheduler: ReminderSchedulerProtocol, InitializeInjectable {
    private let calendarService: CalendarServiceProtocol
    private let localReminderService: LocalNotificationsServiceProtocol
    private let calendarEventValidator: CalendarEventValidatorProtocol
    private let queue = DispatchQueue.global(qos: .default)

    // MARK: InitializeInjectable
    required init(dependencies: ReminderScheduler.Dependencies) {
        (calendarService, localReminderService, calendarEventValidator) = dependencies
    }

    typealias Dependencies = (CalendarServiceProtocol, LocalNotificationsServiceProtocol, CalendarEventValidatorProtocol)
}

// MARK: ReminderSchedulerProtocol
extension ReminderScheduler {
    func reScheduleReminders() {
        queue.async {
            self.scheduleReminders()
        }
    }
}

private extension ReminderScheduler {

    func scheduleReminders() {
        guard calendarService.isCalendarAuthorized == true else { return }

        localReminderService.verifyNotificationCenterAuthorized { [weak self] (result) in
            guard
                result == true,
                let self = self,
                let events = self.calendarService.getEvents() else { return }

            events
                .filter(self.calendarEventValidator.validateAtLeastOneOfAttendeesIsUsingANonGmail(event:))
                .map(self.map(event:))
                .forEach(self.localReminderService.setReminder(for:))
        }
    }
    
    func map(event: CalendarServiceEntity) -> LocalNotificationServiceEntity {
        return LocalNotificationServiceEntity(
            title: event.title,
            body: event.notes ?? "",
            date: event.startDate,
            id: event.eventIdentifier
        )
    }
}
