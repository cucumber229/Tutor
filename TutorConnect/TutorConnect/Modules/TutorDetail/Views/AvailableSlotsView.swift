//
//  AvailableSlotsView.swift
//  TutorConnect
//
//  Created by Дмитрий Леонтьев on 14.06.2025.
//

import Foundation
import UIKit
import FirebaseFirestore

final class AvailableSlotsView: UIView {
    
    private(set) var selectedSlot: Date?
    private(set) var selectedSubject: String?
    private var selectedSlotView: SlotSelectionView?
    private var selectedButton: UIButton?
    var onSlotSelected: ((String, Date) -> Void)?
    private var rawSlotMapping: [String: [String: String]] = [:]
    
    // MARK: - UI
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.distribution = .fill
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
}

// MARK: - Public methods

extension AvailableSlotsView {
    func configure(with slots: [String: [Timestamp]]) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for (subject, timestamps) in slots {
            let subjectLabel = UILabel()
            subjectLabel.text = subject
            subjectLabel.font = UIFont(name: Fonts.ubuntuBold, size: 16)
            subjectLabel.textColor = .black

            let formattedDates: [(title: String, date: Date)] = timestamps.map {
                let date = $0.dateValue()
                return (SlotFormatter.prettyFormat(from: date), date)
            }

            let slotSelectionView = SlotSelectionView()
            slotSelectionView.configureSlots(from: formattedDates.map { $0.date })

            slotSelectionView.onSlotSelected = { [weak self, weak slotSelectionView] slotText, button in
                guard let self = self,
                      let selected = formattedDates.first(where: { $0.title == slotText })?.date
                else { return }

                self.updateSelectedSlot(view: slotSelectionView, button: button, date: selected, subject: subject)
            }

            let container = UIStackView(arrangedSubviews: [subjectLabel, slotSelectionView])
            container.axis = .vertical
            container.spacing = 8

            stackView.addArrangedSubview(container)
        }
    }

    func updateSelectedSlot(view: SlotSelectionView?, button: UIButton, date: Date, subject: String) {
        if let prev = selectedButton {
            prev.isSelected = false
            prev.backgroundColor = .systemGray6.withAlphaComponent(0.7)
            prev.layer.borderColor = UIColor.clear.cgColor
        }

        if selectedButton == button {
            selectedButton = nil
            selectedSlotView = nil
            selectedSlot = nil
            selectedSubject = nil
            return
        }

        selectedButton = button
        selectedSlotView = view
        selectedSlot = date
        selectedSubject = subject

        button.isSelected = true
        button.backgroundColor = .systemBlue.withAlphaComponent(0.8)
        button.layer.borderColor = UIColor.systemBlue.cgColor

        onSlotSelected?(subject, date)
    }
    
    func rawTime(for formatted: String, subject: String) -> String? {
        return rawSlotMapping[subject]?[formatted]
    }
}

// MARK: - Private methods

private extension AvailableSlotsView {
    func setupUI() {
        addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
