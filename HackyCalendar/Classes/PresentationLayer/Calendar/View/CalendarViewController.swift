//
//  CalendarViewController.swift
//  HackyCalendar
//
//  Created by Aleksandr Pavliuk on 5/21/19.
//  Copyright © 2019 aporganization. All rights reserved.
//

import UIKit

struct CalendarCellModel {
    let title: String
    let notes: String?
    let attendeesURLs: [URL]?
    let eventIdentifier: String
    let isAlarmExist: Bool
}

protocol CalendarViewControllerProtocol: class {
    func reloadTable(with cellModels: [CalendarCellModel])
}

final class CalendarViewController: UIViewController, CalendarViewControllerProtocol, SetInjectable,
UITableViewDelegate, UITableViewDataSource {
    @IBOutlet private weak var tableView: UITableView!

    private var presenter: CalendarPresenterProtocol?
    private var data: [CalendarCellModel] = []

    private struct Constants {
        static let tableViewCellReuseIdentifier = "TableViewCellId"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewHasBeenLoad()
    }
}

// MARK: SetInjectable
extension CalendarViewController {
    typealias Dependencies = (CalendarPresenterProtocol)

    func inject(dependencies: Dependencies) {
        (presenter) = dependencies
    }
}

// MARK: CalendarViewControllerProtocol
extension CalendarViewController {
    func reloadTable(with cellModels: [CalendarCellModel]) {
        DispatchQueue.main.async {
            self.data = cellModels
            self.tableView.reloadData()
        }
    }
}

// MARK: UITableViewDelegate, UITableViewDataSource
extension CalendarViewController {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.tableViewCellReuseIdentifier, for: indexPath)
        guard let model = data[safe: indexPath.row] else {
            assertionFailure("Index is wrong")
            return cell
        }

        cell.textLabel?.text = model.title
        cell.detailTextLabel?.text = model.isAlarmExist ? "Alarm" : "No Alarms"
        cell.detailTextLabel?.textColor = model.isAlarmExist ? .red : .black

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let model = data[safe: indexPath.row] else {
            assertionFailure("Index is wrong")
            return
        }
        presenter?.cellWasSelected(with: model)
    }
}

