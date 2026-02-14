//
//  DrivingTelemetry.swift
//  Apexiel Proj1
//
//  Created by Kenji Fahselt on 7/13/25.
//


import Foundation
import CoreLocation


import Foundation
import CoreLocation

// 1. The Struct (Exactly as you provided)
struct DrivingTelemDataPoint: Identifiable {
    let id = UUID()
    let speed: Double               // m/s
    let timestamp: Date
    let acceleration: SIMD3<Double> // G-Force
    let rotationRate: SIMD3<Double> // rad/s
    let yaw: Double?
    let totalDistance: Double       // X-AXIS for Graph
    
    // Location data
    let coordinate: CLLocationCoordinate2D
    let heading: Double?
}

// 2. The Mock Generator Extension
extension DrivingTelemDataPoint {
    
    static func generateMockLap(duration: TimeInterval = 60, timeOffset: TimeInterval = 0) -> [DrivingTelemDataPoint] {
        var points: [DrivingTelemDataPoint] = []
        let startDate = Date().addingTimeInterval(timeOffset)
        
        let frequency = 10.0 // 10Hz
        let steps = Int(duration * frequency)
        
        // Track Math
        let centerLat = 47.6062
        let centerLon = -122.3321
        let trackRadius = 0.0025
        var cumulativeDistance: Double = 0.0
        var prevCoordinate: CLLocationCoordinate2D?
        
        for i in 0..<steps {
            let time = Double(i) / frequency
            let progress = time / duration
            
            // Speed Physics (Slow in corners, Fast in straights)
            let baseSpeed = 35.0
            let speedVar = 10.0 * cos(progress * 4 * .pi)
            let currentSpeed = max(10.0, baseSpeed + speedVar)
            
            // Location Math (Figure 8-ish oval)
            let angle = progress * 2 * .pi
            let latOffset = trackRadius * cos(angle)
            let lonOffset = (trackRadius * 1.6) * sin(angle)
            let coord = CLLocationCoordinate2D(
                latitude: centerLat + latOffset,
                longitude: centerLon + lonOffset
            )
            
            // Calculate Distance (Cumulative)
            if let prev = prevCoordinate {
                let locA = CLLocation(latitude: prev.latitude, longitude: prev.longitude)
                let locB = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
                cumulativeDistance += locA.distance(from: locB)
            }
            prevCoordinate = coord
            
            // Create Point
            let point = DrivingTelemDataPoint(
                speed: currentSpeed,
                timestamp: startDate.addingTimeInterval(time),
                acceleration: SIMD3<Double>(0, 0, 0), // Placeholder
                rotationRate: SIMD3<Double>(0, 0, 0),
                yaw: 0,
                totalDistance: cumulativeDistance, // <--- Key for Graph
                coordinate: coord,
                heading: 0
            )
            
            points.append(point)
        }
        
        return points
    }
    
    
    static func generateMockLapVariant(duration: TimeInterval = 62, timeOffset: TimeInterval = 0) -> [DrivingTelemDataPoint] {
            var points: [DrivingTelemDataPoint] = []
            let startDate = Date().addingTimeInterval(timeOffset)
            
            let frequency = 10.0
            let steps = Int(duration * frequency)
            
            // Track Math (Same Center)
            let centerLat = 47.6062
            let centerLon = -122.3321
            let trackRadius = 0.0025
            var cumulativeDistance: Double = 0.0
            var prevCoordinate: CLLocationCoordinate2D?
            
            for i in 0..<steps {
                let time = Double(i) / frequency
                let progress = time / duration
                
                // VARIANCE 1: Different Speed Profile
                // This driver brakes LATER but accelerates SLOWER (The "Dive Bomb" technique)
                // We shift the phase of the cosine wave slightly (+ 0.5)
                let baseSpeed = 33.0 // Slightly slower average
                let speedVar = 12.0 * cos((progress * 4 * .pi) + 0.5)
                // Add slight random noise to speed to test "jitter" smoothing
                let noise = Double.random(in: -0.5...0.5)
                let currentSpeed = max(8.0, baseSpeed + speedVar + noise)
                
                // VARIANCE 2: Different Racing Line
                // We multiply the radius by a slight factor to simulate taking a "Wider" line
                // Widens the track by ~5 meters at the apex
                let wideLineFactor = 1.0 + (0.05 * sin(progress * 2 * .pi))
                
                let angle = progress * 2 * .pi
                let latOffset = (trackRadius * wideLineFactor) * cos(angle)
                let lonOffset = ((trackRadius * 1.6) * wideLineFactor) * sin(angle)
                
                let coord = CLLocationCoordinate2D(
                    latitude: centerLat + latOffset,
                    longitude: centerLon + lonOffset
                )
                
                // Calculate Distance
                if let prev = prevCoordinate {
                    let locA = CLLocation(latitude: prev.latitude, longitude: prev.longitude)
                    let locB = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
                    cumulativeDistance += locA.distance(from: locB)
                }
                prevCoordinate = coord
                
                let point = DrivingTelemDataPoint(
                    speed: currentSpeed,
                    timestamp: startDate.addingTimeInterval(time),
                    acceleration: SIMD3<Double>(0, 0, 0),
                    rotationRate: SIMD3<Double>(0, 0, 0),
                    yaw: 0,
                    totalDistance: cumulativeDistance,
                    coordinate: coord,
                    heading: 0
                )
                
                points.append(point)
            }
            
            return points
        }
}

//legacy struct for backwards compatibility with turnlogic and turnrender VMS
struct MotionData: Identifiable {
    let id = UUID()
    let timestamp: Date
    let acceleration: SIMD3<Double> // x, y, z
    let rotationRate: SIMD3<Double> // x, y, z
    let yaw: Double? // if using fused yaw later
}

struct LocationData: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let speed: Double
    let heading: Double?
    let timestamp: Date
}


