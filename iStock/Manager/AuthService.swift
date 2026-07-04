//
//  AuthService.swift
//  iStock
//
//  Created by Luan Carlos on 04/07/26.
//

import Combine
import Foundation
import FirebaseAuth

@MainActor
final class AuthService: ObservableObject {
    static let shared = AuthService()

    @Published var usuario: User?
    @Published var erro: String?
    @Published var carregando = false

    private var handle: AuthStateDidChangeListenerHandle?

    private init() {
        // fica escutando: se logar/deslogar em qualquer tela, o app inteiro sabe na hora
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.usuario = user
        }
    }

    var estaLogado: Bool { usuario != nil }

    var nomeOuEmail: String {
        usuario?.displayName?.isEmpty == false ? usuario!.displayName! : (usuario?.email ?? "")
    }

    func entrar(email: String, senha: String) async {
        carregando = true
        erro = nil
        do {
            try await Auth.auth().signIn(withEmail: email, password: senha)
        } catch {
            erro = traduzErro(error)
        }
        carregando = false
    }

    func cadastrar(nome: String, email: String, senha: String) async {
        carregando = true
        erro = nil
        do {
            let resultado = try await Auth.auth().createUser(withEmail: email, password: senha)
            let changeRequest = resultado.user.createProfileChangeRequest()
            changeRequest.displayName = nome
            try await changeRequest.commitChanges()
        } catch {
            erro = traduzErro(error)
        }
        carregando = false
    }

    func sair() {
        try? Auth.auth().signOut()
    }

    private func traduzErro(_ error: Error) -> String {
        let codigo = (error as NSError).code
        switch AuthErrorCode(rawValue: codigo) {
        case .invalidEmail: return "E-mail inválido."
        case .emailAlreadyInUse: return "Esse e-mail já está cadastrado."
        case .weakPassword: return "Senha muito fraca (mínimo 6 caracteres)."
        case .wrongPassword, .invalidCredential: return "E-mail ou senha incorretos."
        case .userNotFound: return "Usuário não encontrado."
        default: return "Erro: \(error.localizedDescription)"
        }
    }

    deinit {
        if let handle { Auth.auth().removeStateDidChangeListener(handle) }
    }
}
