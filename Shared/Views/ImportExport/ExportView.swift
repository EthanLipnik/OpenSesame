//
//  ExportView.swift
//  ExportView
//
//  Created by Ethan Lipnik on 8/22/21.
//

import SwiftUI
import CoreData
import CSV

struct ExportView: View {
    // MARK: - Environment
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    
    // MARK: - CoreData Variables
    @FetchRequest(
        sortDescriptors: [],
        animation: .default)
    private var accounts: FetchedResults<Account>
    
    // MARK: - Variables
    @State var fileURL: URL? = nil
    @State private var isExporting: Bool = false
    
    // MARK: - View
    var body: some View {
        Spacer()
            .fileMover(isPresented: $isExporting, file: fileURL, onCompletion: { result in
                
                switch result {
                case .success(let url):
                    try? FileManager.default.moveItem(at: FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("OpenSesame Passwords.csv"), to: url)
                case .failure(let error):
                    print(error)
                }
                dismiss.callAsFunction()
            })
            .onAppear {
                let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("OpenSesame Passwords.csv")
                let stream = OutputStream(toFileAtPath: url.path, append: false)!
                do {
                    let csv = try CSVWriter(stream: stream)
                    try csv.write(row: ["Title", "URL", "Username", "Password", "OTPAuth"])
                    
                    for account in accounts {
                        if let decryptedPassword = try? CryptoSecurityService.decrypt(account.password!) {
                            try csv.write(row: [account.domain ?? "", account.url ?? "", account.username ?? "", decryptedPassword, account.otpAuth ?? ""])
                        }
                    }
                    
                    csv.stream.close()
                    
                    fileURL = url
                    isExporting = true
                } catch {
                    dismiss.callAsFunction()
                }
            }
    }
}

struct ExportView_Previews: PreviewProvider {
    static var previews: some View {
        ExportView()
    }
}
