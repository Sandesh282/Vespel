import SwiftUI

struct ContentView: View {

      @State private var selectedTab: Int = 0
  
    var body: some View {
        ZStack(alignment: .bottom) {
            
            switch selectedTab {
            case 1: LibraryView()
            case 2: PlayerView()
            case 3: ProfileView()
            default: HomeView()
            }
            
            HStack(spacing: 10) {
                TabBarButton(
                    systemImage: "house.fill",
                    isSelected: selectedTab == 0
                ) { selectedTab = 0 }
                
                TabBarButton(
                    systemImage: "music.note.list",
                    isSelected: selectedTab == 1
                ) { selectedTab = 1 }
                
                TabBarButton(
                    systemImage: "play.circle.fill",
                    isSelected: selectedTab == 2
                ) { selectedTab = 2 }
                TabBarButton(systemImage: "person.crop.circle", isSelected: selectedTab == 3) {
                    selectedTab = 3
                }
                
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 0)
                    .padding(.horizontal, 12)
                    .padding(.bottom, -2)
            )
            .padding(.bottom, -5)
            .offset(y: 10)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
    
}
struct TabBarButton: View {
    let systemImage: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
            Button(action: action) {
                VStack(spacing: 4) {
                    Image(systemName: systemImage)
                        .font(.system(size: 30, weight: .semibold))

                }
                .frame(maxWidth: .infinity)
                .foregroundColor(isSelected ? .white : .gray)
                .contentShape(Rectangle())
            }
        }
}


#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
