//
//  TrapCatViewController.swift
//  TestApp
//
//  Created by Никита Лужбин on 12.02.2025.
//

import UIKit

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

extension Collection {
    // Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

final class HexagonalGridView: UIView {
    
    private var itemsPerRow = 5
    private var viewsAmount = 144

    override func draw(_ rect: CGRect) {
        guard viewsAmount != 0 else { return }

        subviews.forEach { $0.removeFromSuperview() }
        
        let spacing: CGFloat = 30
        let itemWidth = rect.width / 5 - spacing
        let itemHeight = itemWidth

        var rows: [[Int]] = []

        var currentItem = 0
        var currentRow = 0

        while currentItem <= viewsAmount - 1 {
            let amountOfItemsToFill = min(currentRow % 2 == 0 ? 5 : 4, viewsAmount - currentItem)

            let packedRow = Array(currentItem..<currentItem + amountOfItemsToFill)
            rows.append(packedRow)
            currentItem += amountOfItemsToFill

            currentRow += 1
        }

        
        for (rowIndex, row) in rows.enumerated() {
            let isSmallRow = rows[safe: rowIndex - 1]?.count == 5
            
            for (itemIndex, _) in row.enumerated() {
                let leftRowOffset = isSmallRow ? (itemWidth / 2 + spacing / 2) : 0

                let view = HexagonalView(x: itemIndex, y: rowIndex)
                view.frame = .init(
                    x: spacing / 2 + leftRowOffset + CGFloat(itemIndex) * (itemWidth + spacing),
                    y: CGFloat(rowIndex) * (itemHeight - spacing + 5),
                    width: itemWidth,
                    height: itemHeight
                )

                addSubview(view)
            }
        }
    }
    
    func addHexagonalView() {
        viewsAmount += 1
        setNeedsDisplay()
    }
}

final class HexagonalView: UIView {

    private let x: Int
    private let y: Int
    
    private let textLabel = UILabel()
    
    init(x: Int, y: Int) {
        self.x = x
        self.y = y

        super.init(frame: .zero)
        
        textLabel.textAlignment = .center
        textLabel.textColor = .white
        textLabel.text = "\(String(x))-\(String(y))"
        textLabel.sizeToFit()

        self.addSubview(textLabel)

        textLabel.autoPinEdgesToSuperviewEdges()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let sideLength = min(rect.width / 2, rect.height / sqrt(3)) // Ensuring proportions
        let centerX = rect.midX
        let centerY = rect.midY

        let bezierPath = UIBezierPath()
        bezierPath.lineWidth = 1

        // Calculate Hexagon Points
        for i in 0..<6 {
            let angle = CGFloat.pi / 3 * CGFloat(i) // 60-degree increments
            let x = centerX + sideLength * cos(angle)
            let y = centerY + sideLength * sin(angle)

            if i == 0 {
                bezierPath.move(to: CGPoint(x: x, y: y))
            } else {
                bezierPath.addLine(to: CGPoint(x: x, y: y))
            }
        }
        bezierPath.close()

        UIColor.black.setFill()
        bezierPath.fill()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundColor = .clear
    }
}


final class TrapCatViewController: UIViewController {
    
    var hexagonalGridView = HexagonalGridView()
    var addButton = UIButton()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        addButton.setTitle("Add", for: .normal)
        addButton.setTitleColor(.black, for: .normal)
        addButton.addTarget(self, action: #selector(addButtonDidTap), for: .touchUpInside)
        
        view.addSubview(hexagonalGridView)
        view.addSubview(addButton)
        

        hexagonalGridView.translatesAutoresizingMaskIntoConstraints = false
        addButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            hexagonalGridView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            hexagonalGridView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hexagonalGridView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hexagonalGridView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50)
        ])
        
//        hexagonalView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            hexagonalView.widthAnchor.constraint(equalToConstant: 100),
//            hexagonalView.heightAnchor.constraint(equalToConstant: 100),
//            hexagonalView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            hexagonalView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//        ])
    }

    @objc private func addButtonDidTap() {
        hexagonalGridView.addHexagonalView()
    }
}
