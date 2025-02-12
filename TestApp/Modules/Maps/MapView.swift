//
//  MapView.swift
//  TestApp
//
//  Created by Никита Лужбин on 10.01.2025.
//

import MapKit
import UIKit

final class MapView: UIView {

    // MARK: - Private Properties
    
    private let mapView = MKMapView()

    private let planeAnnotation = MKPointAnnotation()
    private var routeCoordinates: [CLLocationCoordinate2D] = []
    
    private var placemarks: [CLPlacemark] = []
    
    private let kazanCoordinate = CLLocationCoordinate2D(latitude: 55.8304, longitude: 49.0661)
    private let moscowCoordinate = CLLocationCoordinate2D(latitude: 55.7558, longitude: 37.6173)
    private let patongCoordinate = CLLocationCoordinate2D(latitude: 7.902866, longitude: 98.304797)
    
    lazy var fromCoordinate = moscowCoordinate
    lazy var toCoordinate = kazanCoordinate

    private let defaultScale: Double = 300_000
    
    private var timer: Timer?

    var fraction: Double = 0.0

    // MARK: - Init

    deinit {
        print("Deinitialized")
    }

    // MARK: - Life Cycle

    // MARK: - Public Methods
    
//    func configure(with placemarks: [CLPlacemark]) {
//        drawSelf()
//
//        if let firstLocationCoordinate = placemarks.first?.location?.coordinate {
//            centerMapToFit(locations: [firstLocationCoordinate], animated: false)
//        }
//    }
    
    func configure(with placemarks: [CLPlacemark]) {
        drawSelf()
        
        let semaphore = DispatchSemaphore(value: 0)

        let initialLocations = ["Москва", "Тула", "Рязань"]
//        let initialLocations = ["Москва", "Ереван", "Рим", "Париж", "Ереван"]
//        let initialLocations = ["Москва", "Денпасар", "Moscow"]
        
        DispatchQueue.global(qos: .userInitiated).async {
            initialLocations.forEach { location in
                CLGeocoder().geocodeAddressString(location) { placemarks, error in
                    self.placemarks.append(placemarks!.first!)
                    semaphore.signal()
                }

                semaphore.wait()
            }

            DispatchQueue.main.async {
                if let firstLocationCoordinate = self.placemarks.first?.location?.coordinate {
                    self.centerMapToFit(locations: [firstLocationCoordinate], animated: false)
                }
            }
        }
    }

    // MARK: - Drawnings

    private func drawSelf() {
        mapView.delegate = self
        mapView.mapType = .standard
        
        planeAnnotation.coordinate = fromCoordinate
        mapView.addAnnotation(planeAnnotation)
        
        addSubview(mapView)
        mapView.autoPinEdgesToSuperviewEdges()
    }

