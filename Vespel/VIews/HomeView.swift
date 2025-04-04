import SwiftUI

struct HomeView: View {
    
    @State private var searchText: String = ""
    @State private var selectedTag: String = "Trending right now"
    @State private var featuredSongs: [Song] = [
        Song(title: "Havana",
             artist: "Camila Cabello",
             duration: 200,
             artwork: "havana_cover",
             audioFile: "havana.mp3"),
        Song(title: "The Dark Side",
             artist: "Muse - Simulation Theory",
             duration: 210,
             artwork: "darkside",
             audioFile: "darkside.mp3"),
        Song(title: "As It Was",
             artist: "Harry Styles",
             duration: 200,
             artwork: "asitwas",
             audioFile: "asitwas.mp3")
        
    ]
    
    private let tags = ["Trending right now", "Rock", "Hip Hop", "Electro"]
    
    @State private var trendingSongs: [Song] = [
        Song(title: "I'm Good (Blue)",
             artist: "David Guetta & Bebe Rexha",
             duration: 180,
             artwork: "imgood",
             audioFile: "im_good_blue.mp3"),
        Song(title: "Under the Influence",
             artist: "Chris Brown",
             duration: 210,
             artwork: "underinfluence",
             audioFile: "under_influence.mp3"),
        Song(title: "Forget Me",
             artist: "Lewis Capaldi",
             duration: 200,
             artwork: "forgetme",
             audioFile: "forget_me.mp3")
    ]
    
    @State private var favoriteSongs: Set<String> = []
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [
                                Color(red: 0.05, green: 0.02, blue: 0.12),
                                Color(red: 0.12, green: 0.01, blue: 0.2)
                            ]), startPoint: .topLeading, endPoint: .bottomTrailing)
                            .ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading) {
                        
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            TextField("Search", text: $searchText)
                                .textFieldStyle(PlainTextFieldStyle())
                        }
                        .padding()
                        .background(Color.white.opacity(0.15))
                        .cornerRadius(15)
                        .padding([.horizontal, .top])
                        
                        Text("Trending right now")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white)
                            .padding(.horizontal)
                            .padding(.top, 10)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
                                ForEach(featuredSongs) { song in
                                    FeaturedCard(song: song)
                                    
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.top, 8)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(tags, id: \.self) { tag in
                                    Button(action: {
                                        selectedTag = tag
                                        
                                    }) {
                                        Text(tag)
                                            .font(.callout)
                                            .foregroundColor(selectedTag == tag ? .white : .gray)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(selectedTag == tag
                                                          ? Color.purple.opacity(0.8)
                                                          : Color.white.opacity(0.05))
                                            )
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.top, 8)
                        
                        ScrollView {
                            VStack(alignment: .leading, spacing: 12) {
                                ForEach(trendingSongs) { song in
                                    HStack(alignment: .leading, spacing: 15) {
                                        Image(song.artwork)
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width: 60, height: 60)
                                                        .cornerRadius(12)
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(song.title)
                                                .font(.headline)
                                                .foregroundColor(.white)
                                            Text(song.artist)
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                        Spacer()

                                        Button(action: {
                                            toggleFavorite(song)
                                        }) {
                                            Image(systemName: favoriteSongs.contains(song.title) ? "heart.fill" : "heart")
                                                .foregroundColor(.white)
                                        }
                                    }
                                    .padding(.vertical, 8)
                                    .padding(.horizontal)
                                    .background(Color.white.opacity(0.05))
                                    .cornerRadius(10)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 10)
                        }
                        
                        Spacer()
                    }
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Text("Home")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                    }
                    
                    .background(Color.clear)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func toggleFavorite(_ song: Song) {
        if favoriteSongs.contains(song.title) {
            favoriteSongs.remove(song.title)
        } else {
            favoriteSongs.insert(song.title)
        }
    }
}

#Preview{
    HomeView()
        .preferredColorScheme(.dark)
}
