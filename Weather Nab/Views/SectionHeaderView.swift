//
//  SectionHeaderView.swift
//  Weather Nab
//
//  Created by Huy Nguyen on 10/5/21.
//

import Foundation
import UIKit
import EasyPeasy

class SectionHeaderView: UITableViewHeaderFooterView {
    let titleLabel = UILabel()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        titleLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        titleLabel.accessibilityIdentifier = AccessibilityIdentifier.dailyForecastSectionHeaderLabel
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.numberOfLines = 0
        addSubview(titleLabel)
        titleLabel.easy.layout(Edges(Insets(
            top: Constant.spacing(1),
            left: Constant.spacing(2),
            bottom: Constant.spacing(1),
            right: Constant.spacing(2)
        )))
    }
}
