//
//  AudioPlayer.swift
//  iStock
//
//  Created by Berg Limma on 07/07/26.
//

import AVFoundation
import Combine
import Foundation

@MainActor
final class AudioPlayer: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var reproduzindo = false
    @Published var mensagemIdAtual: String?

    private var player: AVAudioPlayer?

    func reproduzir(url: URL, mensagemId: String) {
        if mensagemIdAtual == mensagemId, reproduzindo {
            parar()
            return
        }

        parar()

        do {
            #if os(iOS)
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            #endif

            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            player?.play()
            reproduzindo = true
            mensagemIdAtual = mensagemId
        } catch {
            print("Erro ao reproduzir áudio: \(error.localizedDescription)")
        }
    }

    func parar() {
        player?.stop()
        player = nil
        reproduzindo = false
        mensagemIdAtual = nil
    }

    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            self.reproduzindo = false
            self.mensagemIdAtual = nil
        }
    }
}
