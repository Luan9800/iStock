//
//  iStockApp.swift
//  iStock
//
//  Created by Luan Carlos on 02/07/26.
//

import SwiftUI
import FirebaseCore

@main
struct iStockApp: App {
    init() {
        let env = ProcessInfo.processInfo.environment
        let estaEmPreview = env["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
            || env["XCODE_RUNNING_FOR_PLAYGROUNDS"] == "1"

        guard !estaEmPreview else {
            print("ℹ️ Rodando em Preview — Firebase não inicializado.")
            return
        }

        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        print("✅ Firebase conectado com sucesso!")
    }

    var body: some Scene {
        WindowGroup {
            CadastroProdutoView()
        }
    }
}
