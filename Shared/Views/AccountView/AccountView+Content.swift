//
//  AccountView+Content.swift
//  AccountView+Content
//
//  Created by Ethan Lipnik on 8/22/21.
//

import SwiftUI

extension AccountView {
    var content: some View {
        
        // Give styling to domain
        var attributedDomain = AttributedString(((account.url?.isEmpty ?? true) ? nil : account.url?.removeHTTP.removeWWW) ?? account.domain ?? "Unknown website")
        if let domain = account.domain {
            if let match = attributedDomain.range(of: domain, options: [.caseInsensitive, .diacriticInsensitive]) {
                attributedDomain.foregroundColor = Color.secondary
                attributedDomain[match].foregroundColor = Color("Label")
            }
        }
        
        return GroupBox {
            VStack(alignment: .leading) {
                if let website = account.domain {
                    HStack(alignment: .top) {
                        FaviconView(website: website)
                            .drawingGroup()
                            .frame(width: 50, height: 50)
                        VStack(alignment: .leading) {
                            Text(attributedDomain)
                                .font(.headline)
                            if let dateAdded = account.dateAdded {
                                Text("Date Added: ")
                                    .foregroundColor(.secondary)
                                + Text(dateAdded, style: .date)
                                    .foregroundColor(.secondary)
                            }
                            
                            if let lastModified = account.lastModified {
                                Text("Last Modified: ")
                                    .foregroundColor(.secondary)
                                + Text(lastModified, style: .date)
                                    .foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                        Button(isEditing ? "Done" : "Edit") {
                            withAnimation {
                                isEditing.toggle()
                            }
                            //                            if !isEditing {
                            //                                UserAuthenticationService.authenticate()
                            //                                    .sink { success in
                            //                                        if success {
                            //                                            withAnimation {
                            //                                                isEditing = true
                            //                                            }
                            //                                        }
                            //                                    }
                            //                                    .store(in: &UserAuthenticationService.cancellables)
                            //                            } else {
                            //                                withAnimation {
                            //                                    isEditing = false
                            //                                    isAddingVerificationCode = false
                            //                                }
                            //                            }
                        }
#if os(iOS)
                        .hoverEffect()
#endif
                    }
                }
                AccountDetailsView(account: account, isEditing: $isEditing, isAddingVerificationCode: $isAddingVerificationCode)
                    .padding(.vertical)
                GroupBox {
                    TextField("Notes", text: $newNotes, onCommit: {
                        account.notes = newNotes
                        
                        try? viewContext.save()
                    }).textFieldStyle(.plain)
                }
#if os(macOS)
                Spacer()
#endif
                HStack {
                    if let website = ((account.url?.isEmpty ?? true) ? nil : account.url) ?? account.domain, let url = URL(string: website.withHTTPIfNeeded) {
                        Link("Go to website", destination: url)
                            .foregroundColor(.accentColor)
#if os(iOS)
                            .hoverEffect()
#endif
                    }
                    Spacer()
//                    if isEditing {
//                        if !isAddingAlternateDomains {
//                            Button("Alternate Domains") {
//                                newAlternateDomains = String((account.alternateDomains?
//                                                                .map({ String($0) }) ?? [])
//                                                                .joined(separator: ","))
//                                isAddingAlternateDomains = true
//                            }
//                        } else {
//                            TextField("Alternate Domains", text: $newAlternateDomains, onCommit: {
//                                isAddingAlternateDomains = false
//                                account.alternateDomains = newAlternateDomains.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: ",").map({ $0 as NSString })
//                            })
//                                .textFieldStyle(.roundedBorder)
//#if os(iOS)
//                                .autocapitalization(.none)
//#endif
//                                .disableAutocorrection(true)
//                        }
//                    }
                }
            }
#if os(macOS)
            .padding()
#endif
        }
        .padding()
        .frame(maxWidth: 600)
    }
}
