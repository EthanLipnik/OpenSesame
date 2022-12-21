//
//  ImportManager.swift
//  ImportManager
//
//  Created by Ethan Lipnik on 9/9/21.
//

import AuthenticationServices
import Combine
import CSV
import DomainParser
import Foundation

class ImportManager: ObservableObject {
    // MARK: - Variables

    @Published
    var importedAccounts: [ImportedAccount] = []
    @Published
    var addedAccounts: Set<Account> = []
    @Published
    var isImporting: Bool = false
    @Published
    var progress: Float = 0

    let viewContext = PersistenceController.shared.container.viewContext

    var selectedVault: Vault?
    let appFormat: AppFormat

    // MARK: - Types

    struct ImportedAccount: Identifiable, Hashable {
        let id: UUID = .init()

        var name: String
        var url: String
        var username: String
        var password: String
        var otpAuth: String?
        var notes: String?
        var isPinned: Bool = false
    }

    // MARK: - Init

    init(vault: Vault? = nil, appFormat: AppFormat) {
        selectedVault = vault
        self.appFormat = appFormat

        print(appFormat)
    }

    func importFromFile(_ url: URL) {
        DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
            let stream = InputStream(url: url)!
            var importedAccounts: [ImportedAccount] = []

            let csv = try! CSVReader(stream: stream, hasHeaderRow: true).lazy
            switch appFormat {
            case .browser:
                importedAccounts = csv.map { ImportedAccount(
                    name: $0[safe: 0] ?? "",
                    url: $0[safe: 1] ?? "",
                    username: $0[safe: 2] ?? "",
                    password: $0[safe: 3] ?? "",
                    otpAuth: $0[safe: 4]
                ) }
            case .bitwarden:
                importedAccounts = csv.map { ImportedAccount(
                    name: $0[safe: 3] ?? "",
                    url: $0[safe: 6] ?? "",
                    username: $0[safe: 7] ?? "",
                    password: $0[safe: 8] ?? "",
                    otpAuth: $0[safe: 9],
                    notes: $0[safe: 4],
                    isPinned: ($0[safe: 1] ?? "0") == "1" ? true : false
                ) }
            case .onePassword:
                importedAccounts = csv.map { ImportedAccount(
                    name: $0[safe: 2] ?? "",
                    url: $0[safe: 4] ?? "",
                    username: $0[safe: 5] ?? "",
                    password: $0[safe: 1] ?? "",
                    otpAuth: nil,
                    notes: $0[safe: 0]
                ) }
            }

            DispatchQueue.main.async {
                self.importedAccounts = importedAccounts.map { $0 }
            }
            stream.close()
        }
    }

    func save(completion: @escaping (Error?) -> Void) {
        guard let selectedVault else {
            return
        }

        isImporting = true

        DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
            do {
                let domainParser = try DomainParser()

                func finalize() {
                    if progress >= Float(importedAccounts.count) {
                        do {
                            try viewContext.save()

                            // Save credentials for autofill
                            ASCredentialIdentityStore.shared.getState { state in
                                if state.isEnabled {
                                    let domainIdentifers = addedAccounts
                                        .map { ASPasswordCredentialIdentity(
                                            serviceIdentifier: ASCredentialServiceIdentifier(
                                                identifier: $0
                                                    .domain!,
                                                type: .domain
                                            ),
                                            user: $0.username!,
                                            recordIdentifier: nil
                                        ) }

                                    ASCredentialIdentityStore.shared.saveCredentialIdentities(
                                        domainIdentifers,
                                        completion: { _, error in
                                            print(
                                                error?
                                                    .localizedDescription ??
                                                    "No errors in saving credentials"
                                            )
                                        }
                                    )
                                }
                            }

                            completion(nil)
                        } catch {
                            completion(error)
                        }
                    }
                }

                for i in 0 ..< importedAccounts.count {
                    let importedAccount = importedAccounts[i]
                    do {
                        var domain: String = importedAccount.name
                            .isEmpty ? "Account\(i == 0 ? "" : " \(i + 1)")" : importedAccount.name

                        if let url = URL(string: importedAccount.url), let host = url.host,
                           let parsedDomain = domainParser.parse(host: host)?.domain?.lowercased()
                        {
                            domain = parsedDomain
                        }
                        if !addedAccounts
                            .contains(where: {
                                $0.domain == domain && $0.username == importedAccount.username
                            })
                        {
                            let account = Account(context: viewContext)
                            account.domain = domain
                            account.url = importedAccount.url.removeHTTP.removeWWW

                            account.username = importedAccount.username
                            account.otpAuth = importedAccount.otpAuth
                            account.dateAdded = Date()
                            account.notes = importedAccount.notes
                            account.isPinned = importedAccount.isPinned

                            guard let encryptedPassword = try CryptoSecurityService
                                .encrypt(importedAccount.password)
                            else {
                                DispatchQueue.main.async {
                                    progress += 1
                                    finalize()
                                }
                                return
                            }
                            account.password = encryptedPassword
                            account.passwordLength = Int16(importedAccount.password.count)

                            selectedVault.addToAccounts(account)

                            DispatchQueue.main.async {
                                addedAccounts.insert(account)
                                progress += 1

                                finalize()
                            }
                        } else {
                            DispatchQueue.main.async {
                                progress += 1

                                finalize()
                            }
                        }
                    } catch {
                        print(importedAccount)
                        completion(error)
                    }
                }
            } catch {
                completion(error)
            }
        }
    }
}

enum FileFormat: String {
    case json
    case csv
}

enum AppFormat: String, Identifiable {
    var id: String {
        rawValue
    }

    case onePassword
    case bitwarden
    case browser
}
