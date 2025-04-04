import SwiftUI

struct GlassInfoPanel: View {
    var title: String
    var artist: String

    var body: some View {
        BlurView2(style: .systemUltraThinMaterialDark)
            .frame(height: 60)
            .overlay(
                VStack(spacing: 4) {
                    Text(title)
                        .font(.title3)
                        .bold()
                        .foregroundColor(.white)

                    Text(artist)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding()
            )
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .padding(.horizontal)
    }
}
