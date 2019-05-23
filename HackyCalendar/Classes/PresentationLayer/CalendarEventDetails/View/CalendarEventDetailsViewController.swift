//
//  CalendarEventDetailsViewController.swift
//  HackyCalendar
//
//  Created by Aleksandr Pavliuk on 5/23/19.
//  Copyright © 2019 aporganization. All rights reserved.
//

import UIKit

protocol CalendarEventDetailsViewControllerProtocol: class {
    func update(with model: CalendarEventDetailsViewModel)
}

final class CalendarEventDetailsViewController: UIViewController, CalendarEventDetailsViewControllerProtocol, SetInjectable {
    private var presenter: CalendarEventDetailsPresenterProtocol?

    @IBOutlet private  weak var titleLabel: UILabel!
    @IBOutlet private weak var notesLabel: UILabel!
    @IBOutlet private weak var alarmLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewHasBeenLoaded()
    }
}

// MARK: SetInjectable
extension CalendarEventDetailsViewController {
    func inject(dependencies: CalendarEventDetailsViewController.Dependencies) {
        presenter = dependencies
    }

    typealias Dependencies = CalendarEventDetailsPresenterProtocol
}


// MARK: CalendarEventDetailsViewControllerProtocol
extension CalendarEventDetailsViewController {
    func update(with model: CalendarEventDetailsViewModel) {
        titleLabel.text = model.title
        notesLabel.text = model.notes
        alarmLabel.text = model.alarmNote
    }
}
