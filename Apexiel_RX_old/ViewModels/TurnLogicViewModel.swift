//
//  drivingViewModel.swift
//  Apexiel Proj1
//
//  Created by Kenji Fahselt on 7/13/25.
//

import CoreMotion
import CoreLocation

//contains logic for detecting turns



class MotionManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let motion = CMMotionManager()
    private let locationManager = CLLocationManager()
    
    //exported viewmodel telem data
    @Published var latestMotion: MotionData?
    @Published var latestLocation: LocationData?
    @Published var yaw: Double?
    
    
    

    
    // Variables to track current turn data:
    //!T
    //temp turn variables
    @Published var turnTelemetryRecords: [TurnTelemetry] = []
    @Published  var isTurning = false
    @Published  var checkpt1 = false
    @Published  var checkpt2 = false
    @Published  var checkpt3 = false
    
    @Published var previousYaw: Double?
    @Published var previousHeading: CLLocationDirection? // in degrees

    
    
    private var turnStartTime: Date?
    private var turnEndTime: Date?
    private var turnStartSpeed: Double?
    private var turnEndSpeed: Double?
    private var turnYawStart: Double?
    private var turnYawEnd: Double?
    private var turnGPSPath: [CLLocationCoordinate2D] = []
    
    private var accelerationSamples: [Double] = []
    //!T



    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()

        //startAccelerometer()
        //startGyroscope()
        //startDeviceMotion()
        startMotionTracking()
        

    }
    /*
    func startAccelerometer() {
        guard motion.isAccelerometerAvailable else { return }
        motion.accelerometerUpdateInterval = 0.1
        motion.startAccelerometerUpdates()
    }

    func startGyroscope() {
        guard motion.isGyroAvailable else { return }
        motion.gyroUpdateInterval = 0.1
        motion.startGyroUpdates(to: .main) { [weak self] gyroData, _ in
            guard let self = self,
                  let acc = self.motion.accelerometerData,
                  let gyro = gyroData else { return }
            
      

            self.latestMotion = MotionData(
                timestamp: Date(),
                acceleration: SIMD3(acc.acceleration.x, acc.acceleration.y, acc.acceleration.z),
                rotationRate: SIMD3(gyro.rotationRate.x, gyro.rotationRate.y, gyro.rotationRate.z),
                yaw: nil // optionally populate later with fused attitude
            )
        }
    }
    */
    
   

    func startMotionTracking() {
        guard motion.isDeviceMotionAvailable else { return }

        motion.deviceMotionUpdateInterval = 0.1
        motion.startDeviceMotionUpdates(using: .xArbitraryZVertical, to: .main) { [weak self] motionData, _ in
            guard let self = self, let motionData = motionData else { return }
            print("tracking motion")
            
           
            let acc = motionData.userAcceleration
            let rot = motionData.rotationRate
            let yaw = motionData.attitude.yaw

            self.latestMotion = MotionData(
                timestamp: Date(),
                acceleration: SIMD3(acc.x, acc.y, acc.z),
                rotationRate: SIMD3(rot.x, rot.y, rot.z),
                yaw: yaw
            )
        }
    }

    
    //finds yaw
    func startDeviceMotion() {
          guard motion.isDeviceMotionAvailable else { return }
          
          motion.deviceMotionUpdateInterval = 0.1
          motion.startDeviceMotionUpdates(using: .xArbitraryZVertical, to: .main) { [weak self] motionData, error in
              guard let attitude = motionData?.attitude else { return }
              self?.yaw = attitude.yaw // radians
          }
      }
    
    

    // CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        latestLocation = LocationData(
            coordinate: loc.coordinate,
            speed: loc.speed,
            heading: locationManager.heading?.trueHeading,
            timestamp: loc.timestamp
        )
        
        //call detect turn method from inside delegate
        if let location = locationManager.location {
            print("entering turn block")
            detectTurnWithCurve(location: location)
           // detectTurn(location: location)
        }
    }
    
    
    //extra location manager delegate
    /*
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        // Merge heading into existing location, or just update a separate published var
        if var loc = latestLocation {
            latestLocation = LocationData(
                coordinate: loc.coordinate,
                speed: loc.speed,
                heading: newHeading.trueHeading,
                timestamp: loc.timestamp
            )
        }
    }
    
    */
    
   
    
    //orignal detect turn method just uses fused yaw/ acceleration and heading
    func detectTurn(location: CLLocation) {
        guard let motion = self.latestMotion, let yaw = motion.yaw else { return }
        
        //print("tracking turn")
        
     //   let speed = location.speed
      //  let angularVelocity = abs(motion.rotationRate.z)
        
        let accelerationMagnitude = sqrt(
            pow(motion.acceleration.x, 2) +
            pow(motion.acceleration.y, 2) +
            pow(motion.acceleration.z, 2)
        )

        // Adjusted thresholds
        let turningThresholdYaw: Double = 0.015 // radians (~0.86°)
        let turningThresholdGyro: Double = 0.2 // rad/s
       // let minSpeed: Double = 2.0 // m/s
        
        
        let heading = location.course // degrees
        let speed = location.speed
        let angularVelocity = abs(motion.rotationRate.z)

            // Calculate differences
        let yawDelta = previousYaw.map { abs(yaw - $0) } ?? 0
        let headingDelta = previousHeading.map { abs(heading - $0) } ?? 0

            // Normalize heading diff
        let normalizedHeadingDelta = headingDelta > 180 ? 360 - headingDelta : headingDelta

            // Thresholds
        
        //rally settings
       
        /*
        let yawSpikeThreshold = 0.15 // ~8.6° yaw change
        let headingChangeThreshold = 10.0 // degrees
        let minSpeed: Double = 1.5 // m/s
        
        */
        let yawSpikeThreshold = 0.15 // ~8.6° yaw change
        let headingChangeThreshold = 10.0 // degrees
        let minSpeed: Double = 1.5 // m/s
        
        if !isTurning {
            // Detect turn start
            if yawDelta > yawSpikeThreshold && normalizedHeadingDelta > headingChangeThreshold && speed > minSpeed {
                checkpt1 = true
                isTurning = true
                turnStartTime = Date()
                turnYawStart = yaw
                turnStartSpeed = speed
                turnGPSPath = [location.coordinate]
                accelerationSamples = [accelerationMagnitude]
            }
        } else {
            // Continue collecting during the turn
            checkpt2 = true
            turnGPSPath.append(location.coordinate)
            accelerationSamples.append(accelerationMagnitude)
            
            let yawChange = abs(yaw - (turnYawStart ?? yaw))
            let turningStillHappening = yawChange > 0.01 || angularVelocity > 0.2
            
            if yawDelta < 0.03 && angularVelocity < 0.1 {
                checkpt3 = true
                // Turn ended
                isTurning = false
                turnEndTime = Date()
                turnYawEnd = yaw
                turnEndSpeed = speed
                
                let duration = turnEndTime!.timeIntervalSince(turnStartTime!)
                let averageAcceleration = accelerationSamples.reduce(0, +) / Double(accelerationSamples.count)
                let yawChangeFinal = abs(turnYawEnd! - turnYawStart!)
                let angleDegrees = yawChangeFinal * 180 / .pi
                
                let telemetry = TurnTelemetry(
                    startTime: turnStartTime!,
                    endTime: turnEndTime!,
                    startSpeed: turnStartSpeed ?? 0,
                    endSpeed: turnEndSpeed ?? 0,
                    averageAcceleration: averageAcceleration,
                    yawChange: yawChangeFinal,
                    gpsPath: turnGPSPath,
                    angle: angleDegrees
                )
                
                DispatchQueue.main.async {
                    
                    self.turnTelemetryRecords.append(telemetry)
                    TelemetryStorageManager.saveTurnTelemetryToJSON(self.turnTelemetryRecords)

                }
            }
        }
        previousYaw = yaw
        previousHeading = heading
    }
    
    
    
    
    //UPDATED TURN DETECTION AND HELPER METHODS
    
    
    
    
    
    //helper
    // Moving average smoother
    func movingAverage(_ values: [Double], windowSize: Int = 5) -> Double {
        guard !values.isEmpty else { return 0 }
        let slice = values.suffix(windowSize)
        return slice.reduce(0, +) / Double(slice.count)
    }
    
    
    func bearingBetween(_ coord1: CLLocationCoordinate2D, _ coord2: CLLocationCoordinate2D) -> Double {
        let lat1 = coord1.latitude * .pi / 180
        let lon1 = coord1.longitude * .pi / 180
        let lat2 = coord2.latitude * .pi / 180
        let lon2 = coord2.longitude * .pi / 180
        
        let dLon = lon2 - lon1
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        var bearing = atan2(y, x) * 180 / .pi
        if bearing < 0 { bearing += 360 }
        return bearing
    }

    // Properties to keep history
    var yawHistory: [Double] = []
    var gyroHistory: [Double] = []
    var lastTurnActivity: Date?

    // New property to track heading at start
    var turnHeadingStart: Double?

    
    var previousLocation: CLLocationCoordinate2D?
    var previousGPSBearing: Double?
    
    
    
    
    //updated detect turn method, uses curveature of GPS data and helper functions on top of original method
    func detectTurnWithCurve(location: CLLocation) {
        guard let motion = self.latestMotion, let yaw = motion.yaw else { return }

        let accelerationMagnitude = sqrt(
            pow(motion.acceleration.x, 2) +
            pow(motion.acceleration.y, 2) +
            pow(motion.acceleration.z, 2)
        )
        //RALLY
        // --- Thresholds ---
        let yawSpikeThreshold: Double = 0.15       // ~8.6° yaw change
        let gyroThreshold: Double = 0.2            // rad/s
        let headingChangeThreshold: Double = 10.0  // degrees (GPS + course)
        let minSpeed: Double = 1.5                 // m/s
        let turnEndGracePeriod: Double = 0.5       // seconds of inactivity
        

        
        let heading = location.course
        let speed = location.speed
        let angularVelocity = abs(motion.rotationRate.z)
        
        // --- History / smoothing ---
        yawHistory.append(yaw)
        gyroHistory.append(angularVelocity)
        
        let smoothedYaw = movingAverage(yawHistory, windowSize: 5)
        let smoothedGyro = movingAverage(gyroHistory, windowSize: 5)
        
        let yawDelta = previousYaw.map { abs(smoothedYaw - $0) } ?? 0
        let headingDelta = previousHeading.map { abs(heading - $0) } ?? 0
        let normalizedHeadingDelta = headingDelta > 180 ? 360 - headingDelta : headingDelta
        
        // --- GPS curvature ---
        var gpsHeadingDelta: Double = 0
        if let lastCoord = previousLocation {
            let gpsBearing = bearingBetween(lastCoord, location.coordinate)
            let gpsDiff = abs(gpsBearing - (previousGPSBearing ?? gpsBearing))
            gpsHeadingDelta = gpsDiff > 180 ? 360 - gpsDiff : gpsDiff
            previousGPSBearing = gpsBearing
        }
        previousLocation = location.coordinate
        
        if !isTurning {
            // --- Detect Turn Start ---
            if (yawDelta > yawSpikeThreshold || smoothedGyro > gyroThreshold || gpsHeadingDelta > headingChangeThreshold)
                && speed > minSpeed {
                
                isTurning = true
                turnStartTime = Date()
                turnYawStart = smoothedYaw
                turnHeadingStart = heading
                turnStartSpeed = speed
                turnGPSPath = [location.coordinate]
                accelerationSamples = [accelerationMagnitude]
                
                lastTurnActivity = Date()
            }
        } else {
            // --- Collect during turn ---
            turnGPSPath.append(location.coordinate)
            accelerationSamples.append(accelerationMagnitude)
            
            let yawChange = abs(smoothedYaw - (turnYawStart ?? smoothedYaw))
            let headingChange = abs(heading - (turnHeadingStart ?? heading))
            
            let stillTurning = yawChange > 0.05 || smoothedGyro > 0.15 || gpsHeadingDelta > 5
            if stillTurning {
                lastTurnActivity = Date()
            }
            
            // --- Detect Turn End ---
            if let lastActive = lastTurnActivity,
               Date().timeIntervalSince(lastActive) > turnEndGracePeriod {
                
                isTurning = false
                turnEndTime = Date()
                turnYawEnd = smoothedYaw
                turnEndSpeed = speed
                
                let duration = turnEndTime!.timeIntervalSince(turnStartTime!)
                let averageAcceleration = accelerationSamples.reduce(0, +) / Double(accelerationSamples.count)
                let yawChangeFinal = abs(turnYawEnd! - turnYawStart!)
                let angleDegrees = yawChangeFinal * 180 / .pi
                
                let telemetry = TurnTelemetry(
                    startTime: turnStartTime!,
                    endTime: turnEndTime!,
                    startSpeed: turnStartSpeed ?? 0,
                    endSpeed: turnEndSpeed ?? 0,
                    averageAcceleration: averageAcceleration,
                    yawChange: yawChangeFinal,
                    gpsPath: turnGPSPath,
                    angle: angleDegrees
                )
                
                DispatchQueue.main.async {
                    self.turnTelemetryRecords.append(telemetry)
                    TelemetryStorageManager.saveTurnTelemetryToJSON(self.turnTelemetryRecords)
                }
            }
        }
        
        previousYaw = smoothedYaw
        previousHeading = heading
    }
    
    
    
    
    
    //turn detect function for karting settings
    func K_detectTurnWithCurve(location: CLLocation) {
        guard let motion = self.latestMotion, let yaw = motion.yaw else { return }

        // Calculate total acceleration magnitude
        let accelerationMagnitude = sqrt(
            pow(motion.acceleration.x, 2) +
            pow(motion.acceleration.y, 2) +
            pow(motion.acceleration.z, 2)
        )

        // MARK: - Karting thresholds
        let yawSpikeThreshold: Double = 0.5          // rad, ~28.6°
        let gyroThreshold: Double = 0.6              // rad/s
        let headingChangeThreshold: Double = 25.0    // degrees
        let minSpeed: Double = 2.0                   // m/s
        let turnEndGracePeriod: Double = 1.2         // sec

        let heading = location.course
        let speed = location.speed
        let angularVelocity = abs(motion.rotationRate.z)

        // MARK: - Smoothing & History
        yawHistory.append(yaw)
        gyroHistory.append(angularVelocity)
        
        let smoothedYaw = movingAverage(yawHistory, windowSize: 5)
        let smoothedGyro = movingAverage(gyroHistory, windowSize: 5)

        let yawDelta = previousYaw.map { abs(smoothedYaw - $0) } ?? 0
        let headingDelta = previousHeading.map { abs(heading - $0) } ?? 0
        let normalizedHeadingDelta = headingDelta > 180 ? 360 - headingDelta : headingDelta

        // MARK: - GPS curvature
        var gpsHeadingDelta: Double = 0
        if let lastCoord = previousLocation {
            let gpsBearing = bearingBetween(lastCoord, location.coordinate)
            let gpsDiff = abs(gpsBearing - (previousGPSBearing ?? gpsBearing))
            gpsHeadingDelta = gpsDiff > 180 ? 360 - gpsDiff : gpsDiff
            previousGPSBearing = gpsBearing
        }
        previousLocation = location.coordinate

        // MARK: - Turn confidence calculation
        let confidence = min(
            1.0,
            (yawDelta / yawSpikeThreshold) +
            (smoothedGyro / gyroThreshold) +
            (gpsHeadingDelta / headingChangeThreshold)
        ) / 3.0  // normalize to 0..1

        // MARK: - Detect turn start
        if !isTurning {
            if (yawDelta > yawSpikeThreshold || smoothedGyro > gyroThreshold || gpsHeadingDelta > headingChangeThreshold)
                && speed > minSpeed {
                
                isTurning = true
                turnStartTime = Date()
                turnYawStart = smoothedYaw
                turnHeadingStart = heading
                turnStartSpeed = speed
                turnGPSPath = [location.coordinate]
                accelerationSamples = [accelerationMagnitude]
                lastTurnActivity = Date()
            }
        } else {
            // MARK: - Collect during turn
            turnGPSPath.append(location.coordinate)
            accelerationSamples.append(accelerationMagnitude)

            let yawChange = abs(smoothedYaw - (turnYawStart ?? smoothedYaw))
            let headingChange = abs(heading - (turnHeadingStart ?? heading))
            
            let stillTurning = yawChange > 0.05 || smoothedGyro > 0.15 || gpsHeadingDelta > 5
            if stillTurning { lastTurnActivity = Date() }

            // MARK: - Detect turn end
            if let lastActive = lastTurnActivity,
               Date().timeIntervalSince(lastActive) > turnEndGracePeriod {

                isTurning = false
                turnEndTime = Date()
                turnYawEnd = smoothedYaw
                turnEndSpeed = speed

                let averageAcceleration = accelerationSamples.reduce(0, +) / Double(accelerationSamples.count)
                let yawChangeFinal = abs(turnYawEnd! - turnYawStart!)
                let angleDegrees = yawChangeFinal * 180 / .pi

                let telemetry = TurnTelemetry(
                    startTime: turnStartTime!,
                    endTime: turnEndTime!,
                    startSpeed: turnStartSpeed ?? 0,
                    endSpeed: turnEndSpeed ?? 0,
                    averageAcceleration: averageAcceleration,
                    yawChange: yawChangeFinal,
                    gpsPath: turnGPSPath,
                    angle: angleDegrees
                )

                DispatchQueue.main.async {
                    self.turnTelemetryRecords.append(telemetry)
                    TelemetryStorageManager.saveTurnTelemetryToJSON(self.turnTelemetryRecords)
                }
            }
        }

        previousYaw = smoothedYaw
        previousHeading = heading
    }


    
    
    
}







