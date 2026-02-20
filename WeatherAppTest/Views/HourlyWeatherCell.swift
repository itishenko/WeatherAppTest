import UIKit
import SnapKit

final class HourlyWeatherCell: UICollectionViewCell {
    static let reuseIdentifier = "HourlyWeatherCell"

    private let timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(white: 1, alpha: 0.85)
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textAlignment = .center
        return label
    }()

    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let tempLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textAlignment = .center
        return label
    }()

    private let rainLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(red: 0.55, green: 0.85, blue: 1.0, alpha: 1.0)
        label.font = .systemFont(ofSize: 11, weight: .medium)
        label.textAlignment = .center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        [timeLabel, iconImageView, tempLabel, rainLabel].forEach { contentView.addSubview($0) }

        timeLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(4)
        }

        iconImageView.snp.makeConstraints {
            $0.top.equalTo(timeLabel.snp.bottom).offset(6)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(30)
        }

        tempLabel.snp.makeConstraints {
            $0.top.equalTo(iconImageView.snp.bottom).offset(5)
            $0.centerX.equalToSuperview()
        }

        rainLabel.snp.makeConstraints {
            $0.top.equalTo(tempLabel.snp.bottom).offset(3)
            $0.centerX.equalToSuperview()
        }
    }

    func configure(with hour: HourWeather, isNow: Bool) {
        if isNow {
            timeLabel.text = "Сейчас"
            timeLabel.font = .systemFont(ofSize: 13, weight: .bold)
            timeLabel.textColor = .white
        } else {
            let date = Date(timeIntervalSince1970: TimeInterval(hour.timeEpoch))
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            timeLabel.text = formatter.string(from: date)
            timeLabel.font = .systemFont(ofSize: 13, weight: .medium)
            timeLabel.textColor = UIColor(white: 1, alpha: 0.85)
        }

        iconImageView.image = nil
        iconImageView.loadWeatherIcon(from: hour.condition.icon)
        tempLabel.text = "\(Int(hour.tempC.rounded()))°"

        if hour.chanceOfRain > 0 {
            rainLabel.text = "\(hour.chanceOfRain)%"
        } else {
            rainLabel.text = nil
        }
    }
}
