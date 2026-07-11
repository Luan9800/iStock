//
//  AssistenteIAView.swift
//  iStock
//

import SwiftUI

struct AssistenteIAView: View {
    @ObservedObject private var criteriosStore = CriteriosAssistenteStore.shared

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                cabecalho

                VStack(spacing: 12) {
                    ForEach(ModoAssistenteIA.allCases) { modo in
                        NavigationLink {
                            destino(para: modo)
                        } label: {
                            AIOptionCard(
                                icon: modo.icone,
                                title: modo.titulo,
                                subtitle: modo.descricao,
                                color: modo.cor
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }

                NavigationLink {
                    CriteriosAssistenteView()
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "slider.horizontal.3")
                        Text("Critérios da loja")
                            .fontWeight(.semibold)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                    .foregroundStyle(.white)
                    .padding()
                    .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(.plain)

                CartaoVidroView {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Critérios ativos")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                        Text(criteriosStore.criterios.resumo)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.85))
                            .fixedSize(horizontal: false, vertical: true)

                        let notas = criteriosStore.criterios.notasPersonalizadas
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                        if !notas.isEmpty {
                            Text(notas)
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.55))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(20)
            .frame(maxWidth: 640)
            .frame(maxWidth: .infinity)
        }
        .background {
            FundoTecnologicoView()
                .ignoresSafeArea()
        }
        .navigationTitle("Assistente de IA")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
    }

    private var cabecalho: some View {
        VStack(spacing: 10) {
            Image(systemName: "sparkles")
                .font(.system(size: 40, weight: .light))
                .foregroundStyle(AppTheme.azulClaro)

            Text("Consultor Apple e negociação com critérios da sua loja")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .padding(.top, 8)
        .padding(.bottom, 4)
    }

    @ViewBuilder
    private func destino(para modo: ModoAssistenteIA) -> some View {
        switch modo {
        case .negociacao:
            NegotiationChatView()
        case .consultorVendas:
            AppleConsultantView(modo: .cliente)
        case .consultorTecnico:
            AppleConsultantView(modo: .pessoal)
        }
    }
}

#Preview {
    NavigationStack {
        AssistenteIAView()
    }
}

struct CriteriosAssistenteView: View {
    @ObservedObject private var store = CriteriosAssistenteStore.shared
    @Environment(\.dismiss) private var dismiss

    @State private var rascunho = CriteriosAssistente.padrao
    @State private var salvando = false

    var body: some View {
        Form {
            Section("Margens e descontos") {
                Stepper(
                    "Margem mínima: \(Int(rascunho.margemMinimaPercentual))%",
                    value: $rascunho.margemMinimaPercentual,
                    in: 5...50,
                    step: 1
                )
                Stepper(
                    "Desconto máximo: \(Int(rascunho.descontoMaximoPercentual))%",
                    value: $rascunho.descontoMaximoPercentual,
                    in: 0...25,
                    step: 1
                )
                HStack {
                    Text("Margem mínima em R$")
                    Spacer()
                    TextField("150", value: $rascunho.valorMinimoMargem, format: .number)
                        .multilineTextAlignment(.trailing)
                        #if os(iOS)
                        .keyboardType(.decimalPad)
                        #endif
                        .frame(width: 100)
                }
            }

            Section("Atendimento") {
                Picker("Tom", selection: $rascunho.tomAtendimento) {
                    ForEach(TomAtendimento.allCases) { tom in
                        Text(tom.rotulo).tag(tom)
                    }
                }
                Picker("Flexibilidade de preço", selection: $rascunho.flexibilidadePreco) {
                    ForEach(FlexibilidadePreco.allCases) { flex in
                        Text(flex.rotulo).tag(flex)
                    }
                }
                Toggle("Aceitar troca / permuta", isOn: $rascunho.aceitarTroca)
                Toggle("Priorizar produtos lacrados", isOn: $rascunho.priorizarLacrado)
            }

            Section("Notas da loja") {
                TextField(
                    "Ex.: Garantia de 90 dias, PIX com 3% de desconto…",
                    text: $rascunho.notasPersonalizadas,
                    axis: .vertical
                )
                .lineLimit(3...6)
            }

            Section {
                Button {
                    salvando = true
                    store.salvar(rascunho)
                    salvando = false
                    dismiss()
                } label: {
                    HStack {
                        Spacer()
                        if salvando {
                            ProgressView()
                        } else {
                            Text("Salvar critérios")
                                .fontWeight(.semibold)
                        }
                        Spacer()
                    }
                }
                .disabled(salvando)
            }
        }
        .navigationTitle("Critérios")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .onAppear { rascunho = store.criterios }
    }
}
