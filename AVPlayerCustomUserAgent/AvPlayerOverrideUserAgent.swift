//
//  AvPlayerOverrideUserAgent.swift
//  AVPlayerCustomUserAgent
//
//  Created by Alessandro "Sandro" Calzavara on 30/04/21.
//

import Foundation
import AVKit

let customLoaderDelegate = CustomLoaderDelegate(userAgent: UserAgent.default)

// helper class to handle loading of a custom asset url
class CustomLoaderDelegate : NSObject, AVAssetResourceLoaderDelegate {
    let userAgent: String
    var fetchedUrlData = [URL: Data]() // cache the response per url, since we get multiple callbacks for the same resource
    
    init(userAgent: String) {
        self.userAgent = userAgent
    }
    
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        if let url = loadingRequest.request.url, let dataRequest = loadingRequest.dataRequest {
            func finishRequestWithData(_ data: Data) {
                if let contentInformationRequest = loadingRequest.contentInformationRequest {
                    contentInformationRequest.isByteRangeAccessSupported = false
                    contentInformationRequest.contentType = "audio/mpeg"
                    contentInformationRequest.contentLength = Int64(data.count)
                }
                if (dataRequest.requestsAllDataToEndOfResource) {
                    dataRequest.respond(with: data)
                    loadingRequest.finishLoading()
                } else {
                    let start = Int(dataRequest.requestedOffset)
                    let end = Int(dataRequest.requestedOffset) + dataRequest.requestedLength
                    dataRequest.respond(with: data[start..<end])
                    loadingRequest.finishLoading()
                }
            }
            if let data = self.fetchedUrlData[url] {
                finishRequestWithData(data)
            } else {
                // fetch the resource with our custom user-agent using URLRequest
                var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
                components.scheme = (components.scheme ?? "").contains("https") ? "https" : "http"
                fetch(url: components.url!, userAgent: self.userAgent) { data in
                    self.fetchedUrlData[url] = data
                    finishRequestWithData(data)
                }
            }
        }
        
        return true // we can handle it
    }
}

// helper to fetch an url with a custom user-agent
func fetch(url: URL, userAgent: String, onData: @escaping (Data) -> ()) {
    print("fetch \(url)")
    let session = URLSession.shared
    
    var urlRequest = URLRequest(url: url)
    urlRequest.addValue(userAgent, forHTTPHeaderField: "User-Agent")
    
    let task = session.dataTask(with: urlRequest) { (data, response, error) in
        guard error == nil else {
            print(error!)
            return
        }
        guard let responseData = data else {
            print("Fetch error: no response data")
            return
        }
        guard let httpResponse = response as? HTTPURLResponse else {
            print("Fetch error: not an HTTP response")
            return
        }
        guard httpResponse.statusCode == 200 else {
            print("Fetch error: not an HTTP 200")
            return
        }
        onData(responseData)
    }
    task.resume()
}
