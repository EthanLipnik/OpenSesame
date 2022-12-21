//
//  FaviconView.swift
//  FaviconView
//
//  Created by Ethan Lipnik on 8/18/21.
//

import FaviconFinder
import SwiftUI

struct FaviconView: View {
    // MARK: - Variables

    let website: String

    static let cache = NSCache<NSString, FaviconImage>()

    @State
    private var image: FaviconImage?

    // MARK: - View

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.white)
            if let existingCompany = websiteToExistingCompany() {
                existingCompany
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(5)
            } else if let image {
                Group {
#if canImport(UIKit)
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
#else
                    Image(nsImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
#endif
                }
                .transition(.opacity)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .padding(5)
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .overlay(
                        Text(website.isEmpty ? "" : website[0].uppercased())
                            .font(.system(.title, design: .rounded).bold())
                            .foregroundColor(.black)
                    )
                    .onAppear {
                        if let cache = FaviconView.cache.object(forKey: website as NSString) {
                            self.image = cache
                        }
                    }
                    .task {
                        guard let url = URL(string: website.withWWWIfNeeded.withHTTPIfNeeded),
                              UserSettings.default.shouldLoadFavicon else { return }

                        do {
                            let favicon = try await FaviconFinder(url: url).downloadFavicon()

                            withAnimation {
                                self.image = favicon.image
                            }

                            FaviconView.cache.setObject(favicon.image, forKey: website as NSString)
                        } catch {}
                    }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }

    // MARK: - Local Company Logos

    func websiteToExistingCompany() -> Image? {
        switch website.lowercased() {
        case "apple.com", "apple.co.uk":
            return Image("Websites/Apple")
        case "google.com", "google.co.uk", "goo.gl":
            return Image("Websites/Google")
        case "github.com", "github.co.uk":
            return Image("Websites/GitHub")
        case "twitter.com", "twitter.co.uk", "t.co":
            return Image("Websites/Twitter")
        default:
            return nil
        }
    }
}

struct FaviconView_Previews: PreviewProvider {
    static var previews: some View {
        FaviconView(website: "Google.com")
            .aspectRatio(1 / 1, contentMode: .fit)
            .padding()
    }
}
