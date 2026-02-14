//
//  graphView.swift
//  Apexiel Proj1
//
//  Created by Kenji Fahselt on 9/9/25.
//

import SwiftUI
import Charts
import CoreLocation

/*
 ***

 ### `TurnTelemetry` Extension

 **`distance`** * **Description:** This computed property calculates the total distance of a turn in meters. It iterates through the `gpsPath` array, which contains `CLLocationCoordinate2D` points, and sums the distances between each consecutive point. This provides a more accurate distance than simply measuring between the start and end points.
 * **Returns:** A `Double` representing the total distance of the turn in meters.
 * **Example Usage:** `let turnDistance = myTurn.distance`

 ---

 ### `AccelerationDataPoint` Struct

 **Description:** This is a simple, identifiable data structure used to prepare telemetry data for charting. It conforms to the `Identifiable` protocol, which is a requirement for rendering data points in a `ForEach` loop within a `SwiftUI` `Chart`.

 * **Properties:**
     * `id`: A `UUID` that uniquely identifies each data point.
     * `cumulativeDistance`: A `Double` representing the total distance traveled from the start of the run up to the end of a specific turn.
     * `acceleration`: A `Double` representing the average acceleration for that turn.
 * **Purpose:** It transforms complex `TurnTelemetry` objects into a simplified format (`x`, `y` values) that the `Charts` framework can easily consume and visualize.

 ---

 ### `dataPoints(from:)` Function

 * **Description:** This utility function converts an array of `TurnTelemetry` objects into an array of `AccelerationDataPoint` structs. It iterates through the telemetry data, calculates the cumulative distance at each turn, and creates a new data point for each one.
 * **Parameters:**
     * `telemetry`: An array of `TurnTelemetry` objects containing the raw data for the run.
 * **Returns:** An array of `AccelerationDataPoint` structs, suitable for use in a `Chart` view.
 * **Example Usage:** `let chartData = dataPoints(from: myTurnTelemetryArray)`

 ---

 ### `AccelerationChartView` Struct

 **Description:** A `SwiftUI` `View` that displays a line chart of average acceleration versus cumulative distance. It uses the `Charts` framework to create a visually appealing and informative graph.

 * **Properties:**
     * `telemetry`: The source of data for the chart, an array of `TurnTelemetry` objects.
 * **View Body:**
     * The view's body first calls the `dataPoints(from:)` function to prepare the data for charting.
     * A `Chart` is created, which automatically handles the layout and rendering of the graph.
     * A `ForEach` loop iterates through the prepared data points.
     * For each point, a `LineMark` is created to draw a line segment connecting the points.
     * The `x` and `y` axes are mapped to `cumulativeDistance` and `acceleration`, respectively.
     * The line is styled with a blue color and a circular symbol is added at each data point for clarity.
     * `.chartXAxisLabel` and `.chartYAxisLabel` modifiers are used to provide clear, descriptive labels for the axes.
     * `padding()` is applied to provide spacing around the chart.

 ---

 ### `AccelerationChartView_Previews` Struct

 **Description:** This struct provides a live preview of the `AccelerationChartView` in Xcode. It's a standard feature of `SwiftUI` that allows developers to see what their view will look like without needing to run the app on a simulator or device.

 * **Purpose:** It creates sample `TurnTelemetry` data (presumably loaded from a JSON file via a helper method `.turnWithJson`) and passes it to the `AccelerationChartView`, ensuring that the preview is populated with realistic data.
 * **Configuration:** The preview is configured with a fixed height and padding to showcase the chart effectively.
 
 
 
 
 
 
 
 */



// Helper extension to calculate cumulative distance
extension TurnTelemetry {
    var distance: Double {
        guard gpsPath.count > 1 else { return 0 }
        var total: Double = 0
        for i in 0..<(gpsPath.count - 1) {
            let loc1 = CLLocation(latitude: gpsPath[i].latitude, longitude: gpsPath[i].longitude)
            let loc2 = CLLocation(latitude: gpsPath[i+1].latitude, longitude: gpsPath[i+1].longitude)
            total += loc1.distance(from: loc2) // meters
        }
        return total
    }
}

struct AccelerationDataPoint: Identifiable {
    let id = UUID()
    let cumulativeDistance: Double
    let acceleration: Double
}

// Convert telemetry into data points for the chart
func dataPoints(from telemetry: [TurnTelemetry]) -> [AccelerationDataPoint] {
    var points: [AccelerationDataPoint] = []
    var cumulativeDistance: Double = 0
    
    for turn in telemetry {
        cumulativeDistance += turn.distance
        points.append(
            AccelerationDataPoint(cumulativeDistance: cumulativeDistance, acceleration: turn.averageAcceleration)
        )
    }
    
    return points
}

struct AccelerationChartView: View {
    let telemetry: [TurnTelemetry]
    
    var body: some View {
        let points = dataPoints(from: telemetry)
        
        Chart {
            ForEach(points) { point in
                LineMark(
                    x: .value("Distance (m)", point.cumulativeDistance),
                    y: .value("Avg Acceleration (m/s²)", point.acceleration)
                )
                .foregroundStyle(.blue)
                .symbol(Circle()) // Optional: show dots at each point
            }
        }
        .chartXAxisLabel("Cumulative Distance (m)")
        .chartYAxisLabel("Average Acceleration (m/s²)")
        .padding()
    }
}

// Preview with fake telemetry
struct AccelerationChartView_Previews: PreviewProvider {
    static var previews: some View {
        let jsonTelemetry: [TurnTelemetry] = [
            .turnWithJson(id: 0),
            .turnWithJson(id: 1),
            .turnWithJson(id: 2),
            .turnWithJson(id: 3)
        ]
        AccelerationChartView(telemetry: jsonTelemetry)
            .frame(height: 300)
            .padding()
    }
}

