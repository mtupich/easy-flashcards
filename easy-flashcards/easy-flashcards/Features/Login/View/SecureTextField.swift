import SwiftUI
import UIKit

struct SecureTextField: UIViewRepresentable {

    let placeholder: String
    @Binding var text: String
    /// Quando verdadeiro, o sistema pode oferecer senha forte do iCloud (como em `textContentType(.newPassword)`).
    /// O campo de confirmação deve permanecer sem isso; a cópia para ele é feita só em inserções grandes (ver `LoginViewModel`).
    var allowsNewPasswordContentType: Bool = false

    func makeUIView(context: Context) -> UITextField {
        let field = UITextField()
        field.isSecureTextEntry = true
        if allowsNewPasswordContentType {
            field.textContentType = .newPassword
            field.passwordRules = nil
        } else {
            field.textContentType = .none
            field.passwordRules = nil
        }
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.spellCheckingType = .no
        field.textColor = .white
        field.font = .systemFont(ofSize: 17)
        field.delegate = context.coordinator
        field.setContentHuggingPriority(.defaultHigh, for: .vertical)

        field.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: UIColor.placeholderText]
        )

        return field
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }

    final class Coordinator: NSObject, UITextFieldDelegate {
        var text: Binding<String>

        init(text: Binding<String>) {
            self.text = text
        }

        func textField(
            _ textField: UITextField,
            shouldChangeCharactersIn range: NSRange,
            replacementString string: String
        ) -> Bool {
            if let current = textField.text,
               let range = Range(range, in: current) {
                text.wrappedValue = current.replacingCharacters(in: range, with: string)
            }
            return false
        }

        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
    }
}
