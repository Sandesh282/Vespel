import SwiftUI
import UIKit
import CoreImage
import Combine
import AVFoundation

// MARK: - Lyric Data Model
struct LyricLine: Identifiable, Decodable {
    let id = UUID()
    let time: TimeInterval
    let text: String
    
    private enum CodingKeys: String, CodingKey {
        case time, text
    }
}

// MARK: - Lyric Manager
class LyricManager: ObservableObject {
    @Published var currentTime: TimeInterval = 0.0
    @Published var currentLyricIndex: Int = 0
    @Published var lyrics: [LyricLine] = []
    
    private var cancellable: AnyCancellable?
    
    init() {
        loadLyrics()
    }
    
    func loadLyrics() {
        guard let url = Bundle.main.url(forResource: "havana_lyrics", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            lyrics = [
                LyricLine(time: 0, text: "Havana, ooh na-na"),
                LyricLine(time: 3.2, text: "Half of my heart is in Havana, ooh na-na")
            ]
            return
        }
        
        do {
            let decoder = JSONDecoder()
            lyrics = try decoder.decode([LyricLine].self, from: data)
        } catch {
            print("Error decoding lyrics: \(error)")
            lyrics = [
                LyricLine(time: 0, text: "Error loading lyrics"),
                LyricLine(time: 5, text: "Check JSON format")
            ]
        }
    }
    
    func startTimer() {
        cancellable = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateCurrentTime()
            }
    }
    
    func stopTimer() {
        cancellable?.cancel()
    }
    
    private func updateCurrentTime() {
        if let index = lyrics.lastIndex(where: { $0.time <= currentTime }) {
            currentLyricIndex = index
        }
    }
    
    func reset() {
        currentTime = 0.0
        currentLyricIndex = 0
    }
}

// MARK: - Lyrics View
struct LyricsView: View {
    @ObservedObject var lyricManager: LyricManager
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                            ForEach(lyricManager.lyrics.indices, id: \.self) { index in
                                let line = lyricManager.lyrics[index]
                                let isActive = index == lyricManager.currentLyricIndex
                                
                                Group {
                                    if line.text.hasPrefix("[") {
                                        Text(line.text)
                                            .font(.subheadline)
                                            .foregroundColor(isActive ? .yellow : .gray.opacity(0.7))
                                    } else {
                                        Text(line.text)
                                            .foregroundColor(isActive ? .white : .gray)
                                            .font(isActive ? .title3.bold() : .body)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                                .multilineTextAlignment(.center)
                                .padding(.vertical, 4)
                                .id(index)
                            }
                        }
                        .padding()
            }
            .onReceive(lyricManager.$currentLyricIndex) { index in
                withAnimation(.easeInOut) {
                    proxy.scrollTo(index, anchor: .center)
                }
            }
        }
    }
}
class DisplayLinkWrapper: NSObject {
    @objc var updateHandler: (() -> Void)?
    
    @objc func update() {
        updateHandler?()
    }
}

struct PlayerView: View {
    @State private var animate = false
    @State private var dragOffset: CGSize = .zero
    @State private var songProgress: CGFloat = 0.0
    @State private var showQueue = false
    @State private var isPlaying = false
    @State private var showLyrics = false
    @StateObject private var lyricManager = LyricManager()
    @State private var audioPlayer: AVAudioPlayer?
    @State private var displayLink: CADisplayLink?
    @State private var songDuration: TimeInterval = 218.0
    
