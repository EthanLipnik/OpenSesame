//
//  AutoFillView.swift
//  OpenSesame
//
//  Created by Ethan Lipnik on 9/15/21.
//

import SwiftUI

struct AutoFillView: View {
    @EnvironmentObject var autoFill: AutoFillService
    
    let cancel: () -> Void
    let completion: (Account) -> Void
    
    @State private var isLocked: Bool = true
    @State private var search: String = ""
    
    var body: some View {
#if os(iOS)
        NavigationView {
            content
                .navigationTitle("OpenSesame")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel", action: cancel)
                    }
                }
        }
#else
        content
#endif
    }
    
    var content: some View {
        let suggestions = search.isEmpty ? autoFill.suggestedAccounts : autoFill.suggestedAccounts
            .filter({ $0.domain?.contains(search, caseInsentive: true) ?? false || $0.username?.contains(search, caseInsentive: true) ?? false })
        
        return ZStack {
            if !isLocked {
                List {
                    if !suggestions.isEmpty {
                        Section("Suggestions") {
                            ForEach(suggestions) { account in
                                ItemView(account: account, completion: completion)
                            }
                        }
                    }
                    
                    Section("All Accounts") {
                        ForEach(search.isEmpty ? autoFill.allAccounts : autoFill.allAccounts
                                    .filter({ $0.domain?.contains(search, caseInsentive: true) ?? false || $0.username?.contains(search, caseInsentive: true) ?? false })) { account in
                            ItemView(account: account, completion: completion)
                        }
                    }
                }
#if os(macOS)
                .listStyle(.inset(alternatesRowBackgrounds: true))
#endif
                .searchable(text: $search)
                .opacity(isLocked ? 0 : 1)
                .blur(radius: isLocked ? 25 : 0)
                .allowsHitTesting(!isLocked)
                .animation(.default, value: isLocked)
            }
            LockView(isLocked: $isLocked) {
                if let selectedCredential = autoFill.selectedCredential, let account = selectedCredential.asAccount(autoFill.allAccounts) {
                    completion(account)
                } else {
                    isLocked = false
                }
            }
            .zIndex(1)
            .opacity(isLocked ? 1 : 0)
            .blur(radius: isLocked ? 0 : 25)
            .animation(.default, value: isLocked)
            .allowsHitTesting(isLocked) // Prevent lock screen from being interacted with even though it's in the foreground.
        }
    }
    
    struct ItemView: View {
        let account: Account
        
        let completion: (Account) -> Void
        
        var body: some View {
            Button {
                completion(account)
            } label: {
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
#if os(macOS)
            .buttonStyle(.plain)
#endif
        }
    }
}

struct AutoFillView_Previews: PreviewProvider {
    static var previews: some View {
        AutoFillView {
            
        } completion: { account in
            
        }
    }
}
