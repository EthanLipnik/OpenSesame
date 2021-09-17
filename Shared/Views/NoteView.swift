//
//  NoteView.swift
//  OpenSesame
//
//  Created by Ethan Lipnik on 9/15/21.
//

import SwiftUI

struct NoteView: View {
//    let note: Note
    
    @State private var displayedBody: String = ""
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(LinearGradient(colors: [Color("Note-YellowTop"), Color("Note-YellowBottom")], startPoint: .top, endPoint: .bottom))
#if os(macOS)
                .shadow(radius: 15, y: 8)
#else
                .shadow(radius: 30, y: 8)
#endif
            VStack {
                Text("Social Security")
                    .font(.system(.title, design: .rounded).bold())
                    .frame(maxWidth: .infinity, alignment: .center)
                Divider()
                Text("Body")
                    .font(.system(.body, design: .rounded))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            .padding()
        }
        .padding()
        .frame(minHeight: 300)
    }
}

struct NoteView_Previews: PreviewProvider {
    static var previews: some View {
        NoteView()
    }
}
