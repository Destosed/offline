//
//  PrizedSaperViewController.swift
//  TestApp
//
//  Created by Никита Лужбин on 03.12.2023.
//

import Foundation
import UIKit

struct GameField {
    var rows: [GameRow] = []
}

struct GameRow {
    let prizeCoefficient: Float
    var gameCells: [GameCell] = []
    var level: Int
}

struct GameCell {
    var isBomb: Bool
}

final class PrizedSaperViewController: UIViewController {

    private var currentRowLevel = 0

    private var gameField = GameField()

    private let gameFieldStackView = UIStackView()
    private let gameFieldView = GameFieldView()

    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        drawSelf()

        setupInitialField()
        gameFieldView.configure(with: gameField)
        drawCurrentField()
    }

    // MARK: - Actions

    @objc func didTapGameCell(_ sender: UITapGestureRecognizer) {
        
    }

    // MARK: - Private Methods

    private func drawSelf() {
        
        title = "Сапер с призами"
        view.backgroundColor = .white

        view.addSubview(gameFieldStackView)

        gameFieldStackView.autoAlignAxis(toSuperviewAxis: .horizontal)
        gameFieldStackView.autoPinEdge(toSuperviewEdge: .left)
        gameFieldStackView.autoPinEdge(toSuperviewEdge: .right, withInset: 20)
    }

    private func setupInitialField() {
        for row in 1...4 {
            var gameRow = GameRow(prizeCoefficient: 1 + Float(row) / 4, level: row)
            var cells = Array(repeating: GameCell(isBomb: false), count: 5)

            for cellIndex in 0..<row {
                cells[cellIndex].isBomb = true
            }

            cells.shuffle()

            gameRow.gameCells = cells
            gameField.rows.append(gameRow)
        }

        gameField.rows.reverse()
    }

    private func drawCurrentField() {
        gameFieldStackView.arrangedSubviews.forEach { gameFieldStackView.removeArrangedSubview($0) }

        for row in gameField.rows {
            let stackView = UIStackView()

            stackView.axis = .horizontal

            for gameCell in row.gameCells {
                let gameCellView = GameCellView()

                gameCellView.isBomb = gameCell.isBomb
                gameCellView.layer.borderColor = UIColor.black.cgColor
                gameCellView.layer.borderWidth = 1
                gameCellView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                         action: #selector(didTapGameCell(_:))))

                stackView.addArrangedSubview(gameCellView)

                gameCellView.autoSetDimensions(to: .init(width: view.frame.width / 6, height: view.frame.width / 6))
            }

            let coefficientLabel = UILabel()
            coefficientLabel.textColor = .black
            coefficientLabel.textAlignment = .center
            coefficientLabel.text = String(row.prizeCoefficient)

            stackView.insertArrangedSubview(coefficientLabel, at: 0)

            gameFieldStackView.addArrangedSubview(stackView)
        }
    }
}

final class GameFieldView: UIView {

    // MARK: - Properties

    private let stackView = UIStackView()

    // MARK: - Life Cycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        drawSelf()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Drawnings

    private func drawSelf() {
        stackView.axis = .vertical
        stackView.spacing = 5
    }
    
    // MARK: - Actions

    // MARK: - Public Methods

    func configure(with gameField: GameField) {
        for row in gameField.rows {
            let gameRowView = GameRowView()
            gameRowView.configure(for: row)
            stackView.addArrangedSubview(gameRowView)
        }
    }

    // MARK: - Instance Methods
}

final class GameRowView: UIView {

    // MARK: - Properties

    private let level = 0
    private let coefficientLabel = UILabel()
    private let stackView = UIStackView()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        drawSelf()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Drawnings

    private func drawSelf() {
        stackView.axis = .horizontal
        
        coefficientLabel.textColor = .black
        coefficientLabel.textAlignment = .center

        addSubview(stackView)
        stackView.addArrangedSubview(coefficientLabel)
    }

    // MARK: - Public Methods

    func configure(for row: GameRow) {
        coefficientLabel.text = String(row.prizeCoefficient)

        for gameCell in row.gameCells {
            let gameCellView = GameCellView()

            gameCellView.isBomb = gameCell.isBomb
            gameCellView.autoSetDimensions(to: .init(width: 100, height: 100))

            stackView.addArrangedSubview(gameCellView)
        }
    }

    func setDisabled(to isDisabled: Bool) {
        stackView.isUserInteractionEnabled = isDisabled
    }
}

final class GameCellView: UIView {

    // MARK: - Properties

    var isBomb = false

    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Actions

    @objc private func didTap() {
        UIView.transition(with: self, duration: 0.25, options: .transitionFlipFromLeft) {
            self.backgroundColor = self.isBomb ? .red : .green
        }
    }
}
