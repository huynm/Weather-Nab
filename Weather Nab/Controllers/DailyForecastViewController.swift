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
    private let messageLabel = UILabel()
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
    }
    
    private func setupView() {
        title = NSLocalizedString("dailyForecast.screenTitle", comment: "")
        view.backgroundColor = .systemBackground
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.delegate = self
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
        searchController.searchBar.accessibilityIdentifier = AccessibilityIdentifier.dailyForecastSearchBar
        
        tableView.isHidden = true
        tableView.accessibilityIdentifier = AccessibilityIdentifier.dailyForecastTableView
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        tableView.easy.layout(Edges())
        
        messageLabel.isHidden = true
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = .preferredFont(forTextStyle: .body)
        messageLabel.adjustsFontForContentSizeCategory = true
        view.addSubview(messageLabel)
        messageLabel.easy.layout(
            CenterY(),
            Left(Constant.spacing(2)),
            Right(Constant.spacing(2))
        )
        
        spinnerView.isHidden = true
        spinnerView.accessibilityIdentifier = AccessibilityIdentifier.dailyForecastSpinner
        spinnerView.startAnimating()
        view.addSubview(spinnerView)
        spinnerView.easy.layout(Center())
    }
    
    private func bindViewModel() {
        viewModel.outputs.showAlert
            .observe(on: MainScheduler.instance)
            .bind { [weak self] in
                let title: String
                let message: String
                switch $0 {
                case let .minimumQueryLength(length):
                    title = NSLocalizedString("alert.minimumQueryLength.title", comment: "")
                    message = String.localizedStringWithFormat(
                        NSLocalizedString("alert.minimumQueryLength.message", comment: ""),
                        length
                    )
                }
                
                let alertController = UIAlertController(
                    title: title,
                    message: message,
                    preferredStyle: .alert
                )
                let okAction = UIAlertAction(
                    title: NSLocalizedString("button.ok", comment: ""),
                    style: .cancel,
                    handler: nil
                )
                alertController.addAction(okAction)
                self?.present(alertController, animated: true, completion: nil)
            }
            .disposed(by: disposeBag)
        
        Observable.combineLatest(
            viewModel.outputs.isLoading,
            viewModel.outputs.viewState)
            .observe(on: MainScheduler.instance)
            .bind { [weak self] isLoading, state in
                self?.spinnerView.isHidden = true
                self?.messageLabel.isHidden = true
                self?.tableView.isHidden = true
                
                if isLoading {
                    self?.spinnerView.isHidden = false
                    return
                }
                
                switch state {
                case .initial:
                    self?.messageLabel.isHidden = false
                    self?.messageLabel.text = NSLocalizedString("dailyForecast.initialMessage", comment: "")
                case let .forecastReport(forecastReport):
                    self?.forecastReport = forecastReport
                    self?.tableView.isHidden = false
                    self?.tableView.reloadData()
                case let .error(error):
                    self?.messageLabel.isHidden = false
                    switch error {
                    case .cityNotFound:
                        self?.messageLabel.text = NSLocalizedString("dailyForecast.error.cityNotFound", comment: "")
                    case .unknown:
                        self?.messageLabel.text = NSLocalizedString("dailyForecast.error.unknown", comment: "")
                    }
                }
            }
            .disposed(by: disposeBag)
    }
}

extension DailyForecastViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        viewModel.inputs.didSubmitQuery(searchBar.text)
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
        
        let cellIdentifier = "ForecastCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? ContainerTableViewCell<ForecastView>
            ?? ContainerTableViewCell<ForecastView>(reuseIdentifier: cellIdentifier)
        
        let forecast = forecastReport.forecasts[indexPath.row]
        let dateFormatter = DateFormatter.default
        let degreeFormatter = MeasurementFormatter.default
        let percentageFormatter = NumberFormatter.percentageFormatter
        
        cell.containedView.dateLabel.text = format(
            title: NSLocalizedString("dailyForecast.dateTitle", comment: ""),
            value: dateFormatter.string(from: forecast.date)
        )
        cell.containedView.avgTemperatureLabel.text = format(
            title: NSLocalizedString("dailyForecast.avgTemperatureTitle", comment: ""),
            value: degreeFormatter.string(
                from: forecast.avgTemperature,
                measurementUnit: forecast.measurementUnit
            )
        )
        cell.containedView.humidityLabel.text = format(
            title: NSLocalizedString("dailyForecast.humidityTitle", comment: ""),
            value: percentageFormatter.string(from: NSNumber(value: forecast.humidity))
        )
        cell.containedView.pressureLabel.text = format(
            title: NSLocalizedString("dailyForecast.pressureTitle", comment: ""),
            value: "\(forecast.pressure)"
        )
        cell.containedView.descriptionLabel.text = format(
            title: NSLocalizedString("dailyForecast.descriptionTitle", comment: ""),
            value: forecast.description
        )
        return cell
    }
    
    private func format(title: String, value: String?) -> String {
        return "\(title): \(value ?? "")"
    }
}

extension DailyForecastViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return forecastReport?.city
    }
}
