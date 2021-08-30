//
//  CardView.swift
//  CardView
//
//  Created by Ethan Lipnik on 8/30/21.
//

import SwiftUI

struct CardView: View {
    let card: Card
    
    @State private var isShowingNumber: Bool = false
    @State private var decryptedNumber: String? = nil
    @State private var displayedNumber: String = ""
    
    init(card: Card) {
        self.card = card
        
        self._displayedNumber = .init(initialValue: CryptoSecurityService.randomString(length: 15, numbersOnly: true)!)
    }
    
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
                    Spacer()
                    HStack {
                        Text(displayedNumber)
                            .font(.title2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .blur(radius: isShowingNumber ? 0 : 8)
                            .animation(.default, value: isShowingNumber)
                            .onTapGesture {
                                if !isShowingNumber {
                                    do {
                                        decryptedNumber = try CryptoSecurityService.decrypt(card.number!)
                                        
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
                                        displayedNumber = CryptoSecurityService.randomString(length: 15, numbersOnly: true)!
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
                            Text(card.expirationDate!, style: .date)
                                .font(.title3)
                        }
                    }
                }
            }
            .padding()
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color("Tertiary"))
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(lineWidth: 2)
                        .fill(Color(white: 0.5, opacity: 0.25))
                }.compositingGroup()
            )
            .padding()
            .aspectRatio(1.6, contentMode: .fill)
            .frame(width: 400)
        }.shadow(radius: 15, y: 8)
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(card: .init())
    }
}
