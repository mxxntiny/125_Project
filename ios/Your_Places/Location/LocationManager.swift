//
//  LocationManager.swift
//  Your_Places
//
//  Created by Aidan Huerta on 1/29/26.
//

/* This file is responsible ONLY for:
// - Requesting location permissions
// - Retrieving the user’s current GPS location
// - Exposing location updates to SwiftUI
//
// You should modify this file ONLY when:
// - Changing how location is requested (one-time vs continuous updates)
// - Adjusting GPS accuracy or battery usage
// - Handling location permission changes differently
// - Improving error handling or retry behavior
// - Supporting background location or mock/test locations
//
// This file should NOT contain:
// - Backend/API calls
// - UI logic
// - Recommendation logic or user preferences
//
// Keep this file focused on location access only.
*/


// CoreLocation provides access to GPS, location permissions,
// latitude, longitude, and related system services
import CoreLocation


// Combine allows values to be observed and automatically update the UI
// This powers the @Published property wrapper
import Combine



// LocationManager is responsible for:
// 1. Requesting location permission
// 2. Requesting the user's current location
// 3. Exposing location data to SwiftUI

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    // NSObject -> Required boilerplate to talk to Apple system APIs
    // ObservableObject -> watch this object and automatically update the UI when values change
    // CLLocationManagerDelegate -> This class promises to handle location callbacks.
    
    
    // Apple's built-in location manager that talks to GPS hardware
    private let manager = CLLocationManager()

    // Stores the user's current location (latitude + longitude)
    // ? at end -> Optional because the location may not be available immediately
    @Published var location: CLLocation?
    
    // Stores the current authorization (permission) status
    // Examples: notDetermined, denied, authorizedWhenInUse
    @Published var authorizationStatus: CLAuthorizationStatus

    
    // This initializer runs when LocationManager is created
    override init() {
        
        // Read the current authorization status from the system
        self.authorizationStatus = manager.authorizationStatus
        
        // Call the initializer of NSObject (required)
        super.init()
        
        // Tell the CLLocationManager to send updates to this class
        manager.delegate = self
        
        // Request the best possible GPS accuracy
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    
    // Call this function to ask for permission and request the user's location
    func requestLocation() {
        
        // Ask the user for permission to access location while the app is in use
        // This triggers a system popup
        manager.requestWhenInUseAuthorization()
        
        // Request a single location update
        // (not continuous tracking)
        manager.requestLocation()
    }

    // MARK: - CLLocationManagerDelegate
    // The methods below are called automatically by iOS

    
    // Called when the system successfully provides location data
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // Use the most recent location provided by the system
        // Assigning this triggers UI updates because of @Published
        location = locations.first
        
    }

    // Called when the system fails to retrieve location data
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        // Print the error to the console for debugging
        print("Location error:", error.localizedDescription)
        
    }
    
    // Called when the user's location permission changes
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        // Update the published authorization status
        authorizationStatus = manager.authorizationStatus
        
        // If permission has been granted, request the user's location
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            
            manager.requestLocation()
        }
    }
}
