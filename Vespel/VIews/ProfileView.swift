import SwiftUI

struct ProfileView: View {
    @State private var animate = false
    let userName = "Kryonix"
    let nickname = "@vespel_san"

    let likedSongs: [Song] = [
        Song(title: "The Dark Side", artist: "Muse", duration: 210, artwork: "darkside", audioFile: "darkside.mp3"),
        Song(title: "Under the Influence", artist: "Chris Brown", duration: 210, artwork: "underinfluence", audioFile: "under_influence.mp3")
    ]

    let recentlyPlayed: [Song] = [
        Song(title: "Forget Me", artist: "Lewis Capaldi", duration: 200, artwork: "forgetme", audioFile: "forget_me.mp3"),
        Song(title: "I'm Good (Blue)", artist: "David Guetta", duration: 180, artwork: "imgood", audioFile: "im_good_blue.mp3")
    ]

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [
                Color(red: 0.05, green: 0.02, blue: 0.12),
                Color(red: 0.12, green: 0.01, blue: 0.2)
            ]), startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()

            ScrollView {
                        VStack(alignment: .center, spacing: 24) {
                            VStack(spacing: 16) {

                                Image("profile_picture")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                                    .overlay(
                                        Circle()
                                            .stroke(LinearGradient(
                                                gradient: Gradient(colors: [.white.opacity(0.3), .clear]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ), lineWidth: 2)
                                    )
                                    .padding(4)
                                    .background(
                                        ZStack {
                                                Circle()
                                                    .fill(Color.clear)
                                                Blur_View(style: .systemUltraThinMaterialDark)
                                                    .clipShape(Circle())
                                                }
                                    )
                                    .opacity(animate ? 1 : 0)
                                    .scaleEffect(animate ? 1 : 0.8)
                                    .offset(y: animate ? 0 : 50)
                                
                                VStack(spacing: 4) {
                                    Text(userName)
                                        .font(.system(size: 28, weight: .bold))
                                        .foregroundColor(.white)
                                        .kerning(0.5)
                                    
                                    Text(nickname)
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(.gray)
                                }
                                .opacity(animate ? 1 : 0)
                                .offset(y: animate ? 0 : 20)
                            }
                            .animation(.easeOut(duration: 0.4).delay(0.2), value: animate)
                            .padding(.vertical, 24)


                            VStack(alignment: .leading, spacing: 24) {

                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Favorites")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 5)
                                        .opacity(animate ? 1 : 0)
                                        .offset(y: animate ? 0 : 20)
                                        .animation(.easeOut.delay(0.3), value: animate)
                                    
                                    ForEach(likedSongs.indices, id: \.self) { index in
                                        SongGlassCard(song: likedSongs[index])
                                            .opacity(animate ? 1 : 0)
                                            .offset(y: animate ? 0 : 30)
                                            .animation(
                                                .interpolatingSpring(stiffness: 100, damping: 10)
                                                .delay(Double(index) * 0.05 + 0.4),
                                                value: animate
                                            )
                                    }
                                }
                                .padding(.horizontal)

                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Recently Played")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 5)
                                        .opacity(animate ? 1 : 0)
                                        .offset(y: animate ? 0 : 20)
                                        .animation(.easeOut.delay(0.5), value: animate)
                                    
                                    ForEach(recentlyPlayed.indices, id: \.self) { index in
                                        SongGlassCard(song: recentlyPlayed[index])
                                            .opacity(animate ? 1 : 0)
                                            .offset(y: animate ? 0 : 30)
                                            .animation(
                                                .interpolatingSpring(stiffness: 100, damping: 10)
                                                .delay(Double(index) * 0.05 + 0.6),
                                                value: animate
                                            )
                                    }
                                }
                                .padding(.horizontal)
                                }
                            }
                            .padding(.top)
                        }
                    }
                    .navigationTitle("Profile")
                    .navigationBarTitleDisplayMode(.inline)
                    .onAppear {
                        withAnimation(.spring()) {
                            animate = true
                        }
                    }
                }
            }

// MARK: - Glassmorphism Song Card
struct SongGlassCard: View {
    let song: Song

    var body: some View {
        HStack(spacing: 14) {
            Image(song.artwork)
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                Text(song.title)
                    .font(.headline)
                    .foregroundColor(.white)
                Text(song.artist)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Spacer()
        }
        .padding()
        .background(Blur_View(style: .systemUltraThinMaterial))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 3)
    }
}

// MARK: - Blur View for Glassmorphism Effect
struct Blur_View: UIViewRepresentable {
    var style: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: style))
        return view
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

#Preview {
    ProfileView()
        .preferredColorScheme(.dark)
}
