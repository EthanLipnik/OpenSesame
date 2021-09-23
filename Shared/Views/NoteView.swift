//
//  NoteView.swift
//  OpenSesame
//
//  Created by Ethan Lipnik on 9/15/21.
//

import SwiftUI

struct NoteView: View {
    let note: Note
    
    @State private var displayedBody: String = ""
    @State private var isShowingBody: Bool = false
    @State private var isEditing: Bool = false
    @State private var decryptedBody: String? = nil
    
    var body: some View {
        let colors: [Color] = {
            switch note.color {
            case 0:
                return [Color("Note-YellowTop"), Color("Note-YellowBottom")]
            case 1:
                return [Color("Note-BlueTop"), Color("Note-BlueBottom")]
            case 2:
                return [Color("Note-OrangeTop"), Color("Note-OrangeBottom")]
            default:
                return [Color("Note-YellowTop"), Color("Note-YellowBottom")]
            }
        }()
        
        return ScrollView {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom))
#if os(macOS)
                    .shadow(radius: 15, y: 8)
#else
                    .shadow(radius: 30, y: 8)
#endif
                VStack {
                    Text(note.name!)
                        .font(.system(.title, design: .rounded).bold())
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Divider()
                    Text(displayedBody)
                        .font(.system(.body, design: .monospaced))
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .blur(radius: isShowingBody ? 0 : 8)
                        .contextMenu {
                            Button {
                                decryptedBody?.copyToPasteboard()
                            } label: {
                                Label("Copy note", systemImage: "doc.on.doc")
                            }.disabled(!isShowingBody)
                            Button(action: togglePassword) {
                                Label(isShowingBody ? "Hide note" : "Reveal note", systemImage: isShowingBody ? "eye.slash" : "eye")
                            }

                        }
                        .animation(.default, value: isShowingBody)
                        .onTapGesture(perform: togglePassword)
                        .onHover { isHovering in
#if os(macOS)
                            if isHovering {
                                NSCursor.pointingHand.set()
                            } else {
                                NSCursor.arrow.set()
                            }
#endif
                        }
                }
                .padding()
            }
            .padding()
            .frame(maxWidth: 400, minHeight: 300)
            Spacer()
                .frame(maxWidth: .infinity)
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            displayedBody = CryptoSecurityService.randomString(length: Int(note.bodyLength))!
        }
    }
    
    private func togglePassword() {
        if !isShowingBody {
            do {
                decryptedBody = try CryptoSecurityService.decrypt(note.body!)
                
                displayedBody = decryptedBody ?? displayedBody
                
                isShowingBody = true
            } catch {
                print(error)
                
#if os(macOS)
                NSAlert(error: error).runModal()
#endif
            }
        } else {
            isShowingBody.toggle()
            decryptedBody = nil
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                displayedBody = CryptoSecurityService.randomString(length: Int(note.bodyLength))!
            }
        }
    }
}

struct NoteView_Previews: PreviewProvider {
    static var previews: some View {
        NoteView(note: .init())
    }
}
