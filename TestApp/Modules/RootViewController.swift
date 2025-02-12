//
//  RootViewController.swift
//  TestApp
//
//  Created by Никита Лужбин on 03.12.2023.
//

import Foundation
import UIKit

enum Game: CaseIterable {

    case pyatnashki
    case prizedSaper
    case battle
    case saper
    case maps
    case trapTheCat

    func title() -> String {
        switch self {
        case .pyatnashki:
            return "Пятнашки"
        
        case .prizedSaper:
            return "Сапер с призами"

        case .battle:
            return "Битва"

        case .saper:
            return "Сапер"

        case .maps:
            return "Карты"

        case .trapTheCat:
            return "Trap The Cat"
        }
    }

    func controller() -> UIViewController {
        switch self {
        case .pyatnashki:
            return PyatnashkiViewController()

        case .prizedSaper:
            return PrizedSaperViewController()

        case .battle:
            return BattleViewController()

        case .saper:
            return SaperViewController()

        case .maps:
            return MapsViewController()

        case .trapTheCat:
            return TrapCatViewController()
        }
    }
}

final class RootViewController: UIViewController {

    private let tableView = UITableView()

    private let games = Game.allCases

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Игры"

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        view.addSubview(tableView)

        tableView.autoPinEdgesToSuperviewEdges()
    }
}

extension RootViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let viewController = games[indexPath.row].controller()
        viewController.title = games[indexPath.row].title()

        navigationController?.pushViewController(
            viewController,
            animated: true
        )
    }
}

extension RootViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        games.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else {
            fatalError()
        }

        cell.textLabel?.text = games[indexPath.row].title()

        return cell
    }
}
