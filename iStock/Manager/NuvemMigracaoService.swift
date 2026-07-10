//
//  NuvemMigracaoService.swift
//  iStock
//
//  Envia dados do modo local para o Firestore na primeira sessão na nuvem.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

@MainActor
final class NuvemMigracaoService {
    static let shared = NuvemMigracaoService()

    private init() {}

    private func chaveMigracao(uid: String) -> String {
        "istock.migracao.nuvem.\(uid)"
    }

    func migrarSeNecessario() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard !UserDefaults.standard.bool(forKey: chaveMigracao(uid: uid)) else { return }

        let lancamentos = LocalInventoryStore.shared.carregar()
        let avaliacoes = LocalAvaliacaoStore.shared.carregar()
        let transacoes = LocalTransacaoLogStore.shared.carregar()

        guard !lancamentos.isEmpty || !avaliacoes.isEmpty || !transacoes.isEmpty else {
            UserDefaults.standard.set(true, forKey: chaveMigracao(uid: uid))
            return
        }

        let db = FirestoreProvider.db

        for item in lancamentos {
            let id = item.id?.isEmpty == false ? item.id! : UUID().uuidString
            do {
                try db.collection("lancamentos").document(id).setData(from: item, merge: true)
            } catch {
                print("Migração lancamento \(id): \(error.localizedDescription)")
            }
        }

        for item in avaliacoes {
            let id = item.id?.isEmpty == false ? item.id! : UUID().uuidString
            do {
                try db.collection("avaliacoes").document(id).setData(from: item, merge: true)
            } catch {
                print("Migração avaliação \(id): \(error.localizedDescription)")
            }
        }

        for item in transacoes {
            let id = item.id?.isEmpty == false ? item.id! : UUID().uuidString
            do {
                try db.collection("transacoes").document(id).setData(from: item, merge: true)
            } catch {
                print("Migração transação \(id): \(error.localizedDescription)")
            }
        }

        UserDefaults.standard.set(true, forKey: chaveMigracao(uid: uid))
    }
}
