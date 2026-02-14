//
//  StorageManager.swift
//  Apexiel Proj1
//
//  Created by Kenji Fahselt on 7/26/25.
//

import Foundation
import CoreLocation
/*
 
 Build and run your app.

 Plug in your iPhone → Open Finder → Select your device.

 Your app appears under the Files tab with its documents.

 ✅ Any files in the Documents/ directory will be accessible here!
 
 
 
 */
/// A utility for saving, listing, and loading turn telemetry data to and from JSON files.
struct TelemetryStorageManager {
    
    /// Saves an array of `TurnTelemetry` records to a uniquely named JSON file in the app's Documents directory.
    /// - Parameter turns: The array of telemetry records to encode and persist.
   
    static func saveTurnTelemetryToJSON(_ turns: [TurnTelemetry]) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601

        do {
            let data = try encoder.encode(turns)
            
            // Generate a unique filename using timestamp
            let timestamp = ISO8601DateFormatter().string(from: Date())
            let filename = "turn_telemetry_\(timestamp).json"
            let url = getDocumentsDirectory().appendingPathComponent(filename)
            
            try data.write(to: url)
            print("✅ Saved \(turns.count) turn records to: \(url)")
            
            // Update manifest
            addFileToManifest(filename: filename)
            
        } catch {
            print("❌ Failed to save turn telemetry: \(error)")
        }
    }
    
    /// Adds a saved telemetry file to the manifest JSON, which keeps track of all stored telemetry filenames.
    /// - Parameter filename: The name of the newly created telemetry JSON file.
   
    static private func addFileToManifest(filename: String) {
        let manifestURL = getDocumentsDirectory().appendingPathComponent("telemetry_manifest.json")
        var manifest: [String] = []

        if let data = try? Data(contentsOf: manifestURL),
           let existing = try? JSONDecoder().decode([String].self, from: data) {
            manifest = existing
        }
        
        manifest.append(filename)
        
        if let newData = try? JSONEncoder().encode(manifest) {
            try? newData.write(to: manifestURL)
        }
    }
    
    /// Returns the URL for the app's Documents directory.
    /// - Returns: A `URL` pointing to the Documents directory.
    static func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    /// Lists all telemetry JSON files in the Documents directory that match the `turn_telemetry_` filename pattern.
    /// - Returns: An array of `URL`s pointing to the saved telemetry files.
    static func listTelemetryFiles() -> [URL] {
        let docs = getDocumentsDirectory()
        let files = (try? FileManager.default.contentsOfDirectory(
            at: docs,
            includingPropertiesForKeys: nil
        )) ?? []
        
        // Only return files that match your pattern
        return files.filter { $0.lastPathComponent.hasPrefix("turn_telemetry_") }
    }
    
    /// Loads telemetry records from a given JSON file URL.
    /// - Parameter url: The URL of the telemetry JSON file to load.
    /// - Returns: An array of `TurnTelemetry` records if decoding succeeds, otherwise `nil`.
    static func loadTelemetry(from url: URL) -> [TurnTelemetry]? {
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([TurnTelemetry].self, from: data)
        } catch {
            print("❌ Failed to load telemetry from \(url): \(error)")
            return nil
        }
    }
}



