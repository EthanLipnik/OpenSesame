//
//  AccountDetailsView+EmailView.swift
//  AccountDetailsView+EmailView
//
//  Created by Ethan Lipnik on 8/22/21.
//

import SwiftUI

extension AccountView.AccountDetailsView {
    var emailView: some View {
        VStack(alignment: .leading) {
            Label("Email", systemImage: "person.fill")
                .foregroundColor(Color.secondary)
            if isEditing {
                TextField("Email or Username", text: $newUsername)
                    .textFieldStyle(.roundedBorder)
            } else {
                Text(account.username!)
                    .font(.headline)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}
