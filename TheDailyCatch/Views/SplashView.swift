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

            // Content layered on top
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 40)

                // Tape stickers — flush to screen edges
                VStack(spacing: 16) {
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

                // Logo
                Image("BigLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 108)
                    .padding(.top, 16)

                // Tagline
                Text("5 stories. 2 minutes. Freshly caught\nfor your everyday.")
                    .font(.custom("SpaceGrotesk-Light", size: 14).weight(.medium))
                    .foregroundStyle(AppTheme.textDark.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.top, 20)

                Spacer()
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
