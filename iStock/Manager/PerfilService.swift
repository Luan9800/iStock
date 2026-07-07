//
//  PerfilService.swift
//  iStock
//
//  Created by Berg Limma on 07/07/26.
//

import Combine
import FirebaseAuth
import Foundation

@MainActor
final class PerfilService: ObservableObject {
    static let shared = PerfilService()

    @Published var fotoURL: String?
    @Published var carregandoFoto = false
    @Published var erro: String?

    private var uidAtual: String?

    private init() {}

    func carregarParaUsuario(uid: String?) {
        uidAtual = uid
        guard let uid else {
            fotoURL = nil
            return
        }

        let local = caminhoLocal(uid: uid)
        if FileManager.default.fileExists(atPath: local.path) {
            fotoURL = local.absoluteString
            return
        }

        if let salva = UserDefaults.standard.string(forKey: chaveFoto(uid)), !salva.isEmpty {
            fotoURL = salva
            return
        }

        if let photo = Auth.auth().currentUser?.photoURL?.absoluteString, !photo.isEmpty {
            fotoURL = photo
            return
        }

        fotoURL = nil
    }

    func salvarFoto(_ data: Data) async -> Bool {
        guard let uid = uidAtual ?? AuthService.shared.uid else {
            erro = "Usuário não identificado."
            return false
        }

        carregandoFoto = true
        erro = nil
        defer { carregandoFoto = false }

        let comprimida = ImageCompressor.compressJPEG(data) ?? data

        if AuthService.shared.usandoLoginLocal {
            return salvarFotoLocal(comprimida, uid: uid)
        }
        return await salvarFotoNuvem(comprimida, uid: uid)
    }

    // MARK: - Local

    @discardableResult
    private func salvarFotoLocal(_ data: Data, uid: String) -> Bool {
        let arquivo = caminhoLocal(uid: uid)
        do {
            try FileManager.default.createDirectory(
                at: arquivo.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try data.write(to: arquivo)
            fotoURL = arquivo.absoluteString
            UserDefaults.standard.set(arquivo.absoluteString, forKey: chaveFoto(uid))
            return true
        } catch {
            self.erro = error.localizedDescription
            return false
        }
    }

    // MARK: - Nuvem

    private func salvarFotoNuvem(_ data: Data, uid: String) async -> Bool {
        guard Auth.auth().currentUser != nil else {
            erro = "Faça login na nuvem para salvar a foto."
            return false
        }

        let path = "perfis/\(uid)/avatar.jpg"
        do {
            let url = try await ImageStorageService.shared.upload(data: data, path: path)
            fotoURL = url.absoluteString
            UserDefaults.standard.set(url.absoluteString, forKey: chaveFoto(uid))

            if let user = Auth.auth().currentUser {
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.photoURL = url
                try await changeRequest.commitChanges()
            }
            return true
        } catch {
            self.erro = error.localizedDescription
            return false
        }
    }

    private func caminhoLocal(uid: String) -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("perfis/\(uid).jpg")
    }

    private func chaveFoto(_ uid: String) -> String {
        "istock.perfil.foto.\(uid)"
    }
}
