//
//  MultipeerShareSheet.swift
//  MultipeerShareSheet
//
//  Created by Ethan Lipnik on 8/22/21.
//

import SwiftUI
import MultipeerKit

struct MultipeerShareSheet: View {
    @StateObject var multipeer = MultipeerService.shared
    @Environment(\.dismiss) var dismiss
    
    let account: Account
    
    var body: some View {
        NavigationView {
            List(multipeer.availablePeers) { peer in
                NavigationLink {
                    ShareAccountConfirmationView(peer: peer, account: account)
                        .environmentObject(multipeer)
                } label: {
                    Label(peer.name, systemImage: "person.fill")
                }
            }
            .animation(.default, value: multipeer.availablePeers)
            .listStyle(.sidebar)
#if os(iOS)
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button("Done", action: dismiss.callAsFunction)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
#endif
            .navigationTitle("Share Account")
            
#if os(macOS)
            EmptyView()
#endif
        }
    }
    
    struct ShareAccountConfirmationView: View {
        @EnvironmentObject var multipeer: MultipeerService
        let peer: Peer
        let account: Account
        @State var inviteAccepted: Bool = false
        
        @Environment(\.dismiss) var dismiss
        
        var body: some View {
            VStack {
                Text("This doesn't function yet")
                    .foregroundColor(Color.secondary)
                if !inviteAccepted {
                    Text("Inviting...")
                        .animation(.default, value: inviteAccepted)
                }
                Text(peer.name)
                GroupBox {
                    Text(account.domain!)
                    Text(account.username!)
                }
                
                if inviteAccepted {
                    Button("Share") {
                        if let decryptedPassword = try? CryptoSecurityService.decrypt(account.password!) {
                            multipeer.transceiver.send(ShareableAccount(domain: account.domain!, dateAdded: account.dateAdded ?? Date(), lastModified: account.lastModified, password: decryptedPassword, username: account.username!, url: account.url!), to: [peer])
                            
                            dismiss.callAsFunction()
                        }
                    }
                }
            }
            .onChange(of: multipeer.invitedPeers) { newValue in
                if newValue.contains(where: { $0.id == peer.id }) {
                    inviteAccepted = true
                }
            }
            .task {
                self.multipeer.invite(peer)
            }
        }
    }
}

struct MultipeerShareSheet_Previews: PreviewProvider {
    static var previews: some View {
        MultipeerShareSheet(account: .init())
    }
}
