//
//  RelatorioMensalService.swift
//  iStock
//
//  Created by Berg Limma on 07/07/26.
//

import Combine
import Foundation

@MainActor
final class RelatorioMensalService: ObservableObject {
    static let shared = RelatorioMensalService()

    @Published private(set) var arquivos: [RelatorioArquivo] = []
    @Published private(set) var relatorioAtual: RelatorioFinanceiro?
    @Published var erro: String?

    private let ultimaGeracaoKey = "istock.relatorio.ultima.geracao"

    private init() {
        relatorioAtual = RelatorioAnaliseService.gerar()
        carregarArquivos()
    }

    var diasAteProximoRelatorio: Int {
        let ultima = UserDefaults.standard.object(forKey: ultimaGeracaoKey) as? Date ?? .distantPast
        let calendario = Calendar.current
        let proxima = calendario.date(byAdding: .day, value: RelatorioAnaliseService.diasPeriodoRelatorio, to: ultima) ?? .now
        return max(0, calendario.dateComponents([.day], from: .now, to: proxima).day ?? 0)
    }

    func atualizarRelatorioAtual() {
        relatorioAtual = RelatorioAnaliseService.gerar()
        PainelNotificacaoService.shared.atualizarSugestoes()
    }

    func verificarGeracaoAutomatica() {
        atualizarRelatorioAtual()
        let ultima = UserDefaults.standard.object(forKey: ultimaGeracaoKey) as? Date
        let calendario = Calendar.current

        if let ultima,
           let dias = calendario.dateComponents([.day], from: ultima, to: .now).day,
           dias < RelatorioAnaliseService.diasPeriodoRelatorio {
            return
        }

        _ = gerarPDFAutomatico()
    }

    @discardableResult
    func gerarPDFManual() -> URL? {
        atualizarRelatorioAtual()
        guard let relatorio = relatorioAtual,
              let data = RelatorioPDFGerador.gerar(relatorio) else {
            erro = "Não foi possível gerar o PDF."
            return nil
        }
        return salvarPDF(data, relatorio: relatorio, automatico: false)
    }

    @discardableResult
    private func gerarPDFAutomatico() -> URL? {
        guard let relatorio = relatorioAtual,
              let data = RelatorioPDFGerador.gerar(relatorio) else { return nil }
        return salvarPDF(data, relatorio: relatorio, automatico: true)
    }

    private func salvarPDF(_ data: Data, relatorio: RelatorioFinanceiro, automatico: Bool) -> URL? {
        let diretorio = diretorioRelatorios()
        do {
            try FileManager.default.createDirectory(at: diretorio, withIntermediateDirectories: true)
            let nome = "relatorio-\(Formatters.arquivoData.string(from: .now)).pdf"
            let url = diretorio.appendingPathComponent(nome)
            try data.write(to: url)

            UserDefaults.standard.set(Date(), forKey: ultimaGeracaoKey)
            carregarArquivos()

            let arquivo = RelatorioArquivo(
                id: nome,
                url: url,
                dataGeracao: .now,
                periodoFim: relatorio.periodoFim
            )
            if automatico {
                PainelNotificacaoService.shared.adicionarRelatorio(arquivo)
            }

            erro = nil
            return url
        } catch {
            self.erro = error.localizedDescription
            return nil
        }
    }

    func carregarArquivos() {
        let diretorio = diretorioRelatorios()
        guard let urls = try? FileManager.default.contentsOfDirectory(
            at: diretorio,
            includingPropertiesForKeys: [.creationDateKey],
            options: [.skipsHiddenFiles]
        ) else {
            arquivos = []
            return
        }

        arquivos = urls
            .filter { $0.pathExtension.lowercased() == "pdf" }
            .compactMap { url -> RelatorioArquivo? in
                let attrs = try? url.resourceValues(forKeys: [.creationDateKey])
                return RelatorioArquivo(
                    id: url.lastPathComponent,
                    url: url,
                    dataGeracao: attrs?.creationDate ?? .now,
                    periodoFim: attrs?.creationDate ?? .now
                )
            }
            .sorted { $0.dataGeracao > $1.dataGeracao }
    }

    @discardableResult
    func excluirRelatorio(_ arquivo: RelatorioArquivo) -> Bool {
        do {
            try FileManager.default.removeItem(at: arquivo.url)
            arquivos.removeAll { $0.id == arquivo.id }
            erro = nil
            return true
        } catch {
            self.erro = "Não foi possível excluir o relatório: \(error.localizedDescription)"
            return false
        }
    }

    private func diretorioRelatorios() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("relatorios", isDirectory: true)
    }
}
