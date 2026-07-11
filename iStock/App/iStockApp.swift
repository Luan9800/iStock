//
//  iStockApp.swift
//  iStock
//
//  Created by Luan Carlos on 02/07/26.
//

import SwiftUI
import FirebaseCore
import GoogleSignIn

@main
struct iStockApp: App {
    @StateObject private var auth: AuthService

    init() {
        Self.configureFirebase()
        _auth = StateObject(wrappedValue: AuthService.shared)
        AuthService.shared.configurarListenerSeNecessario()
    }

    private static func configureFirebase() {
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
        KeychainConfigurator.configurarAposFirebase()
        GoogleSignInHelper.configurar()
        print("✅ Firebase conectado com sucesso!")
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if auth.estaLogado {
                    MainView()
                } else {
                    LoginView()
                }
            }
            .onOpenURL { url in
                GIDSignIn.sharedInstance.handle(url)
            }
            .preferredColorScheme(.dark)
        }
        #if os(macOS)
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified)
        .defaultSize(width: 1100, height: 720)
        #endif
    }
}
