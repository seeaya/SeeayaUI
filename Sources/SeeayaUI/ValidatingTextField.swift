//
//  ValidatingTextField.swift
//  
//
//  Created by Connor Barnes on 7/12/21.
//

import SwiftUI

@available(macOS 11.0, *)
public struct ValidatingTextField<Value: Equatable>: View {
  @Binding var value: Value
  @State private var textValue: String
  
  var title: String
  var showError: Bool
  var stringValue: (Value) -> String
  var validate: (String) -> Value?
  var errorMessage: (String) -> String?
  
  public init(
    _ title: String,
    value: Binding<Value>,
    showError: Bool = true,
    stringValue: @escaping (Value) -> String,
    validate: @escaping (String) -> Value?,
    errorMessage: @escaping (String) -> String? = { _ in nil }
  ) {
    self.title = title
    _value = value
    self.showError = showError
    self.stringValue = stringValue
    self.validate = validate
    self.errorMessage = errorMessage
    _textValue = .init(initialValue: stringValue(value.wrappedValue))
  }
  
  public var body: some View {
    HStack(spacing: 6) {
      if #available(macOS 12.0, *) {
        TextField(title, text: $textValue)
          .onSubmit {
            validateText()
          }
          .focusable(true) { isFocused in
            if !isFocused {
              validateText()
            }
          }
          .onChange(of: value) { newValue in
            if let current = validate(textValue) {
              if current == newValue {
                // Don't change the text if validated value is the new value
                return
              }
            }
            
            textValue = stringValue(newValue)
          }
          .onChange(of: textValue) { newTextValue in
            if let validated = validate(newTextValue) {
              value = validated
            }
          }
      } else {
        TextField(title, text: $textValue) { isEditing in
          if !isEditing {
            validateText()
          }
        } onCommit: {
          validateText()
        }
        .onChange(of: value) { newValue in
          if let current = validate(textValue) {
            if current == newValue {
              // Don't change the text if validated value is the new value
              return
            }
          }
          
          textValue = stringValue(newValue)
        }
      }
      
      if validate(textValue) == nil {
        Image(systemName: "exclamationmark.triangle.fill")
          .help(errorMessage(textValue) ?? "\"\(textValue)\" is an invalid value")
          .transition(
            .move(edge: .trailing).combined(with: .opacity)
          )
      }
    }
    .animation(.easeInOut, value: textValue)
  }
}

// MARK: - Helpers
@available(macOS 11.0, *)
private extension ValidatingTextField {
  func validateText() {
    if let validated = validate(textValue) {
      value = validated
    } else {
      textValue = stringValue(value)
    }
  }
}

// MARK: - Previews
@available(macOS 11.0, *)
struct ValidatingTextField_Previews: PreviewProvider {
  static var previews: some View {
    ValidatingTextField("Name", value: .constant(5)) { number in
      String(number)
    } validate: { string in
      Int(string)
    } errorMessage: { string in
      "\"\(string)\" is not a number"
    }
    .frame(width: 200, height: 150)
    .padding()
  }
}
