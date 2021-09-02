//
//  FaviconView.swift
//  FaviconView
//
//  Created by Ethan Lipnik on 8/18/21.
//

import SwiftUI
import FaviconFinder

struct FaviconView: View {
    // MARK: - Variables
    let website: String
    
    static let cache = NSCache<NSString, FaviconImage>()
    
    @State private var image: FaviconImage? = nil
    
    // MARK: - View
    var body: some View {
        Group {
            if let existingCompany = websiteToExistingCompany() {
                existingCompany
                    .resizable()
                    .padding(5)
                    .background(Color.white)
                    .cornerRadius(10)
            } else if let image = image {
                Group {
#if canImport(UIKit)
                    Image(uiImage: image)
                        .resizable()
#else
                    Image(nsImage: image)
                        .resizable()
#endif
                }
                .transition(.opacity)
                .cornerRadius(8)
                .padding(5)
                .background(Color.white)
                .cornerRadius(10)
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .overlay(Text(website.isEmpty ? "" : website[0].uppercased())
                                .font(.system(.largeTitle, design: .rounded).bold()))
                    .onAppear {
                        if let cache = FaviconView.cache.object(forKey: website as NSString) {
                            
                            self.image = cache
                        }
                    }
                    .task {
                        if let cache = FaviconView.cache.object(forKey: website as NSString) {
                            
                            self.image = cache
                            
                            return
                        }
                        
                        guard let url = URL(string: website.withHTTPIfNeeded) else { return }
                        FaviconFinder(url: url, preferredType: .html, preferences: [
                            FaviconDownloadType.html: FaviconType.appleTouchIcon.rawValue,
                            FaviconDownloadType.ico: "favicon.ico"
                        ]).downloadFavicon { result in
                            switch result {
                            case .success(let favicon):
                                withAnimation {
                                    self.image = favicon.image
                                }
                                
                                FaviconView.cache.setObject(favicon.image, forKey: website as NSString)
                                
                            case .failure(let error):
                                print("Error", error, url)
                            }
                        }
                    }
            }
        }
    }
    
    // MARK: - Local Company Logos
    func websiteToExistingCompany() -> Image? {
        switch website.lowercased() {
        case "apple.com", "apple.co.uk":
            return Image("Apple")
        case "google.com", "google.co.uk", "goo.gl":
            return Image("Google")
        case "github.com", "github.co.uk":
            return Image("GitHub")
        case "twitter.com", "twitter.co.uk", "t.co":
            return Image("Twitter")
        default:
            return nil
        }
    }
}

struct FaviconView_Previews: PreviewProvider {
    static var previews: some View {
        FaviconView(website: "Google.com")
            .aspectRatio(1/1, contentMode: .fit)
            .padding()
    }
}
