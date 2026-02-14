//
//  graphModel.swift
//  Apexiel Proj1
//
//  Created by Kenji Fahselt on 9/9/25.
//
import CoreLocation


func accelerationSegments(for turn: TurnTelemetry) -> [AccelerationSegment] {
    let gpsPath = turn.gpsPath
    var segments: [AccelerationSegment] = []
    guard gpsPath.count > 1 else { return segments }

    var cumulativeDistance: Double = 0
    for i in 1..<gpsPath.count {
        let start = CLLocation(latitude: gpsPath[i-1].latitude, longitude: gpsPath[i-1].longitude)
        let end = CLLocation(latitude: gpsPath[i].latitude, longitude: gpsPath[i].longitude)
        let segmentDistance = end.distance(from: start)
        cumulativeDistance += segmentDistance

        // assign same average acceleration for simplicity
        let segment = AccelerationSegment(distance: cumulativeDistance, acceleration: turn.averageAcceleration)
        segments.append(segment)
    }

    return segments
}
