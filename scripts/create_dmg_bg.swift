#!/usr/bin/env swift

import AppKit

// Create image with retina resolution
let width: CGFloat = 600
let height: CGFloat = 400
let scale: CGFloat = 2

let rep = NSBitmapImageRep(
    bitmapDataPlanes: nil,
    pixelsWide: Int(width * scale),
    pixelsHigh: Int(height * scale),
    bitsPerSample: 8,
    samplesPerPixel: 4,
    hasAlpha: true,
    isPlanar: false,
    colorSpaceName: .calibratedRGB,
    bytesPerRow: 0,
    bitsPerPixel: 0
)!

rep.size = NSSize(width: width, height: height)

NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)

// Background color (light gray)
NSColor(white: 0.94, alpha: 1.0).setFill()
NSRect(x: 0, y: 0, width: width, height: height).fill()

// Arrow - pointing from app to Applications folder
let arrowPath = NSBezierPath()
let arrowY: CGFloat = 220
let arrowStartX: CGFloat = 220
let arrowEndX: CGFloat = 400

// Arrow line
arrowPath.move(to: NSPoint(x: arrowStartX, y: arrowY))
arrowPath.line(to: NSPoint(x: arrowEndX - 15, y: arrowY))

// Arrow head
arrowPath.move(to: NSPoint(x: arrowEndX - 25, y: arrowY + 12))
arrowPath.line(to: NSPoint(x: arrowEndX, y: arrowY))
arrowPath.line(to: NSPoint(x: arrowEndX - 25, y: arrowY - 12))

NSColor(white: 0.5, alpha: 1.0).setStroke()
arrowPath.lineWidth = 2.0
arrowPath.lineCapStyle = .round
arrowPath.lineJoinStyle = .round
arrowPath.stroke()

// Text "Drag to Applications"
let paragraphStyle = NSMutableParagraphStyle()
paragraphStyle.alignment = .center

let textAttributes: [NSAttributedString.Key: Any] = [
    .font: NSFont.systemFont(ofSize: 18, weight: .medium),
    .foregroundColor: NSColor(white: 0.4, alpha: 1.0),
    .paragraphStyle: paragraphStyle
]

let text = "Drag to Applications"
let textRect = NSRect(x: 0, y: 50, width: width, height: 30)
text.draw(in: textRect, withAttributes: textAttributes)

// Draw Applications folder icon on the right side
let appFolderIcon = NSWorkspace.shared.icon(forFile: "/Applications")
let iconSize: CGFloat = 100
appFolderIcon.size = NSSize(width: iconSize, height: iconSize)

// Position: right side where the app-drop-link will place the alias
let iconX: CGFloat = 450 - iconSize / 2  // Center at x=450 (matches --app-drop-link)
let iconY: CGFloat = 210 - iconSize / 2  // Center at y=210 (400-190=210, converted from top)
appFolderIcon.draw(
    in: NSRect(x: iconX, y: iconY, width: iconSize, height: iconSize),
    from: .zero,
    operation: .sourceOver,
    fraction: 1.0
)

NSGraphicsContext.restoreGraphicsState()

// Save as PNG
let pngData = rep.representation(using: .png, properties: [:])!
let outputPath = ProcessInfo.processInfo.arguments.count > 1
    ? ProcessInfo.processInfo.arguments[1]
    : "/tmp/dmg-background.png"

try! pngData.write(to: URL(fileURLWithPath: outputPath))
print("Created DMG background at: \(outputPath)")
