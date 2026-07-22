//
//  AppTheme.swift
//  iStock
//
//  Created by Berg Limma on 07/07/26.
//

import SwiftUI

enum AppTheme {
    #if os(macOS)
    // Tokens alinhados ao iStock WEB (global.css)
    static let azulPrimario = Color(red: 0.0, green: 0.478, blue: 1.0)       // #007AFF
    static let azulEscuro = Color(red: 0.0, green: 0.318, blue: 0.835)        // #0051D5
    static let azulClaro = Color(red: 0.451, green: 0.722, blue: 1.0)         // #73B8FF
    static let azulProfundo = Color(red: 0.059, green: 0.078, blue: 0.118)    // #0F141E
    static let azulNoite = Color(red: 0.039, green: 0.051, blue: 0.078)       // #0A0D14
    static let fundoExtra = Color(red: 0.078, green: 0.102, blue: 0.141)      // #141A24
    static let verde = Color(red: 0.204, green: 0.780, blue: 0.349)           // #34C759
    static let laranja = Color(red: 1.0, green: 0.584, blue: 0.0)             // #FF9500
    static let vermelho = Color(red: 1.0, green: 0.231, blue: 0.188)          // #FF3B30
    static let mint = Color(red: 0.388, green: 0.902, blue: 0.745)            // #63E6BE
    static let ciano = Color(red: 0.196, green: 0.824, blue: 0.902)           // #32D2E6
    static let amarelo = Color(red: 1.0, green: 0.839, blue: 0.039)           // #FFD60A
    static let vidro = Color.white.opacity(0.06)
    static let vidroBorda = Color.white.opacity(0.12)
    static let sidebar = Color.white.opacity(0.04)
    static let radius: CGFloat = 14
    static let radiusCard: CGFloat = 18
    static let radiusLG: CGFloat = 24
    static let sidebarWidth: CGFloat = 240
    #else
    static let azulPrimario = Color(red: 0.0, green: 0.478, blue: 1.0)       // #007AFF
    static let azulEscuro = Color(red: 0.0, green: 0.318, blue: 0.835)        // #0051D5
    static let azulClaro = Color(red: 0.45, green: 0.72, blue: 1.0)
    static let azulProfundo = Color(red: 0.06, green: 0.08, blue: 0.12)
    static let azulNoite = Color(red: 0.04, green: 0.05, blue: 0.08)
    static let fundoExtra = Color(red: 0.08, green: 0.10, blue: 0.14)
    static let verde = Color.green
    static let laranja = Color.orange
    static let vermelho = Color.red
    static let mint = Color.mint
    static let ciano = Color.cyan
    static let amarelo = Color.yellow
    static let vidro = Color.white.opacity(0.06)
    static let vidroBorda = Color.white.opacity(0.12)
    static let sidebar = Color.white.opacity(0.04)
    static let radius: CGFloat = 14
    static let radiusCard: CGFloat = 18
    static let radiusLG: CGFloat = 24
    static let sidebarWidth: CGFloat = 220
    #endif

