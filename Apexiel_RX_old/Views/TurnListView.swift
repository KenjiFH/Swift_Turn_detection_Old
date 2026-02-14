//
//  TurnListView.swift
//  Apexiel Proj1
//
//  Created by Kenji Fahselt on 7/15/25.
//

import SwiftUI
import MapKit


//TURNLISTVIEW provides a testing framework for data ingestion and how
//turns are visualized on MapKit to validate accuracy and data integreity
//currently uses the TurnTelemetry extension for generating mock data in mem





func showAllTurns(on mapView: MKMapView, turns: [TurnTelemetry]) {
    var overallRect = MKMapRect.null

    for turn in turns {
        let coords = turn.gpsPath
        guard coords.count > 1 else { continue }

        // Polyline for the path
        let polyline = MKPolyline(coordinates: coords, count: coords.count)
        mapView.addOverlay(polyline)

        // Expand overall rect to include this polyline
        overallRect = overallRect.union(polyline.boundingMapRect)

        // Start annotation
        if let start = coords.first {
            let startAnnotation = MKPointAnnotation()
            startAnnotation.coordinate = start
            startAnnotation.title = "Start"
            startAnnotation.subtitle = "startTime: \(turn.startTime)"
            mapView.addAnnotation(startAnnotation)
        }

        // End annotation
        if let end = coords.last {
            let endAnnotation = MKPointAnnotation()
            endAnnotation.coordinate = end
            endAnnotation.title = "End"
            endAnnotation.subtitle = "endTime: \(turn.endTime) m/s"
            mapView.addAnnotation(endAnnotation)
        }

        // Apex
        if coords.count > 2 {
            let apex = coords[coords.count / 2]
            let apexAnnotation = MKPointAnnotation()
            apexAnnotation.coordinate = apex
            apexAnnotation.title = "Apex"
            apexAnnotation.subtitle = "Yaw Change: \(turn.yawChange)"
            mapView.addAnnotation(apexAnnotation)
        }
    }

    //  Adjust camera to fit *all* paths, with padding
    if !overallRect.isNull {
        let padding = UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50)
        mapView.setVisibleMapRect(overallRect, edgePadding: padding, animated: true)
    }
}



//this struct displays turns from a [TurnTelemetry] array
struct AllTurnsMapView: UIViewRepresentable {
    let turns: [TurnTelemetry]

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        showAllTurns(on: mapView, turns: turns) // 👈 call show allturns here
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        // In case turns update later
        uiView.removeOverlays(uiView.overlays)
        uiView.removeAnnotations(uiView.annotations)
        showAllTurns(on: uiView, turns: turns) // 👈 call show turns here too
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.lineWidth = 4
                renderer.strokeColor = .systemBlue
                return renderer
            }
            return MKOverlayRenderer()
        }
        
        
    }
}







//this main view is what the phones sim displays
struct AllTurnsView: View {
    @StateObject private var motionManager = MotionManager()

  

      var body: some View {
          AllTurnsMapView(turns: motionManager.turnTelemetryRecords)
              .edgesIgnoringSafeArea(.all)
      }
}




//this is for debugging in the preview (stores turns in memory)
struct DebugOverviewMap: View {
    let fakeTurns: [TurnTelemetry] = [
        .mockTurn(id: 0),
        .mockTurn(id: 1),
        .mockTurn(id: 2)
    ]
    
    var body: some View {
        AllTurnsMapView(turns: fakeTurns)
            .edgesIgnoringSafeArea(.all)
    }
}



//this view uses the data we collected from dirtfish
struct DebugJsonOverviewMap: View {
    let jsonTurns: [TurnTelemetry] = [
        .turnWithJson(id: 0),
        .turnWithJson(id: 1),
        .turnWithJson(id: 2),
        .turnWithJson(id: 3)
    ]
    
    var body: some View {
        AllTurnsMapView(turns: jsonTurns)
            .edgesIgnoringSafeArea(.all)
    }
}


#Preview {
    DebugJsonOverviewMap()
    
}
