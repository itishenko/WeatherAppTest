import UIKit
import SnapKit

final class WeatherViewController: UIViewController {

    // MARK: - ViewModel

    private let viewModel = WeatherViewModel()

    // MARK: - Background

    private let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor(red: 0.12, green: 0.33, blue: 0.70, alpha: 1).cgColor,
            UIColor(red: 0.06, green: 0.18, blue: 0.47, alpha: 1).cgColor,
            UIColor(red: 0.03, green: 0.09, blue: 0.26, alpha: 1).cgColor
        ]
        layer.locations = [0, 0.55, 1]
        return layer
    }()

    // MARK: - Scroll View

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.contentInsetAdjustmentBehavior = .never
        return sv
    }()

    private let contentView = UIView()

    // MARK: - Current Weather

    private let cityLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 34, weight: .light)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    private let temperatureLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 96, weight: .thin)
        label.textAlignment = .center
        return label
    }()

    private let conditionLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(white: 1, alpha: 0.8)
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.textAlignment = .center
        return label
    }()

    private let highLowLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(white: 1, alpha: 0.75)
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        return label
    }()

    // MARK: - Hourly Section

    private let hourlyCard = WeatherCardView()

    private let hourlyTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "ПОЧАСОВОЙ ПРОГНОЗ"
        label.textColor = UIColor(white: 1, alpha: 0.55)
        label.font = .systemFont(ofSize: 11, weight: .semibold)
        label.letterSpacing(1.2)
        return label
    }()

    private lazy var hourlyCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 64, height: 104)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.dataSource = self
        cv.register(HourlyWeatherCell.self, forCellWithReuseIdentifier: HourlyWeatherCell.reuseIdentifier)
        return cv
    }()

    // MARK: - Daily Section

    private let dailyCard = WeatherCardView()

    private let dailyTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "ПРОГНОЗ НА 3 ДНЯ"
        label.textColor = UIColor(white: 1, alpha: 0.55)
        label.font = .systemFont(ofSize: 11, weight: .semibold)
        label.letterSpacing(1.2)
        return label
    }()

    private let dailyStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 0
        return sv
    }()

    // MARK: - Details Section

    private let detailsCard = WeatherCardView()

    private let detailsStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 0
        return sv
    }()

    // MARK: - State Views

    private lazy var loadingView: LoadingView = {
        let view = LoadingView()
        view.isHidden = true
        return view
    }()

    private lazy var errorView: ErrorView = {
        let view = ErrorView()
        view.isHidden = true
        view.onRetry = { [weak self] in self?.viewModel.loadWeather() }
        return view
    }()

    // MARK: - Data

    private var hourlyItems: [HourWeather] = []

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupScrollView()
        setupStateViews()
        bindViewModel()
        viewModel.loadWeather()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    // MARK: - Setup

    private func setupBackground() {
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        scrollView.snp.makeConstraints { $0.edges.equalToSuperview() }
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(view)
        }

        setupCurrentWeatherSection()
        setupHourlySection()
        setupDailySection()
        setupDetailsSection()
    }

    private func setupCurrentWeatherSection() {
        [cityLabel, temperatureLabel, conditionLabel, highLowLabel].forEach { contentView.addSubview($0) }

        cityLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(72)
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(24)
        }

        temperatureLabel.snp.makeConstraints {
            $0.top.equalTo(cityLabel.snp.bottom).offset(0)
            $0.centerX.equalToSuperview()
        }

        conditionLabel.snp.makeConstraints {
            $0.top.equalTo(temperatureLabel.snp.bottom).offset(-4)
            $0.centerX.equalToSuperview()
        }

        highLowLabel.snp.makeConstraints {
            $0.top.equalTo(conditionLabel.snp.bottom).offset(6)
            $0.centerX.equalToSuperview()
        }
    }

    private func setupHourlySection() {
        contentView.addSubview(hourlyCard)
        hourlyCard.addSubview(hourlyTitleLabel)
        hourlyCard.addSubview(hourlyCollectionView)

        hourlyCard.snp.makeConstraints {
            $0.top.equalTo(highLowLabel.snp.bottom).offset(36)
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        hourlyTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(14)
            $0.leading.equalToSuperview().offset(16)
        }

        let divider = makeDivider()
        hourlyCard.addSubview(divider)
        divider.snp.makeConstraints {
            $0.top.equalTo(hourlyTitleLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(0.5)
        }

        hourlyCollectionView.snp.makeConstraints {
            $0.top.equalTo(divider.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(112)
            $0.bottom.equalToSuperview().inset(6)
        }
    }

    private func setupDailySection() {
        contentView.addSubview(dailyCard)
        dailyCard.addSubview(dailyTitleLabel)
        dailyCard.addSubview(dailyStackView)

        dailyCard.snp.makeConstraints {
            $0.top.equalTo(hourlyCard.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        dailyTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(14)
            $0.leading.equalToSuperview().offset(16)
        }

        let divider = makeDivider()
        dailyCard.addSubview(divider)
        divider.snp.makeConstraints {
            $0.top.equalTo(dailyTitleLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(0.5)
        }

        dailyStackView.snp.makeConstraints {
            $0.top.equalTo(divider.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }

    private func setupDetailsSection() {
        contentView.addSubview(detailsCard)
        detailsCard.addSubview(detailsStackView)

        detailsCard.snp.makeConstraints {
            $0.top.equalTo(dailyCard.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(44)
        }

        detailsStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(16)
        }
    }

    private func setupStateViews() {
        [loadingView, errorView].forEach { view.addSubview($0) }
        loadingView.snp.makeConstraints { $0.edges.equalToSuperview() }
        errorView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    private func bindViewModel() {
        viewModel.onStateChanged = { [weak self] state in
            self?.handleState(state)
        }
    }

    // MARK: - State Handling

    private func handleState(_ state: WeatherState) {
        switch state {
        case .loading:
            loadingView.isHidden = false
            errorView.isHidden = true
            scrollView.isHidden = true

        case .loaded(let response):
            loadingView.isHidden = true
            errorView.isHidden = true
            scrollView.isHidden = false
            updateUI(with: response)

        case .error(let message):
            loadingView.isHidden = true
            errorView.isHidden = false
            scrollView.isHidden = true
            errorView.configure(message: message)
        }
    }

    // MARK: - UI Update

    private func updateUI(with response: ForecastWeatherResponse) {
        cityLabel.text = response.location.name
        temperatureLabel.text = "\(Int(response.current.tempC.rounded()))°"
        conditionLabel.text = response.current.condition.text

        if let today = response.forecast.forecastday.first {
            let high = Int(today.day.maxtempC.rounded())
            let low = Int(today.day.mintempC.rounded())
            highLowLabel.text = "В: \(high)°   Н: \(low)°"
        }

        hourlyItems = viewModel.hourlyItems(from: response)
        hourlyCollectionView.reloadData()

        updateDailySection(forecastDays: response.forecast.forecastday)
        updateDetailsSection(current: response.current)
    }

    private func updateDailySection(forecastDays: [ForecastDay]) {
        dailyStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (index, day) in forecastDays.enumerated() {
            let row = DailyRowView()
            row.configure(with: day, isToday: index == 0, isLast: index == forecastDays.count - 1)
            row.snp.makeConstraints { $0.height.equalTo(56) }
            dailyStackView.addArrangedSubview(row)
        }
    }

    private func updateDetailsSection(current: CurrentWeather) {
        detailsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let items: [(String, String, String)] = [
            ("thermometer.medium", "Ощущается как", "\(Int(current.feelslikeC.rounded()))°"),
            ("humidity.fill", "Влажность", "\(current.humidity)%"),
            ("wind", "Ветер", "\(Int(current.windKph.rounded())) км/ч \(current.windDir)"),
            ("sun.max.fill", "УФ-индекс", "\(Int(current.uv.rounded()))")
        ]

        for (index, item) in items.enumerated() {
            let row = DetailRowView()
            row.configure(systemIcon: item.0, title: item.1, value: item.2)
            detailsStackView.addArrangedSubview(row)

            if index < items.count - 1 {
                let sep = makeDivider()
                detailsStackView.addArrangedSubview(sep)
                sep.snp.makeConstraints { $0.height.equalTo(0.5) }
            }
        }
    }

    // MARK: - Helpers

    private func makeDivider() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor(white: 1, alpha: 0.13)
        return view
    }
}

// MARK: - UICollectionViewDataSource

extension WeatherViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        hourlyItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: HourlyWeatherCell.reuseIdentifier,
            for: indexPath
        ) as! HourlyWeatherCell
        cell.configure(with: hourlyItems[indexPath.item], isNow: indexPath.item == 0)
        return cell
    }
}

// MARK: - UILabel helpers

private extension UILabel {
    func letterSpacing(_ spacing: CGFloat) {
        guard let text else { return }
        attributedText = NSAttributedString(
            string: text,
            attributes: [
                .kern: spacing,
                .font: font as Any,
                .foregroundColor: textColor as Any
            ]
        )
    }
}
