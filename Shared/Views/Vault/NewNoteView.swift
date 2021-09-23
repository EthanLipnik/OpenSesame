//
//  NewNoteView.swift
//  OpenSesame
//
//  Created by Ethan Lipnik on 9/15/21.
//

import SwiftUI

struct NewNoteView: View {
    // MARK: - Environment
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var viewContext
    
    // MARK: - Variables
    let selectedVault: Vault
    
    @State private var name: String = ""
    @State private var bodyTxt: String = ""
    @State private var selectedColor: Int = 0
    
    // MARK: - View
    var body: some View {
        let colors: [Color] = {
            switch selectedColor {
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
        
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom))
#if os(macOS)
                    .shadow(radius: 15, y: 8)
#else
                    .shadow(radius: 30, y: 8)
#endif
                VStack {
                    TextField("Name", text: $name)
                        .font(.system(.title, design: .rounded).bold())
                        .frame(maxWidth: .infinity, alignment: .center)
                    Divider()
                    Picker("Color", selection: $selectedColor) {
                        Text("Yellow")
                            .tag(0)
                        Text("Blue")
                            .tag(1)
                        Text("Orange")
                            .tag(2)
                    }
                    .pickerStyle(.segmented)
                    .colorScheme(.light)
                    TextEditor(text: $bodyTxt)
                        .padding(5)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color("Tertiary").opacity(0.5)).blendMode(.overlay))
                        .font(.system(.body, design: .rounded))
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                }
                .padding()
            }
            .padding()
            .frame(minHeight: 200)
            Spacer()
            HStack {
                Button("Cancel", role: .cancel) {
                    dismiss.callAsFunction()
                }
                .keyboardShortcut(.cancelAction)
#if os(iOS)
                .hoverEffect()
#endif
                
                Spacer()
                
                Button("Add", action: add)
                    .keyboardShortcut(.defaultAction)
                    .disabled(name.isEmpty || bodyTxt.isEmpty)
#if os(iOS)
                .hoverEffect()
#endif
            }.padding()
        }
    }
    
    // MARK: - Functions
    private func add() {
        do {
            let note = Note(context: viewContext)
            note.name = name
            
            note.body = try CryptoSecurityService.encrypt(bodyTxt)
            note.bodyLength = Int16(bodyTxt.count)
            
            note.color = Int16(selectedColor)
            
            selectedVault.addToNotes(note)
            
            try viewContext.save()
            
            dismiss.callAsFunction()
        } catch {
            print(error)
        }
    }
}

struct NewNoteView_Previews: PreviewProvider {
    static var previews: some View {
        NewNoteView(selectedVault: .init())
    }
}
