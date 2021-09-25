//
//  CloudKitShareView.swift
//  OpenSesame
//
//  Created by Ethan Lipnik on 9/24/21.
//

import SwiftUI
import CloudKit
import CoreData

#if os(iOS)
import UIKit

struct CloudKitShareButton<Object: NSManagedObject>: UIViewRepresentable {
    typealias UIViewType = UIButton

    @ObservedObject
    var toShare: Object
    @State
    var share: CKShare?

    func makeUIView(context: UIViewRepresentableContext<CloudKitShareButton>) -> UIButton {
        let button = UIButton()

        button.setImage(UIImage(systemName: "person.crop.circle.badge.plus"), for: .normal)
        button.addTarget(context.coordinator, action: #selector(context.coordinator.pressed(_:)), for: .touchUpInside)

        context.coordinator.button = button
        return button
    }

    func updateUIView(_ uiView: UIButton, context: UIViewRepresentableContext<CloudKitShareButton>) {

    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UICloudSharingControllerDelegate {
        var button: UIButton?

        func cloudSharingController(_ csc: UICloudSharingController, failedToSaveShareWithError error: Error) {
            //Handle some errors here.
        }

        func itemTitle(for csc: UICloudSharingController) -> String? {
//            return parent.toShare.name
            return "Title"
        }

        var parent: CloudKitShareButton

        init(_ parent: CloudKitShareButton) {
            self.parent = parent
        }

        @objc func pressed(_ sender: UIButton) {
            //Pre-Create the CKShare record here, and assign to parent.share...

            let sharingController = UICloudSharingController(share: parent.share!, container: CKContainer(identifier: "iCloud.\(OpenSesameConfig.PRODUCT_BUNDLE_IDENTIFIER_BASE)"))

            sharingController.delegate = self
            sharingController.availablePermissions = [.allowReadWrite]
            if let button = self.button {
                sharingController.popoverPresentationController?.sourceView = button
            }

            let window = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .flatMap({ $0.windows })
                .first
            window?.rootViewController?.present(sharingController, animated: true)
        }
    }
}

//struct CloudKitShareView<Object: NSManagedObject>: UIViewControllerRepresentable {
//    let object: Object
//    let title: String
//
//    func makeUIViewController(context: Context) -> UICloudSharingController {
//        let cloudSharingController = UICloudSharingController {
//            (controller, completion: @escaping (CKShare?, CKContainer?, Error?) -> Void) in
//            PersistenceController.shared.container.share([object], to: nil) { objectIDs, share, container, error in
//                if let actualShare = share {
//                    actualShare[CKShare.SystemFieldKey.title] = title
//                }
//                completion(share, container, error)
//            }
//        }
//        cloudSharingController.delegate = context.coordinator
//
//        return cloudSharingController
//    }
//
//    func updateUIViewController(_ uiViewController: UICloudSharingController, context: Context) {
//
//    }
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(title: title)
//    }
//
//    class Coordinator: NSObject, UICloudSharingControllerDelegate {
//        let title: String
//
//        init(title: String) {
//            self.title = title
//        }
//
//        func cloudSharingController(_ csc: UICloudSharingController, failedToSaveShareWithError error: Error) {
//            print(error)
//        }
//
//        func itemTitle(for csc: UICloudSharingController) -> String? {
//            return title
//        }
//    }
//}
#else
#endif
