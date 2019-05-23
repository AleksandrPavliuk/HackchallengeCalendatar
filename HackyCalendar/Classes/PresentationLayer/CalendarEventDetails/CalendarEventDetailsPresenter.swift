//
//  CalendarEventDetailsPresenter.swift
//  HackyCalendar
//
//  Created by Aleksandr Pavliuk on 5/23/19.
//  Copyright © 2019 aporganization. All rights reserved.
//

import Foundation

protocol CalendarEventDetailsPresenterProtocol {
    func viewHasBeenLoaded()
}

final class CalendarEventDetailsPresenter: CalendarEventDetailsPresenterProtocol, SetInjectable {
    private weak var view: CalendarEventDetailsViewControllerProtocol?
    private var eventIdentifier: String?
    private var calendarService: CalendarServiceProtocol?
}


// MARK: SetInjectable
extension CalendarEventDetailsPresenter {
    func inject(dependencies: CalendarEventDetailsPresenter.Dependencies) {
        (view, eventIdentifier, calendarService) = dependencies
    }

    typealias Dependencies = (CalendarEventDetailsViewControllerProtocol?, eventIdentifier: String?, CalendarServiceProtocol?)
}

// MARK: CalendarEventDetailsPresenterProtocol
extension CalendarEventDetailsPresenter {
    func viewHasBeenLoaded() {
        guard
            let calendarService = calendarService,
            let eventIdentifier = eventIdentifier,
            let event = calendarService.getEvent(with: eventIdentifier) else {
            return
        }

        let notes = event.notes ?? "No notes added"
        let alarmNote = event.isAlarmExist ? "Notice alarm is exist" : "No native alarm is exist"

        let model = CalendarEventDetailsViewModel(title: event.title, notes: notes , alarmNote: alarmNote)
        view?.update(with: model)
    }
}
