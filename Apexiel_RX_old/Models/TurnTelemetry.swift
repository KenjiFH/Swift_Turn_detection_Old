//
//  TurnTelemetry.swift
//  Apexiel Proj1
//
//  Created by Kenji Fahselt on 7/13/25.
//
import Foundation
import CoreLocation



/*
struct TurnTelemetry : Identifiable, Codable{
    let id = UUID()
    let startTime: Date
    let endTime: Date
    let startSpeed: Double
    let endSpeed: Double
    let averageAcceleration: Double
    let yawChange: Double
    let gpsPath: [CLLocationCoordinate2D]
    
    let angle: Double
    
}
 */

struct TurnTelemetry: Identifiable, Codable {
    let id: UUID
    let startTime: Date
    let endTime: Date
    let startSpeed: Double
    let endSpeed: Double
    let averageAcceleration: Double
    let yawChange: Double
    let gpsPath: [CLLocationCoordinate2D]
    let angle: Double

    // Custom encode/decode CLLocationCoordinate2D since it’s not Codable by default
    enum CodingKeys: String, CodingKey {
        case id, startTime, endTime, startSpeed, endSpeed, averageAcceleration, yawChange, gpsPath, angle
    }

    struct CoordinateWrapper: Codable {
        let latitude: Double
        let longitude: Double

        var coordinate: CLLocationCoordinate2D {
            CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }

        init(coordinate: CLLocationCoordinate2D) {
            self.latitude = coordinate.latitude
            self.longitude = coordinate.longitude
        }
    }

    init(
        id: UUID = UUID(),
        startTime: Date,
        endTime: Date,
        startSpeed: Double,
        endSpeed: Double,
        averageAcceleration: Double,
        yawChange: Double,
        gpsPath: [CLLocationCoordinate2D],
        angle: Double
    ) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.startSpeed = startSpeed
        self.endSpeed = endSpeed
        self.averageAcceleration = averageAcceleration
        self.yawChange = yawChange
        self.gpsPath = gpsPath
        self.angle = angle
    }

    // Encode and decode manually to handle CLLocationCoordinate2D
    func encode(to encoder: Encoder) throws {
        var container = try encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(startTime, forKey: .startTime)
        try container.encode(endTime, forKey: .endTime)
        try container.encode(startSpeed, forKey: .startSpeed)
        try container.encode(endSpeed, forKey: .endSpeed)
        try container.encode(averageAcceleration, forKey: .averageAcceleration)
        try container.encode(yawChange, forKey: .yawChange)
        try container.encode(angle, forKey: .angle)

        let wrappedCoords = gpsPath.map { CoordinateWrapper(coordinate: $0) }
        try container.encode(wrappedCoords, forKey: .gpsPath)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(UUID.self, forKey: .id)
        startTime = try container.decode(Date.self, forKey: .startTime)
        endTime = try container.decode(Date.self, forKey: .endTime)
        startSpeed = try container.decode(Double.self, forKey: .startSpeed)
        endSpeed = try container.decode(Double.self, forKey: .endSpeed)
        averageAcceleration = try container.decode(Double.self, forKey: .averageAcceleration)
        yawChange = try container.decode(Double.self, forKey: .yawChange)
        angle = try container.decode(Double.self, forKey: .angle)

        let wrappedCoords = try container.decode([CoordinateWrapper].self, forKey: .gpsPath)
        gpsPath = wrappedCoords.map { $0.coordinate }
    }
}
















//testing functions




//extension allows for us to use static functions to test variables for ui elements in-memory




//use mockturn for graph as well, needs var for avg acceleration too
extension TurnTelemetry {
   
    //we need a function to do this live on a map -> needs to take in Json object and convert to required vars
    //