    static let gradienteFundo = LinearGradient(
        colors: [azulNoite, azulProfundo, fundoExtra],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let gradienteBotao = LinearGradient(
        colors: [azulClaro, azulPrimario, azulEscuro],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let gradienteBrilho = RadialGradient(
        colors: [azulClaro.opacity(0.12), .clear],
        center: .center,
        startRadius: 20,
        endRadius: 220
    )

    /// Wash 165° estilo `.painel-secao--*` da WEB.
    static func gradienteSecao(_ accent: Color) -> LinearGradient {
        LinearGradient(
            colors: [
                accent.opacity(0.2),
                Color(red: 0.04, green: 0.06, blue: 0.09).opacity(0.72),
                Color(red: 0.03, green: 0.05, blue: 0.07).opacity(0.88)
            ],
            startPoint: UnitPoint(x: 0.15, y: 0),
            endPoint: UnitPoint(x: 0.85, y: 1)
        )
    }
}

struct FundoTecnologicoView: View {
    var body: some View {
        ZStack {
            AppTheme.gradienteFundo
            
            GeometryReader { geo in
                Circle()
                    .fill(AppTheme.gradienteBrilho)
                    .frame(width: 420, height: 420)
                    .offset(x: geo.size.width * 0.55, y: -80)
                
                Circle()
                    .fill(AppTheme.azulPrimario.opacity(0.03))
                    .frame(width: 300, height: 300)
                    .offset(x: -geo.size.width * 0.3, y: geo.size.height * 0.65)
                
                GridTecnologicoView()
                    .opacity(0.04)
                
                MarcaDaguaInferiorView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    .padding(.trailing, 24)
                    .padding(.bottom, 20)
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

private struct MarcaDaguaInferiorView: View {
    var body: some View {
        VStack(alignment: .center, spacing: marcaEspacamento) {
            Image(systemName: "apple.logo")
                .font(.system(size: marcaAppleSize, weight: .thin))
                .foregroundStyle(.white.opacity(marcaAppleOpacity))

            Text("iStock")
                .font(.system(size: marcaNomeSize, weight: .semibold, design: .rounded))
                .tracking(0.6)
                .foregroundStyle(.white.opacity(marcaNomeOpacity))
        }
        .allowsHitTesting(false)
    }

    #if os(macOS)
    private var marcaAppleSize: CGFloat { 28 }
    private var marcaNomeSize: CGFloat { 15 }
    private var marcaEspacamento: CGFloat { 6 }
    private var marcaAppleOpacity: Double { 0.28 }
    private var marcaNomeOpacity: Double { 0.42 }
    #else
    private var marcaAppleSize: CGFloat { 68 }
    private var marcaNomeSize: CGFloat { 28 }
    private var marcaEspacamento: CGFloat { 6 }
    private var marcaAppleOpacity: Double { 0.08 }
    private var marcaNomeOpacity: Double { 0.08 }
    #endif
}

private struct GridTecnologicoView: View {
    var body: some View {
        Canvas { context, size in
            let espacamento: CGFloat = 32
            var path = Path()
            
            stride(from: 0, through: size.width, by: espacamento).forEach { x in
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
            }
            stride(from: 0, through: size.height, by: espacamento).forEach { y in
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
            }
            
            context.stroke(path, with: .color(.white), lineWidth: 0.5)
        }
    }
}

enum CartaoEstilo {
    case padrao
    case relatorio
}

struct CartaoVidroView<Content: View>: View {
    var estilo: CartaoEstilo = .padrao
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(24)
            .background {
                RoundedRectangle(cornerRadius: AppTheme.radiusLG, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.radiusLG, style: .continuous)
                            .fill(AppTheme.vidro)
                    )
            }
            .overlay {
                RoundedRectangle(cornerRadius: AppTheme.radiusLG, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [.white.opacity(0.22), AppTheme.vidroBorda.opacity(0.5), .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
            #if os(macOS)
            .modifier(SombraCartaoMacModifier(estilo: estilo))
            #else
            .shadow(color: .black.opacity(0.22), radius: 20, y: 10)
            #endif
    }
}

#if os(macOS)
private struct SombraCartaoMacModifier: ViewModifier {
    let estilo: CartaoEstilo

    func body(content: Content) -> some View {
        switch estilo {
        case .relatorio:
            content
                .shadow(color: .black.opacity(0.22), radius: 12, x: 0, y: 10)
                .shadow(color: Color(red: 1.0, green: 0.388, blue: 0.388).opacity(0.2), radius: 10, x: 0, y: 8)
        case .padrao:
            content
                .shadow(color: .black.opacity(0.22), radius: 10, x: 0, y: 10)
        }
    }
}
#endif

struct CampoLoginView: View {
    let icone: String
    let placeholder: String
    @Binding var texto: String
    var ehSenha = false
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icone)
                .font(.body.weight(.semibold))
                .foregroundStyle(AppTheme.azulClaro)
                .frame(width: 22)
            
            Group {
                if ehSenha {
                    SecureField(placeholder, text: $texto)
                } else {
                    TextField(placeholder, text: $texto)
                }
            }
            .textFieldStyle(.plain)
#if os(iOS)
            .textInputAutocapitalization(ehSenha ? .never : placeholder.contains("mail") ? .never : .words)
            .keyboardType(placeholder.contains("mail") ? .emailAddress : placeholder.contains("one") ? .phonePad : .default)
#endif
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        }
        .foregroundStyle(.white)
    }
}

struct BotaoPrimarioView: View {
    let titulo: String
    var desabilitado = false
    let acao: () -> Void
    
    var body: some View {
        Button(action: acao) {
            Text(titulo)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background {
                    if desabilitado {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.white.opacity(0.15))
                    } else {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(AppTheme.gradienteBotao)
                    }
                }
                .foregroundStyle(.white)
                .shadow(color: desabilitado ? .clear : .black.opacity(0.25), radius: 8, y: 4)
        }
        .buttonStyle(.plain)
        .disabled(desabilitado)
    }
}

struct SeletorModoAuthView: View {
    @Binding var selecao: ModoAutenticacao
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(ModoAutenticacao.allCases) { modo in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { selecao = modo }
                } label: {
                    Text(modo.rawValue)
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background {
                            if selecao == modo {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(AppTheme.gradienteBotao)
                            }
                        }
                        .foregroundStyle(selecao == modo ? .white : .white.opacity(0.55))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

// MARK: - Shell e componentes do app

struct LayoutTelaView<Content: View, Trailing: View>: View {
    let titulo: String
    var subtitulo: String? = nil
    var usaCartao = false
    var rolar = true
    @ViewBuilder var trailing: () -> Trailing
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        Group {
            if rolar {
                ScrollView(showsIndicators: false) {
                    conteudoPrincipal
                }
            } else {
                conteudoPrincipal
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        #if os(iOS)
        .background {
            FundoTecnologicoView()
        }
        #endif
        .preferredColorScheme(.dark)
    }
    
    private var conteudoPrincipal: some View {
        VStack(alignment: .leading, spacing: 20) {
            #if os(iOS)
            BarraPerfilSuperiorView()
            #endif

            HStack(alignment: .top, spacing: 12) {
                TituloTelaView(titulo: titulo, subtitulo: subtitulo)
                Spacer(minLength: 8)
                trailing()
            }

            if usaCartao {
                CartaoVidroView {
                    content()
                }
            } else {
                content()
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

extension LayoutTelaView where Trailing == EmptyView {
    init(
        titulo: String,
        subtitulo: String? = nil,
        usaCartao: Bool = false,
        rolar: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.titulo = titulo
        self.subtitulo = subtitulo
        self.usaCartao = usaCartao
        self.rolar = rolar
        self.trailing = { EmptyView() }
        self.content = content
    }
}

struct AppShellView<Content: View>: View {
    let titulo: String
    var subtitulo: String? = nil
    @ViewBuilder let content: Content
    
    var body: some View {
        LayoutTelaView(titulo: titulo, subtitulo: subtitulo, usaCartao: true) {
            content
        }
    }
}

struct TituloTelaView: View {
    let titulo: String
    var subtitulo: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(titulo)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            if let subtitulo {
                Text(subtitulo)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.55))
            }
        }
    }
}

typealias CampoAppView = CampoLoginView

struct BotaoSecundarioView: View {
    let titulo: String
    let acao: () -> Void
    
    var body: some View {
        Button(action: acao) {
            Text(titulo)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(AppTheme.azulClaro)
        }
        .buttonStyle(.plain)
    }
}

struct ItemVidroView<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(14)
            #if os(macOS)
            .background {
                RoundedRectangle(cornerRadius: AppTheme.radiusCard, style: .continuous)
                    .fill(AppTheme.gradienteSecao(AppTheme.verde))
            }
            .overlay {
                RoundedRectangle(cornerRadius: AppTheme.radiusCard, style: .continuous)
                    .stroke(AppTheme.verde.opacity(0.35), lineWidth: 1)
            }
            .sombraCardWEB(accent: AppTheme.verde, glow: 0.22)
            #else
            .background(Color.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            }
            #endif
    }
}

struct EstadoVazioView: View {
    let icone: String
    let titulo: String
    let mensagem: String
    
    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: icone)
                .font(.system(size: 44))
                .foregroundStyle(AppTheme.azulClaro.opacity(0.7))
            Text(titulo)
                .font(.headline)
                .foregroundStyle(.white)
            Text(mensagem)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.5))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
    }
}

