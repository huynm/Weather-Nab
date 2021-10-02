//
//  WeatherViewController.swift
//  Weather Nab
//
//  Created by Huy Nguyen on 10/2/21.
//

import UIKit
import RxSwift
import RxCocoa

class WeatherViewController: UIViewController {
    private let viewModel: WeatherViewModelProtocol
    private let disposeBag = DisposeBag()
    
    required init(viewModel: WeatherViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        viewModel.outputs.weather.bind {
            print($0)
        }.disposed(by: disposeBag)
        
        viewModel.inputs.viewDidLoad()
    }
}
