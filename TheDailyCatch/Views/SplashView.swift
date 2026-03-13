import SwiftUI

struct SplashView: View {
    var onContinue: () -> Void

    @State private var appeared = false
    @State private var didContinue = false

    var body: some View {
        ZStack {
            Color(hex: "E8E7E5")
                .ignoresSafeArea()

            // Typewriter pinned to bottom, full width
            VStack {
                Spacer()
                Image("SplashBackground")
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIScreen.main.bounds.width)
            }
            .ignoresSafeArea(edges: .bottom)

            // Tape stickers at top
            VStack(spacing: -10) {
                Image("DailyCatchUpTape")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 110)
                    .rotationEffect(.degrees(-3), anchor: .leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Image("StayInformedTape")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 110)
                    .rotationEffect(.degrees(2), anchor: .trailing)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .frame(maxHeight: .infinity, alignment: .top)

            // Logo + tagline centered vertically
            VStack(spacing: 20) {
                Image("BigLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 108)

                Text("5 stories. 2 minutes. Freshly caught\nfor your everyday.")
                    .font(.custom("SpaceGrotesk-Light", size: 14).weight(.medium))
                    .foregroundStyle(AppTheme.textDark.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.easeIn(duration: 0.5)) {
                appeared = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                guard !didContinue else { return }
                didContinue = true
                onContinue()
            }
        }
        .onTapGesture {
            guard !didContinue else { return }
            didContinue = true
            onContinue()
        }
    }
}
