//
//  CardView.swift
//  CardView
//
//  Created by Ethan Lipnik on 8/30/21.
//

import SwiftUI

struct CardView: View {
    // MARK: - Variables

    let card: Card

    // #if os(iOS)
//    @ObservedObject var manager = MotionManager()
    // #endif

    @State
    private var isShowingNumber: Bool = false
    @State
    private var decryptedNumber: String?
    @State
    private var displayedNumber: String = ""
    @State
    private var isSharing: Bool = false

    // MARK: - Init

    init(card: Card) {
        self.card = card

        _displayedNumber = .init(
            initialValue: CryptoSecurityService
                .randomString(length: 15, numbersOnly: true)!
        )
    }

    // MARK: - View

    var body: some View {
        ScrollView {
            VStack {
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(Color.secondary.opacity(0.25))
                    .frame(height: 30)
                VStack(alignment: .leading) {
                    Text(card.name!)
                        .font(.title2)
                    Text(card.holder!)
                        .font(.title2)
                        .contextMenu {
                            Button {
                                card.holder?.copyToPasteboard()
                            } label: {
                                Label("Copy card holder", systemImage: "doc.on.doc")
                            }
                        }
                    Spacer()
                    HStack {
                        Text(displayedNumber)
                            .allowsTightening(true)
                            .minimumScaleFactor(0.6)
                            .lineLimit(1)
                            .font(.system(.title2, design: .monospaced).weight(.semibold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .blur(radius: isShowingNumber ? 0 : 8)
                            .contextMenu {
                                Button {
                                    displayedNumber.copyToPasteboard()
                                } label: {
                                    Label("Copy card number", systemImage: "doc.on.doc")
                                }.disabled(!isShowingNumber)
                            }
                            .animation(.default, value: isShowingNumber)
                            .onTapGesture {
                                if !isShowingNumber {
                                    do {
                                        decryptedNumber = try CryptoSecurityService
                                            .decrypt(card.number!)

                                        displayedNumber = decryptedNumber ?? displayedNumber
                                        isShowingNumber = true
                                    } catch {
                                        print(error)

#if os(macOS)
                                        NSAlert(error: error).runModal()
#endif
                                    }
                                } else {
                                    isShowingNumber.toggle()
                                    decryptedNumber = nil

                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                        displayedNumber = CryptoSecurityService.randomString(
                                            length: 15,
                                            numbersOnly: true
                                        )!
                                    }
                                }
                            }
                            .onHover { isHovering in
#if os(macOS)
                                if isHovering {
                                    NSCursor.pointingHand.set()
                                } else {
                                    NSCursor.arrow.set()
                                }
#endif
                            }
                        HStack(alignment: .bottom) {
                            Text("Valid Thru")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(card.expirationDate ?? "")
                                .font(.system(.title3, design: .monospaced).bold())
                                .contextMenu {
                                    Button {
                                        card.expirationDate?.copyToPasteboard()
                                    } label: {
                                        Label("Copy expiration date", systemImage: "doc.on.doc")
                                    }
                                }
                        }
                    }
                }
            }
            .padding()
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(LinearGradient(
                            colors: [Color("Tertiary"), Color("Tertiary").opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        ))
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(lineWidth: 2)
                        .fill(Color(white: 0.5, opacity: 0.25))
                }.compositingGroup()
            )
            .padding()
            .aspectRatio(1.6, contentMode: .fill)
#if os(macOS)
                .frame(width: 400)
#else
                .frame(maxWidth: 400)
#endif
            Spacer()
                .frame(maxWidth: .infinity)
        }
#if os(macOS)
        .shadow(radius: 15, y: 8)
        .toolbar {
            ToolbarItem {
                Spacer()
            }
        }
        .frame(minWidth: 300)
#else
        .shadow(radius: 30, y: 8)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem {
                Button {
                    isSharing.toggle()
                } label: {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
                .halfSheet(isPresented: $isSharing) {
                    ShareSheet(
                        activityItems: [try! CardDocument(card).save()],
                        excludedActivityTypes: [
                            .addToReadingList,
                            .assignToContact,
                            .markupAsPDF,
                            .openInIBooks,
                            .postToFacebook,
                            .postToVimeo,
                            .postToWeibo,
                            .postToFlickr,
                            .postToTwitter,
                            .postToTencentWeibo,
                            .print,
                            .saveToCameraRoll
                        ]
                    )
                    .ignoresSafeArea()
                    .onDisappear {
                        isSharing = false
                    }
                }
            }
        }
#endif
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(card: .init())
    }
}
