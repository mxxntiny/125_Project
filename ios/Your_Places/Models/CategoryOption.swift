//
//  Untitled.swift
//  Your_Places
//
//  Created by Aidan Huerta on 2/9/26.
//

import SwiftUI
import CoreLocation
import Foundation


// A simple model that represents one category shown to the user
struct CategoryOption: Identifiable {
    let id = UUID()
    let title: String                  // Text shown in the UI
    let geoapifyCategories: [String]   // Categories sent to the backend
}
