//
//  ContentView+extension.swift
//  VideoApp Raw
//
//  Created by Rezaul Islam on 11/6/24.
//

import Foundation
import AVFoundation

extension ContentView{
    func splitVideo(url: URL, segmentDuration: CMTime, completion: @escaping ([URL]) -> Void) {
        let asset = AVAsset(url: url)
        let duration = asset.duration
        let totalSeconds = CMTimeGetSeconds(duration)
        let segmentSeconds = CMTimeGetSeconds(segmentDuration)
        var startTime = CMTime(seconds: 0, preferredTimescale: 600)
        var segmentUrls = [URL]()
        let dispatchGroup = DispatchGroup()
        
        while CMTimeGetSeconds(startTime) < totalSeconds {
            dispatchGroup.enter()
            let endTime = CMTimeAdd(startTime, segmentDuration)
            let range = CMTimeRange(start: startTime, end: endTime)
            let outputURL = URL(fileURLWithPath: NSTemporaryDirectory())
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension("mp4")
            
            exportSegment(asset: asset, timeRange: range, outputURL: outputURL) { success in
                if success {
                    segmentUrls.append(outputURL)
                }
                dispatchGroup.leave()
            }
            startTime = endTime
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(segmentUrls)
        }
    }
    
    func exportSegment(asset: AVAsset, timeRange: CMTimeRange, outputURL: URL, completion: @escaping (Bool) -> Void) {
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {
            completion(false)
            return
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        exportSession.timeRange = timeRange
        
        exportSession.exportAsynchronously {
            switch exportSession.status {
            case .completed:
                completion(true)
            default:
                completion(false)
            }
        }
    }
    
    func deleteSegment(url: URL) {
           urls.removeAll { $0 == url }
       } 
    
 

    func mergeVideos(urls: [URL], completion: @escaping (URL?) -> Void) {
        let composition = AVMutableComposition()
        var currentTime = CMTime.zero

        // Create a mutable track for video and audio
        guard let videoTrack = composition.addMutableTrack(
            withMediaType: .video,
            preferredTrackID: kCMPersistentTrackID_Invalid
        ) else {
            completion(nil)
            return
        }

        guard let audioTrack = composition.addMutableTrack(
            withMediaType: .audio,
            preferredTrackID: kCMPersistentTrackID_Invalid
        ) else {
            completion(nil)
            return
        }

        // Add each video segment to the composition
        for url in urls {
            let asset = AVAsset(url: url)
            guard let assetVideoTrack = asset.tracks(withMediaType: .video).first else { continue }
            let assetAudioTrack = asset.tracks(withMediaType: .audio).first
            
            let timeRange = CMTimeRange(start: .zero, duration: asset.duration)
            
            do {
                try videoTrack.insertTimeRange(timeRange, of: assetVideoTrack, at: currentTime)
                if let assetAudioTrack = assetAudioTrack {
                    try audioTrack.insertTimeRange(timeRange, of: assetAudioTrack, at: currentTime)
                }
                currentTime = CMTimeAdd(currentTime, asset.duration)
            } catch {
                print("Failed to insert time range: \(error)")
                completion(nil)
                return
            }
        }

        let outputURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("mp4")

        guard let exportSession = AVAssetExportSession(
            asset: composition,
            presetName: AVAssetExportPresetHighestQuality
        ) else {
            completion(nil)
            return
        }

        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        exportSession.exportAsynchronously {
            switch exportSession.status {
            case .completed:
                completion(outputURL)
            default:
                completion(nil)
            }
        }
    }

    
}
