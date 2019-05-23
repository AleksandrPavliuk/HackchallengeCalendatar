//
//  CalendarEventFilter.swift
//  HackyCalendar
//
//  Created by Aleksandr Pavliuk on 5/23/19.
//  Copyright © 2019 aporganization. All rights reserved.
//

import Foundation

protocol CalendarEventValidatorProtocol {
    func validateAtLeastOneOfAttendeesIsUsingANonGmail(event: CalendarServiceEntity) -> Bool
}

class CalendarEventValidator: CalendarEventValidatorProtocol {
    private struct Constants {
        static let gmailEnding = "gmail.com"
    }

    func validateAtLeastOneOfAttendeesIsUsingANonGmail(event: CalendarServiceEntity) -> Bool {
        guard let attendeesURLs = event.attendeesURLs else { return false }
        return attendeesURLs.contains { !$0.absoluteString.contains(Constants.gmailEnding) }
    }
}
