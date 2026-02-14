//
//  DashBoardView.swift
//  Apexiel Proj1
//
//  Created by Kenji Fahselt on 7/13/25.
//
import SwiftUI




struct DrivingView: View {
    @StateObject var motionManager = MotionManager()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                // Motion Section
                Text("Motion Data📈")
                    .font(.headline)
                
                if let motion = motionManager.latestMotion {
                    VStack(alignment: .leading) {
                        Text("x: \(motion.acceleration.x, specifier: "%.2f")")
                        Text("y: \(motion.acceleration.y, specifier: "%.2f")")
                        Text("z: \(motion.acceleration.z, specifier: "%.2f")")
                        Text("Rotation Z: \(motion.rotationRate.z, specifier: "%.2f")")
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                } else {
                    Text("Motion not available").foregroundColor(.gray)
                }
                
                Divider()
                
                // Location Section
                Text("Location Data📍")
                    .font(.headline)
                
                if let location = motionManager.latestLocation {
                    VStack(alignment: .leading) {
                        Text("Speed: \(location.speed, specifier: "%.2f") m/s")
                        Text("Heading: \(location.heading ?? -1, specifier: "%.1f")°")
                        Text("Lat: \(location.coordinate.latitude)")
                        Text("Lon: \(location.coordinate.longitude)")
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                } else {
                    Text("Location not available").foregroundColor(.gray)
                }
                
                Divider()
                
                // Yaw Section
                Text("Fused Yaw ♻️")
                    .font(.headline)
                
                if let yaw = motionManager.latestMotion?.yaw {
                    Text("\(yaw, specifier: "%.2f")°")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.blue)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                } else {
                    Text("Yaw not available").foregroundColor(.gray)
                }
                
                Divider()
                
                // Turn Telemetry
                Text("Turn Records")
                    .font(.headline)
                
                ForEach(motionManager.turnTelemetryRecords) { turn in
                    VStack(alignment: .leading) {
                        Text("Turn from \(turn.startTime.formatted()) to \(turn.endTime.formatted())")
                            .font(.headline)
                        Text("Angle: \(turn.angle, specifier: "%.1f")°")
                        Text("Entry Speed: \(turn.startSpeed, specifier: "%.2f") m/s")
                        Text("Exit Speed: \(turn.endSpeed, specifier: "%.2f") m/s")
                        Text("Avg Acceleration: \(turn.averageAcceleration, specifier: "%.2f") m/s²")
                        Text("GPS Points: \(turn.gpsPath.count)")
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
            }
            .padding()
            
            VStack {
                
                
                Circle()
                    .fill(motionManager.isTurning ? Color.red : Color.gray)
                    .frame(width: 24, height: 24)
                Text(motionManager.isTurning ? "Turning" : "Not Turning")
                    .font(.headline)
                    .foregroundColor(motionManager.isTurning ? .red : .gray)
                      }
                      .padding()
                      .background(Color(.systemGray6))
                      .cornerRadius(10)
        }
    }
}

#Preview {
    DrivingView()
}

/*

struct DashboardView: View {
    
    @StateObject private var motionManager = MotionManager() // StateObject to manage motion updates

    var body: some View {
        VStack(spacing: 20) {
            // Display Accelerometer Data
            Text("Accelerometer Data")
                .font(.headline)
            
            if let data = motionManager.accelerometerData {
                Text("X: \(data.acceleration.x, specifier: "%.2f")")
                Text("Y: \(data.acceleration.y, specifier: "%.2f")")
                Text("Z: \(data.acceleration.z, specifier: "%.2f")")
            } else {
                Text("No motion found")
            }
            
            // Display Gyroscope Data
            Text("Gyroscope Data")
                .font(.headline)
                .foregroundStyle(Color.purple)
            
            if let gyroData = motionManager.gyroscopeData {
                Text("X: \(gyroData.rotationRate.x, specifier: "%.2f")")
                    .foregroundStyle(Color.purple)
                Text("Y: \(gyroData.rotationRate.y, specifier: "%.2f")")
                    .foregroundStyle(Color.purple)
                Text("Z: \(gyroData.rotationRate.z, specifier: "%.2f")")
                    .foregroundStyle(Color.purple)
            } else {
                Text("Gyro not found")
                    .foregroundStyle(Color.red)
            }
            
            
            Text("Heading Data")
                .font(.headline)
                .foregroundStyle(Color.blue)
            
        if let headingData = motionManager.headingData {
            
            Text("Heading: \(headingData.trueHeading, specifier: "%.2f")")
                .foregroundStyle(Color.blue)
            Text("Magnetic Heading: \(headingData.magneticHeading, specifier: "%.2f")")
                .foregroundStyle(Color.blue)
            Text("Heading Accuracy: \(headingData.headingAccuracy, specifier: "%.2f")")
                .foregroundStyle(Color.blue)
           Text("timestamp: \(headingData.timestamp)")
                 
                 
            } else {
                Text("Gyro not found")
                    .foregroundStyle(Color.blue)
            }
            
            
            
            
            
             
        }
        .padding() // Add padding to the VStack for layout purposes
    }
}

#Preview {
    
        DashboardView()
    
}
*/