//https://www.youtube.com/watch?v=YS4K_GT2_vM


/*
// MotionManager class to handle accelerometer and gyroscope updates
class MotionManager: ObservableObject {
   
    
    private let motion = CMMotionManager() // Core motion manager instance
    
    
    let locationManager = CLLocationManager() // location manager instance
    
    
    
   
    @Published var accelerometerData: CMAccelerometerData? // Published data for SwiftUI updates
   
    @Published var gyroscopeData: CMGyroData? // Published gyroscope data for SwiftUI updates
    
    @Published var headingData: CLHeading?
    
   

    @Published var locationData: CLLocationCoordinate2D?
    
    @Published var speedData: CLLocationSpeed?
  
    
    
    @Published var isMoving: Bool = false
    
  
    
    init() {
        startAcceleromoterUpdates() // Start accelerometer updates
        startGyroscopeUpdates() // Start gyroscope updates
    }

    // Function to start accelerometer updates
    func startAcceleromoterUpdates() {
        if motion.isAccelerometerAvailable {
            motion.accelerometerUpdateInterval = 0.1 // Updates every 0.1 seconds
            motion.startAccelerometerUpdates(to: .main) { [weak self] data, error in
                if let data = data {
                    self?.accelerometerData = data // Update accelerometer data
                }
            }
        }
    }

    // Function to start gyroscope updates
    func startGyroscopeUpdates() {
        if motion.isGyroAvailable {
            motion.gyroUpdateInterval = 0.1 // Updates every 0.1 seconds
            motion.startGyroUpdates(to: .main) { [weak self] data, error in
                if let data = data {
                    self?.gyroscopeData = data // Update gyroscope data
                }
            }
        }
    }
    
    
    func startMotionUpdates() {
        
        locationData = locationManager.location?.coordinate
        speedData = locationManager.location?.speed
        
        
        
        
        
    }
    
    func startHeadingUpdates() {
        
       
        self.headingData = locationManager.heading
            
        
        
    }
    
    

}
*/
