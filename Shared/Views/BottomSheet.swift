//
//  BottomSheet.swift
//  OpenSesame
//
//  Created by Ethan Lipnik on 9/18/21.
//

import ScreenCorners
import SwiftUI

struct BottomSheet<ContentView: View>: ViewModifier {
    @Binding
    var isPresented: Bool
    let isInteractiveDismissEnabled: Bool
    let contentView: ContentView

    init(
        isPresented: Binding<Bool>,
        isInteractiveDismissEnabled: Bool,
        @ViewBuilder content: @escaping () -> ContentView
    ) {
        _isPresented = isPresented
        self.isInteractiveDismissEnabled = isInteractiveDismissEnabled
        contentView = content()
    }

    @State
    private var offset: CGSize = .zero

    func body(content: Content) -> some View {
        let cornerRadius = UIScreen.main.displayCornerRadius

        return content
            .overlay(
                isPresented ?
                    VStack {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.secondary.opacity(0.5))
                            .frame(width: 40, height: 8)
                        contentView
                    }
                    .padding()
                    .background(
                        RoundedRectangle(
                            cornerRadius: cornerRadius == 0 ? 10 : cornerRadius,
                            style: .continuous
                        )
                        .fill(Color("Tertiary"))
                        .shadow(radius: 30, y: 10)
                    )
                    .frame(maxWidth: 600, minHeight: 300)
                    .padding()
                    .offset(offset)
                    .animation(.spring(), value: offset)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let height: CGFloat = {
                                    if offset.height > 0 {
                                        return value.translation.height
                                    } else {
                                        return value.translation.height / 10
                                    }
                                }()

                                offset = CGSize(width: value.translation.width / 10, height: height)
                            }
                            .onEnded { value in
                                if value.translation.height > 100, isInteractiveDismissEnabled {
                                    withAnimation(.default) {
                                        isPresented = false
                                    }
                                }

                                offset = .zero
                            }
                    )
                    .transition(.move(edge: .bottom))
                    : nil,
                alignment: .bottom
            )
            .animation(.spring(), value: isPresented)
    }
}

extension View {
    func bottomSheet(
        isPresented: Binding<Bool>,
        isInteractiveDismissEnabled: Bool = true,
        @ViewBuilder content: @escaping () -> some View
    ) -> some View {
        modifier(BottomSheet(
            isPresented: isPresented,
            isInteractiveDismissEnabled: isInteractiveDismissEnabled,
            content: content
        ))
    }
}

struct BottomSheet_Previews: PreviewProvider {
    static var previews: some View {
        Rectangle()
            .bottomSheet(isPresented: .constant(true)) {
                VStack {
                    Text("Hey")
                }
            }
    }
}
