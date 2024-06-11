//
//  ContentView.swift
//  VideoApp Raw
//
//  Created by Rezaul Islam on 11/6/24.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var videoURL: URL?
    @State private var isShowingVideoPicker = false
    @State private var videoInfoText : String  = ""
    @State var urls : [URL] = []
    @State var mergedVideoUrl : URL?
    
    private func handleVideoPickerResult(_ videoURL: URL) {
        self.videoURL = videoURL
    }
    
    
    
    var body: some View {
        VStack {
            if let mergedVideoUrl = mergedVideoUrl {
                VideoPlayerView(url: mergedVideoUrl)
                    .frame(height: 300)
            }
            
            if let videoURL = videoURL{
                
                HStack{
                    ScrollView(.horizontal, showsIndicators: false){
                        HStack{
                            ForEach(urls, id: \.self){ url in
                                VideoPlayerView(url: url)
                                    .frame(width: 120, height: 50)
                                    .overlay(alignment: .topTrailing) {
                                        Image(systemName: "trash.circle.fill")
                                            .foregroundColor(.pink)
                                            .onTapGesture {
                                                deleteSegment(url: url)
                                            }
                                    }
                            }
                        }
                    }
                    
                    
                    
                }
                .onAppear{
                    splitVideo(url: videoURL, segmentDuration: CMTime(seconds: 20, preferredTimescale: 600)) { urls in
                        self.urls = urls
                        videoInfoText = urls.description
                    }
                }
                
                Button("Merge video"){
                    mergeVideos(urls: self.urls) { mergeUrl in
                        mergedVideoUrl = mergeUrl
                    }
                }
                
            }
            
            
            
            Button("Load Video") {
                videoURL = nil
                urls = []
                mergedVideoUrl = nil
                isShowingVideoPicker = true
            }
            .padding()
        }
        .sheet(isPresented: $isShowingVideoPicker) {
            ImagePickerDelegate(sourceType: .photoLibrary, mediaTypes: ["public.movie"], didPickVideo: handleVideoPickerResult)
        }
    }
    
    
}



#Preview {
    ContentView()
}
