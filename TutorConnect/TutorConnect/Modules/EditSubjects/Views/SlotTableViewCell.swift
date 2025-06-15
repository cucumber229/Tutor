//
//  SlotTableViewCell.swift
//  TutorConnect
//
//  Created by Дмитрий Леонтьев on 14.06.2025.
//

import Foundation
import FirebaseFirestore
import SnapKit
import UIKit

class SlotTableViewCell: UITableViewCell {
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont(name: Fonts.ubuntuBold, size: 14)
        return label
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.distribution = .fill
        return stackView
    }()
    
    // MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
     }
}

// MARK: - Public methods

extension SlotTableViewCell {
    func configure(subject: String, slots: [Timestamp]) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let subjectLabel = UILabel()
        subjectLabel.text = subject
        subjectLabel.font = UIFont(name: Fonts.ubuntuBold, size: 16)
        subjectLabel.textColor = .black

        let formattedDates: [(title: String, date: Date)] = slots.map {
            let date = $0.dateValue()
            return (SlotFormatter.prettyFormat(from: date), date)
        }

        let slotSelectionView = SlotSelectionView()
        slotSelectionView.configureSlots(from: formattedDates.map { $0.date })

        let container = UIStackView(arrangedSubviews: [subjectLabel, slotSelectionView])
        container.axis = .vertical
        container.spacing = 8

        stackView.addArrangedSubview(container)
    }
}

// MARK: - Private methods

private extension SlotTableViewCell {
    func setupUI() {
        addSubviews()
        makeConstraints()
    }
    
    func addSubviews() {
        addSubview(titleLabel)
        addSubview(stackView)
    }
    
    func makeConstraints() {
        titleLabel.snp.makeConstraints {
            $0.left.top.equalToSuperview().offset(15)
        }
        
        stackView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(15)
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.bottom.equalToSuperview().inset(15)
        }
    }
}
