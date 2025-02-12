//
//  RouteSettingsViewController.swift
//  TestApp
//
//  Created by Никита Лужбин on 10.01.2025.
//

import UIKit
import CoreLocation

protocol RouteSettingsDelegate {
    func onPlacemarksSelected(_ placemarks: [CLPlacemark])
}

final class RouteSettingsViewController: UIViewController {

    // MARK: - Private Properties
    
    private let tableView = UITableView()
    private var placemarks: [CLPlacemark] = []

    // MARK: - Public Properties

    var delegate: RouteSettingsDelegate?
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        drawSelf()
    }

    // MARK: - Init

    init(placemarks: [CLPlacemark], delegate: RouteSettingsDelegate? = nil) {
        self.placemarks = placemarks
        self.delegate = delegate
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Drawnings

    private func drawSelf() {
        view.backgroundColor = .white
        
        let addBarButton = UIBarButtonItem(
            image: .init(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(addCity)
        )
        let doneBarButton = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: self,
            action: #selector(onDoneButtonDidTapped)
        )
        navigationItem.rightBarButtonItems = [doneBarButton, addBarButton]
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.dragInteractionEnabled = true
        tableView.dragDelegate = self
        tableView.isEditing = true
        
        view.addSubview(tableView)

        tableView.autoPinEdgesToSuperviewEdges()
    }

    // MARK: - Private methods

    @objc private func addCity() {
        let alertController = UIAlertController(
            title: "Add city",
            message: "Enter adress...",
            preferredStyle: .alert
        )

        alertController.addTextField { textField in
            textField.placeholder = "City adress..."
        }

        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard
                let textField = alertController.textFields?.first,
                let city = textField.text, city.isEmpty == false
            else {
                return
            }

            CLGeocoder().geocodeAddressString(city) { [weak self] placemarks, error in
                if let placemark = placemarks?.first {
                    self?.placemarks.append(placemark)
                    self?.tableView.reloadData()
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(addAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true)
    }
    
    @objc private func onDoneButtonDidTapped() {
        delegate?.onPlacemarksSelected(placemarks)
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDelegate

extension RouteSettingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView,
                   moveRowAt sourceIndexPath: IndexPath,
                   to destinationIndexPath: IndexPath) {

        let city = placemarks.remove(at: sourceIndexPath.row)
        placemarks.insert(city, at: destinationIndexPath.row)
    }
}

// MARK: - UITableViewDataSource

extension RouteSettingsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        placemarks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let placemark = placemarks[indexPath.row]
        
        let cell: UITableViewCell
        
        if let dequeueCell = tableView.dequeueReusableCell(withIdentifier: "routeCell") {
            cell = dequeueCell
        } else {
            cell = UITableViewCell(style: .default, reuseIdentifier: "routeCell")
        }

        cell.textLabel?.text = placemark.name

        return cell
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }

    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}

// MARK: - UITableViewDragDelegate

extension RouteSettingsViewController: UITableViewDragDelegate {
    
    func tableView(_ tableView: UITableView,
                   itemsForBeginning session: UIDragSession,
                   at indexPath: IndexPath) -> [UIDragItem] {
        
        let dragItem = UIDragItem(itemProvider: NSItemProvider())
        
        dragItem.localObject = placemarks[indexPath.row]
        
        return [dragItem]
    }
}
