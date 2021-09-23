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
            return NavigationLink(tag: .init(note), selection: $viewModel.selectedItem) {
                NoteView(note: note)
            } label: {
                Text(note.name!)
                    .bold()
            }
        }
    }
}
