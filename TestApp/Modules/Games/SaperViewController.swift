//
//  SaperViewController.swift
//  TestApp
//
//  Created by Никита Лужбин on 17.11.2024.
//

import UIKit

struct Coordinate: CustomStringConvertible, Equatable {
    let x: Int
    let y: Int

    var description: String { "[\(x) : \(y)]" }
}

final class SaperViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private var itemViews: [ItemView] = []
    private var minesCoordinates: [Coordinate] = []

    private let minesCount = 10
    private let fieldDimension          : CGFloat = 10
    private let gameFieldSpacing        : CGFloat = 10
    private let itemVerticalSpacing     : CGFloat = 2
    private let itemHorizontalSpacing   : CGFloat = 2
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        drawSelf()
    }

    // MARK: - Drawnings
    
    private func drawSelf() {
        view.backgroundColor = .white

        setupBoard()
    }

    // MARK: - Private Methods
    
    private func getNeibors(for coordinate: Coordinate, dimension: Int) -> [Coordinate] {
        var answer: [Coordinate] = []
        
        for ys in [-1, 0, 1] {
            for xs in [-1, 0, 1] {
                if ys == 0 && xs == 0 { continue }

                answer.append(.init(x: coordinate.x + xs, y: coordinate.y + ys))
            }
        }

        answer.removeAll(where: { $0.x < 0 || $0.y < 0  || $0.x > dimension || $0.y > dimension})

        return answer
    }
    
    private func generateMinesCoordinates() {
        while minesCoordinates.count != minesCount {
            let randomX = Int.random(in: 0..<Int(fieldDimension))
            let randomY = Int.random(in: 0..<Int(fieldDimension))
            let randomCoordinate = Coordinate(x: randomX, y: randomY)

            if !minesCoordinates.contains(randomCoordinate) {
                minesCoordinates.append(randomCoordinate)
            }
        }
    }

    private func generateItemViews() {

        let gamefieldWidth = view.frame.width - gameFieldSpacing * 2
        let gamefieldHeight = gamefieldWidth

        let gamefieldLeftCornerX = gameFieldSpacing
        let gamefieldLeftCornerY = view.frame.maxY / 2 - gamefieldHeight / 2

        let spacing = 2.0
        let cellWidth = gamefieldWidth / fieldDimension - 2 * spacing
        let cellHeight = gamefieldHeight / fieldDimension - 2 * spacing
        
        for j in 0..<Int(fieldDimension) {
            for i in 0..<Int(fieldDimension) {
                let origin: CGPoint = .init(
                    x: gamefieldLeftCornerX + Double(i) * (cellWidth + 2 * spacing),
                    y: gamefieldLeftCornerY + Double(j) * (cellHeight + 2 * spacing)
                )
                let size: CGSize = .init(width: cellWidth, height: cellHeight)
                
                let isMine = minesCoordinates.contains(.init(x: i, y: j))

                var milesAround = 0
                for neibor in getNeibors(for: .init(x: i, y: j), dimension: Int(fieldDimension)) {
                    for mine in minesCoordinates {
                        if neibor == mine { milesAround += 1 }
                    }
                }

                let saperFieldModel = ItemView.Model(
                    isOpened: false,
                    value: milesAround,
                    isMine: isMine,
                    isMarked: false,
                    coordinate: .init(x: i, y: j),
                    delegate: self
                )
                let saperFieldview = ItemView(frame: .init(origin: origin, size: size),
                                              model: saperFieldModel)
                
                view.addSubview(saperFieldview)
                itemViews.append(saperFieldview)
            }
        }
    }

    private func showAlert(isLost: Bool) {
        let alertController = UIAlertController(
            title: isLost ? "Поражение" : "Победа!",
            message: "Попробуем еще раз?",
            preferredStyle: .alert
        )

        let okAction = UIAlertAction(title: "Да", style: .default) { _ in self.setupBoard() }

        let noAction = UIAlertAction(title: "Нет", style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
        }

        alertController.addAction(okAction)
        alertController.addAction(noAction)

        present(alertController, animated: true)
    }

    private func setupBoard() {
        UIView.animate(withDuration: 0.25) {
            self.itemViews.forEach { $0.removeFromSuperview() }
            self.itemViews.removeAll()
            self.minesCoordinates.removeAll()

            self.generateMinesCoordinates()
            self.generateItemViews()
        }
    }
}

// MARK: - ItemViewDelegate

extension SaperViewController: ItemViewDelegate {
    
    func didTap(coordinate: Coordinate) {
        guard
            let tappedView = itemViews.first(where: { $0.model.coordinate == coordinate }),
            !minesCoordinates.contains(coordinate)
        else { showAlert(isLost: true) ; return }

        tappedView.flip()

        print("Tap on \(coordinate) with value: \(tappedView.model.value)")
        if tappedView.model.value == 0 {
            getNeibors(for: coordinate, dimension: 10)
                .forEach { neiborCoordinate in
                    if let neiborView = itemViews
                        .first(where: { $0.model.coordinate == neiborCoordinate }), !neiborView.model.isOpened {
                        self.didTap(coordinate: neiborCoordinate)
                    }
                }
        }

        for itemView in itemViews {
            if !itemView.model.isOpened { return }
        }

        showAlert(isLost: false)
    }

    func didLongTap(coordinate: Coordinate) {
        guard
            let tappedView = itemViews.first(where: { $0.model.coordinate == coordinate })
        else {
            return
        }

        tappedView.mark()
    }
}

protocol ItemViewDelegate {
    func didTap(coordinate: Coordinate)
    func didLongTap(coordinate: Coordinate)
}

final class ItemView: UIView {
    
    struct Model {
        var isOpened: Bool
        var value: Int
        var isMine: Bool
        var isMarked: Bool
        var coordinate: Coordinate
        var delegate: ItemViewDelegate?
    }

    private let textLabel = UILabel()
    private(set) var model: Model

    init(frame: CGRect, model: Model) {
        self.model = model
        super.init(frame: frame)
        drawSelf()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func drawSelf() {
        isUserInteractionEnabled = true

        layer.borderWidth = 1
        layer.borderColor = UIColor.black.cgColor

        backgroundColor = !model.isOpened ? .black : model.isMine ? .red : .white

        textLabel.textAlignment = .center
        textLabel.textColor = .black
        textLabel.text = model.isOpened ? (model.isMine || model.value == 0) ? "" : String(model.value) : ""

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapped))
        addGestureRecognizer(tapGesture)
        
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(didLongTapped(gesture:)))
        longTapGesture.delaysTouchesEnded = true
        addGestureRecognizer(longTapGesture)
        
        addSubview(textLabel)

        textLabel.autoPinEdgesToSuperviewEdges()
    }

    func flip() {
        self.model.isOpened = true

        UIView.animate(withDuration: 0.25) {
            self.backgroundColor = self.model.isMine ? .red : .white
            self.textLabel.text = (self.model.isMine || self.model.value == 0) ? "" : String(self.model.value)
        }
    }

    func mark() {
        model.isMarked.toggle()

        UIView.animate(withDuration: 0.25) {
            self.backgroundColor = self.model.isMarked ? .orange : .black
        }
    }

    @objc private func didTapped() {
        model.delegate?.didTap(coordinate: model.coordinate)
    }

    @objc private func didLongTapped(gesture:UIGestureRecognizer) {
        if gesture.state == .ended {
            model.delegate?.didLongTap(coordinate: model.coordinate)
        }
    }
}
