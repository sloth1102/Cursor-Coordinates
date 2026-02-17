//
//  MouseTracker.swift
//  PolarMouse
//
//  Created by Parker Saitowitz on 2/13/26.
//


import AppKit

class MouseTracker {
    static func getMousePosition() -> NSPoint {
        // Returns current mouse position
        return NSEvent.mouseLocation
    }
}