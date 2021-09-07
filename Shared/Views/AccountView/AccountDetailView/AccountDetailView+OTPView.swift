//
//  AccountDetailView+OTPView.swift
//  AccountDetailView+OTPView
//
//  Created by Ethan Lipnik on 8/22/21.
//

import SwiftUI

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
                    TextField("Verification Code URL or Secret", text: $newVerificationURL, onCommit:  {
                        isAddingVerificationCode = false
                        
                        account.otpAuth = newVerificationURL
                        
                        try? viewContext.save()
                        
                        guard !newVerificationURL.isEmpty else { return }
                        if let url = URL(string: newVerificationURL) {
                            otpService.initialize(url)
                        } else {
                            otpService.initialize(newVerificationURL)
                        }
                    })
                        .textFieldStyle(.roundedBorder)
#if os(iOS)
                        .autocapitalization(.none)
#endif
                        .disableAutocorrection(true)
                }
            }
        }
    }
}
