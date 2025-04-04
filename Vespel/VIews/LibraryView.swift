import SwiftUI

struct LibraryView: View {
    @State private var searchText = ""
    @State private var animateGrid = false
    
    let albums: [Album] = [
        Album(artist: "The Weeknd", title: "Blinding Lights", artwork: "blinding"),
        Album(artist: "Glass Animals", title: "Heat Waves", artwork: "heatwaves"),
        Album(artist: "Harry Styles", title: "As It Was", artwork: "asitwas"),
        Album(artist: "Dua Lipa", title: "Levitating", artwork: "levitating"),
        Album(artist: "Justin Bieber", title: "Peaches", artwork: "peaches"),
        Album(artist: "Ed Sheeran", title: "Shivers", artwork: "shivers"),
        Album(artist: "The Kid LAROI", title: "Stay", artwork: "stay"),
        Album(artist: "Adele", title: "Easy On Me", artwork: "easyonme")
    ]
    var filteredAlbums: [Album] {
            if searchText.isEmpty {
                return albums
            } else {
                return albums.filter {
                    $0.title.localizedCaseInsensitiveContains(searchText) ||
                    $0.artist.localizedCaseInsensitiveContains(searchText) ||
                    $0.title.folding(options: .diacriticInsensitive, locale: .current)
                       .localizedCaseInsensitiveContains(searchText.folding(options: .diacriticInsensitive, locale: .current))
                }
            }
        }
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.05, green: 0.02, blue: 0.12),
                    Color(red: 0.12, green: 0.01, blue: 0.2)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.white.opacity(0.7))
                    
                    TextField("Search Library", text: $searchText)
                        .foregroundColor(.white)
                        .placeholder(when: searchText.isEmpty) {
                            Text("Search Library").foregroundColor(.white.opacity(0.5))
                        }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(Blur_View(style: .systemUltraThinMaterialDark))
                .cornerRadius(20)
                .padding(.horizontal)
                .padding(.top, 20)
                
                ScrollView {
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 20),
                            GridItem(.flexible(), spacing: 20)
                        ],
                        spacing: 20
                    ) {
                        ForEach(filteredAlbums.indices, id: \.self) { index in
                            AlbumCard(album: albums[index])
                                .opacity(animateGrid ? 1 : 0)
                                .offset(y: animateGrid ? 0 : 50)
                                .animation(
                                    .interpolatingSpring(stiffness: 100, damping: 10)
                                    .delay(Double(index) * 0.05),
                                    value: animateGrid
                                )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical)
                }
            }
        }
        .navigationTitle("Library")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            animateGrid = true
        }
    }
}

struct AlbumCard: View {
    let album: Album
    
    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            
            ZStack(alignment: .bottom) {
                Image(album.artwork)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size.width, height: size.height)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(LinearGradient(
                                gradient: Gradient(colors: [.white.opacity(0.2), .clear]),
                                startPoint: .top,
                                endPoint: .bottom
                            ), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                
                LinearGradient(
                    gradient: Gradient(colors: [.clear, .black.opacity(0.8)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .cornerRadius(20)
                
                Text(album.title)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.bottom, 12)
                    .padding(.horizontal, 8)
            }
            .frame(width: size.width, height: size.height)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

struct Album: Identifiable {
    let id = UUID()
    let artist: String
    let title: String
    let artwork: String
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

#Preview {
    LibraryView()
        .preferredColorScheme(.dark)
}
