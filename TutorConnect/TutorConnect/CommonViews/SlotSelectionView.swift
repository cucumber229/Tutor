//
//  SlotSelectionView.swift
//  TutorConnect
//
//  Created by Артур Мавликаев on 14.06.2025.
//

import Foundation
import UIKit

final class SlotSelectionView: UIStackView {
    
    // Properties
    var onSlotSelected: ((String, UIButton) -> Void)?
    private let maxRowWidth: CGFloat = UIScreen.main.bounds.width - 30
    private let buttonFont = UIFont(name: Fonts.ubuntuRegular, size: 12)!
    
    // MARK:  Initialization
    
    init() {
        super.init(frame: .zero)
        axis = .vertical
        spacing = 5
        distribution = .fill
        alignment = .leading
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Public methods

extension SlotSelectionView {
    func configureSlots(from slotStrings: [Date]) {
        arrangedSubviews.forEach { $0.removeFromSuperview() }

        let formatted = slotStrings.map { SlotFormatter.prettyFormat(from: $0) }

        var currentRow = makeRow()
        var currentWidth: CGFloat = 0

        for slot in formatted {
            let button = makeButton(for: slot)
            let estimatedWidth = slot.width(withConstrainedHeight: 24, font: buttonFont) + 24

            if currentWidth + estimatedWidth > maxRowWidth {
                addArrangedSubview(currentRow)
                currentRow = makeRow()
                currentWidth = 0
            }

            currentRow.addArrangedSubview(button)
            currentWidth += estimatedWidth
        }

        addArrangedSubview(currentRow)
    }
}

// MARK: - Private methods

private extension SlotSelectionView {
    func makeRow() -> UIStackView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 5
        stack.alignment = .fill
        stack.distribution = .fill
        return stack
    }

    func makeButton(for title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont(name: Fonts.ubuntuRegular, size: 12)
        
        // Нормальное состояние
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .systemGray6.withAlphaComponent(0.7)
        
        // Общий стиль
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.clear.cgColor
        button.clipsToBounds = true
        button.contentEdgeInsets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
        
        // Выбранное состояние (будет вручную управляться из AvailableSlotsView)
        button.setTitleColor(.white, for: .selected)

        button.addAction(UIAction { [weak self] _ in
            self?.handleSelection(button: button, text: title)
        }, for: .touchUpInside)

        return button
    }
    
    func handleSelection(button: UIButton, text: String) {
        onSlotSelected?(text, button)
    }
}
