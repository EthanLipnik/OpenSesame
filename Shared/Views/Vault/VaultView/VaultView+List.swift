//
//  VaultView+List.swift
//  VaultView+List
//
//  Created by Ethan Lipnik on 8/22/21.
//

import SwiftUI

extension VaultView {
    var list: some View {
        List {
            if !notes.isEmpty {
                if accounts.isEmpty && cards.isEmpty {
                    notesList
                } else {
                    Section("Notes") {
                        notesList
                    }
                }
            }
            if !cards.isEmpty {
                if accounts.isEmpty && notes.isEmpty {
                    cardsList
                } else {
                    Section("Cards") {
                        cardsList
                    }
                }
            }

            if !accounts.isEmpty {
                if cards.isEmpty && notes.isEmpty {
                    accountsList
                } else {
                    Section("Accounts") {
                        accountsList
                    }
                }
            }
        }
        #if !os(macOS)
        .overlay(accounts.isEmpty && cards.isEmpty && notes.isEmpty ? Text("Add a new account, note, or card")
            .font(.title.bold())
            .foregroundColor(Color.secondary)
            .padding(.horizontal) : nil)
        #endif
            .confirmationDialog("Are you sure you want to delete this account? You cannot retreive it when it is gone.", isPresented: $shouldDeleteAccount) {
                Button("Delete", role: .destructive) {
                    deleteItems(offsets: IndexSet([accounts.firstIndex(of: itemToBeDeleted!.account!)!]), type: .account)
                }

                Button("Cancel", role: .cancel) {
                    shouldDeleteAccount = false
                }.keyboardShortcut(.defaultAction)
            }
            .confirmationDialog("Are you sure you want to delete this card? You cannot retreive it when it is gone.", isPresented: $shouldDeleteCard) {
                Button("Delete", role: .destructive) {
                    deleteItems(offsets: IndexSet([cards.firstIndex(of: itemToBeDeleted!.card!)!]), type: .card)
                }

                Button("Cancel", role: .cancel) {
                    shouldDeleteCard = false
                }.keyboardShortcut(.defaultAction)
            }
            .confirmationDialog("Are you sure you want to delete this note? You cannot retreive it when it is gone.", isPresented: $shouldDeleteNote) {
                Button("Delete", role: .destructive) {
                    deleteItems(offsets: IndexSet([notes.firstIndex(of: itemToBeDeleted!.note!)!]), type: .note)
                }

                Button("Cancel", role: .cancel) {
                    shouldDeleteNote = false
                }.keyboardShortcut(.defaultAction)
            }
    }

    private var notesList: some View {
        ForEach(notes) { note in
            NoteItemView(note: note)
                .environmentObject(viewModel)
                .contextMenu {
                    Button {
                        note.isPinned.toggle()

                        try? viewContext.save()
                    } label: {
                        Label(note.isPinned ? "Unpin" : "Pin", systemImage: note.isPinned ? "pin.slash" : "pin")
                    }
                    Button("Delete", role: .destructive) {
                        itemToBeDeleted = .init(note)
                        shouldDeleteNote.toggle()
                    }
                }
                .swipeActions {
                    Button(note.isPinned ? "Unpin" : "Pin") {
                        note.isPinned.toggle()

                        try? viewContext.save()
                    }.tint(note.isPinned ? .orange : .accentColor)

                    Button("Delete", role: .destructive) {
                        itemToBeDeleted = .init(note)
                        shouldDeleteNote.toggle()
                    }
                }
        }.onDelete { indexSet in
            itemToBeDeleted = .init(notes[indexSet.first!])
            shouldDeleteNote.toggle()
        }
    }

    private var cardsList: some View {
        ForEach(cards) { card in
            CardItemView(card: card)
                .environmentObject(viewModel)
                .contextMenu {
                    Button {
                        card.isPinned.toggle()

                        try? viewContext.save()
                    } label: {
                        Label(card.isPinned ? "Unpin" : "Pin", systemImage: card.isPinned ? "pin.slash" : "pin")
                    }
                    Button("Delete", role: .destructive) {
                        itemToBeDeleted = .init(card)
                        shouldDeleteCard.toggle()
                    }
                }
                .swipeActions {
                    Button(card.isPinned ? "Unpin" : "Pin") {
                        card.isPinned.toggle()

                        try? viewContext.save()
                    }.tint(card.isPinned ? .orange : .accentColor)

                    Button("Delete", role: .destructive) {
                        itemToBeDeleted = .init(card)
                        shouldDeleteCard.toggle()
                    }
                }
        }.onDelete { indexSet in
            itemToBeDeleted = .init(cards[indexSet.first!])
            shouldDeleteCard.toggle()
        }
    }

    private var accountsList: some View {
        ForEach(accounts) { account in
            AccountItemView(account: account)
                .environmentObject(viewModel)
                .contextMenu {
                    Button {
                        account.isPinned.toggle()

                        try? viewContext.save()
                    } label: {
                        Label(account.isPinned ? "Unpin" : "Pin", systemImage: account.isPinned ? "pin.slash" : "pin")
                    }
                    Button("Delete", role: .destructive) {
                        itemToBeDeleted = .init(account)
                        shouldDeleteAccount.toggle()
                    }
                }
                .swipeActions {
                    Button(account.isPinned ? "Unpin" : "Pin") {
                        account.isPinned.toggle()

                        try? viewContext.save()
                    }.tint(account.isPinned ? .orange : .accentColor)

                    Button("Delete", role: .destructive) {
                        itemToBeDeleted = .init(account)
                        shouldDeleteAccount.toggle()
                    }
                }
        }
        .onDelete { indexSet in
            itemToBeDeleted = .init(accounts[indexSet.first!])
            shouldDeleteAccount.toggle()
        }
    }
}
