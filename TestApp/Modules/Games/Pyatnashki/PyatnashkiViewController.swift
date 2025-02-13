//
//  PyatnashkiController.swift
//  TestApp
//
//  Created by Никита Лужбин on 26.05.2023.
//

import UIKit
import Foundation
import PureLayout

struct PieceModel {
    var imagePiece: UIImage
    var positionIndex: Int
    var isEmptyPiece: Bool
}

final class PyatnashkiViewController: UIViewController {

    // MARK: - Properties
    
    private var imagePieces: [PieceModel] = []
    private var emptyPieceTag = 3
    private var isSolved = false
    
    private var barButton: UIBarButtonItem?
    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()

        flowLayout.itemSize = .init(width: view.frame.width / 4, height: view.frame.width / 4)
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0

        return UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
    }()

    // MARK: - Life Cycle

    override func viewDidLoad() {
        title = "Пятнашки"

        view.backgroundColor = .white

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(PieceCell.self, forCellWithReuseIdentifier: PieceCell.reuseIdentifier)

        barButton = .init(
            image: UIImage(systemName: "flag"),
            style: .plain,
            target: self,
            action: #selector(onButtonDidTapped)
        )
        navigationItem.rightBarButtonItem = barButton

        view.addSubview(collectionView)

        collectionView.autoAlignAxis(toSuperviewAxis: .horizontal)
        collectionView.autoPinEdge(toSuperviewEdge: .left)
        collectionView.autoPinEdge(toSuperviewEdge: .right)
        collectionView.autoSetDimension(.height, toSize: view.frame.width)

        setup()
    }

    // MARK: - Actions

    @objc private func onButtonDidTapped() {
        if !isSolved {
            imagePieces.sort(by: { $0.positionIndex < $1.positionIndex })
            barButton?.image = UIImage(systemName: "shuffle")
        } else {
            imagePieces.shuffle()
            barButton?.image = UIImage(systemName: "flag")
        }

        emptyPieceTag = imagePieces.firstIndex(where: { $0.isEmptyPiece }) ?? 0
        isSolved.toggle()

        collectionView.reloadData()
    }

    // MARK: - Public Methods

    func setup() {
        guard let image = UIImage(named: "image") else {
            return
        }

        let width = image.size.width
        let height = image.size.height

        let widthStep = width / 4
        let heightStep = height / 4

        var images: [UIImage] = []

        //3x3

        for column in 0...3 {
            for row in 0...3 {
                let sourceCGImage = image.cgImage!
                let croppedCGImage = sourceCGImage.cropping(
                    to: .init(
                        x: CGFloat(row) * widthStep,
                        y: CGFloat(column) * heightStep,
                        width: widthStep,
                        height: heightStep
                    )
                )!

                images.append(UIImage(cgImage: croppedCGImage))
            }
        }

        for i in 0..<4 * 4 {
            imagePieces.append(.init(imagePiece: images[i], positionIndex: i, isEmptyPiece: i == emptyPieceTag))
        }

        imagePieces.shuffle()

        emptyPieceTag = imagePieces.firstIndex(where: { $0.isEmptyPiece }) ?? 0

        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource

extension PyatnashkiViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        imagePieces.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PieceCell.reuseIdentifier,
                for: indexPath
            ) as? PieceCell
        else {
            fatalError()
        }

        cell.configure(for: imagePieces[indexPath.row])

        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension PyatnashkiViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.row != emptyPieceTag else {
            return
        }

        switch indexPath.row   {
        case emptyPieceTag - 1:
            let temp = imagePieces[indexPath.row]
            imagePieces[indexPath.row] = imagePieces[indexPath.row + 1]
            imagePieces[indexPath.row + 1] = temp
            emptyPieceTag = indexPath.row

        case emptyPieceTag + 1:
            let temp = imagePieces[indexPath.row]
            imagePieces[indexPath.row] = imagePieces[indexPath.row - 1]
            imagePieces[indexPath.row - 1] = temp
            emptyPieceTag = indexPath.row

        case emptyPieceTag + 4:
            let temp = imagePieces[indexPath.row]
            imagePieces[indexPath.row] = imagePieces[indexPath.row - 4]
            imagePieces[indexPath.row - 4] = temp
            emptyPieceTag = indexPath.row

        case emptyPieceTag - 4:
            let temp = imagePieces[indexPath.row]
            imagePieces[indexPath.row] = imagePieces[indexPath.row + 4]
            imagePieces[indexPath.row + 4] = temp
            emptyPieceTag = indexPath.row

        default:
            break
        }

        collectionView.reloadData()
    }
}

final class PieceCell: UICollectionViewCell {

    // MARK: - Type Properties
    
    static let reuseIdentifier = "PieceCell"

    // MARK: - Private Properties

    private let imageView = UIImageView()

    // MARK: - Public Properties

    func configure(for piece: PieceModel) {
        guard !piece.isEmptyPiece else {
            backgroundColor = .black
            imageView.image = nil
            return
        }

        imageView.image = piece.imagePiece

        addSubview(imageView)

        imageView.autoPinEdgesToSuperviewEdges()
    }
}


