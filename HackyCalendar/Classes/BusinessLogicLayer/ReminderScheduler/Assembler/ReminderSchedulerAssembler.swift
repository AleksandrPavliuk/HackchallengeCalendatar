//
//  ReminderSchedulerAssembler.swift
//  HackyCalendar
//
//  Created by Aleksandr Pavliuk on 5/23/19.
//  Copyright © 2019 aporganization. All rights reserved.
//

import Foundation

protocol ReminderSchedulerAssemblerProtocol: class {
    func makeReminderScheduler() -> ReminderSchedulerProtocol
}

class ReminderSchedulerAssembler: ReminderSchedulerAssemblerProtocol {
    func makeReminderScheduler() -> ReminderSchedulerProtocol {
        let calendarService: CalendarServiceProtocol = CalendarService()
        let localNotificationsService: LocalNotificationsServiceProtocol = LocalNotificationsService()
        let calendarEventValidator: CalendarEventValidatorProtocol = CalendarEventValidator()
        return ReminderScheduler(dependencies: (calendarService, localNotificationsService, calendarEventValidator))
    }
}
