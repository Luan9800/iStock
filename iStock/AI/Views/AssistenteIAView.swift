//
//  AssistenteIAView.swift
//  iStock
//

import SwiftUI

struct AssistenteIAView: View {
    @ObservedObject private var auth = AuthService.shared
    @ObservedObject private var criteriosStore = CriteriosAssistenteStore.shared

    private var ehCliente: Bool {
        auth.papelAtual == .cliente
    }

    private var modosVisiveis: [ModoAssistenteIA] {
        ModoAssistenteIA.modos(para: auth.papelAtual)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                cabecalho

                VStack(spacing: 12) {
                    ForEach(modosVisiveis) { modo in
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

                if !ehCliente {
                    NavigationLink {
                        CriteriosAssistenteView()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "slider.horizontal.3")
                                .font(.title3)
                                .foregroundStyle(AppTheme.azulClaro)
                                .frame(width: 28)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Critérios da loja")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                Text("Margens, descontos e tom usados pelo assistente")
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.55))
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)

                    CartaoVidroView {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Regras ativas agora")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                            Text(criteriosStore.criterios.resumo)
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.85))
                                .fixedSize(horizontal: false, vertical: true)

                            let notas = criteriosStore.criterios.notasPersonalizadas
                                .trimmingCharacters(in: .whitespacesAndNewlines)
                            if !notas.isEmpty {
                                Text("Notas: \(notas)")
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.55))
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .frame(maxWidth: 640)
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            FundoTecnologicoView()
        }
        .navigationTitle("Assistente de IA")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }

    private var cabecalho: some View {
        VStack(spacing: 12) {
            Image("AppLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 64, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .shadow(color: AppTheme.azulPrimario.opacity(0.45), radius: 12, y: 4)

            Text("iStock")
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)

            Text(
                ehCliente
                    ? "Tire dúvidas técnicas sobre produtos Apple"
                    : "Consultor Apple e negociação com critérios da sua loja"
            )
            .font(.subheadline)
            .foregroundStyle(.white.opacity(0.6))
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
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
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                cabecalhoMarca

                Text("O assistente usa estas regras em todas as conversas de negociação e consultoria.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.65))
                    .fixedSize(horizontal: false, vertical: true)

                CartaoVidroView {
                    VStack(alignment: .leading, spacing: 16) {
                        secaoTitulo("Margens e descontos", icone: "percent")

                        campoStepper(
                            titulo: "Margem mínima",
                            valor: "\(Int(rascunho.margemMinimaPercentual))%",
                            binding: $rascunho.margemMinimaPercentual,
                            faixa: 5...50
                        )

                        campoStepper(
                            titulo: "Desconto máximo",
                            valor: "\(Int(rascunho.descontoMaximoPercentual))%",
                            binding: $rascunho.descontoMaximoPercentual,
                            faixa: 0...25
                        )

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Margem mínima em R$")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.white.opacity(0.85))
                            TextField("150", value: $rascunho.valorMinimoMargem, format: .number)
                                .textFieldStyle(.plain)
                                .padding(12)
                                .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
                                .foregroundStyle(.white)
                                #if os(iOS)
                                .keyboardType(.decimalPad)
                                #endif
                        }

                        Text("Define o quanto a loja pode ceder sem comprometer o lucro.")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.45))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                CartaoVidroView {
                    VStack(alignment: .leading, spacing: 16) {
                        secaoTitulo("Atendimento", icone: "person.wave.2")

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tom de atendimento")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.white.opacity(0.85))
                            Picker("", selection: $rascunho.tomAtendimento) {
                                ForEach(TomAtendimento.allCases) { tom in
                                    Text(tom.rotulo).tag(tom)
                                }
                            }
                            .pickerStyle(.segmented)
                            .labelsHidden()
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Flexibilidade de preço")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.white.opacity(0.85))
                            Picker("", selection: $rascunho.flexibilidadePreco) {
                                ForEach(FlexibilidadePreco.allCases) { flex in
                                    Text(flex.rotulo).tag(flex)
                                }
                            }
                            .pickerStyle(.segmented)
                            .labelsHidden()
                        }

                        Toggle(isOn: $rascunho.aceitarTroca) {
                            Text("Aceitar troca / permuta")
                                .foregroundStyle(.white.opacity(0.9))
                        }
                        .tint(AppTheme.azulClaro)

                        Toggle(isOn: $rascunho.priorizarLacrado) {
                            Text("Priorizar produtos lacrados nas sugestões")
                                .foregroundStyle(.white.opacity(0.9))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .tint(AppTheme.azulClaro)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                CartaoVidroView {
                    VStack(alignment: .leading, spacing: 12) {
                        secaoTitulo("Notas da loja", icone: "note.text")

                        TextField(
                            "Ex.: Garantia de 90 dias, PIX com 3% de desconto…",
                            text: $rascunho.notasPersonalizadas,
                            axis: .vertical
                        )
                        .lineLimit(3...6)
                        .textFieldStyle(.plain)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
                        .foregroundStyle(.white)

                        Text("Políticas, garantia, diferenciais e outras orientações para o assistente.")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.45))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

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
                                .tint(.white)
                        } else {
                            Text("Salvar critérios")
                                .font(.headline)
                        }
                        Spacer()
                    }
                    .foregroundStyle(.white)
                    .padding(.vertical, 14)
                    .background(AppTheme.azulPrimario, in: RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(.plain)
                .disabled(salvando)
            }
            .padding(24)
            .frame(maxWidth: 560)
            .frame(maxWidth: .infinity)
        }
        .background {
            FundoTecnologicoView()
        }
        .navigationTitle("Critérios da loja")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .onAppear { rascunho = store.criterios }
    }

    private var cabecalhoMarca: some View {
        HStack(spacing: 14) {
            Image("AppLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 44, height: 44)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text("iStock")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)
                Text("Critérios personalizados da loja")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.55))
            }

            Spacer(minLength: 0)
        }
    }

    private func secaoTitulo(_ titulo: String, icone: String) -> some View {
        Label(titulo, systemImage: icone)
            .font(.headline)
            .foregroundStyle(AppTheme.azulClaro)
    }

    private func campoStepper(
        titulo: String,
        valor: String,
        binding: Binding<Double>,
        faixa: ClosedRange<Double>
    ) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(titulo)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.85))
                Text(valor)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white)
            }
            Spacer()
            Stepper("", value: binding, in: faixa, step: 1)
                .labelsHidden()
                .fixedSize()
        }
    }
}
