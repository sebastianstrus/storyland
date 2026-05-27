//
//  ConfettiView.swift
//  Світ Казок
//

import SwiftUI

struct ConfettiView: View {
    @State private var animateOn = false
    private let pieces: [ConfettiPiece] = (0..<60).map { _ in ConfettiPiece.random() }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(pieces) { piece in
                    ConfettiShape(piece: piece)
                        .fill(piece.color)
                        .frame(width: piece.size, height: piece.size)
                        .position(
                            x: piece.startX * geo.size.width,
                            y: animateOn ? geo.size.height + 60 : -80
                        )
                        .rotationEffect(.degrees(animateOn ? piece.endRotation : piece.startRotation))
                        .opacity(animateOn ? 0.0 : 1.0)
                        .animation(
                            .easeOut(duration: piece.duration).delay(piece.delay),
                            value: animateOn
                        )
                }
            }
            .onAppear {
                animateOn = true
            }
        }
        .allowsHitTesting(false)
    }
}

private struct ConfettiPiece: Identifiable {
    let id = UUID()
    let startX: CGFloat
    let size: CGFloat
    let color: Color
    let startRotation: Double
    let endRotation: Double
    let duration: Double
    let delay: Double
    let shapeKind: Int

    static func random() -> ConfettiPiece {
        let palette: [Color] = [
            Color(red: 0.99, green: 0.61, blue: 0.27),
            Color(red: 0.96, green: 0.31, blue: 0.51),
            Color(red: 0.40, green: 0.69, blue: 0.97),
            Color(red: 0.55, green: 0.36, blue: 0.95),
            Color(red: 0.31, green: 0.81, blue: 0.55),
            Color(red: 1.00, green: 0.84, blue: 0.31)
        ]
        return ConfettiPiece(
            startX: CGFloat.random(in: 0.05...0.95),
            size: CGFloat.random(in: 8...16),
            color: palette.randomElement() ?? .pink,
            startRotation: Double.random(in: 0...360),
            endRotation: Double.random(in: 360...1080),
            duration: Double.random(in: 2.4...4.0),
            delay: Double.random(in: 0...0.6),
            shapeKind: Int.random(in: 0...2)
        )
    }
}

private struct ConfettiShape: Shape {
    let piece: ConfettiPiece

    func path(in rect: CGRect) -> Path {
        switch piece.shapeKind {
        case 0:
            return Path(ellipseIn: rect)
        case 1:
            return Path(rect)
        default:
            var path = Path()
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
            path.closeSubpath()
            return path
        }
    }
}
