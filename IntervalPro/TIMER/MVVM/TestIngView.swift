import SwiftUI
struct TimeInputWithMilliseconds: View {
    @State private var rawInput: String = ""
    @FocusState private var isFocused: Bool
    @State private var showCursor: Bool = true

    var body: some View {
        VStack {
            ZStack {
                HStack(spacing: 0) {
                    Text(formattedMinutes)
                        .font(.system(size: 24, weight: .medium, design: .monospaced))
                    Text(":")
                        .font(.system(size: 24))
                    Text(formattedSeconds)
                        .font(.system(size: 24, weight: .medium, design: .monospaced))
                    Text(":")
                        .font(.system(size: 20))

                    HStack(spacing: 2) {
                        Text(formattedMilliseconds)
                            .font(.system(size: 20, weight: .regular, design: .monospaced))
                        if isFocused && showCursor {
                            Rectangle()
                                .fill(Color.primary)
                                .frame(width: 1, height: 20)
                                .transition(.opacity)
                        }
                    }
                }
                .padding()
                .contentShape(Rectangle())
                .onTapGesture {
                    isFocused = true
                }

                TextField("", text: $rawInput)
                    .keyboardType(.numberPad)
                    .focused($isFocused)
                    .onChange(of: rawInput) { newValue in
                        let filtered = newValue.filter { $0.isNumber }
                        rawInput = String(filtered.prefix(6)) // Max 6 digits
                    }
                    .opacity(0.01) // Hidden input
            }
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)

            Button("Reset") {
                rawInput = ""
            }
        }
        .padding()
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                if isFocused {
                    showCursor.toggle()
                } else {
                    showCursor = false
                }
            }
        }
    }

    // MARK: - Time Formatting

    private var milliseconds: Int {
        Int(rawInput.suffix(2)) ?? 0
    }

    private var secondsRaw: Int {
        if rawInput.count > 2 {
            return Int(rawInput.dropLast(2).suffix(2)) ?? 0
        }
        return 0
    }

    private var minutesRaw: Int {
        if rawInput.count > 4 {
            return Int(rawInput.dropLast(4)) ?? 0
        }
        return 0
    }

    private var totalSeconds: Int {
        var sec = secondsRaw
        var min = minutesRaw

        min += sec / 60
        sec = sec % 60

        if min > 59 { min = 59 }

        return min * 60 + sec
    }

    private var formattedMinutes: String {
        let min = totalSeconds / 60
        return String(format: "%02d", min)
    }

    private var formattedSeconds: String {
        let sec = totalSeconds % 60
        return String(format: "%02d", sec)
    }

    private var formattedMilliseconds: String {
        return String(format: "%02d", milliseconds)
    }
}

#Preview{
    TimeInputWithMilliseconds()
}
