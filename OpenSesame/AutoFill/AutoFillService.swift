//
//  AutoFillService.swift
//  OpenSesame
//
//  Created by Ethan Lipnik on 9/15/21.
//

import AuthenticationServices
import Combine
import CoreData
import DomainParser

class AutoFillService: ObservableObject {
    lazy var viewContext = PersistenceController.shared.container.viewContext

    @Published
    var suggestedAccounts: [Account] = []
    @Published
    var allAccounts: [Account] = []

    lazy var selectedCredential: ASPasswordCredentialIdentity? = nil

    init() {
        do {
            let domainSort = NSSortDescriptor(key: "domain", ascending: true)
            let usernameSort = NSSortDescriptor(key: "username", ascending: false)

            let fetchRequest: NSFetchRequest<Account> = Account.fetchRequest()
            fetchRequest.sortDescriptors = [domainSort, usernameSort]
            let fetchedResults = try viewContext.fetch(fetchRequest)

            allAccounts = fetchedResults
                .filter { $0.password != nil && $0.username != nil }
        } catch {
            print(error)
        }
    }

    func loadAccountsForServiceIdentifiers(
        _ serviceIdentifiers: [ASCredentialServiceIdentifier]
    ) throws {
        let domainParse = try DomainParser()

        let hosts = serviceIdentifiers
            .compactMap { URL(string: $0.identifier)?.host }
        let domains = hosts
            .compactMap { domainParse.parse(host: $0)?.domain?.lowercased() }
        guard let mainDomain = domains.first else { return }

        let fetchRequest: NSFetchRequest<Account> = Account.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "domain contains[c] %@", mainDomain)
        let fetchedResults = try viewContext.fetch(fetchRequest)

        suggestedAccounts = fetchedResults
    }
}
