//
//  ToolbarTabButton.swift
//  
//
//  Created by Connor Barnes on 7/12/21.
//

import SwiftUI

#if os(macOS)
@available(macOS 11.0, *)
public struct ToolbarTabButton: View {
	@State private var isBeingHovered = false
	@State private var isBeingClicked = false
	
	var imageName: String
	var title: String
	var isSelected: Bool
	
	var action: () -> Void
	
	public init(imageName: String, title: String, isSelected: Bool, action: @escaping () -> Void) {
		self.imageName = imageName
		self.title = title
		self.isSelected = isSelected
		self.action = action
	}
	
	public var body: some View {
		VStack {
			Image(systemName: imageName)
				.font(.title)
				.frame(height: 26)
			
			Text(title)
				.font(.system(size: 11))
		}
		.foregroundColor(foregroundColor)
		.padding(4)
		.background(
			highlightColor
			.cornerRadius(6)
		)
		.onHover { hovering in
			isBeingHovered = hovering
		}
		.onLongPressGesture(minimumDuration: 60, maximumDistance: 0) { pressed in
			isBeingClicked = pressed
			if !pressed {
				action()
			}
		} perform: {
			isBeingClicked = false
		}
	}
}

// MARK: Helpers
@available(macOS 11.0, *)
extension ToolbarTabButton {
	var foregroundColor: Color {
		if isSelected {
			return isBeingClicked ? .accentColor.opacity(0.75) : .accentColor
		} else {
			return isBeingClicked ? .primary : .secondary
		}
	}
	
	var highlightColor: Color {
		if isSelected || isBeingHovered {
			return Color(.unemphasizedSelectedTextBackgroundColor)
		} else {
			return .clear
		}
	}
}

// MARK: - Previews
@available(macOS 11.0, *)
struct ToolbarButton_Previews: PreviewProvider {
	static var previews: some View {
		HStack {
			ToolbarTabButton(imageName: "photo",
										title: "Label",
										isSelected: false) { }
			
			ToolbarTabButton(imageName: "photo",
										title: "Label",
										isSelected: true) { }
		}
		.padding()
		.background(Color(.windowBackgroundColor))
	}
}
#endif
