import AVFoundation

class AudioManager: ObservableObject {
    static let shared = AudioManager()
    private var player: AVAudioPlayer?
    
    @Published var currentSong: Song?
    @Published var isPlaying = false
    
    func play(song: Song) {
        guard let url = Bundle.main.url(forResource: song.audioFile, withExtension: "mp3") else { return }
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            currentSong = song
            player?.play()
            isPlaying = true
        } catch {
            print("Audio error: \(error)")
        }
    }
    
    func togglePlay() {
        if isPlaying {
            player?.pause()
        } else {
            _ = player?.play()  
        }
        isPlaying.toggle()
    }
}
