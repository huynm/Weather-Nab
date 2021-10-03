//
//  ForecastView.swift
//  Weather Nab
//
//  Created by Huy Nguyen on 10/2/21.
//

import EasyPeasy
import Foundation
import UIKit

class ForecastView: UIView {
    let dateLabel = UILabel()
    let avgTemperatureLabel = UILabel()
    let pressureLabel = UILabel()
    let humidityLabel = UILabel()
    let descriptionLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        dateLabel.font = .preferredFont(forTextStyle: .body)
        dateLabel.numberOfLines = 0
        
        avgTemperatureLabel.font = .preferredFont(forTextStyle: .body)
        avgTemperatureLabel.numberOfLines = 0
        
        pressureLabel.font = .preferredFont(forTextStyle: .body)
        pressureLabel.numberOfLines = 0
        
        humidityLabel.font = .preferredFont(forTextStyle: .body)
        humidityLabel.numberOfLines = 0
        
        descriptionLabel.font = .preferredFont(forTextStyle: .body)
        descriptionLabel.numberOfLines = 0
        
        let contentView = UIStackView(arrangedSubviews: [
            dateLabel,
            avgTemperatureLabel,
            pressureLabel,
            humidityLabel,
            descriptionLabel
        ])
        contentView.axis = .vertical
        contentView.spacing = 16
        addSubview(contentView)
        contentView.easy.layout(Edges(16))
    }
}