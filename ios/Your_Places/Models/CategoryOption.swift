//
//  Untitled.swift
//  Your_Places
//
//  Created by Aidan Huerta on 2/9/26.
//

import SwiftUI
import CoreLocation
import Foundation

struct CategoryOption: Identifiable, Codable, Hashable {
    var id: String { title }          // stable identity
    let title: String
    let geoapifyCategories: [String]
}
