//
//  UserAgent.swift
//  AVPlayerCustomUserAgent
//
//  Created by Alessandro "Sandro" Calzavara on 30/04/21.
//

import Foundation
import UIKit

class UserAgent {
    static let `default`: String = {
        guard let info = Bundle.main.infoDictionary,
              let appNameRaw = info["CFBundleDisplayName"] ?? info[kCFBundleIdentifierKey as String],
              let appMarketingVersionRaw = info["CFBundleShortVersionString"],
              let appName = appNameRaw as? String,
              let appMarketingVersion = appMarketingVersionRaw as? String
        else {
            fatalError("Unable to generate a default User-Agent. Please check the content of your Info.plist file.")
        }
        
        var appFullVersion = appMarketingVersion
        if let appBuildVersionRaw = info[kCFBundleVersionKey as String], let appBuildVersion = appBuildVersionRaw as? String {
            appFullVersion.append(".\(appBuildVersion)")
        }
        let model = UIDevice.current.model
        let os = UIDevice.current.systemVersion
        let locale = Locale.current.identifier
        
        let ua = "\(appName)/\(appFullVersion) (\(model); iOS \(os); \(locale))"
        return ua
    }()
}
