//
//  MyBookingTableViewCell.swift
//  TutorConnect
//
//  Created by Дмитрий Леонтьев on 15.06.2025.
//

import UIKit
import SnapKit

class MyBookingTableViewCell: UITableViewCell {
    
    // MARK: - UI
    
    private lazy var titlelabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont(name: Fonts.ubuntuBold, size: 14)
        return label
    }()
    
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont(name: Fonts.ubuntuRegular, size: 12)
        return label
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont(name: Fonts.ubuntuRegular, size: 12)
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            titlelabel, timeLabel, nameLabel
        ])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fill
        stackView.alignment = .leading
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

extension MyBookingTableViewCell {
    func configure(with booking: BookingInfo) {
        titlelabel.text = booking.subject

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        let date = booking.time.dateValue()
        timeLabel.text = formatter.string(from: date)

        if let tutorName = booking.tutorName {
            nameLabel.text = "Преподаватель: \(tutorName)"
        } else if let email = booking.email {
            nameLabel.text = "Ученик: \(email)"
        } else {
            nameLabel.text = nil
        }
    }
}

// MARK: - Private methods

private extension MyBookingTableViewCell {
    func setupUI() {
        addSubviews()
        makeConstraints()
    }
    
    func addSubviews() {
        addSubview(stackView)
    }
    
    func makeConstraints() {
        stackView.snp.makeConstraints {
            $0.left.top.equalToSuperview().offset(15)
            $0.bottom.equalToSuperview().inset(15)
        }
    }
}