   static func turnWithJson(id: Int) -> TurnTelemetry {
       
       let path1: [CLLocationCoordinate2D] = [
           CLLocationCoordinate2D(latitude: 47.54064623558368, longitude: -121.81524869109855),
           CLLocationCoordinate2D(latitude: 47.540691727182605, longitude: -121.81536400434352),
           CLLocationCoordinate2D(latitude: 47.54072706848798, longitude: -121.81551523937213),
           CLLocationCoordinate2D(latitude: 47.54079362452733, longitude: -121.81569047966059),
           CLLocationCoordinate2D(latitude: 47.540853568517484, longitude: -121.81585140426913),
           CLLocationCoordinate2D(latitude: 47.54090166369806, longitude: -121.81599334181546),
           CLLocationCoordinate2D(latitude: 47.54089919291609, longitude: -121.81613254585665),
           CLLocationCoordinate2D(latitude: 47.540887975007834, longitude: -121.81627246716052),
           CLLocationCoordinate2D(latitude: 47.54083988148454, longitude: -121.81643376320383)
       ]
       let path2: [CLLocationCoordinate2D] = [
           CLLocationCoordinate2D(latitude: 47.54071796637614, longitude: -121.81770907238123),
           CLLocationCoordinate2D(latitude: 47.54060537865078, longitude: -121.81770907237969),
           CLLocationCoordinate2D(latitude: 47.54049220971603, longitude: -121.81770907238234),
           CLLocationCoordinate2D(latitude: 47.540420679164534, longitude: -121.8177090723811),
           CLLocationCoordinate2D(latitude: 47.540389813509485, longitude: -121.81770907237853),
           CLLocationCoordinate2D(latitude: 47.54041399867386, longitude: -121.81752935387517),
           CLLocationCoordinate2D(latitude: 47.54041176835293, longitude: -121.81733273116724),
           CLLocationCoordinate2D(latitude: 47.54040897662163, longitude: -121.8170866159038)
       ]
       let path3: [CLLocationCoordinate2D] = [
           CLLocationCoordinate2D(latitude: 47.540356586277994, longitude: -121.81493479592737),
           CLLocationCoordinate2D(latitude: 47.54042917361981, longitude: -121.81478881209706),
           CLLocationCoordinate2D(latitude: 47.540482186058085, longitude: -121.81462943646926),
           CLLocationCoordinate2D(latitude: 47.540537557347825, longitude: -121.81451523145752),
           CLLocationCoordinate2D(latitude: 47.540688607546365, longitude: -121.81441190438284),
           CLLocationCoordinate2D(latitude: 47.54079333312688, longitude: -121.81441547517885),
           CLLocationCoordinate2D(latitude: 47.5408775815623, longitude: -121.81441834776919),
           CLLocationCoordinate2D(latitude: 47.540934329448916, longitude: -121.8144546003273),
           CLLocationCoordinate2D(latitude: 47.540950803419705, longitude: -121.81492943418361),
           CLLocationCoordinate2D(latitude: 47.54095322153233, longitude: -121.81505238578791),
           CLLocationCoordinate2D(latitude: 47.540996205687854, longitude: -121.81515331204892),
           CLLocationCoordinate2D(latitude: 47.54106469277843, longitude: -121.81519060173544),
           CLLocationCoordinate2D(latitude: 47.54112848008345, longitude: -121.81516026729766),
           CLLocationCoordinate2D(latitude: 47.541178466146334, longitude: -121.81508551377226),
           CLLocationCoordinate2D(latitude: 47.541219684226064, longitude: -121.81495966707317),
           CLLocationCoordinate2D(latitude: 47.54123316959548, longitude: -121.81479486145439),
           CLLocationCoordinate2D(latitude: 47.541202691406724, longitude: -121.81462679093757),
           CLLocationCoordinate2D(latitude: 47.54112442933207, longitude: -121.81447554402982),
           CLLocationCoordinate2D(latitude: 47.5410053118141, longitude: -121.81433416278473),
           CLLocationCoordinate2D(latitude: 47.54090397437615, longitude: -121.8142139041906),
           CLLocationCoordinate2D(latitude: 47.54086876570863, longitude: -121.81406907856203),
           CLLocationCoordinate2D(latitude: 47.5407908929275, longitude: -121.81398692545118),
           CLLocationCoordinate2D(latitude: 47.540679096486066, longitude: -121.81396332964663),
           CLLocationCoordinate2D(latitude: 47.540564548094004, longitude: -121.81397735769592),
           CLLocationCoordinate2D(latitude: 47.540453468903024, longitude: -121.8140303721604),
           CLLocationCoordinate2D(latitude: 47.54036379689208, longitude: -121.81413810956154),  //
           CLLocationCoordinate2D(latitude: 47.54026978933588, longitude: -121.81421521846345),
           CLLocationCoordinate2D(latitude: 47.54017604430937, longitude: -121.81419054112374),
           CLLocationCoordinate2D(latitude: 47.54012339122529, longitude: -121.81412164775193),
           CLLocationCoordinate2D(latitude: 47.540109488108406, longitude: -121.81399876656239),
           CLLocationCoordinate2D(latitude: 47.54014403879532, longitude: -121.81384898045712),
           CLLocationCoordinate2D(latitude: 47.54021835051015, longitude: -121.81369302575334),
           CLLocationCoordinate2D(latitude: 47.54033059599144, longitude: -121.8136019317771),
           CLLocationCoordinate2D(latitude: 47.54044358699862, longitude: -121.81360871985939),
           CLLocationCoordinate2D(latitude: 47.5405627980364, longitude: -121.81373961421568),
           CLLocationCoordinate2D(latitude: 47.540667665145904, longitude: -121.81379507588564),
           CLLocationCoordinate2D(latitude: 47.5407502996762, longitude: -121.81375787096114),
           CLLocationCoordinate2D(latitude: 47.54077712126427, longitude: -121.8136694550959),
           CLLocationCoordinate2D(latitude: 47.54077684676942, longitude: -121.81356140189055),
           CLLocationCoordinate2D(latitude: 47.54073886288512, longitude: -121.81343515628492),
           CLLocationCoordinate2D(latitude: 47.540696753657755, longitude: -121.81327655296865),
           CLLocationCoordinate2D(latitude: 47.54069186679563, longitude: -121.81308990639104),
           CLLocationCoordinate2D(latitude: 47.54067880445913, longitude: -121.81291838435362),
           CLLocationCoordinate2D(latitude: 47.54065166215942, longitude: -121.81279291333314),
           CLLocationCoordinate2D(latitude: 47.54062441611292, longitude: -121.81266087479514),
           CLLocationCoordinate2D(latitude: 47.54061331968936, longitude: -121.8126070998091),
           CLLocationCoordinate2D(latitude: 47.540632035475134, longitude: -121.81260622220022),
           CLLocationCoordinate2D(latitude: 47.54062193475184, longitude: -121.81257158690559),
           CLLocationCoordinate2D(latitude: 47.5405644351971, longitude: -121.81263771398888),
           CLLocationCoordinate2D(latitude: 47.54053519833593, longitude: -121.81263819004336),
           CLLocationCoordinate2D(latitude: 47.540474850534096, longitude: -121.81259061346768),
           CLLocationCoordinate2D(latitude: 47.540357723540595, longitude: -121.81252370088872)
       ]
       
       
       let path3andHalf: [CLLocationCoordinate2D] = [  CLLocationCoordinate2D(latitude: 47.540356586277994, longitude: -121.81493479592737),
                                                       CLLocationCoordinate2D(latitude: 47.54042917361981, longitude: -121.81478881209706),
                                                       CLLocationCoordinate2D(latitude: 47.540482186058085, longitude: -121.81462943646926),
                                                       CLLocationCoordinate2D(latitude: 47.540537557347825, longitude: -121.81451523145752),
                                                       CLLocationCoordinate2D(latitude: 47.540688607546365, longitude: -121.81441190438284),
                                                       CLLocationCoordinate2D(latitude: 47.54079333312688, longitude: -121.81441547517885),
                                                       CLLocationCoordinate2D(latitude: 47.5408775815623, longitude: -121.81441834776919),
                                                       CLLocationCoordinate2D(latitude: 47.540934329448916, longitude: -121.8144546003273),
                                                       CLLocationCoordinate2D(latitude: 47.540950803419705, longitude: -121.81492943418361),
                                                       CLLocationCoordinate2D(latitude: 47.54095322153233, longitude: -121.81505238578791),
                                                       CLLocationCoordinate2D(latitude: 47.540996205687854, longitude: -121.81515331204892),
                                                       CLLocationCoordinate2D(latitude: 47.54106469277843, longitude: -121.81519060173544),
                                                       CLLocationCoordinate2D(latitude: 47.54112848008345, longitude: -121.81516026729766),
                                                       CLLocationCoordinate2D(latitude: 47.541178466146334, longitude: -121.81508551377226),
                                                       CLLocationCoordinate2D(latitude: 47.541219684226064, longitude: -121.81495966707317),
                                                       CLLocationCoordinate2D(latitude: 47.54123316959548, longitude: -121.81479486145439),
                                                       CLLocationCoordinate2D(latitude: 47.541202691406724, longitude: -121.81462679093757),
                                                       CLLocationCoordinate2D(latitude: 47.54112442933207, longitude: -121.81447554402982),
                                                       CLLocationCoordinate2D(latitude: 47.5410053118141, longitude: -121.81433416278473),
                                                       CLLocationCoordinate2D(latitude: 47.54090397437615, longitude: -121.8142139041906),
                                                       CLLocationCoordinate2D(latitude: 47.54086876570863, longitude: -121.81406907856203),
                                                       CLLocationCoordinate2D(latitude: 47.5407908929275, longitude: -121.81398692545118),
                                                       CLLocationCoordinate2D(latitude: 47.540679096486066, longitude: -121.81396332964663),
                                                       CLLocationCoordinate2D(latitude: 47.540564548094004, longitude: -121.81397735769592),
                                                       CLLocationCoordinate2D(latitude: 47.540453468903024, longitude: -121.8140303721604),
                                                       CLLocationCoordinate2D(latitude: 47.54036379689208, longitude: -121.81413810956154)
        ]
       
       let pathandHalf2: [CLLocationCoordinate2D] = [
        CLLocationCoordinate2D(latitude: 47.54036379689208, longitude: -121.81413810956154),  //
        CLLocationCoordinate2D(latitude: 47.54026978933588, longitude: -121.81421521846345),
        CLLocationCoordinate2D(latitude: 47.54017604430937, longitude: -121.81419054112374),
        CLLocationCoordinate2D(latitude: 47.54012339122529, longitude: -121.81412164775193),
        CLLocationCoordinate2D(latitude: 47.540109488108406, longitude: -121.81399876656239),
        CLLocationCoordinate2D(latitude: 47.54014403879532, longitude: -121.81384898045712),
        CLLocationCoordinate2D(latitude: 47.54021835051015, longitude: -121.81369302575334),
        CLLocationCoordinate2D(latitude: 47.54033059599144, longitude: -121.8136019317771),
        CLLocationCoordinate2D(latitude: 47.54044358699862, longitude: -121.81360871985939),
        CLLocationCoordinate2D(latitude: 47.5405627980364, longitude: -121.81373961421568),
        CLLocationCoordinate2D(latitude: 47.540667665145904, longitude: -121.81379507588564),
        CLLocationCoordinate2D(latitude: 47.5407502996762, longitude: -121.81375787096114),
        CLLocationCoordinate2D(latitude: 47.54077712126427, longitude: -121.8136694550959),
        CLLocationCoordinate2D(latitude: 47.54077684676942, longitude: -121.81356140189055),
        CLLocationCoordinate2D(latitude: 47.54073886288512, longitude: -121.81343515628492),
        CLLocationCoordinate2D(latitude: 47.540696753657755, longitude: -121.81327655296865),
        CLLocationCoordinate2D(latitude: 47.54069186679563, longitude: -121.81308990639104),
        CLLocationCoordinate2D(latitude: 47.54067880445913, longitude: -121.81291838435362),
        CLLocationCoordinate2D(latitude: 47.54065166215942, longitude: -121.81279291333314),
        CLLocationCoordinate2D(latitude: 47.54062441611292, longitude: -121.81266087479514),
        CLLocationCoordinate2D(latitude: 47.54061331968936, longitude: -121.8126070998091),
        CLLocationCoordinate2D(latitude: 47.540632035475134, longitude: -121.81260622220022),
        CLLocationCoordinate2D(latitude: 47.54062193475184, longitude: -121.81257158690559),
        CLLocationCoordinate2D(latitude: 47.5405644351971, longitude: -121.81263771398888),
        CLLocationCoordinate2D(latitude: 47.54053519833593, longitude: -121.81263819004336),
        CLLocationCoordinate2D(latitude: 47.540474850534096, longitude: -121.81259061346768),
        CLLocationCoordinate2D(latitude: 47.540357723540595, longitude: -121.81252370088872)
       ]
       
       
       let path4: [CLLocationCoordinate2D] = [
           CLLocationCoordinate2D(latitude: 47.539751648726515, longitude: -121.81239816440313),
           CLLocationCoordinate2D(latitude: 47.53979270169504, longitude: -121.8126889567702),
           CLLocationCoordinate2D(latitude: 47.539816753103736, longitude: -121.8128636422685),
           CLLocationCoordinate2D(latitude: 47.539805941667, longitude: -121.8130037703151),
           CLLocationCoordinate2D(latitude: 47.53983240698091, longitude: -121.81309993903106),
           CLLocationCoordinate2D(latitude: 47.53991498768938, longitude: -121.81317937669722),
           CLLocationCoordinate2D(latitude: 47.540008031052345, longitude: -121.81324733361024),
           CLLocationCoordinate2D(latitude: 47.54003393775594, longitude: -121.81337183204053),
           CLLocationCoordinate2D(latitude: 47.540045609040114, longitude: -121.8135302809362),
           CLLocationCoordinate2D(latitude: 47.54004409026956, longitude: -121.81367106029052),
           CLLocationCoordinate2D(latitude: 47.54002547024458, longitude: -121.81375869007137),
           CLLocationCoordinate2D(latitude: 47.53999212389753, longitude: -121.8138251542915),
           CLLocationCoordinate2D(latitude: 47.539960579311256, longitude: -121.81386119639929),
           CLLocationCoordinate2D(latitude: 47.53994349293649, longitude: -121.81386991489015),
           CLLocationCoordinate2D(latitude: 47.53994860041183, longitude: -121.81385763651882)
       ]
       
       
       
       
       let gpsPath: [CLLocationCoordinate2D]
       let yawChange: Double
       let angle: Double
       let avgAccel: Double
       let startTime: Date
       let endTime: Date
       let startSpeed: Double
       let endSpeed: Double
      
       
       let dateFormatter = ISO8601DateFormatter()
       dateFormatter.formatOptions = [.withInternetDateTime]
      
       
       let formatStartTime = dateFormatter.date(from: "2025-07-27T17:01:12Z")!
       let formatendTime = dateFormatter.date(from: "2025-07-27T17:01:20Z")!

       
       switch id {
       case 0:
           gpsPath = path1
           yawChange = 0.8324050368494416
           angle = 47.69329545690477
           avgAccel = 0.6692695792134944
        
           startSpeed = 9.547446655980417
           endSpeed = 12.303412390068502
       case 1:
           gpsPath = path2
           yawChange = 4.458542851540717
           angle = 255.45568817150624
           avgAccel = 0.4340121026552042
        
           startSpeed = 9.842202645747182
           endSpeed = 16.996533919169533
       case 2:
           gpsPath = path3
           yawChange = 4.39358281784439
           angle = 251.7337524036791
           avgAccel = 0.5843513837981805
         
           startSpeed = 13.199607427507827
           endSpeed = 13.737882713529089
      
       case 3:
           gpsPath = path4
           yawChange = 1.0436526399722734
           angle = 59.79689154809766
           avgAccel = 0.5171306950942612
        
           startSpeed = 8.110982400393413
           endSpeed = 0.632047922389403
     
       default:
           // fallback to the first dataset if ID is out of range
           gpsPath = path1
           yawChange = 0.8324050368494416
           angle = 47.69329545690477
           avgAccel = 0.6692695792134944
       
           startSpeed = 9.547446655980417
           endSpeed = 12.303412390068502
       }

       return TurnTelemetry(
           startTime: formatStartTime,
           endTime: formatendTime,
           startSpeed: startSpeed,
           endSpeed: endSpeed,
           averageAcceleration: avgAccel,
           yawChange: yawChange,
           gpsPath: gpsPath,
           angle: angle
       )
   }
    
    
    
    
    static func mockTurn(id: Int) -> TurnTelemetry {
        let now = Date()
        
        // Base position: Evergreen Speedway
        let baseLat = 47.8591
        let baseLon = -121.9709
        
        let gpsPath: [CLLocationCoordinate2D]
        let yawChange: Double
        let angle: Double
        
        let avgAccel: Double
        
        switch id {
        case 0: // Gentle left arc
            gpsPath = [
                CLLocationCoordinate2D(latitude: baseLat, longitude: baseLon),
                CLLocationCoordinate2D(latitude: baseLat + 0.00015, longitude: baseLon - 0.0002),
                CLLocationCoordinate2D(latitude: baseLat + 0.0003, longitude: baseLon - 0.0004),
                CLLocationCoordinate2D(latitude: baseLat + 0.00045, longitude: baseLon - 0.0002),
                CLLocationCoordinate2D(latitude: baseLat + 0.0006, longitude: baseLon)
            ]
            yawChange = -0.5  // left turn
            angle = -45.0
            avgAccel = 1.0

        case 1: // Sweeping right arc
            gpsPath = [
                CLLocationCoordinate2D(latitude: baseLat + 0.0007, longitude: baseLon),
                CLLocationCoordinate2D(latitude: baseLat + 0.00085, longitude: baseLon + 0.00025),
                CLLocationCoordinate2D(latitude: baseLat + 0.0010, longitude: baseLon + 0.0005),
                CLLocationCoordinate2D(latitude: baseLat + 0.0012, longitude: baseLon + 0.00025),
                CLLocationCoordinate2D(latitude: baseLat + 0.0013, longitude: baseLon)
            ]
            yawChange = 0.6   // right turn
            angle = 60.0
            avgAccel = 2.0

        case 2: // Tight chicane (left then right)
            gpsPath = [
                CLLocationCoordinate2D(latitude: baseLat + 0.0014, longitude: baseLon),
                CLLocationCoordinate2D(latitude: baseLat + 0.0015, longitude: baseLon - 0.0003),
                CLLocationCoordinate2D(latitude: baseLat + 0.0016, longitude: baseLon + 0.0003),
                CLLocationCoordinate2D(latitude: baseLat + 0.0017, longitude: baseLon)
            ]
            yawChange = 1.0   // zig-zag
            angle = 90.0
            avgAccel = 3.0

        default: // fallback straight-ish
            gpsPath = [
                CLLocationCoordinate2D(latitude: baseLat, longitude: baseLon),
                CLLocationCoordinate2D(latitude: baseLat + 0.0003, longitude: baseLon),
                CLLocationCoordinate2D(latitude: baseLat + 0.0006, longitude: baseLon)
            ]
            yawChange = 1.0
            angle = 80.0
            avgAccel = 1.0
        }
        
        return TurnTelemetry(
            startTime: now,
            endTime: now.addingTimeInterval(3.0),
            startSpeed: 25.0,
            endSpeed: 22.0,
            averageAcceleration: avgAccel,
            yawChange: yawChange,
            gpsPath: gpsPath,
            angle: angle
        )
    }
    
    
    
    
    
    
    
    
    
    
    