    private let songTitle = "Havana"
    private let artistName = "Camila Cabello ft. Young Thug"
    @State private var displayLinkWrapper = DisplayLinkWrapper()
    
    
    private func setupAudioPlayer() {
        guard let url = Bundle.main.url(forResource: "havana", withExtension: "mp3") else {
            print("Havana.mp3 not found")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            songDuration = audioPlayer?.duration ?? 218.0
            
            displayLinkWrapper.updateHandler = {
                updateProgress()
            }

            displayLink = CADisplayLink(
                target: displayLinkWrapper,
                selector: #selector(DisplayLinkWrapper.update)
            )
            displayLink?.add(to: .current, forMode: .common)
        } catch {
            print("Error initializing audio player: \(error.localizedDescription)")
        }
    }

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.15, green: 0.02, blue: 0.12),
                    Color(red: 0.25, green: 0.01, blue: 0.15)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                ZStack {
                    PremiumCircularProgress(progress: songProgress)
                        .frame(width: 280, height: 280)
                    
                    Image("havana_cover")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 200, height: 200)
                        .clipShape(Circle())
                        .shadow(radius: 15)
                        .scaleEffect(animate ? 1 : 0.8)
                        .opacity(animate ? 1 : 0)
                        .rotation3DEffect(.degrees(Double(dragOffset.width / 10)), axis: (x: 0, y: 1, z: 0))
                        .gesture(
                            DragGesture()
                                .onChanged { gesture in
                                    dragOffset = gesture.translation
                                }
                                .onEnded { _ in
                                    withAnimation(.easeOut) {
                                        dragOffset = .zero
                                    }
                                }
                        )
                        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: animate)
                }
                
                VStack(spacing: 10) {
                    Text("Now Playing")
                        .font(.title2)
                        .foregroundColor(.gray)
                        .opacity(animate ? 1 : 0)
                        .offset(y: animate ? 0 : 25)
                        .animation(.easeOut.delay(0.2), value: animate)
                    
                    Text(songTitle)
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)
                        .opacity(animate ? 1 : 0)
                        .offset(y: animate ? 0 : 20)
                        .animation(.easeOut.delay(0.3), value: animate)
                    
                    Text(artistName)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .opacity(animate ? 1 : 0)
                        .offset(y: animate ? 0 : 15)
                        .animation(.easeOut.delay(0.35), value: animate)
                }
                .offset(y: 20)
                
                HStack(spacing: 40) {
                    Button(action: toggleQueue) {
                        Image(systemName: "list.bullet")
                            .font(.title)
                            .foregroundColor(showQueue ? .yellow : .white)
                    }
                    
                    HStack(spacing: 28) {
                        Button(action: previousSong) {
                            Image(systemName: "backward.fill")
                                .font(.title3)
                                .foregroundColor(.white)
                        }
                        
                        Button(action: togglePlayback) {
                            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                .font(.title)
                                .foregroundColor(.black)
                                .frame(width: 60, height: 60)
                                .background(Circle().fill(Color.white))
                                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3)
                        }
                        
                        Button(action: nextSong) {
                            Image(systemName: "forward.fill")
                                .font(.title3)
                                .foregroundColor(.white)
                        }
                    }
                    
                    Button(action: toggleLyrics) {
                        Image(systemName: "text.quote")
                            .font(.title)
                            .foregroundColor(showLyrics ? .yellow : .white)
                    }
                }
                .padding(.top, 20)
                .padding(.top, 8)
                .opacity(animate ? 1 : 0)
                .offset(y: animate ? 0 : 40)
                .animation(.easeOut.delay(0.4), value: animate)
                
                Spacer()
                
                BlurView2(style: .systemUltraThinMaterialDark)
                    .frame(height: showQueue ? 280 : (showLyrics ? 300 : 120))
                    .overlay(
                        VStack(spacing: 12) {
                            if !showLyrics && !showQueue {
                                VStack(spacing: 4) {
                                    Text(songTitle)
                                        .font(.title3)
                                        .bold()
                                        .foregroundColor(.white)
                                    
                                    Text(artistName)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                .transition(.opacity)
                            }
                            
                            if showQueue {
                                queueView
                            } else if showLyrics {
                                LyricsView(lyricManager: lyricManager)
                                    .frame(maxHeight: .infinity)
                                    .transition(.opacity)
                            }
                        }
                        .padding()
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 30))
                    .padding(.horizontal)
                    .offset(y: animate ? -60 : 100)
                    .opacity(animate ? 1 : 0)
                    .animation(.easeOut.delay(0.55), value: animate)
            }
        }
        .onAppear {
            animate = true
            setupAudioPlayer()
        }
        .onDisappear {
            audioPlayer?.stop()
            displayLink?.invalidate()
            lyricManager.stopTimer()
        }
    }
    
    private let songImages = [
        "asitwas",
        "blinding",
        "darkside",
        "easyonme",
        "forgetme",
        "heatwaves",
        "imgood",
        "levitating",
        "peaches",
        "shivers",
        "stay",
        "underinfluence"
    ]
    private var queueView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(songImages, id: \.self) { songName in
                    ZStack(alignment: .bottom) {
                        Image(songName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 120, height: 160)
                            .cornerRadius(20)
                            .clipped()

                        Text(songName.capitalized)
                            .font(.headline)
                            .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.9), radius: 4, x: 0, y: 2)
                            .padding(.bottom, 8)
                    }
                    .frame(width: 120, height: 160)
                    .scrollTransition { content, phase in
                        content
                            .opacity(phase.isIdentity ? 1.0 : 0.3)
                            .scaleEffect(phase.isIdentity ? 1.0 : 0.7)
                            .offset(y: phase.isIdentity ? 0 : 50)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .scrollTargetBehavior(.viewAligned)
    }

    private func updateProgress() {
        guard let player = audioPlayer else { return }
        let progress = player.currentTime / songDuration
        songProgress = CGFloat(progress)
        lyricManager.currentTime = player.currentTime
    }
    
    private func togglePlayback() {
        if isPlaying {
            audioPlayer?.pause()
            lyricManager.stopTimer()
        } else {
            audioPlayer?.play()
            lyricManager.startTimer()
        }
        isPlaying.toggle()
    }
    
    private func toggleQueue() {
        withAnimation(.spring()) {
            showQueue.toggle()
            if showQueue { showLyrics = false }
        }
    }
    
    private func toggleLyrics() {
        withAnimation(.spring()) {
            showLyrics.toggle()
            if showLyrics { showQueue = false }
        }
    }
    
    private func previousSong() {
        audioPlayer?.currentTime = 0
        lyricManager.reset()
        songProgress = 0
    }
    
    private func nextSong() {
        audioPlayer?.currentTime = 0
        lyricManager.reset()
        songProgress = 0
        if isPlaying {
            audioPlayer?.play()
        }
    }
}

