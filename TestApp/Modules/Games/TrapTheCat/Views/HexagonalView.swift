//
//  HexagonalViewDelegate.swift
//  TestApp
//
//  Created by Никита Лужбин on 13.02.2025.
//

import UIKit

protocol HexagonalViewDelegate {
    func didTap(at coord: Coord)
}

final class HexagonalView: UIView {

    // MARK: - Nested Types
    
    enum State {
        case cat, blocked, empty
    }
    
    // MARK: - Public Properties
    
    let coord: Coord
    
    // MARK: - Private Properties
    
    private(set) var isBlocked: Bool = false
    private(set) var isCat: Bool = false
    
    private var delegate: HexagonalViewDelegate?

    private var fillColor = UIColor.gray
    private let textLabel = UILabel()

    // MARK: - Init
    
    init(coord: Coord, delegate: HexagonalViewDelegate?) {
        self.coord = coord
        self.delegate = delegate

        super.init(frame: .zero)
        
        textLabel.textAlignment = .center
        textLabel.textColor = .white
        textLabel.sizeToFit()
//        textLabel.text = "\(String(coord.x))-\(String(coord.y))"

        self.addSubview(textLabel)
        self.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(didTapSelf))
        )

        textLabel.autoPinEdgesToSuperviewEdges()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIView
    
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

        fillColor.setFill()
        bezierPath.fill()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundColor = .clear
    }

    func setState(to state: State) {
        switch state {
        case .cat:
            fillColor = .yellow
            isCat = true
            
        case .blocked:
            fillColor = .black
            isBlocked = true
            isCat = false
            
        case .empty:
            fillColor = .gray
            isBlocked = false
            isCat = false
        }

        setNeedsDisplay()
    }
    
    @objc func didTapSelf() {
        delegate?.didTap(at: coord)
    }
}
