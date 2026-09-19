//
//  VideoPlayerView.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 9/18/26.
//

import SwiftUI
import AVFoundation
import AVKit

struct VideoPlayerView: NSViewRepresentable {
    let player: AVPlayer

    func makeNSView(context: Context) -> AVPlayerView {
        let view = AVPlayerView()
        view.player = player
        return view
    }

    func updateNSView(_ nsView: AVPlayerView, context: Context) {}
}