struct PremiumCircularProgress: View {
    var progress: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [Color.purple.opacity(0.3), Color.blue.opacity(0.3), Color.purple.opacity(0.3)]),
                        center: .center
                    ),
                    lineWidth: 24
                )
                .blur(radius: 20)
                .opacity(0.6)
                .frame(width: 300, height: 300)
            
            Circle()
                .stroke(Color.white.opacity(0.08), lineWidth: 12)
            
            Circle()
                .trim(from: 0.0, to: progress)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [.purple, .blue, .pink, .purple]),
                        center: .center),
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: Color.purple.opacity(0.6), radius: 6, x: 0, y: 0)
                .shadow(color: Color.blue.opacity(0.4), radius: 12, x: 0, y: 0)
                .animation(.easeInOut(duration: 0.8), value: progress)
        }
        .frame(width: 260, height: 260)
    }
}

struct BlurView2: UIViewRepresentable {
    var style: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}


#Preview {
    PlayerView()
        .preferredColorScheme(.dark)
}

//import SwiftUI
//import UIKit
//import Combine
//import AVFoundation
//
//// MARK: - Lyric Data Model
//struct LyricLine: Identifiable {
//    let id = UUID()
//    let time: TimeInterval
//    let text: String
//
//}
//
//// MARK: - Lyric Manager
//class LyricManager: ObservableObject {
//    @Published var currentTime: TimeInterval = 0.0
//    @Published var currentLyricIndex: Int = 0
//
//    var lyrics: [LyricLine] = [
//
//        LyricLine(time: 0, text: "First line of the song"),
//        LyricLine(time: 10, text: "Second line of the song"),
//
//    ]
//
//    private var cancellable: AnyCancellable?
//
//    init() {
//        // Simulate song playback time progression
//        cancellable = Timer.publish(every: 1, on: .main, in: .common)
//            .autoconnect()
//            .sink { [weak self] _ in
//                self?.updateCurrentTime()
//            }
//    }
//
//    private func updateCurrentTime() {
//        currentTime += 1
//        if let index = lyrics.lastIndex(where: { $0.time <= currentTime }) {
//            currentLyricIndex = index
//        }
//    }
//}
//
//// MARK: - Lyrics View
//struct LyricsView: View {
//    @ObservedObject var lyricManager: LyricManager
//
//    var body: some View {
//        ScrollViewReader { proxy in
//            ScrollView {
//                VStack(alignment: .leading, spacing: 8) {
//                    ForEach(lyricManager.lyrics.indices, id: \.self) { index in
//                        Text(lyricManager.lyrics[index].text)
//                            .foregroundColor(index == lyricManager.currentLyricIndex ? .white : .gray)
//                            .font(index == lyricManager.currentLyricIndex ? .title3.bold() : .body)
//                            .id(index)
//                    }
//                }
//                .padding()
//            }
//            .onReceive(lyricManager.$currentLyricIndex) { index in
//                withAnimation {
//                    proxy.scrollTo(index, anchor: .center)
//                }
//            }
//        }
//    }
//}
//struct PlayerView: View {
//    @State private var animate = false
//    @State private var dragOffset: CGSize = .zero
//    @State private var songProgress: CGFloat = 0.3
//    @State private var showQueue = false
//    @State private var isPlaying = false
//    @State private var timerCancellable: AnyCancellable? = nil
//    @State private var showLyrics = false
//    @StateObject private var lyricManager = LyricManager()
//    @State private var currentLyricIndex = 0
//
//    private let lyrics = [
//            "Granada, tierra soñada por mí,",
//            "Mi cantar se vuelve gitano cuando es para ti.",
//            "Mi cantar, hecho de fantasía,",
//            "Mi cantar, flor de melancolía,",
//            "Que yo te vengo a dar.",
//            "Granada, tierra ensangrentada en tardes de toros,",
//            "Mujer que conserva el embrujo de los ojos moros.",
//            "Te sueño rebelde y gitana, cubierta de flores,",
//            "Y beso tu boca de grana, jugosa manzana que me habla de amores.",
//            "Granada, manola cantada en coplas preciosas,",
//            "No tengo otra cosa que darte que un ramo de rosas.",
//            "De rosas de suave fragancia que le dieran marco a la Virgen Morena.",
//            "Granada, tu tierra está llena de lindas mujeres, de sangre y de sol."
//        ]
//
//    var body: some View {
//        ZStack {
//            LinearGradient(
//                gradient: Gradient(colors: [
//                    Color(red: 0.05, green: 0.02, blue: 0.12),
//                    Color(red: 0.12, green: 0.01, blue: 0.2)
//                ]),
//                startPoint: .topLeading,
//                endPoint: .bottomTrailing
//            )
//            .ignoresSafeArea()
//
//            VStack(spacing: 24) {
//                Spacer()
//
//                ZStack {
//                    PremiumCircularProgress(progress: songProgress)
//                        .frame(width: 280, height: 280)
//
//                    Image("album_cover")
//                        .resizable()
//                        .aspectRatio(contentMode: .fill)
//                        .frame(width: 200, height: 200)
//                        .clipShape(Circle())
//                        .shadow(radius: 15)
//                        .scaleEffect(animate ? 1 : 0.8)
//                        .opacity(animate ? 1 : 0)
//                        .rotation3DEffect(.degrees(Double(dragOffset.width / 10)), axis: (x: 0, y: 1, z: 0))
//                        .gesture(
//                            DragGesture()
//                                .onChanged { gesture in
//                                    dragOffset = gesture.translation
//                                }
//                                .onEnded { _ in
//                                    withAnimation(.easeOut) {
//                                        dragOffset = .zero
//                                    }
//                                }
//                        )
//                        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: animate)
//                }
//
//                VStack(spacing: 10) {
//                    Text("Now Playing")
//                        .font(.title2)
//                        .foregroundColor(.gray)
//                        .opacity(animate ? 1 : 0)
//                        .offset(y: animate ? 0 : 25)
//                        .animation(.easeOut.delay(0.2), value: animate)
//
//                    Text("Song Title")
//                        .font(.title)
//                        .bold()
//                        .foregroundColor(.white)
//                        .opacity(animate ? 1 : 0)
//                        .offset(y: animate ? 0 : 20)
//                        .animation(.easeOut.delay(0.3), value: animate)
//                }
//                .offset(y: 20)
//
//                HStack(spacing: 40) {
//                    Button(action: {
//                        // Shuffle action
//                    }) {
//                        Image(systemName: "shuffle")
//                            .font(.title)
//                            .foregroundColor(.white)
//                    }
//
//                    HStack(spacing: 28) {
//                            Button(action: {
//                                // Previous action
//                            }) {
//                                Image(systemName: "backward.fill")
//                                    .font(.title3)
//                                    .foregroundColor(.white)
//                            }
//
//                            Button(action: {
//                                isPlaying.toggle()
//                            }) {
//                                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
//                                    .font(.title)
//                                    .foregroundColor(.black)
//                                    .frame(width: 60, height: 60)
//                                    .background(Circle().fill(Color.white))
//                                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3)
//                            }
//
//                            Button(action: {
//                                // Next action
//                            }) {
//                                Image(systemName: "forward.fill")
//                                    .font(.title3)
//                                    .foregroundColor(.white)
//                            }
//                        }
//
//                    Button(action: {
//                        withAnimation(.spring()) {
//                            showQueue.toggle()
//                            showLyrics = !showQueue
//                        }
//                        }) {
//                            Image(systemName: "list.bullet")
//                                .font(.title)
//                                .foregroundColor(.white)
//                        }
//                }
//                .padding(.top, 20)
//                .foregroundColor(.white)
//                .padding(.top, 8)
//                .opacity(animate ? 1 : 0)
//                .offset(y: animate ? 0 : 40)
//                .animation(.easeOut.delay(0.4), value: animate)
//
//                Spacer()
//
////                BlurView2(style: .systemUltraThinMaterialDark)
////                    .frame(height: showQueue ? 280 : 120)
////                    .overlay(
////                        VStack(spacing: 12) {
////                            VStack(spacing: 4) {
////                                Text("Song Title")
////                                    .font(.title3)
////                                    .bold()
////                                    .foregroundColor(.white)
////
////                                Text("Artist Name")
////                                    .font(.subheadline)
////                                    .foregroundColor(.gray)
////                            }
////                            .opacity(animate ? 1 : 0)
////                            .offset(y: animate ? 0 : 20)
////                            .animation(.easeOut.delay(0.5), value: animate)
////
////                            if showQueue {
////                                ScrollView(.horizontal) {
////                                    HStack(spacing: 16) {
////                                        ForEach(1..<10) { index in
////                                            RoundedRectangle(cornerRadius: 20)
////                                                .fill(LinearGradient(
////                                                    colors: [Color.purple.opacity(0.7), Color.blue.opacity(0.7)],
////                                                    startPoint: .topLeading,
////                                                    endPoint: .bottomTrailing))
////                                                .frame(width: 120, height: 160)
////                                                .overlay(
////                                                    VStack {
////                                                        Image(systemName: "music.note")
////                                                            .font(.largeTitle)
////                                                            .foregroundColor(.white)
////                                                        Text("Track \(index)")
////                                                            .foregroundColor(.white)
////                                                            .bold()
////                                                    }
////                                                    .padding()
////                                                )
////                                                .scrollTransition { content, phase in
////                                                    content
////                                                        .opacity(phase.isIdentity ? 1.0 : 0.3)
////                                                        .scaleEffect(phase.isIdentity ? 1.0 : 0.7)
////                                                        .offset(y: phase.isIdentity ? 0 : 50)
////                                                }
////                                        }
////                                    }
////                                    .scrollTargetLayout()
////                                }
////                                .scrollTargetBehavior(.viewAligned)
////                                .contentMargins(16, for: .scrollContent)
////                                .transition(.move(edge: .bottom).combined(with: .opacity))
////                            }
////                        }
////                        .padding()
////                    )
////                    .clipShape(RoundedRectangle(cornerRadius: 30))
////                    .padding(.horizontal)
////                    .offset(y: animate ? -60 : 100)
////                    .opacity(animate ? 1 : 0)
////                    .animation(.easeOut.delay(0.55), value: animate)
//                BlurView2(style: .systemUltraThinMaterialDark)
//                    .frame(height: showQueue ? 280 : 120)
//                    .overlay(
//                        VStack(spacing: 12) {
//                            VStack(spacing: 4) {
//                                Text("Song Title")
//                                    .font(.title3)
//                                    .bold()
//                                    .foregroundColor(.white)
//
//                                Text("Artist Name")
//                                    .font(.subheadline)
//                                    .foregroundColor(.gray)
//                            }
//                            .opacity(!showLyrics && !showQueue ? 1 : 0)
//                            .offset(y: !showLyrics && !showQueue ? 0 : 20)
//                            .animation(.easeOut.delay(0.5), value: showLyrics)
//
//                            if showQueue {
//                                ScrollView(.horizontal) {
//                                    HStack(spacing: 16) {
//                                        ForEach(1..<10) { index in
//                                            RoundedRectangle(cornerRadius: 20)
//                                                .fill(LinearGradient(
//                                                    colors: [Color.purple.opacity(0.7), Color.blue.opacity(0.7)],
//                                                    startPoint: .topLeading,
//                                                    endPoint: .bottomTrailing))
//                                                .frame(width: 120, height: 160)
//                                                .overlay(
//                                                    VStack {
//                                                        Image(systemName: "music.note")
//                                                            .font(.largeTitle)
//                                                            .foregroundColor(.white)
//                                                        Text("Track \(index)")
//                                                            .foregroundColor(.white)
//                                                            .bold()
//                                                    }
//                                                    .padding()
//                                                )
//                                                .scrollTransition { content, phase in
//                                                    content
//                                                        .opacity(phase.isIdentity ? 1.0 : 0.3)
//                                                        .scaleEffect(phase.isIdentity ? 1.0 : 0.7)
//                                                        .offset(y: phase.isIdentity ? 0 : 50)
//                                                }
//                                        }
//                                    }
//                                    .scrollTargetLayout()
//                                }
//                                .scrollTargetBehavior(.viewAligned)
//                                .contentMargins(16, for: .scrollContent)
//                                .transition(.move(edge: .bottom).combined(with: .opacity))
//                            } else if showLyrics && isPlaying {
//                                HStack {
//                                    Spacer()
//                                    LyricsView(lyricManager: lyricManager)
//                                        .frame(maxWidth: .infinity, alignment: .center)
//                                    Spacer()
//                                }
//                                .transition(.opacity.combined(with: .move(edge: .bottom)))
//                                .animation(.easeInOut, value: showLyrics)
//
//                            }
//                        }
//                        .padding()
//                    )
//                    .clipShape(RoundedRectangle(cornerRadius: 30))
//                    .padding(.horizontal)
//                    .offset(y: animate ? -60 : 100)
//                    .opacity(animate ? 1 : 0)
//                    .animation(.easeOut.delay(0.55), value: animate)
//
//            }
//        }
//        .onAppear {
//            animate = true
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                if !showQueue { showLyrics = true }
//            }
//
//        }
//    }
//}
//
//struct PremiumCircularProgress: View {
//    var progress: CGFloat
//
//    var body: some View {
//        ZStack {
//
//            Circle()
//                .stroke(
//                    AngularGradient(
//                        gradient: Gradient(colors: [Color.purple.opacity(0.3), Color.blue.opacity(0.3), Color.purple.opacity(0.3)]),
//                        center: .center
//                    ),
//                    lineWidth: 24
//                )
//                .blur(radius: 20)
//                .opacity(0.6)
//                .frame(width: 300, height: 300)
//
//            // Background faded circle
//            Circle()
//                .stroke(Color.white.opacity(0.08), lineWidth: 12)
//
//            // Main progress circle
//            Circle()
//                .trim(from: 0.0, to: progress)
//                .stroke(
//                    AngularGradient(
//                        gradient: Gradient(colors: [.purple, .blue, .pink, .purple]),
//                        center: .center),
//                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
//                )
//                .rotationEffect(.degrees(-90))
//                .shadow(color: Color.purple.opacity(0.6), radius: 6, x: 0, y: 0)
//                .shadow(color: Color.blue.opacity(0.4), radius: 12, x: 0, y: 0)
//                .animation(.easeInOut(duration: 0.8), value: progress)
//        }
//        .frame(width: 260, height: 260)
//    }
//}
//
//struct BlurView2: UIViewRepresentable {
//    var style: UIBlurEffect.Style
//
//    func makeUIView(context: Context) -> UIVisualEffectView {
//        UIVisualEffectView(effect: UIBlurEffect(style: style))
//    }
//
//    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
//}
//
//
//struct CircularProgressView: View {
//    var progress: CGFloat
//
//    var body: some View {
//        ZStack {
//            Circle()
//                .stroke(
//                    LinearGradient(colors: [Color.white.opacity(0.05), Color.white.opacity(0.15)], startPoint: .top, endPoint: .bottom),
//                    lineWidth: 10
//                )
//
//            Circle()
//                .trim(from: 0.0, to: progress)
//                .stroke(
//                    AngularGradient(
//                        gradient: Gradient(colors: [Color.purple.opacity(0.6), Color.blue.opacity(0.6), Color.purple.opacity(0.6)]),
//                        center: .center
//                    ),
//                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
//                )
//                .shadow(color: Color.purple.opacity(0.4), radius: 10, x: 0, y: 0)
//                .rotationEffect(.degrees(-90))
//                .animation(.easeInOut(duration: 0.6), value: progress)
//
//            Circle()
//                .stroke(
//                    Color.white.opacity(0.06),
//                    lineWidth: 1
//                )
//        }
//        .frame(width: 240, height: 240)
//        .background(
//            Circle()
//                .fill(Color.white.opacity(0.02))
//                .blur(radius: 10)
//        )
//    }
//}
//
//
