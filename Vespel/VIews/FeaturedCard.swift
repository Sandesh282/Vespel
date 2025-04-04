import SwiftUI

struct FeaturedCard: View {
    let song: Song
    
    var body: some View {
        ZStack {
            
            if UIImage(named: song.artwork) != nil {
                Image(song.artwork)
                    .resizable()
                    .scaledToFill()
            } else {
                
                LinearGradient(
                    gradient: Gradient(colors: [.purple, .blue]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
            
            LinearGradient(
                gradient: Gradient(colors: [Color.black.opacity(0.0), Color.black.opacity(0.6)]),
                startPoint: .center,
                endPoint: .bottom
            )
            

            VStack(alignment: .leading, spacing: 8) {
                Spacer()
                
                Text(song.title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(song.artist)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer().frame(height: 10)
            }
            .padding()
            

            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        // Show menu or something
                    }) {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                }
                Spacer()
            }
            .padding()
            

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 50, height: 50)
                            Image(systemName: "play.fill")
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                }
            }
        }
        .frame(width: 200, height: 200)
        .cornerRadius(20)
        .clipped()
        .shadow(radius: 5)
    }
}

struct FeaturedCard_Previews: PreviewProvider {
    static var previews: some View {
        FeaturedCard(
            song: Song(title: "The Dark Side",
                       artist: "Muse - Simulation Theory",
                       duration: 210,
                       artwork: "darkside",
                       
                       audioFile: "darkside.mp3")
        )
        .preferredColorScheme(.dark)
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
