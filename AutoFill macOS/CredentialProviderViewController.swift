//
//  CredentialProviderViewController.swift
//  AutoFill macOS
//
//  Created by Ethan Lipnik on 8/19/21.
//

import AuthenticationServices
import SwiftUI

class CredentialProviderViewController: ASCredentialProviderViewController {
    lazy var autoFillService = AutoFillService()

    override func viewDidLoad() {
        super.viewDidLoad()

        let vc = NSHostingController(rootView: AutoFillView { [weak self] in
            self?.extensionContext.cancelRequest(withError: ASExtensionError(.userCanceled))
        } completion: { [weak self] account in
            guard let self else { return }
            do {
                guard let encryptedPassword = account.password,
                      let password = try CryptoSecurityService.decrypt(encryptedPassword)
                else { throw CocoaError(.coderValueNotFound) }
                let passwordCredential = ASPasswordCredential(
                    user: account.username ?? "",
                    password: password
                )

                CryptoSecurityService.encryptionKey = nil

                self.extensionContext.completeRequest(
                    withSelectedCredential: passwordCredential,
                    completionHandler: nil
                )
            } catch {
                print(error)
            }
        }.environmentObject(autoFillService))
        vc.view.translatesAutoresizingMaskIntoConstraints = true
        vc.view.frame = view.bounds
        vc.view.autoresizingMask = [.width, .height]

        view.addSubview(vc.view)

        addChild(vc)
    }
}
