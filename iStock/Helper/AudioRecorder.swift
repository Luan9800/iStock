//
//  AudioRecorder.swift
//  iStock
//
//  Created by Berg Limma on 07/07/26.
//

import AVFoundation
import Combine
import Foundation

@MainActor
final class AudioRecorder: NSObject, ObservableObject {
    @Published var gravando = false
    @Published var duracao: TimeInterval = 0

    private var recorder: AVAudioRecorder?
    private var pollingTask: Task<Void, Never>?
    private var arquivoURL: URL?

    func iniciar() {
        #if os(iOS)
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playAndRecord, mode: .default)
        try? session.setActive(true)
        #endif

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(UUID().uuidString).m4a")

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            recorder = try AVAudioRecorder(url: url, settings: settings)
            recorder?.record()
            arquivoURL = url
            gravando = true
            duracao = 0
            pollingTask = Task { @MainActor [weak self] in
                while !Task.isCancelled {
                    try? await Task.sleep(for: .milliseconds(100))
                    guard let self, self.gravando else { return }
                    self.duracao = self.recorder?.currentTime ?? 0
                }
            }
        } catch {
            print("Erro ao iniciar gravação: \(error.localizedDescription)")
        }
    }

    func parar() -> (data: Data, duracao: Double)? {
        pollingTask?.cancel()
        pollingTask = nil
        recorder?.stop()
        gravando = false

        guard let url = arquivoURL,
              let data = try? Data(contentsOf: url) else { return nil }

        let duracaoFinal = duracao
        try? FileManager.default.removeItem(at: url)
        arquivoURL = nil
        recorder = nil

        return (data, duracaoFinal)
    }

    func cancelar() {
        pollingTask?.cancel()
        pollingTask = nil
        recorder?.stop()
        gravando = false
        if let url = arquivoURL {
            try? FileManager.default.removeItem(at: url)
        }
        arquivoURL = nil
        recorder = nil
        duracao = 0
    }
}
