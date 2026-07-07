//
//  SocialAuthHelper.swift
//  iStock
//
//  Created by Berg Limma on 07/07/26.
//

import AuthenticationServices
import CryptoKit
import FirebaseAuth
import FirebaseCore
import Foundation
import GoogleSignIn

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

enum SocialAuthError: LocalizedError {
    case apresentacaoIndisponivel
    case tokenInvalido
    case cancelado
    case keychain

    var errorDescription: String? {
        switch self {
        case .apresentacaoIndisponivel: return "Não foi possível abrir a tela de login."
        case .tokenInvalido: return "Token de autenticação inválido."
        case .cancelado: return "Login cancelado."
        case .keychain:
            return "Erro ao acessar o Keychain. Feche o app, abra Acesso às Chaves no Mac, remova entradas antigas do iStock e tente novamente."
        }
    }
}

enum GoogleSignInHelper {
    static func configurar() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
    }

    @MainActor
    static func entrar() async throws {
        let credencial = try await obterCredencial()
        try await Auth.auth().signIn(with: credencial)
    }

    @MainActor
    static func obterCredencial() async throws -> AuthCredential {
        #if os(iOS)
        guard let cena = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let raiz = cena.windows.first?.rootViewController else {
            throw SocialAuthError.apresentacaoIndisponivel
        }
        let resultado: GIDSignInResult
        do {
            resultado = try await GIDSignIn.sharedInstance.signIn(withPresenting: raiz)
        } catch {
            throw mapearErroGoogle(error)
        }
        #elseif os(macOS)
        guard let janela = NSApplication.shared.keyWindow ?? NSApplication.shared.windows.first else {
            throw SocialAuthError.apresentacaoIndisponivel
        }
        let resultado: GIDSignInResult
        do {
            resultado = try await GIDSignIn.sharedInstance.signIn(withPresenting: janela)
        } catch {
            throw mapearErroGoogle(error)
        }
        #endif

        guard let idToken = resultado.user.idToken?.tokenString else {
            throw SocialAuthError.tokenInvalido
        }

        return GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: resultado.user.accessToken.tokenString
        )
    }

    private static func mapearErroGoogle(_ error: Error) -> Error {
        let nsErro = error as NSError
        if nsErro.domain == "com.google.GIDSignIn", nsErro.code == -2 {
            return SocialAuthError.keychain
        }
        if nsErro.localizedDescription.lowercased().contains("keychain") {
            return SocialAuthError.keychain
        }
        return error
    }
}

@MainActor
final class AppleSignInHelper: NSObject {
    static let shared = AppleSignInHelper()

    private var nonceAtual: String?
    private var continuacaoCredencial: CheckedContinuation<AuthCredential, Error>?

    func entrar() async throws {
        let credencial = try await obterCredencial()
        try await Auth.auth().signIn(with: credencial)
    }

    func obterCredencial() async throws -> AuthCredential {
        try await withCheckedThrowingContinuation { (continuacao: CheckedContinuation<AuthCredential, Error>) in
            self.continuacaoCredencial = continuacao
            let nonce = gerarNonce()
            nonceAtual = nonce

            let provedor = ASAuthorizationAppleIDProvider()
            let pedido = provedor.createRequest()
            pedido.requestedScopes = [.fullName, .email]
            pedido.nonce = sha256(nonce)

            let controlador = ASAuthorizationController(authorizationRequests: [pedido])
            controlador.delegate = self
            controlador.presentationContextProvider = self
            controlador.performRequests()
        }
    }

    private func gerarNonce(comprimento: Int = 32) -> String {
        let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        return String((0..<comprimento).map { _ in charset.randomElement()! })
    }

    private func sha256(_ entrada: String) -> String {
        let dados = Data(entrada.utf8)
        let hash = SHA256.hash(data: dados)
        return hash.map { String(format: "%02x", $0) }.joined()
    }
}

extension AppleSignInHelper: ASAuthorizationControllerDelegate {
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard let credencialApple = authorization.credential as? ASAuthorizationAppleIDCredential,
              let dadosToken = credencialApple.identityToken,
              let idToken = String(data: dadosToken, encoding: .utf8),
              let nonce = nonceAtual else {
            continuacaoCredencial?.resume(throwing: SocialAuthError.tokenInvalido)
            continuacaoCredencial = nil
            return
        }

        let credencialFirebase = OAuthProvider.appleCredential(
            withIDToken: idToken,
            rawNonce: nonce,
            fullName: credencialApple.fullName
        )

        continuacaoCredencial?.resume(returning: credencialFirebase)
        continuacaoCredencial = nil
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        let nsErro = error as NSError
        if nsErro.code == ASAuthorizationError.canceled.rawValue {
            continuacaoCredencial?.resume(throwing: SocialAuthError.cancelado)
        } else {
            continuacaoCredencial?.resume(throwing: error)
        }
        continuacaoCredencial = nil
    }
}

extension AppleSignInHelper: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        #if os(iOS)
        let cena = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }
        return cena?.windows.first { $0.isKeyWindow } ?? ASPresentationAnchor()
        #elseif os(macOS)
        return NSApplication.shared.keyWindow ?? NSApplication.shared.windows.first ?? ASPresentationAnchor()
        #endif
    }
}