    static func mockTurnWithAcceleration(id: Int) -> TurnTelemetry {
            let now = Date()
            let baseLat = 47.8591
            let baseLon = -121.9709

            // Curved path for the turn
            let gpsPath: [CLLocationCoordinate2D] = [
                CLLocationCoordinate2D(latitude: baseLat, longitude: baseLon),
                CLLocationCoordinate2D(latitude: baseLat + 0.0002, longitude: baseLon + 0.0003),
                CLLocationCoordinate2D(latitude: baseLat + 0.0004, longitude: baseLon + 0.0005),
                CLLocationCoordinate2D(latitude: baseLat + 0.0006, longitude: baseLon + 0.0003),
                CLLocationCoordinate2D(latitude: baseLat + 0.0007, longitude: baseLon)
            ]

          

            return TurnTelemetry(
                startTime: now,
                endTime: now.addingTimeInterval(3.0),
                startSpeed: 25.0,
                endSpeed: 22.0,
                averageAcceleration: 20,
                yawChange: 0.45,
                gpsPath: gpsPath,
                angle: 45.0
            )
        }
}







//DEPRECATED NOW IN GRAPHVIEW as distance var


//For graph telemetry
func totalDistance(for gpsPath: [CLLocationCoordinate2D]) -> Double {
    guard gpsPath.count > 1 else { return 0 }
    var distance: Double = 0
    for i in 1..<gpsPath.count {
        let start = CLLocation(latitude: gpsPath[i-1].latitude, longitude: gpsPath[i-1].longitude)
        let end = CLLocation(latitude: gpsPath[i].latitude, longitude: gpsPath[i].longitude)
        distance += end.distance(from: start) // meters
    }
    return distance
}
struct AccelerationSegment: Identifiable {
    let id = UUID()
    let distance: Double // meters from start
    let acceleration: Double // avg acce
}




