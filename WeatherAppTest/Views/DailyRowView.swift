import UIKit
import SnapKit

final class DailyRowView: UIView {
    private let dayLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 17, weight: .medium)
        return label
    }()

    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let rainLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(red: 0.55, green: 0.85, blue: 1.0, alpha: 1.0)
        label.font = .systemFont(ofSize: 13, weight: .medium)
        return label
    }()

    private let lowLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(white: 1, alpha: 0.55)
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.textAlignment = .right
        return label
    }()

    private let highLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textAlignment = .right
        return label
    }()

    private let separator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 1, alpha: 0.12)
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        [dayLabel, iconImageView, rainLabel, lowLabel, highLabel, separator].forEach { addSubview($0) }

        dayLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(110)
        }

        iconImageView.snp.makeConstraints {
            $0.leading.equalTo(dayLabel.snp.trailing).offset(4)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(26)
        }

        rainLabel.snp.makeConstraints {
            $0.leading.equalTo(iconImageView.snp.trailing).offset(4)
            $0.centerY.equalToSuperview()
        }

        lowLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(38)
        }

        highLabel.snp.makeConstraints {
            $0.trailing.equalTo(lowLabel.snp.leading).offset(-10)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(38)
        }

        separator.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(0.5)
        }
    }

    func configure(with day: ForecastDay, isToday: Bool, isLast: Bool) {
        if isToday {
            dayLabel.text = "Сегодня"
        } else {
            let inputFormatter = DateFormatter()
            inputFormatter.dateFormat = "yyyy-MM-dd"
            if let date = inputFormatter.date(from: day.date) {
                let outputFormatter = DateFormatter()
                outputFormatter.dateFormat = "EEEE"
                outputFormatter.locale = Locale(identifier: "ru_RU")
                let fullDay = outputFormatter.string(from: date)
                dayLabel.text = fullDay.prefix(1).uppercased() + fullDay.dropFirst()
            }
        }

        iconImageView.image = nil
        iconImageView.loadWeatherIcon(from: day.day.condition.icon)

        if day.day.dailyChanceOfRain > 0 {
            rainLabel.text = "\(day.day.dailyChanceOfRain)%"
        } else {
            rainLabel.text = nil
        }

        highLabel.text = "\(Int(day.day.maxtempC.rounded()))°"
        lowLabel.text = "\(Int(day.day.mintempC.rounded()))°"
        separator.isHidden = isLast
    }
}
