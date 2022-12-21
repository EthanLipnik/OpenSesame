//
//  HorizontalSizeClass.swift
//  OpenSesame (macOS)
//
//  Created by Ethan Lipnik on 12/20/22.
//

import SwiftUI

enum HorizontalClass {
    case compact
    case regular
}

private struct HorizontalSizeClassKey: EnvironmentKey {
    static let defaultValue = HorizontalClass.regular
}

extension EnvironmentValues {
    var horizontalSizeClass: HorizontalClass {
        get { self[HorizontalSizeClassKey.self] }
        set { self[HorizontalSizeClassKey.self] = newValue }
    }
}
