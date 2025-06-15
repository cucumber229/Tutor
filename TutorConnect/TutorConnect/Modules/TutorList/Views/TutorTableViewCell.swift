//
//  TutorTableViewCell.swift
//  TutorConnect
//
//  Created by Artyom Tabachenko on 14.06.2025.
//

import Foundation
import UIKit
import SnapKit

class TutorTableViewCell: UITableViewCell {
    
    // MARK: - UI
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont(name: Fonts.ubuntuBold, size: 14)
        return label
    }()
    
    private lazy var subjectsStackView = SubjectStackView()
    
    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont(name: Fonts.ubuntuRegular, size: 14)
        return label
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

extension TutorTableViewCell {
    func configure(with tutor: TutorModel) {
        nameLabel.text = tutor.name
        priceLabel.text = "Цена: \(tutor.pricePerHour)₽/час"
        subjectsStackView.configure(with: tutor.subjects)
    }
}

// MARK: - Private methods

private extension TutorTableViewCell {
    func setupUI() {
        addSubviews()
        makeConstraints()
    }
    
    func addSubviews() {
        addSubview(nameLabel)
        addSubview(subjectsStackView)
        addSubview(priceLabel)
    }
    
    func makeConstraints() {
        nameLabel.snp.makeConstraints {
            $0.left.top.equalToSuperview().offset(15)
        }
        
        subjectsStackView.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(10)
            $0.left.equalToSuperview().offset(15)
            $0.bottom.equalToSuperview().inset(15)
            $0.right.equalToSuperview().inset(15)
        }
        
        priceLabel.snp.makeConstraints {
            $0.right.equalToSuperview().inset(15)
            $0.top.equalToSuperview().offset(15)
        }
    }
}

// MARK: - Constants

extension TutorTableViewCell {
    enum Constants {
        
    }
}
