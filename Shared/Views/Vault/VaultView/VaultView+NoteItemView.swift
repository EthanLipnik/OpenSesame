//
//  VaultView+NoteItemView.swift
//  OpenSesame
//
//  Created by Ethan Lipnik on 9/22/21.
//

import SwiftUI

extension VaultView {
    struct NoteItemView: View {
        @EnvironmentObject var viewModel: ViewModel

        let note: Note
        var isPopover: Bool = false

        @State private var isPresenting: Bool = false

        var body: some View {
            Group {
                if isPopover {
                    Button {
                        isPresenting.toggle()
                    } label: {
                        content
                    }
                    .popover(isPresented: $isPresenting) {
                        NavigationView {
                            NoteView(note: note)
                                .toolbar {
                                    ToolbarItem(placement: .navigation) {
                                        Button("Done") {
                                            isPresenting = false
                                        }
                                    }
                                }
                        }
                        .frame(minWidth: 400, minHeight: 600)
                    }
                    .buttonStyle(.plain)
                } else {
                    NavigationLink(tag: .init(note), selection: $viewModel.selectedItem) {
                        NoteView(note: note)
                    } label: {
                        content
                    }
                }
            }
        }

        var content: some View {
            let color: Color = {
                switch note.color {
                case 0:
                    return Color("Note-YellowTop")
                case 1:
                    return Color("Note-BlueTop")
                case 2:
                    return Color("Note-OrangeTop")
                default:
                    return Color("Note-YellowTop")
                }
            }()

            return Label {
                Text(note.name!)
                    .bold()
            } icon: {
                Image(systemName: "rectangle.fill")
                    .foregroundColor(color)
            }
        }
    }
}
