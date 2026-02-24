//
//  LocationProviding.swift
//  Your_Places
//
//  Created by Aidan Huerta on 2/23/26.
//
// Location abstraction layer
//  - ViewModels depend on LocationProviding (protocol), not LocationManager directly.
//  - LocationService adapts LocationManager to this protocol.
//

import Foundation
import CoreLocation

protocol LocationProviding {
    var authorizationStatus: CLAuthorizationStatus { get }
    func requestLocation()
    func currentCoordinate() -> CLLocationCoordinate2D?
    func waitForCoordinate(timeoutSeconds: Double) async -> CLLocationCoordinate2D?
}

struct LocationService: LocationProviding {
    private let manager: LocationManager

    init(manager: LocationManager) {
        self.manager = manager
    }

    var authorizationStatus: CLAuthorizationStatus {
        manager.authorizationStatus
    }

    func requestLocation() {
        manager.requestLocation()
    }

    func currentCoordinate() -> CLLocationCoordinate2D? {
        manager.location?.coordinate
    }

    /// Simple polling wait (keeps this refactor lightweight for a class project).
    func waitForCoordinate(timeoutSeconds: Double) async -> CLLocationCoordinate2D? {
        let start = Date()
        while Date().timeIntervalSince(start) < timeoutSeconds {
            if let coord = currentCoordinate() { return coord }
            try? await Task.sleep(nanoseconds: 200_000_000) // 0.2s
        }
        return nil
    }
}
