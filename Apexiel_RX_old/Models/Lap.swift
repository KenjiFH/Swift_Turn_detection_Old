//
//  Lap.swift
//  Apexiel Proj1
//
//  Created by Kenji Fahselt on 11/4/25.
//

import Foundation
import UIKit
import CoreLocation
import MapKit

//so instead of using coordiates as in CLLocationCoordinate2D we should try to use a DrivingTelemDataPoint
//TODO replace coordinates: [CLLocationCoordinate2D] with an array of DrivingTelemDataPoint, that we get coords and telem
struct Lap: Identifiable {
    let id = UUID()
    var coordinates: [CLLocationCoordinate2D]
    var color: UIColor
}


//lap1Coords = [DrivingTelemDataPoint(cclpoint, accel, gyro, etc)
//access by Lap.DrivingTelemDataPoint.coodinate
//each DrivingTelemDataPoint has ONE CLLocationCoordinate2D
extension Lap {
    static var mockLaps: [Lap] {
        let lap1Coords = [
            CLLocationCoordinate2D(latitude: 37.3317, longitude: -122.0307),
            CLLocationCoordinate2D(latitude: 37.3320, longitude: -122.0310),
            CLLocationCoordinate2D(latitude: 37.3323, longitude: -122.0307),
            CLLocationCoordinate2D(latitude: 37.3320, longitude: -122.0304),
            CLLocationCoordinate2D(latitude: 37.3317, longitude: -122.0307)
        ]
        
        let lap2Coords = [
            CLLocationCoordinate2D(latitude: 37.3317, longitude: -122.0307),
            CLLocationCoordinate2D(latitude: 37.3321, longitude: -122.0311),
            CLLocationCoordinate2D(latitude: 37.3324, longitude: -122.0306),
            CLLocationCoordinate2D(latitude: 37.3321, longitude: -122.0302),
            CLLocationCoordinate2D(latitude: 37.3317, longitude: -122.0307)
        ]
        
        let lap3Coords = [
            CLLocationCoordinate2D(latitude: 37.3317, longitude: -122.0307),
            CLLocationCoordinate2D(latitude: 37.3319, longitude: -122.0312),
            CLLocationCoordinate2D(latitude: 37.3325, longitude: -122.0308),
            CLLocationCoordinate2D(latitude: 37.3322, longitude: -122.0303),
            CLLocationCoordinate2D(latitude: 37.3317, longitude: -122.0307)
        ]
        
        return [
            Lap(coordinates: lap1Coords, color: .systemBlue),
            Lap(coordinates: lap2Coords, color: .systemRed),
            Lap(coordinates: lap3Coords, color: .systemOrange)
        ]
    }
}