extension ToolbarContent {
    @ToolbarContentBuilder
    func semFundoAutomatico() -> some ToolbarContent {
        if #available(macOS 26.0, iOS 18.0, *) {
            self.sharedBackgroundVisibility(.hidden)
        } else {
            self
        }
    }
}

struct BadgeAppView: View {
    let texto: String
    var cor: Color = AppTheme.azulClaro
    var amplo: Bool = false
    
    private var raio: CGFloat { amplo ? 10 : 6 }
    
    var body: some View {
        Text(texto)
            .font(amplo ? .caption.weight(.semibold) : .caption2.weight(.semibold))
            .lineLimit(1)
            .padding(.horizontal, amplo ? 14 : 7)
            .padding(.vertical, amplo ? 7 : 4)
            .background(
                RoundedRectangle(cornerRadius: raio, style: .continuous)
                    .fill(cor.opacity(0.18))
            )
            .overlay(
                RoundedRectangle(cornerRadius: raio, style: .continuous)
                    .strokeBorder(cor.opacity(0.45), lineWidth: 1)
            )
            .foregroundStyle(cor)
    }
}

struct PainelSidebarView: View {
    var body: some View {
        AppTheme.sidebar
            .background(.ultraThinMaterial)
    }
}

/// Card com wash colorido no estilo das seções do Painel WEB.
struct CartaoTintadoView<Content: View>: View {
    let accent: Color
    var cornerRadius: CGFloat = 16
    var glow: Double = 0.22
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(16)
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(AppTheme.gradienteSecao(accent))
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(accent.opacity(0.35), lineWidth: 1)
            }
            #if os(macOS)
            .sombraCardWEB(accent: accent, glow: glow)
            #else
            .shadow(color: .black.opacity(0.3), radius: 12, y: 8)
            .shadow(color: accent.opacity(0.22), radius: 14, y: 10)
            #endif
    }
}

#if os(macOS)
extension View {
    /// Sombra dupla igual ao WEB: `0 10px 24px black@0.3` + `0 12px 28px accent@glow`.
    func sombraCardWEB(accent: Color, glow: Double = 0.22) -> some View {
        self
            .shadow(color: .black.opacity(0.3), radius: 12, x: 0, y: 10)
            .shadow(color: accent.opacity(glow), radius: 14, x: 0, y: 12)
    }

    func sombraProdutoCardWEB() -> some View {
        self
            .shadow(color: .black.opacity(0.35), radius: 12, x: 0, y: 10)
            .shadow(color: AppTheme.azulClaro.opacity(0.08), radius: 0.5, x: 0, y: 0)
            .shadow(color: AppTheme.azulPrimario.opacity(0.28), radius: 14, x: 0, y: 12)
    }
}
#endif
