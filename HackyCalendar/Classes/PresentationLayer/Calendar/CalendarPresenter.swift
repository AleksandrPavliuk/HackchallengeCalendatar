//
//  CalendarPresenter.swift
//  HackyCalendar
//
//  Created by Aleksandr Pavliuk on 5/22/19.
//  Copyright © 2019 aporganization. All rights reserved.
//

import Foundation

protocol CalendarPresenterProtocol {
    func viewHasBeenLoad()
    func cellWasSelected(with model: CalendarCellModel)
}

final class CalendarPresenter: CalendarPresenterProtocol, SetInjectable {
    private weak var view: CalendarViewControllerProtocol?
    private var calendarService: (CalendarServiceProtocol & CalendarAlarmServiceProtocol)?
    private var flowCoordinator: MainFlowCoordinatorProtocol?
    private var localNotificationsService: LocalNotificationsServiceProtocol?
    private var reminderScheduler: ReminderSchedulerProtocol?

    private let requestsAccessDispatchGroup = DispatchGroup()

}

// MARK: CalendarPresenterProtocol
extension CalendarPresenter {
    func viewHasBeenLoad() {
        requestCalendarAccess()
        requestUserNortificationCenterAccess()

        requestsAccessDispatchGroup.notify(queue: .main) { [weak self] in
            guard let reminderScheduler = self?.reminderScheduler else {
                return
            }
            reminderScheduler.reScheduleReminders()
        }
    }

    func cellWasSelected(with model: CalendarCellModel) {
        guard let calendarService = calendarService else { return }
        if calendarService.doesEventHasAlarm(identifier: model.eventIdentifier) {
            flowCoordinator?.showCancelAlert() {
                do {
                    try calendarService.cancelEventAlarm(identifier: model.eventIdentifier)
                } catch {
                    
                }
            }
        }
    }
}

// MARK: SetInjectable
extension CalendarPresenter {
    typealias Dependencies = (
        CalendarViewControllerProtocol?,
        (CalendarServiceProtocol & CalendarAlarmServiceProtocol)?,
        MainFlowCoordinatorProtocol?,
        LocalNotificationsServiceProtocol?,
        ReminderSchedulerProtocol?
    )
    
    func inject(dependencies: Dependencies) {
        (view, calendarService, flowCoordinator, localNotificationsService, reminderScheduler) = dependencies
    }
}

// MARK: Private methods

private extension CalendarPresenter {

    func requestUserNortificationCenterAccess() {
        requestsAccessDispatchGroup.enter()
        localNotificationsService?.requestAccess { [weak self] (result) in
            guard let self = self else { return }
            self.requestsAccessDispatchGroup.leave()
        }
    }
    func requestCalendarAccess() {
        requestsAccessDispatchGroup.enter()
        calendarService?.requestAccess { [weak self] (result) in
            guard let self = self, let view = self.view else { return }

            self.requestsAccessDispatchGroup.leave()

            if case .success = result {
                let events = self.calendarService?.getEvents()
                let viewModel = self.makeViewModel(from: events)
                view.reloadTable(with: viewModel)
            }
        }
    }
        func makeViewModel(from calendarEntities: [CalendarServiceEntity]?) -> [CalendarCellModel] {
            return (calendarEntities ?? []).map {
                CalendarCellModel(
                    title: $0.title,
                    notes: $0.notes,
                    attendeesURLs: $0.attendeesURLs,
                    eventIdentifier: $0.eventIdentifier,
                    isAlarmExist: $0.isAlarmExist)

            }
        }
}



