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
                                .font(.system(.title, design: .rounded).bold()))
                    .onAppear {
                        if let cache = FaviconView.cache.object(forKey: website as NSString) {
                            
                            self.image = cache
                        }
                    }
                    .task {
                        guard let url = URL(string: website.withWWWIfNeeded.withHTTPIfNeeded), UserSettings.default.shouldLoadFavicon else { return }
                        
                        do {
                            let favicon = try await FaviconFinder(url: url).downloadFavicon()
                            
                            withAnimation {
                                self.image = favicon.image
                            }
                            
                            FaviconView.cache.setObject(favicon.image, forKey: website as NSString)
                        } catch { }
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
