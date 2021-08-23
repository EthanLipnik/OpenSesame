//
//  MultipeerService.swift
//  MultipeerService
//
//  Created by Ethan Lipnik on 8/22/21.
//

import Combine
import MultipeerKit
import CloudKit
import CoreData

class MultipeerService: ObservableObject {
    static let shared = MultipeerService()
    
    @Published var availablePeers: [Peer] = []
    @Published var invitedPeers: [Peer] = []
    
    let transceiver: MultipeerTransceiver
    
    private init() {
        let security = MultipeerConfiguration.Security(identity: nil, encryptionPreference: .required) { peer, data, completion in
            print(peer, data as Any)
            completion(true)
        }
        let config = MultipeerConfiguration(serviceType: "OpenSesame", peerName: UUID().uuidString, defaults: UserDefaults.standard, security: security, invitation: .none)
        
        transceiver = MultipeerTransceiver(configuration: config)
        
        transceiver.receive(ShareableAccount.self) { payload, sender in
            print("Got my thing from \(sender.name)! \(payload)")
            
//            let viewContext = PersistenceController.shared.container.viewContext
//            
////            let account = Account(context: viewContext)
////            account.username = payload.username
////            account.username = payload
        }
        
        self.availablePeers = transceiver.availablePeers
        transceiver.availablePeersDidChange = { peers in
            self.availablePeers = peers
        }
    }
    
    func invite(_ peer: Peer) {
        transceiver.invite(peer, with: nil, timeout: 10) { result in
            switch result {
            case .success(let peer):
                self.invitedPeers.append(peer)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    deinit {
        transceiver.stop()
    }
}
