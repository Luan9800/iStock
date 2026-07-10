//
//  FirestoreProvider.swift
//  iStock
//

import FirebaseFirestore

/// Banco Firestore compartilhado com istock-web (projeto istock-4771d).
enum FirestoreProvider {
    static let databaseId = "istock"

    static var db: Firestore {
        Firestore.firestore(database: databaseId)
    }
}
