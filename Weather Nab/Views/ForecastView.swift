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
    let averageTemperatureLabel = UILabel()
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
        dateLabel.accessibilityIdentifier = AccessibilityIdentifier.dailyForecastDateLabel
        dateLabel.numberOfLines = 0
        dateLabel.adjustsFontForContentSizeCategory = true
        
        averageTemperatureLabel.font = .preferredFont(forTextStyle: .body)
        averageTemperatureLabel.accessibilityIdentifier = AccessibilityIdentifier.dailyForecastAverageTemperatureLabel
        averageTemperatureLabel.numberOfLines = 0
        averageTemperatureLabel.adjustsFontForContentSizeCategory = true
        
        pressureLabel.font = .preferredFont(forTextStyle: .body)
        pressureLabel.accessibilityIdentifier = AccessibilityIdentifier.dailyForecastPressureLabel
        pressureLabel.numberOfLines = 0
        pressureLabel.adjustsFontForContentSizeCategory = true
        
        humidityLabel.font = .preferredFont(forTextStyle: .body)
        humidityLabel.accessibilityIdentifier = AccessibilityIdentifier.dailyForecastHumidityLabel
        humidityLabel.numberOfLines = 0
        humidityLabel.adjustsFontForContentSizeCategory = true
        
        descriptionLabel.font = .preferredFont(forTextStyle: .body)
        descriptionLabel.accessibilityIdentifier = AccessibilityIdentifier.dailyForecastDescriptionLabel
        descriptionLabel.numberOfLines = 0
        descriptionLabel.adjustsFontForContentSizeCategory = true
        
        let contentView = UIStackView(arrangedSubviews: [
            dateLabel,
            averageTemperatureLabel,
            pressureLabel,
            humidityLabel,
            descriptionLabel
        ])
        contentView.axis = .vertical
        contentView.spacing = Constant.spacing(2)
        addSubview(contentView)
        contentView.easy.layout(Edges(Constant.spacing(2)))
    }
}
