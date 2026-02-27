import SwiftUI

struct FishingAnimationView: View {
    @State private var bobY: CGFloat = 0
    @State private var fishX: CGFloat = 40
    @State private var fishGoingRight = false
    @State private var splashVisible = false

    private let px: CGFloat = 3
    private let c = Color(hex: "2C2C2C")

    var body: some View {
        ZStack {
            // Fishing line — attached to top of bobber
            Rectangle()
                .fill(c.opacity(0.4))
                .frame(width: 1.5, height: 55)
                .offset(x: 0, y: -5 + bobY / 2)

            // Bobber (hook)
            VStack(spacing: 0) {
                Rectangle().fill(c.opacity(0.6)).frame(width: px, height: px * 2)
                Rectangle().fill(Color(hex: "E84B3A")).frame(width: px * 2, height: px)
            }
            .offset(y: 24 + bobY)

            // Water line
            HStack(spacing: px) {
                ForEach(0..<15, id: \.self) { _ in
                    Rectangle()
                        .fill(Color(hex: "5D84C4").opacity(0.2))
                        .frame(width: px, height: px)
                }
            }
            .offset(y: 34)

            // Splash pixels
            Group {
                pxBlock(c: Color(hex: "5D84C4").opacity(0.4)).offset(x: -12, y: 26)
                pxBlock(c: Color(hex: "5D84C4").opacity(0.3)).offset(x: 10, y: 24)
                pxBlock(c: Color(hex: "5D84C4").opacity(0.35)).offset(x: -8, y: 22)
                pxBlock(c: Color(hex: "5D84C4").opacity(0.25)).offset(x: 14, y: 26)
            }
            .opacity(splashVisible ? 1 : 0)

            // Pixel fish — flips direction based on movement
            pixelFish
                .scaleEffect(x: fishGoingRight ? -1 : 1, y: 1)
                .offset(x: fishX, y: 48)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                bobY = 6
                splashVisible = true
            }
            animateFish()
        }
    }

    private func animateFish() {
        // Swim left
        fishGoingRight = false
        withAnimation(.easeInOut(duration: 2.5)) {
            fishX = -40
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            // Swim right
            fishGoingRight = true
            withAnimation(.easeInOut(duration: 2.5)) {
                fishX = 40
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                animateFish()
            }
        }
    }

    private func pxBlock(c: Color) -> some View {
        Rectangle().fill(c).frame(width: px, height: px)
    }

    private func p(_ opacity: Double = 0.7) -> some View {
        Rectangle().fill(c.opacity(opacity)).frame(width: px, height: px)
    }

    private var e: some View {
        Color.clear.frame(width: px, height: px)
    }

    private var w: some View {
        Rectangle().fill(Color.white).frame(width: px, height: px)
    }

    private var pixelFish: some View {
        // Logo-style pixel fish: 7 rows, white eye, vertical triangle tail fin
        VStack(spacing: 0) {
            // Row 1: dorsal fin + tail top
            HStack(spacing: 0) { e; e; e; e; e; p(); p(); e; e; e; e; e; e; p(); p() }
            // Row 2: upper body + tail
            HStack(spacing: 0) { e; e; e; p(); p(); p(); p(); p(); p(); p(); e; e; p(); p(); p() }
            // Row 3: body top + tail
            HStack(spacing: 0) { e; e; p(); p(); p(); p(); p(); p(); p(); p(); p(); p(); p(); p(); p() }
            // Row 4: center (eye) + tail
            HStack(spacing: 0) { e; e; p(); w; p(); p(); p(); p(); p(); p(); p(); p(); p(); p(); p() }
            // Row 5: body bottom + tail
            HStack(spacing: 0) { e; e; p(); p(); p(); p(); p(); p(); p(); p(); p(); p(); p(); p(); p() }
            // Row 6: lower body + tail
            HStack(spacing: 0) { e; e; e; p(); p(); p(); p(); p(); p(); p(); e; e; p(); p(); p() }
            // Row 7: ventral fin + tail bottom
            HStack(spacing: 0) { e; e; e; e; e; p(); p(); e; e; e; e; e; e; p(); p() }
        }
    }
}
