//
//  VaultView+AccountItemView.swift
//  VaultView+AccountItemView
//
//  Created by Ethan Lipnik on 8/22/21.
//

import SwiftUI

extension VaultView {
    struct AccountItemView: View {
        @EnvironmentObject
        var viewModel: ViewModel

        let account: Account
        var isPopover: Bool = false

        @State
        private var isPresenting: Bool = false

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
                            AccountView(account: account)
                                .toolbar {
                                    ToolbarItem(placement: .navigation) {
                                        Button("Done") {
                                            isPresenting = false
                                        }
                                    }
                                }
                        }
#if os(iOS)
                        .frame(minWidth: 400, minHeight: 600)
#else
                        .frame(minHeight: 500)
#endif
                    }
                    .buttonStyle(.plain)
                } else {
                    NavigationLink(tag: .init(account), selection: $viewModel.selectedItem) {
                        AccountView(account: account)
                    } label: {
                        content
                    }
                }
            }
        }

        var content: some View {
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
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(account.username!)
                        .foregroundColor(Color.secondary)
                        .lineLimit(1)
                        .blur(radius: CommandLine.arguments.contains("-marketing") ? 5 : 0)
                }
            }
        }
    }
}
