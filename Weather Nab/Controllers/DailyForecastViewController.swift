//
//  DailyForecastViewController.swift
//  Weather Nab
//
//  Created by Huy Nguyen on 10/2/21.
//

import EasyPeasy
import UIKit
import RxSwift
import RxCocoa

class DailyForecastViewController: UIViewController {
    private let tableView = UITableView()
    private let errorLabel = UILabel()
    private let spinnerView = UIActivityIndicatorView(style: .large)
    private let searchController = UISearchController()
    
    private let viewModel: DailyForecastViewModelProtocol
    private let disposeBag = DisposeBag()
    private var forecastReport: DailyForecastReport?
    
    required init(viewModel: DailyForecastViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bindViewModel()
        viewModel.inputs.viewDidLoad()
    }
    
    private func setupView() {
        title = "Weather Forecast"
        view.backgroundColor = .white
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.delegate = self
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
        
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        tableView.easy.layout(Edges())
        
        view.addSubview(errorLabel)
        errorLabel.easy.layout(Center())
        
        spinnerView.startAnimating()
        view.addSubview(spinnerView)
        spinnerView.easy.layout(Center())
    }
    
    private func bindViewModel() {
        viewModel.outputs.initialQuery
            .observe(on: MainScheduler.instance)
            .bind { [weak self] in self?.searchController.searchBar.text = $0 }
            .disposed(by: disposeBag)
        
        Observable.combineLatest(
            viewModel.outputs.isLoading,
            viewModel.outputs.viewState)
            .observe(on: MainScheduler.instance)
            .bind { [weak self] isLoading, state in
                self?.spinnerView.isHidden = true
                self?.errorLabel.isHidden = true
                self?.tableView.isHidden = true
                
                if isLoading {
                    self?.spinnerView.isHidden = false
                    return
                }
                
                switch state {
                case let .forecastReport(forecastReport):
                    self?.forecastReport = forecastReport
                    self?.tableView.isHidden = false
                    self?.tableView.reloadData()
                case let .error(error):
                    self?.errorLabel.isHidden = false
                    self?.errorLabel.text = "\(error)"
                }
            }
            .disposed(by: disposeBag)
    }
}

extension DailyForecastViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        viewModel.inputs.queryDidChange(searchBar.text)
    }
}

extension DailyForecastViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forecastReport?.forecasts.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let forecastReport = forecastReport else {
            return UITableViewCell()
        }
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = "\(forecastReport.forecasts[indexPath.row].avgTemperature.rounded())"
        cell.detailTextLabel?.text = forecastReport.forecasts[indexPath.row].description
        return cell
    }
}

extension DailyForecastViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return forecastReport?.city
    }
}
