//
//  AudioPlayerControls.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 9/18/26.
//

import SwiftUI
import AVFoundation

struct AudioPlayerControls: View {
    let player: AVAudioPlayer?

    var body: some View {
        VStack(spacing: 16) {
            Text("Audio Playback")
                .font(.headline)

            HStack {
                Button("Play") { player?.play() }
                Button("Pause") { player?.pause() }
                Button("Stop") { player?.stop() }
            }
        }
        .padding()
    }
}
