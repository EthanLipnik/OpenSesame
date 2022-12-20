//
//  Item.swift
//  Item
//
//  Created by Ethan Lipnik on 8/30/21.
//

import CoreData
import Foundation

struct Item: Identifiable, Hashable {
    var id: NSManagedObjectID {
        return account?.objectID ?? card?.objectID ?? note!.objectID
    }

    private(set) var account: Account?
    private(set) var card: Card?
    private(set) var note: Note?

    init?(_ account: Account?) {
        self.account = account

        if account == nil {
            return nil
        }
    }

    init(_ account: Account) {
        self.account = account
    }

    init?(_ card: Card?) {
        self.card = card

        if card == nil {
            return nil
        }
    }

    init(_ card: Card) {
        self.card = card
    }

    init(_ note: Note) {
        self.note = note
    }

    init?(_ note: Note?) {
        self.note = note

        if note == nil {
            return nil
        }
    }

    private init() {}
}
