//
//  ContentView.swift
//  iStock
//
//  Created by Luan Carlos on 02/07/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Text("Testando — se você está vendo isso, o problema é no Firebase/Auth")
            .padding()
    }
}

/* struct ContentView: View {
    @ObservedObject private var auth = AuthService.shared

    var body: some View {
        if auth.estaLogado {
            CadastroProdutoView()
        } else {
           // LoginView()
        }
    }
} */
