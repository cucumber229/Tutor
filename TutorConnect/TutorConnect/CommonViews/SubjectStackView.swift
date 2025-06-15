//
//  SubjectStackView.swift
//  TutorConnect
//
//  Created by Artyom Tabachenko on 14.06.2025.
//

import UIKit
import SnapKit
import Foundation

final class SubjectStackView: UIStackView {
    
    // Properties
    private let maxRowWidth: CGFloat = UIScreen.main.bounds.width - 30 // отступы
    private let labelFont = UIFont(name: Fonts.ubuntuRegular, size: 12)!
    
    // MARK: Initialization
    
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

extension SubjectStackView {
    func configure(with subjects: [String]) {
        renderLabels(from: subjects)
    }

    func configureSlots(from slotStrings: [Date]) {
        let formatted = slotStrings.map { SlotFormatter.prettyFormat(from: $0) }
        renderLabels(from: formatted)
    }
}

// MARK: - Private methods

private extension SubjectStackView {
    func renderLabels(from texts: [String]) {
        arrangedSubviews.forEach { $0.removeFromSuperview() }

        var currentRow = makeHorizontalStack()
        var currentWidth: CGFloat = 0

        for text in texts {
            let view = makeLabelView(for: text)
            let estimatedWidth = text.width(withConstrainedHeight: 24, font: labelFont) + 24

            if currentWidth + estimatedWidth > maxRowWidth {
                addArrangedSubview(currentRow)
                currentRow = makeHorizontalStack()
                currentWidth = 0
            }

            currentRow.addArrangedSubview(view)
            currentWidth += estimatedWidth
        }

        addArrangedSubview(currentRow)
    }
    
    func makeHorizontalStack() -> UIStackView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.spacing = 5
        return stack
    }

    func makeLabelView(for subject: String) -> UIView {
        let label: UILabel = {
            let label = UILabel()
            label.text = subject
            label.font = UIFont(name: Fonts.ubuntuRegular, size: 12)
            label.textColor = .black
            label.backgroundColor = .clear
            label.textAlignment = .center
            label.setContentHuggingPriority(.required, for: .horizontal)
            label.setContentCompressionResistancePriority(.required, for: .horizontal)
            return label
        }()
        
        let view: UIView = {
            let view = UIView()
            view.backgroundColor = .systemGray6.withAlphaComponent(0.7)
            view.layer.cornerRadius = 8
            view.addSubview(label)
            label.snp.makeConstraints {
                $0.edges.equalToSuperview().inset(NSDirectionalEdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
            }
            return view
        }()

        return view
    }
}
