//
//  AppDelegate.swift
//  HackyCalendar
//
//  Created by Aleksandr Pavliuk on 5/21/19.
//  Copyright © 2019 aporganization. All rights reserved.
//

import UIKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var appCoordinator: ApplicationCoordinatorProtocol?
    private var localNotificationsDelegateHandler: LocalNotificationsDelegateHandler?
    private let reminderScheduler: ReminderSchedulerProtocol = {
        return ReminderSchedulerAssembler().makeReminderScheduler()
    }()


    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        if let window = setupWindow() {
            appCoordinator = ApplicationCoordinator(window: window)
            appCoordinator?.start()

            localNotificationsDelegateHandler = LocalNotificationsDelegateHandler()
            localNotificationsDelegateHandler?.inject(dependencies: (appCoordinator))
        }

        UIApplication.shared.setMinimumBackgroundFetchInterval(60)

        return true
    }

    func application(_ application: UIApplication,
                     performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        reminderScheduler.reScheduleReminders()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        reminderScheduler.reScheduleReminders()
    }

    private func setupWindow() -> UIWindow? {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
        window?.makeKeyAndVisible()

        return window
    }

}

