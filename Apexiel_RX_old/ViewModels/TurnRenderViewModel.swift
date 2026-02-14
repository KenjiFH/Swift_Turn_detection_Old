//
//  TurnDataViewModel.swift
//  Apexiel Proj1
//
//  Created by Kenji Fahselt on 7/13/25.
//


import SwiftUI
import MapKit
//viewmodel for rendering turns on mapkit
struct TurnMapView: View {
    let turn: TurnTelemetry
    
    @State private var region: MKCoordinateRegion
    
    init(turn: TurnTelemetry) {
        self.turn = turn
        _region = State(initialValue: Self.regionThatFits(turn.gpsPath))
    }
    
    var body: some View {
        Map(coordinateRegion: $region, annotationItems: annotations) { point in
            MapMarker(coordinate: point.coordinate, tint: point.color)
        }
        .overlay(
            TurnPolylineOverlay(coordinates: turn.gpsPath)
        )
    }

    var annotations: [MapPoint] {
        [
            MapPoint(id: "start", coordinate: turn.gpsPath.first!, color: .green),
            MapPoint(id: "end", coordinate: turn.gpsPath.last!, color: .red)
        ]
    }

    static func regionThatFits(_ coordinates: [CLLocationCoordinate2D]) -> MKCoordinateRegion {
        guard let first = coordinates.first else {
            return MKCoordinateRegion()
        }

        var minLat = first.latitude
        var maxLat = first.latitude
        var minLon = first.longitude
        var maxLon = first.longitude

        for coord in coordinates {
            minLat = min(minLat, coord.latitude)
            maxLat = max(maxLat, coord.latitude)
            minLon = min(minLon, coord.longitude)
            maxLon = max(maxLon, coord.longitude)
        }

        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )

        let span = MKCoordinateSpan(
            latitudeDelta: max(0.001, (maxLat - minLat) * 1.5),
            longitudeDelta: max(0.001, (maxLon - minLon) * 1.5)
        )

        return MKCoordinateRegion(center: center, span: span)
    }
}


// Simple identifiable model for map points
struct MapPoint: Identifiable {
    let id: String
    let coordinate: CLLocationCoordinate2D
    let color: Color
}




struct TurnPolylineOverlay: UIViewRepresentable {
    let coordinates: [CLLocationCoordinate2D]

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator

        // Add polyline
        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        mapView.addOverlay(polyline)

        // Add start and end annotations
        if let start = coordinates.first {
            let startAnnotation = MKPointAnnotation()
            startAnnotation.coordinate = start
            startAnnotation.title = "Start"
            mapView.addAnnotation(startAnnotation)
        }

        if let end = coordinates.last {
            let endAnnotation = MKPointAnnotation()
            endAnnotation.coordinate = end
            endAnnotation.title = "End"
            mapView.addAnnotation(endAnnotation)
        }
        
        // Add midpoint annotation
        if coordinates.count >= 3 {
            let midIndex = coordinates.count / 2
            let midAnnotation = MKPointAnnotation()
            midAnnotation.coordinate = coordinates[midIndex]
            midAnnotation.title = "Mid"
            mapView.addAnnotation(midAnnotation)
        }

       


        // Zoom to polyline
        mapView.setVisibleMapRect(polyline.boundingMapRect,
                                  edgePadding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20),
                                  animated: false)

        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(overlay: polyline)
                renderer.strokeColor = UIColor.systemBlue
                renderer.lineWidth = 3
                return renderer
            }
            return MKOverlayRenderer()
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            let identifier = "marker"

            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView

            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
            } else {
                annotationView?.annotation = annotation
            }

            if annotation.title == "Start" {
                annotationView?.markerTintColor = .green
            } else if annotation.title == "End" {
                annotationView?.markerTintColor = .red
            }

            return annotationView
        }

    }
}



//for map overview of all turns
struct OverviewTurnMapView: View {
    let turns: [TurnTelemetry]

    @State private var region: MKCoordinateRegion = MKCoordinateRegion()

    var body: some View {
        Map(coordinateRegion: $region, annotationItems: allAnnotations) { point in
            MapMarker(coordinate: point.coordinate, tint: point.color)
        }
        .onAppear {
            region = regionThatFitsAll(turns)
        }
        .overlay(
            AllTurnPolylineOverlay(turns: turns)
        )
    }

    var allAnnotations: [MapPoint] {
        turns.flatMap { turn in
            [
                MapPoint(id: "\(turn.id)-start", coordinate: turn.gpsPath.first!, color: .green),
                MapPoint(id: "\(turn.id)-end", coordinate: turn.gpsPath.last!, color: .red)
            ]
        }
    }

    func regionThatFitsAll(_ turns: [TurnTelemetry]) -> MKCoordinateRegion {
        guard let first = turns.first?.gpsPath.first else {
            return MKCoordinateRegion()
        }

        var minLat = first.latitude
        var maxLat = first.latitude
        var minLon = first.longitude
        var maxLon = first.longitude

        for turn in turns {
            for coord in turn.gpsPath {
                minLat = min(minLat, coord.latitude)
                maxLat = max(maxLat, coord.latitude)
                minLon = min(minLon, coord.longitude)
                maxLon = max(maxLon, coord.longitude)
            }
        }

        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )

        let span = MKCoordinateSpan(
            latitudeDelta: max(0.001, (maxLat - minLat) * 1.5),
            longitudeDelta: max(0.001, (maxLon - minLon) * 1.5)
        )

        return MKCoordinateRegion(center: center, span: span)
    }
}

//helper for map overview 
struct AllTurnPolylineOverlay: UIViewRepresentable {
    let turns: [TurnTelemetry]

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator

        for turn in turns {
            let polyline = MKPolyline(coordinates: turn.gpsPath, count: turn.gpsPath.count)
            mapView.addOverlay(polyline)
        }

        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(overlay: polyline)
                renderer.strokeColor = UIColor.systemBlue
                renderer.lineWidth = 2
                return renderer
            }
            return MKOverlayRenderer()
        }
    }
}



