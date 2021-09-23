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
        
        var body: some View {
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
            
            return NavigationLink(tag: .init(note), selection: $viewModel.selectedItem) {
                NoteView(note: note)
            } label: {
                Label {
                    Text(note.name!)
                        .bold()
                } icon: {
                    Image(systemName: "rectangle.fill")
                        .foregroundColor(color)
                }
            }
        }
    }
}
