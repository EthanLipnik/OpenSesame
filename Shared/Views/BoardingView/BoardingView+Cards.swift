//
//  BoardingView+Cards.swift
//  BoardingView+Cards
//
//  Created by Ethan Lipnik on 9/13/21.
//

import SwiftUI

extension BoardingView {
    struct CardView: View {
        @Binding var selectedIndex: Int
        
        var body: some View {
            VStack(spacing: 30) {
                Text("Cards")
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                Spacer()
                VStack(spacing: 30) {
                    cardView
                    Text("Easily and securily store your credit and debit cards.")
                        .font(.title3)
                        .foregroundColor(Color.secondary)
                }
                Spacer()
                Button {
                    UserDefaults.standard.set(true, forKey: "didShowBoardingScreen")
                } label: {
                    Text("Finish")
                        .font(.title.bold())
                        .frame(maxWidth: 300)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .keyboardShortcut(.defaultAction)
            }
            .padding(30)
        }
        
        var cardView: some View {
            VStack {
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(Color.secondary.opacity(0.25))
                    .frame(height: 30)
                VStack(alignment: .leading) {
                    Text("Primary Card")
                        .font(.title2)
                    Text("John Appleseed")
                        .font(.title2)
                    Spacer()
                    HStack {
                        Text("340942513229502")
                            .font(.system(.title2, design: .monospaced).weight(.semibold))
                            .lineLimit(1)
                            .allowsTightening(true)
                            .minimumScaleFactor(0.7)
                            .frame(maxWidth: .infinity)
                            .blur(radius: 8)
                        HStack(alignment: .bottom) {
                            Text("Valid Thru")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("9/12")
                                .font(.system(.title3, design: .monospaced).bold())
                        }
                    }
                }
            }
            .padding()
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(LinearGradient(colors: [Color("Tertiary"), Color("Tertiary").opacity(0.7)], startPoint: .top, endPoint: .bottom))
#if os(macOS)
                        .shadow(radius: 15, y: 8)
#else
                        .shadow(radius: 30, y: 8)
#endif
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(lineWidth: 2)
                        .fill(Color(white: 0.5, opacity: 0.25))
                }
                    .compositingGroup()
            )
            .aspectRatio(1.6, contentMode: .fit)
        }
    }
}
