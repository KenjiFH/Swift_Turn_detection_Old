import SwiftUI
import MapKit

struct RecentTurnView: View {
    @StateObject private var motionManager = MotionManager()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("📊 Driving Telemetry")
                    .font(.title)

                Divider()

                if motionManager.turnTelemetryRecords.isEmpty {
                    Text("No turns detected yet.")
                        .foregroundColor(.gray)
                } else {
                    ForEach(motionManager.turnTelemetryRecords) { turn in
                        VStack(alignment: .leading, spacing: 8) {
                            Text("🧭 Turn at \(turn.startTime.formatted(date: .abbreviated, time: .standard))")
                                .font(.headline)

                            TurnMapView(turn: turn)
                                .frame(height: 300)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .shadow(radius: 4)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Angle: \(turn.angle, specifier: "%.1f")°")
                                Text("Yaw Change: \(turn.yawChange, specifier: "%.3f") rad")
                                Text("Duration: \(turn.endTime.timeIntervalSince(turn.startTime), specifier: "%.2f")s")
                                Text("Entry Speed: \(turn.startSpeed, specifier: "%.2f") m/s")
                                Text("Exit Speed: \(turn.endSpeed, specifier: "%.2f") m/s")
                                Text("Average Acceleration: \(turn.averageAcceleration, specifier: "%.2f") m/s²")
                            }
                            .font(.subheadline)
                        }

                        Divider()
                    }
                }
            }
            .padding()
        }
    }
}

#Preview {
    RecentTurnView()
}

