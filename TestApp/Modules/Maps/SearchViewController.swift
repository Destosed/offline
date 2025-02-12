//
//  SearchViewController.swift
//  TestApp
//
//  Created by Никита Лужбин on 09.01.2025.
//

import UIKit
import CoreLocation

protocol SearchViewControllerDelegate {
    func didSelectCoordinate(coordinate: CLLocationCoordinate2D)
}

final class SearchViewController: UIViewController {
    
    // MARK: - Properties
    
    var delegate: SearchViewControllerDelegate?
    
    private let textField = UITextField()
    private let tableView = UITableView()

    private var placemarks = [CLPlacemark]()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .cyan

        textField.placeholder = "Search..."
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldValueChanged), for: .editingChanged)

        tableView.delegate = self
        tableView.dataSource = self

        view.addSubview(textField)
        view.addSubview(tableView)

        textField.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        textField.autoSetDimension(.height, toSize: 50)
        tableView.autoPinEdge(.top, to: .bottom, of: textField)
        tableView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
    }

    // MARK: - Private Methods

    private func search(text: String) {
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(text) { placemarks, error in
            self.placemarks = placemarks ?? []

            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    @objc private func textFieldValueChanged() {
        search(text: textField.text ?? "")
    }
}

// MARK: - UITextFieldDelegate

extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }
}

// MARK: - UITableViewDataSource

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        placemarks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        
        cell.textLabel?.text = placemarks[indexPath.row].name
        cell.textLabel?.textColor = .black
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension SearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let coordinate = placemarks[indexPath.row].location?.coordinate {
            delegate?.didSelectCoordinate(coordinate: coordinate)
            self.dismiss(animated: true)
        }
    }
}
