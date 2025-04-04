import SwiftUI

struct MiniPlayerBar: View {
    var body: some View {
        HStack {
            Image(systemName: "music.note")
                .resizable()
                .frame(width: 40, height: 40)
                .cornerRadius(5)
            VStack(alignment: .leading) {
                Text("Song Title")
                    .foregroundColor(.white)
                    .font(.headline)
                Text("Artist")
                    .foregroundColor(.gray)
                    .font(.subheadline)
            }
            Spacer()
            Button(action: {
            }) {
                Image(systemName: "play.fill")
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(BlurView(style: .systemUltraThinMaterialDark))
        .cornerRadius(15)
        .padding(.horizontal)
    }
}

struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) { }
}

#Preview {
    MiniPlayerBar()
}
