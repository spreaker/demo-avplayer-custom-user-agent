//
//  CMTime+Util.swift
//  AVPlayerCustomUserAgent
//
//  Created by Alessandro "Sandro" Calzavara on 30/04/21.
//

import Foundation
import AVFoundation

extension CMTime {

    func timeWithOffset(_ offset: TimeInterval) -> CMTime {
        let seconds = CMTimeGetSeconds(self)
        let secondsWithOffset = seconds + offset
        return CMTimeMakeWithSeconds(secondsWithOffset, preferredTimescale: self.timescale)
    }
    
    func humanDescription() -> String {
        let totalSeconds = Int(CMTimeGetSeconds(self))
        let hours: Int = Int(totalSeconds / 3600)
        let minutes: Int = Int(totalSeconds % 3600 / 60)
        let seconds: Int = Int((totalSeconds % 3600) % 60)
        
        if hours > 0 {
            return String(format: "%i:%02i:%02i", hours, minutes, seconds)
        } else {
            return String(format: "%02i:%02i", minutes, seconds)
        }
    }
}
