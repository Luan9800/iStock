//
//  KeychainConfigurator.swift
//  iStock
//
//  Created by Berg Limma on 07/07/26.
//

import FirebaseAuth
import Foundation
import Security

enum KeychainConfigurator {
    /// Necessário no macOS (app sandbox) para Firebase Auth e Google Sign-In.
    static func configurarAposFirebase() {
        #if os(macOS)
        configurarFirebaseAuth()
        #endif
    }

    #if os(macOS)
    private static func configurarFirebaseAuth() {
        guard let grupo = obterGrupoKeychain() else {
            print("⚠️ keychain-access-groups não encontrado nos entitlements do macOS.")
            return
        }

        do {
            try Auth.auth().useUserAccessGroup(grupo)
        } catch {
            print("⚠️ Erro ao configurar keychain do Firebase: \(error.localizedDescription)")
        }
    }

    private static func obterGrupoKeychain() -> String? {
        guard let task = SecTaskCreateFromSelf(nil) else { return nil }

        guard let grupos = SecTaskCopyValueForEntitlement(
            task,
            "keychain-access-groups" as CFString,
            nil
        ) as? [String] else {
            return nil
        }

        return grupos.first
    }
    #endif
}
