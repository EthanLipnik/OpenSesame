//
//  AccountDetailView+OTPView.swift
//  AccountDetailView+OTPView
//
//  Created by Ethan Lipnik on 8/22/21.
//

import SwiftUI
#if canImport(CodeScanner)
import CodeScanner
#endif

extension AccountView.AccountDetailsView {
    var otpView: some View {
        Group {
            if !(account.otpAuth?.isEmpty ?? true) {
                if let code = otpService.verificationCode {
                    VStack(alignment: .leading) {
                        Label("Verification Code", systemImage: "ellipsis.rectangle.fill")
                            .foregroundColor(Color.secondary)
                        HStack {
                            Text(code)
                                .font(.system(.largeTitle, design: .monospaced).bold())
                                .contextMenu {
                                    Button {
                                        code.copyToPasteboard()
                                    } label: {
                                        Label("Copy code", systemImage: "doc.on.doc")
                                    }
                                }

                            if let date = otpService.verificationCodeDate {
                                Spacer()
                                Text(date, style: .relative)
                                    .font(.headline)
                                    .foregroundColor(Color.secondary)
                            }
                        }
                    }
                }
            } else {
                if !isAddingVerificationCode {
                    Button("Add Verification Code") {
                        withAnimation {
                            isEditing = true
                            isAddingVerificationCode = true
                        }
                    }
                } else if isEditing {
                    HStack {
                        TextField(
                            "Verification Code URL or Secret",
                            text: $newVerificationURL,
                            onCommit: {
                                addVerificationCode(newVerificationURL)
                            }
                        )
                        .textFieldStyle(.roundedBorder)
#if os(iOS)
                            .autocapitalization(.none)
#endif
                            .disableAutocorrection(true)

#if canImport(CodeScanner)
                        Button {
                            isScanningQRCode.toggle()
                        } label: {
                            Image(systemName: "qrcode.viewfinder")
                        }
//                    .bottomSheet(isPresented: $isScanningQRCode) {
//                        CodeScannerView(codeTypes: [.qr]) { result in
//                            switch result {
//                            case .success(let code):
//                                isScanningQRCode = false
//                                addVerificationCode(code)
//                            case .failure(let error):
//                                print(error)
//                            }
//                        }
//                        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
//                        .padding()
//                        .shadow(radius: 15)
//                    }
                        .halfSheet(isPresented: $isScanningQRCode) {
                            CodeScannerView(codeTypes: [.qr]) { result in
                                switch result {
                                case let .success(code):
                                    isScanningQRCode = false
                                    addVerificationCode(code)
                                case let .failure(error):
                                    print(error)
                                }
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                            .padding()
                            .shadow(radius: 15)
                        }
#endif
                    }
                }
            }
        }
    }

    private func addVerificationCode(_ code: String) {
        isAddingVerificationCode = false

        account.otpAuth = code

        try? viewContext.save()

        guard !code.isEmpty else { return }
        if let url = URL(string: code) {
            otpService.initialize(url)
        } else {
            otpService.initialize(code)
        }
    }
}
