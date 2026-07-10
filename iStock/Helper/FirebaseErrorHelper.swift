//
//  FirebaseErrorHelper.swift
//  iStock
//

import FirebaseFirestore
import Foundation

enum FirebaseErrorHelper {
  static func mensagem(_ error: Error) -> String {
    let nsErro = error as NSError

    if nsErro.domain == FirestoreErrorDomain,
       nsErro.code == FirestoreErrorCode.permissionDenied.rawValue {
      return mensagemPermissaoNegada()
    }

    let descricao = error.localizedDescription.lowercased()
    if descricao.contains("missing or insufficient permissions")
      || descricao.contains("permission_denied")
      || descricao.contains("permission denied") {
      return mensagemPermissaoNegada()
    }

    return error.localizedDescription
  }

  static func ehPermissaoNegada(_ error: Error) -> Bool {
    let nsErro = error as NSError
    if nsErro.domain == FirestoreErrorDomain,
       nsErro.code == FirestoreErrorCode.permissionDenied.rawValue {
      return true
    }
    let descricao = error.localizedDescription.lowercased()
    return descricao.contains("missing or insufficient permissions")
      || descricao.contains("permission_denied")
      || descricao.contains("permission denied")
  }

  private static func mensagemPermissaoNegada() -> String {
    """
    Permissão negada no Firebase. Publique as regras de segurança do projeto:
    1. Console Firebase → Firestore → Regras (ou Storage → Regras)
    2. Cole o conteúdo de firebase/firestore.rules e firebase/storage.rules
    3. Clique em Publicar

    Ou, com Firebase CLI: firebase deploy --only firestore:rules,storage
  """
  }
}
