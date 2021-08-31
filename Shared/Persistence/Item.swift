//
//  Item.swift
//  Item
//
//  Created by Ethan Lipnik on 8/30/21.
//

import Foundation
import CoreData

struct Item: Identifiable, Hashable {
    var id: NSManagedObjectID {
        return account?.objectID ?? card!.objectID
    }
    
    let account: Account?
    let card: Card?
    
    init?(_ account: Account?) {
        self.account = account
        self.card = nil
        
        if account == nil {
            return nil
        }
    }
    
    init(_ account: Account) {
        self.account = account
        self.card = nil
    }
    
    init?(_ card: Card?) {
        self.card = card
        self.account = nil
        
        if card == nil {
            return nil
        }
    }
    
    init(_ card: Card) {
        self.card = card
        self.account = nil
    }
    
    private init() {
        self.card = nil
        self.account = nil
    }
}
