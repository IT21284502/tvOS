import Foundation
import AVFoundation
import Combine
import Combine

// MARK: - AVAudioPlayerDelegate
class AudioManager: NSObject, ObservableObject, AVAudioPlayerDelegate {
    // Audio level for visualization (0.0 to 1.0)
    @Published var currentAmplitude: Float = 0.1
    private var audioMeteringTimer: Timer?
    
    // Audio session for metering
    private let audioSession = AVAudioSession.sharedInstance()

    // MARK: - Properties
    struct Song: Identifiable {
        let id = UUID()
        let name: String
        let audioFileName: String
        let imageName: String
    }
    
    @Published var songs: [Song] = [
        Song(name: "Song 1", audioFileName: "song1", imageName: "c1"),
        Song(name: "Song 2", audioFileName: "song2", imageName: "c2"),
        Song(name: "Song 3", audioFileName: "song3", imageName: "c3")
    ]
    
    @Published var albumArt = ["cover1", "cover2", "cover3"]
    
    @Published var currentIndex = 0
    @Published var isPlaying = false
    @Published var progress: Double = 0 {
        didSet {
            objectWillChange.send()
        }
    }
    @Published var repeatOn = false
    
    var currentSong: Song {
        songs[currentIndex]
    }

    var player: AVAudioPlayer?
    private var timer: Timer?
    
    // MARK: - Initialization
    override init() {
        super.init()
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }

    func selectSong(at index: Int) {
        guard index >= 0 && index < songs.count else { return }
        currentIndex = index
        playCurrent()
    }
    
    func next() {
        if currentIndex < songs.count - 1 {
            currentIndex += 1
        } else {
            currentIndex = 0
        }
        playCurrent()
    }
    
    func previous() {
        if currentIndex > 0 {
            currentIndex -= 1
        } else {
            currentIndex = songs.count - 1
        }
        playCurrent()
    }
    
    func playPause() {
        guard let player = player else { return }
        
        if player.isPlaying {
            player.pause()
            stopAudioMetering()
        } else {
            do {
                try audioSession.setCategory(.playback, mode: .default)
                try audioSession.setActive(true)
                player.play()
                startAudioMetering()
            } catch {
                print("Failed to play audio: \(error.localizedDescription)")
            }
        }
        isPlaying = player.isPlaying
    }

    private func playCurrent() {
        let song = songs[currentIndex]
        
        do {
            // Stop current playback and clean up
            player?.stop()
            timer?.invalidate()
            stopAudioMetering()
            
            // Get the URL for the audio file
            guard let url = Bundle.main.url(forResource: song.audioFileName, withExtension: "mp3") else {
                print("Error: Could not find audio file \(song.audioFileName).mp3")
                return
            }
            
            // Create and configure the audio player
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            player?.isMeteringEnabled = true  // Enable metering
            player?.prepareToPlay()
            
            // Start playback and update state
            player?.play()
            isPlaying = true
            startProgressTimer()
            startAudioMetering()  // Start metering after player is ready
            
        } catch {
            print("Error loading file: \(error)")
        }
    }

    // MARK: - Playback Control
    private func startProgressTimer() {
        timer?.invalidate() // Invalidate any existing timer
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let player = self.player else { return }
            
            // Update progress
            if player.duration > 0 {
                self.progress = player.currentTime / player.duration
            }
            
            // If we've reached the end of the track
            if !player.isPlaying && self.progress >= 0.99 {
                if self.repeatOn {
                    player.currentTime = 0
                    player.play()
                } else {
                    self.next()
                }
            }
            
            // Notify observers of the change
            self.objectWillChange.send()
        }
    }
    
    // MARK: - AVAudioPlayerDelegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if !flag {
            print("Playback failed")
            return
        }
        
        if repeatOn {
            player.currentTime = 0
            player.play()
        } else {
            next()
        }
        
        // Notify observers of the change
        objectWillChange.send()
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("Audio player decode error: \(error?.localizedDescription ?? "Unknown error")")
        isPlaying = false
        stopAudioMetering()
        objectWillChange.send()
    }
    
    // MARK: - Audio Metering
    
    private func startAudioMetering() {
        // Invalidate any existing timer
        audioMeteringTimer?.invalidate()
        
        // Enable metering on the player
        player?.isMeteringEnabled = true
        
        // Start a new timer to update the audio levels
        audioMeteringTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self = self, let player = self.player else { return }
            
            // Update the meters
            player.updateMeters()
            
            // Get the average power for the first channel
            let minDb: Float = -80.0
            let decibels = player.averagePower(forChannel: 0)
            
            // Convert decibels to a 0-1 range
            if decibels < minDb {
                self.currentAmplitude = 0.0
            } else if decibels >= 0.0 {
                self.currentAmplitude = 1.0
            } else {
                // Convert from decibels to a 0-1 range
                let normalized = (decibels - minDb) / (-minDb)
                // Square the value to make the visualization more responsive
                self.currentAmplitude = pow(normalized, 2)
            }
        }
    }
    
    private func stopAudioMetering() {
        // Stop the metering timer
        audioMeteringTimer?.invalidate()
        audioMeteringTimer = nil
        
        // Reset the amplitude
        currentAmplitude = 0.1
    }
    
    deinit {
        // Clean up when AudioManager is deallocated
        stopAudioMetering()
        timer?.invalidate()
        player?.stop()
    }
}

