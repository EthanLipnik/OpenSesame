//
//  NoteView.swift
//  OpenSesame
//
//  Created by Ethan Lipnik on 9/15/21.
//

import SwiftUI

struct NoteView: View {
    @Environment(\.managedObjectContext) var viewContext

    let note: Note

    @State private var displayedBody: String = ""
    @State private var isShowingBody: Bool = false
    @State private var isEditing: Bool = false
    @State private var decryptedBody: String?
    @State private var isSharing: Bool = false

    @State private var newColor: Int = 0

    var body: some View {
        let colors: [Color] = {
            switch newColor {
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
                    if isEditing {
                        Picker("Color", selection: $newColor) {
                            Text("Yellow")
                                .tag(0)
                            Text("Blue")
                                .tag(1)
                            Text("Orange")
                                .tag(2)
                        }
                        .pickerStyle(.segmented)
                        .colorScheme(.light)
                        TextEditor(text: $displayedBody)
                            .padding(5)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color("Tertiary").opacity(0.5)).blendMode(.overlay))
                            .font(.system(.title3, design: .monospaced))
                            .frame(maxWidth: .infinity, minHeight: 400, maxHeight: .infinity)
                    } else {
                        Text(displayedBody)
                            .font(.system(.title3, design: .monospaced))
                            .frame(maxWidth: .infinity, minHeight: 250, maxHeight: .infinity, alignment: .topLeading)
                            .blur(radius: isShowingBody ? 0 : 8)
                            .contextMenu {
                                Button {
                                    decryptedBody?.copyToPasteboard()
                                } label: {
                                    Label("Copy note", systemImage: "doc.on.doc")
                                }.disabled(!isShowingBody)
                                Button(action: toggleBody) {
                                    Label(isShowingBody ? "Hide note" : "Reveal note", systemImage: isShowingBody ? "eye.slash" : "eye")
                                }
                            }
                            .animation(.default, value: isShowingBody)
                            .onTapGesture(perform: toggleBody)
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
                }
                .padding()
            }
            .padding()
            .frame(maxWidth: 400)
            Spacer()
                .frame(maxWidth: .infinity)
        }
        .onAppear {
            displayedBody = CryptoSecurityService.randomString(length: Int(note.bodyLength))!
            newColor = Int(note.color)
        }
        .onChange(of: newColor) { color in
            note.color = Int16(color)
            print(color)
        }
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    if !isEditing {
                        displayBody()
                        newColor = Int(note.color)
                    } else {
                        do {
                            note.body = try CryptoSecurityService.encrypt(displayedBody)
                            note.bodyLength = Int16(displayedBody.count)

                            try viewContext.save()
                        } catch {
                            print(error)
                        }
                    }

                    withAnimation {
                        isEditing.toggle()
                    }
                } label: {
                    Label(isEditing ? "Done" : "Edit", systemImage: isEditing ? "checkmark.circle.fill" : "pencil")
                }
            }
            ToolbarItem {
                Button {
                    isSharing.toggle()
                } label: {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
                .halfSheet(isPresented: $isSharing) {
                    ShareSheet(
                        activityItems: [try! NoteDocument(note).save()],
                        excludedActivityTypes: [.addToReadingList, .assignToContact, .markupAsPDF, .openInIBooks, .postToFacebook, .postToVimeo, .postToWeibo, .postToFlickr, .postToTwitter, .postToTencentWeibo, .print, .saveToCameraRoll]
                    )
                    .ignoresSafeArea()
                    .onDisappear {
                        isSharing = false
                    }
                }
            }
        }
        #else
                .toolbar {
                    ToolbarItem {
                        Spacer()
                    }
                }
                .frame(minWidth: 300)
        #endif
    }

    private func toggleBody() {
        if !isShowingBody {
            displayBody()
        } else {
            isShowingBody.toggle()
            decryptedBody = nil

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                displayedBody = CryptoSecurityService.randomString(length: Int(note.bodyLength))!
            }
        }
    }

    private func displayBody() {
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
    }
}

struct NoteView_Previews: PreviewProvider {
    static var previews: some View {
        NoteView(note: .init())
    }
}