    func start() throws {
        routeCoordinates = [placemarks.first!.location!.coordinate]
        
        let semaphore = DispatchSemaphore(value: 0)
        
        var pairs: [(CLPlacemark, CLPlacemark)] = []
        
        for index in 0..<placemarks.count - 1 {
            pairs.append((placemarks[index], placemarks[index + 1]))
        }
        
        DispatchQueue.global().async { [weak self] in

            pairs.forEach { pair in
                DispatchQueue.main.async { [weak self] in
                    self?.buildRoute(from: pair.0, to: pair.1, duration: 4, completion: {
                        semaphore.signal()
                    })
                }

                semaphore.wait()
            }

            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                
                self.centerMapToFit(
                    locations: self.placemarks.compactMap { $0.location?.coordinate },
                    animated: true
                )
            }
        }
    }
    
    // MARK: - Private Methods
    
    func buildRoute(
        from: CLPlacemark,
        to: CLPlacemark,
        duration: TimeInterval,
        completion: @escaping () -> Void
    ) {
            
        guard
            let fromCoordinate = from.location?.coordinate,
            let toCoordinate   =   to.location?.coordinate
        else {
            return
        }

        let finalPolyline = MKGeodesicPolyline(coordinates: [fromCoordinate, toCoordinate], count: 2)
        let points = finalPolyline.points()
        
        var previousSegment: MKPolyline?
        
        var currentCoordinateIndex = 0
        
        let step = 2
        
        var indexesWhenRotatePlane: [Int] = [0, finalPolyline.pointCount - 1]

        indexesWhenRotatePlane.append(
            contentsOf: self.getMiddle(from: 0, to: finalPolyline.pointCount - 1, depth: 3)
        )

        let tickTimeInterval = 0.07 //duration / (Double(finalPolyline.pointCount) / Double(step))

        timer = Timer.scheduledTimer(withTimeInterval: tickTimeInterval, repeats: true) { [weak self] timer in
            guard let self = self, currentCoordinateIndex <= finalPolyline.pointCount - 1 else {
                print("Timer finished")
                timer.invalidate()
                completion()
                return
            }

            let nextMapPoint = points[currentCoordinateIndex]
            
            let currentPolyline = MKGeodesicPolyline(
                coordinates: [points[0].coordinate, nextMapPoint.coordinate],
                count: 2
            )
            
            self.mapView.addOverlay(currentPolyline)

            if let previousSegment {
                self.mapView.removeOverlay(previousSegment)
            }
            
            previousSegment = currentPolyline
            
            if indexesWhenRotatePlane.contains(currentCoordinateIndex) {
                self.rotateVehicle(
                    startPoint: points[currentCoordinateIndex],
                    endPoint: points[currentCoordinateIndex + 1]
                )
            }
            
            self.setVehiclePosition(to: nextMapPoint.coordinate)
            
            currentCoordinateIndex += step
        }
    }

    private func drawPolyline() {
        
    }

    private func rotateVehicle(startPoint: MKMapPoint, endPoint: MKMapPoint) {
        let planeDirection = directionBetweenPoints(sourcePoint: startPoint, endPoint)
        
        if let planeAnnotationView = self.mapView.view(for: self.planeAnnotation) {
            DispatchQueue.main.async {
                planeAnnotationView.transform = CGAffineTransformRotate(
                    self.mapView.transform,
                    self.degreesToRadians(degrees: planeDirection)
                )
            }
        }
    }

    private func setVehiclePosition(to coordinate: CLLocationCoordinate2D) {
        planeAnnotation.coordinate = coordinate
        centerMapToFit(locations: [coordinate], animated: false)
    }

    func getMiddle(from: Int, to: Int, depth: Int = 3) -> [Int] {
        if depth == 0 { return [] }
        
        let middle = (from + to) / 2

        var array: [Int] = [middle]

        array.append(contentsOf: getMiddle(from: from, to: middle, depth: depth - 1))
        array.append(contentsOf: getMiddle(from: middle, to: to, depth: depth - 1))

        return array
    }
    
    // MARK: - Angles
    
    private func directionBetweenPoints(sourcePoint: MKMapPoint, _ destinationPoint: MKMapPoint) -> CLLocationDirection {
        let x = destinationPoint.x - sourcePoint.x
        let y = destinationPoint.y - sourcePoint.y
        
        return radiansToDegrees(radians: atan2(y, x)).truncatingRemainder(dividingBy: 360)
    }

    private func radiansToDegrees(radians: Double) -> Double {
        return radians * 180 / Double.pi
    }

    private func degreesToRadians(degrees: Double) -> Double {
        return degrees * Double.pi / 180
    }

    func centerMapToFit(locations: [CLLocationCoordinate2D], animated: Bool = true) {
        var region: MKCoordinateRegion? = nil

        defer {
            if let region = region {
                mapView.setRegion(region, animated: animated)
            }
        }
        
        guard locations.count > 1 else {
            if let firstLocation = locations.first {
                region = .init(
                    center: firstLocation,
                    latitudinalMeters: defaultScale,
                    longitudinalMeters: defaultScale
                )
                
            }
            
            return
        }
        
        let latitudes = locations.compactMap { $0.latitude }
        let longitudes = locations.compactMap { $0.longitude }

        // Ищем среднюю координату и по ней центрируем
        let middleLatitude = (latitudes.min()! + latitudes.max()!) / 2
        let middleLongitude = (longitudes.min()! + longitudes.max()!) / 2

        let leftestLatitude = latitudes.min()!
        let rightestLatitude = latitudes.max()!
        let leftestLongitude = longitudes.min()!
        let rightestLongitude = longitudes.max()!

        // Ищем 4 точки, которые вписывают в себя все локации, по дистанции делаем зум
        let a = CLLocation(latitude: leftestLatitude,
                                       longitude: middleLongitude)
        let b = CLLocation(latitude: rightestLatitude,
                                       longitude: middleLongitude)
        let c = CLLocation(latitude: middleLatitude,
                                       longitude: leftestLongitude)
        let d = CLLocation(latitude: middleLatitude,
                                       longitude: rightestLongitude)
        
        let distance = max(a.distance(from: b), c.distance(from: d))
        region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: middleLatitude,
                                           longitude: middleLongitude),
            latitudinalMeters: distance * 1.5,
            longitudinalMeters: distance * 1.5
        )
    }
}

// MARK: - MKMapViewDelegate

extension MapView: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyline = overlay as? MKPolyline else {
                return MKOverlayRenderer()
        }
        
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.lineWidth = 5.0
        renderer.alpha = 1
        renderer.strokeColor = .red
        
        return renderer
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let planeIdentifier = "Plane"
        
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: planeIdentifier)
                ?? MKAnnotationView(annotation: annotation, reuseIdentifier: planeIdentifier)
        
        annotationView.image = UIImage(systemName: "airplane")
        
        return annotationView
    }
}
