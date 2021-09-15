//
//  VaultView+AccountItemView.swift
//  VaultView+AccountItemView
//
//  Created by Ethan Lipnik on 8/22/21.
//

import SwiftUI

extension VaultView {
    struct AccountItemView: View {
        @EnvironmentObject var viewModel: ViewModel
        
        let account: Account
        
        var body: some View {
            return NavigationLink(tag: .init(account), selection: $viewModel.selectedItem) {
                AccountView(account: account)
            } label: {
                HStack {
                    if let domain = account.domain, UserSettings.default.shouldShowFaviconInList {
                        FaviconView(website: domain)
                            .drawingGroup()
                            .frame(width: 30, height: 30)
                    }
                    VStack(alignment: .leading) {
                        Text(AttributedString(account: account))
                            .bold()
                            .lineLimit(1)
                        Text(account.username!)
                            .foregroundColor(Color.secondary)
                            .lineLimit(1)
                            .blur(radius: CommandLine.arguments.contains("-marketing") ? 5 : 0)
                    }
                }
            }
        }
    }
}
