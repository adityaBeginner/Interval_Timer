import SwiftUI
import Combine

class KeyboardResponder: ObservableObject {
    @Published var keyboardHeight: CGFloat = 0.0
    private var cancellable: AnyCancellable?

    init() {
        // Subscribe to keyboard notifications
        cancellable = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .merge(with: NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification))
            .sink { [weak self] notification in
                self?.handleKeyboardNotification(notification)
            }
    }

    deinit {
        cancellable?.cancel()
    }

    private func handleKeyboardNotification(_ notification: Notification) {
        if notification.name == UIResponder.keyboardWillShowNotification {
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                // Update with animation on the main thread
                DispatchQueue.main.async {
                    withAnimation {
                        self.keyboardHeight = keyboardFrame.height
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                withAnimation {
                    self.keyboardHeight = 0
                }
            }
        }
    }
}
