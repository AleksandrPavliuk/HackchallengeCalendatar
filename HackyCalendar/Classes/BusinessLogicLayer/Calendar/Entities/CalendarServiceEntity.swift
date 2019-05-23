//
//  CalendarServiceEntity.swift
//  HackyCalendar
//
//  Created by Aleksandr Pavliuk on 5/23/19.
//  Copyright © 2019 aporganization. All rights reserved.
//

import Foundation

struct CalendarServiceEntity {
    let title: String
    let notes: String?
    let attendeesURLs: [URL]?
    let eventIdentifier: String
    let isAlarmExist: Bool
    let startDate: Date
}
