//
//  HexagonalGridView.swift
//  TestApp
//
//  Created by Никита Лужбин on 13.02.2025.
//

import UIKit

final class HexagonalGridView: UIView {

    // MARK: - Private Properties
    
    private var defaultCatCoord = Coord(x: 2, y: 6)
    private var views: [HexagonalView] = []

    // MARK: - UIView
    
    override func draw(_ rect: CGRect) {

        for _ in 0..<views.count {
            let hexagonalViewToRemove = views.popLast()
            hexagonalViewToRemove?.removeFromSuperview()
        }
        
        let itemsPerRow = 6
        let spacing: CGFloat = 30
        let itemWidth = rect.width / CGFloat(itemsPerRow) - spacing
        let itemHeight = itemWidth

        var randomWalls: Set<Coord> = []
        for _ in 0..<15 {
            randomWalls.insert(.init(x: Int.random(in: 0..<itemsPerRow), y: Int.random(in: 0..<34)))
        }

        for j in 0..<34 {
            for i in 0..<itemsPerRow {
                let coord = Coord(x: i, y: j)
                
                let view = HexagonalView(coord: coord, delegate: self)

                view.frame = .init(
                    x: (j % 2 == 0 ? 34 : 0) + CGFloat(i) * (itemWidth + spacing),
                    y: CGFloat(j) * (itemHeight - 15),
                    width: itemWidth,
                    height: itemHeight
                )

                view.setState(
                    to: coord == defaultCatCoord ? .cat : randomWalls.contains(coord) ? .blocked : .empty
                )
                
                addSubview(view)
                
                views.append(view)
            }
        }
    }

    // MARK: - Public Methods

    func clear() {
        views.forEach { $0.setState(to: .blocked) }
    }

    // MARK: - Private Methods

    func getNeibors(for coord: Coord) -> [Coord] {
        let parentsDelta: [Coord] = coord.y % 2 == 0 ? [
            .init(x: 0, y: -1), .init(x: 0, y: 2), .init(x: 0, y: -2),
            .init(x: 1, y: -1), .init(x: 0, y: 1), .init(x: 1, y: 1)
        ] : [
            .init(x: -1, y: -1), .init(x: 0, y: -1), .init(x: 0, y: 2),
            .init(x: 0, y: -2), .init(x: -1, y: 1), .init(x: 0, y: 1)
        ]

        return parentsDelta.map { coord + $0 }
    }

    func getView(at coord: Coord) -> HexagonalView? {
        if let view = self.views.first(where: { $0.coord == coord }) {
            return view
        }

        return nil
    }
}

extension HexagonalGridView: HexagonalViewDelegate {
    
    func didTap(at coord: Coord) {
        if let view = getView(at: coord), !view.isCat {
            view.setState(to: .blocked)
        }

        let catView = views.first(where: { $0.isCat })!
        
        var nextCatViewOptions = getNeibors(for: catView.coord)
            .compactMap { self.getView(at: $0) }

        if nextCatViewOptions.count < 6 {
            print("Loss")
            catView.setState(to: .empty)
            return
        }
        
        nextCatViewOptions = nextCatViewOptions
            .filter({ !$0.isBlocked && !$0.isCat })
        
        if let nextCatView = nextCatViewOptions.randomElement() {
            catView.setState(to: .empty)
            nextCatView.setState(to: .cat)
            defaultCatCoord = nextCatView.coord
        } else {
            print("WIN")
        }
    }
}
