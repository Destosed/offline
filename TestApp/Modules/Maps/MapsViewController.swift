import UIKit
import MapKit

final class MapsViewController: UIViewController {

    // MARK: - Properties
    
    private var placemarks: [CLPlacemark] = []
    
    private let mapView = MapView()
    private let actionButton = UIButton()
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        drawSelf()
        mapView.configure(with: [])
    }

    @objc private func drawSelf() {
        let barButton = UIBarButtonItem(image: .init(systemName: "gear"),
                                        style: .plain,
                                        target: self,
                                        action: #selector(onSearchButtonDidTapped))
        navigationItem.rightBarButtonItem = barButton

        actionButton.setBackgroundImage(.init(systemName: "play.square.fill"), for: .normal)
        actionButton.tintColor = .black
        actionButton.addTarget(self, action: #selector(onActionButtonDidTapped), for: .touchUpInside)

        view.addSubview(mapView)
        view.addSubview(actionButton)

        mapView.autoPinEdgesToSuperviewEdges()
        actionButton.autoSetDimensions(to: .init(width: 100, height: 100))
        actionButton.autoAlignAxis(toSuperviewAxis: .vertical)
        actionButton.autoPinEdge(toSuperviewEdge: .bottom, withInset: 40)
    }

    @objc private func onSearchButtonDidTapped() {
        let controller = RouteSettingsViewController(placemarks: placemarks, delegate: self)

        self.navigationController?.pushViewController(controller, animated: true)
    }

    @objc func onActionButtonDidTapped() {
        try? mapView.start()
    }
}

// MARK: - RouteSettingsDelegate

extension MapsViewController: RouteSettingsDelegate {
    
    func onPlacemarksSelected(_ placemarks: [CLPlacemark]) {
        self.placemarks = placemarks
        mapView.configure(with: placemarks)
    }
}
