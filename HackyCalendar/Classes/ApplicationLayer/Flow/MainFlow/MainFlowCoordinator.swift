//
//  MainFlowCoordinator.swift
//  HackyCalendar
//
//  Created by Aleksandr Pavliuk on 5/22/19.
//  Copyright © 2019 aporganization. All rights reserved.
//

import Foundation
import UIKit

protocol MainFlowCoordinatorProtocol: class, CoordinatorProtocol {
    func showCancelAlert(comletion: @escaping () -> Void)
    func showCalendarEventDetailsView(for eventId: String)
}

final class MainFlowCoordinator: MainFlowCoordinatorProtocol {

    let window: UIWindow

    fileprivate var navigationController: UINavigationController?
    fileprivate var calendarViewController: CalendarViewController?

    init(window: UIWindow) {
        self.window = window
    }

    private var mainStoryboard: UIStoryboard {
        return UIStoryboard(name: "Main", bundle: Bundle.main)
    }
}

// MARK: CoordinatorProtocol
extension MainFlowCoordinator {
    func start() {

        guard let navController = mainStoryboard.instantiateInitialViewController() as? UINavigationController else {
            assertionFailure("Error, root navigation not found")
            return
        }

        guard let viewController = navController.viewControllers.first as? CalendarViewController else {
            assertionFailure("Calendar view controller not found")
            return
        }

        let presenter = CalendarPresenter()

        let presenterDependencies = CalendarPresenter.Dependencies(
            viewController,
            CalendarService(),
            self,
            LocalNotificationsService(),
            ReminderSchedulerAssembler().makeReminderScheduler()
        )

        presenter.inject(dependencies: presenterDependencies)

        viewController.inject(dependencies: presenter)

        navigationController = navController
        calendarViewController = viewController

        window.rootViewController = navController
    }
}

// MARK: MainFlowCoordinatorProtocol
extension MainFlowCoordinator {
    func showCancelAlert(comletion: @escaping () -> Void) {
        let cancelAlert = UIAlertController(
            title: "Event cancelation",
            message: "A you sure you want to cancel this event?",
            preferredStyle: .actionSheet
        )

        let action = UIAlertAction(title: "Yes", style: .default) { (action) in
            comletion()
        }

        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        cancelAlert.addAction(action)
        cancelAlert.addAction(cancel)

        calendarViewController?.present(cancelAlert, animated: true, completion: nil)
    }

    func showCalendarEventDetailsView(for eventId: String) {

        guard let viewController = mainStoryboard.instantiateViewController(withIdentifier: "CalendarEventDetailsViewController") as? CalendarEventDetailsViewController else {
            assertionFailure("CalendarEventDetailsViewController not found")
            return
        }

        let presenter = CalendarEventDetailsPresenter()

        let presenterDependencies = CalendarEventDetailsPresenter.Dependencies(
            viewController,
            eventId,
            CalendarService()
        )

        presenter.inject(dependencies: presenterDependencies)
        viewController.inject(dependencies: presenter)

        navigationController?.pushViewController(viewController, animated: true)
    }
}

