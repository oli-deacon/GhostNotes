import SwiftUI

struct NotesView: View {
    @ObservedObject var viewModel: NotesViewModel
    @FocusState private var isEditorFocused: Bool

    private let panelCornerRadius: CGFloat = 28
    private let cardCornerRadius: CGFloat = 22
    private let sageHighlight = Color(red: 0.78, green: 0.88, blue: 0.80)
    private let sageTint = Color(red: 0.38, green: 0.56, blue: 0.45)
    private let sageShadow = Color(red: 0.18, green: 0.28, blue: 0.22)

    private var clickThroughHelpText: String {
        let shortcut = HotkeyManager.description(for: .toggleClickThrough)

        if viewModel.isClickThroughEnabled {
            return "Disable click-through (\(shortcut))"
        }

        return "Enable click-through (\(shortcut))"
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: panelCornerRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            sageHighlight.opacity(0.30),
                            Color(red: 0.88, green: 0.95, blue: 0.89).opacity(0.14)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .background(
                    RoundedRectangle(cornerRadius: panelCornerRadius, style: .continuous)
                        .fill(.ultraThinMaterial)
                )
                .overlay(alignment: .top) {
                    RoundedRectangle(cornerRadius: panelCornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    sageHighlight.opacity(0.28),
                                    Color(red: 0.93, green: 0.97, blue: 0.93).opacity(0.03)
                                ],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                        .padding(1)
                        .mask(
                            RoundedRectangle(cornerRadius: panelCornerRadius, style: .continuous)
                        )
                }
                .overlay(
                    RoundedRectangle(cornerRadius: panelCornerRadius, style: .continuous)
                        .strokeBorder(sageHighlight.opacity(0.24), lineWidth: 1)
                )
                .shadow(color: sageShadow.opacity(0.18), radius: 26, x: 0, y: 18)
                .shadow(color: sageHighlight.opacity(0.08), radius: 12, x: 0, y: 1)

            VStack(spacing: 14) {
                header

                if viewModel.isClickThroughEnabled {
                    clickThroughBanner
                }

                editorCard
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 14)
            .padding(.top, 34)
        }
        .frame(minWidth: 420, minHeight: 220)
        .padding(10)
        .background(Color.clear)
        .onAppear {
            DispatchQueue.main.async {
                if !viewModel.isClickThroughEnabled {
                    isEditorFocused = true
                }
            }
        }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Ghost Notes")
                    .font(.system(.title3, design: .rounded, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text("Floating presenter overlay")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 12)

            HStack(spacing: 10) {
                fontSizeControl
                opacityControl
                clickThroughControl
            }
        }
        .padding(14)
        .background(glassCardBackground)
        .overlay(glassCardStroke)
    }

    private var fontSizeControl: some View {
        HStack(spacing: 8) {
            Text("Text")
                .font(.system(.caption, design: .rounded, weight: .medium))
                .foregroundStyle(.secondary)

            Button(action: viewModel.decreaseFontSize) {
                Image(systemName: "textformat.size.smaller")
            }
            .help("Smaller text (\(HotkeyManager.description(for: .decreaseFontSize)))")
            .buttonStyle(GlassIconButtonStyle())

            Text("\(Int(viewModel.fontSize)) pt")
                .font(.system(.caption, design: .rounded).monospacedDigit())
                .foregroundStyle(.primary)
                .frame(minWidth: 42, alignment: .center)

            Button(action: viewModel.increaseFontSize) {
                Image(systemName: "textformat.size.larger")
            }
            .help("Larger text (\(HotkeyManager.description(for: .increaseFontSize)))")
            .buttonStyle(GlassIconButtonStyle())
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(controlChipBackground)
    }

    private var opacityControl: some View {
        HStack(spacing: 8) {
            Text("Opacity")
                .font(.system(.caption, design: .rounded, weight: .medium))
                .foregroundStyle(.secondary)

            Slider(value: $viewModel.windowOpacity, in: 0.2 ... 1.0)
                .frame(width: 92)
                .help("Adjust opacity (\(HotkeyManager.description(for: .decreaseOpacity)) / \(HotkeyManager.description(for: .increaseOpacity)))")

            Text("\(Int(viewModel.windowOpacity * 100))%")
                .font(.system(.caption, design: .rounded).monospacedDigit())
                .foregroundStyle(.primary)
                .frame(width: 38, alignment: .trailing)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(controlChipBackground)
    }

    private var clickThroughControl: some View {
        Button {
            viewModel.toggleClickThrough()
        } label: {
            HStack(spacing: 7) {
                Image(systemName: viewModel.isClickThroughEnabled ? "hand.tap.fill" : "hand.tap")
                    .imageScale(.small)

                Text("Pass-through")
                    .font(.caption.weight(.medium))
            }
            .foregroundStyle(viewModel.isClickThroughEnabled ? sageTint : .primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule(style: .continuous)
                    .fill(viewModel.isClickThroughEnabled ? sageHighlight.opacity(0.18) : sageHighlight.opacity(0.08))
            )
            .overlay(
                Capsule(style: .continuous)
                    .strokeBorder(viewModel.isClickThroughEnabled ? sageTint.opacity(0.30) : sageHighlight.opacity(0.16), lineWidth: 1)
            )
        }
        .help(clickThroughHelpText)
        .buttonStyle(.plain)
    }

    private var clickThroughBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "hand.tap.fill")
                .foregroundStyle(sageTint)
                .imageScale(.medium)

            Text("Pass-through is on. Use \(HotkeyManager.description(for: .toggleClickThrough)) to interact again.")
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(.primary.opacity(0.85))

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(sageHighlight.opacity(0.14))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(sageTint.opacity(0.22), lineWidth: 1)
        )
    }

    private var editorCard: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            sageHighlight.opacity(0.16),
                            Color(red: 0.88, green: 0.94, blue: 0.89).opacity(0.07)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .background(
                    RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous)
                        .fill(.thinMaterial)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous)
                        .strokeBorder(sageHighlight.opacity(0.18), lineWidth: 1)
                )

            if viewModel.notesText.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Paste your presenter notes here.")
                        .font(.system(size: viewModel.fontSize, weight: .medium, design: .rounded))
                        .foregroundStyle(.primary.opacity(0.72))

                    Text("They stay local on this Mac and reopen the next time you launch the app.")
                        .font(.system(size: max(viewModel.fontSize - 2, 12), weight: .regular, design: .rounded))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 22)
                .padding(.vertical, 24)
                .allowsHitTesting(false)
            }

            TextEditor(text: $viewModel.notesText)
                .font(.system(size: viewModel.fontSize, weight: .regular, design: .rounded))
                .foregroundStyle(.primary)
                .scrollContentBackground(.hidden)
                .padding(.horizontal, 16)
                .padding(.vertical, 18)
                .focused($isEditorFocused)
                .background(Color.clear)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var glassCardBackground: some View {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        sageHighlight.opacity(0.18),
                        Color(red: 0.88, green: 0.94, blue: 0.89).opacity(0.10)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(.thinMaterial)
            )
    }

    private var glassCardStroke: some View {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
            .strokeBorder(sageHighlight.opacity(0.18), lineWidth: 1)
    }

    private var controlChipBackground: some View {
        Capsule(style: .continuous)
            .fill(sageHighlight.opacity(0.08))
            .overlay(
                Capsule(style: .continuous)
                    .strokeBorder(sageHighlight.opacity(0.14), lineWidth: 1)
            )
    }
}

private struct GlassIconButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.caption, design: .rounded, weight: .semibold))
            .foregroundStyle(.primary)
            .padding(6)
            .background(
                Circle()
                    .fill(Color(red: 0.84, green: 0.92, blue: 0.85).opacity(configuration.isPressed ? 0.20 : 0.11))
            )
            .overlay(
                Circle()
                    .strokeBorder(Color(red: 0.74, green: 0.87, blue: 0.77).opacity(0.16), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.22, dampingFraction: 0.82), value: configuration.isPressed)
    }
}
