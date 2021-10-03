//
//  ContainerTableViewCell.swift
//  Weather Nab
//
//  Created by Huy Nguyen on 10/2/21.
//

import EasyPeasy
import Foundation
import UIKit

class ContainerTableViewCell<T>: UITableViewCell where T: UIView {
    let containedView: T
    
    init(_ builder: () -> T = { T() }, reuseIdentifier: String?) {
        self.containedView = builder()
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        contentView.addSubview(containedView)
        containedView.easy.layout(Edges())
    }
}
