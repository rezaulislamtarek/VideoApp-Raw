//
//  VideoPlayerView.swift
//  VideoApp Raw
//
//  Created by Rezaul Islam on 11/6/24.
//

import SwiftUI
import AVKit
import AVFoundation

struct VideoPlayerView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let playerViewController = AVPlayerViewController()
        let player = AVPlayer(url: url)
        playerViewController.player = player
        playerViewController.showsPlaybackControls = true
        playerViewController.videoGravity = .resizeAspect
        player.play()
        return playerViewController
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        // No need to update the view controller in this example
    }
}

