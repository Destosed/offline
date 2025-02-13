//
//  TrapCatViewController.swift
//  TestApp
//
//  Created by Никита Лужбин on 12.02.2025.
//

import UIKit

final class TrapCatViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private var hexagonalGridView = HexagonalGridView()
    private var addButton = UIButton()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        drawSelf()
    }

    // MARK: - Drawnings

    private func drawSelf() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(hexagonalGridView)

        hexagonalGridView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            hexagonalGridView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            hexagonalGridView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hexagonalGridView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hexagonalGridView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
}




