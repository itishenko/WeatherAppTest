import UIKit

final class WeatherCardView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAppearance()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupAppearance() {
        backgroundColor = UIColor(white: 1, alpha: 0.13)
        layer.cornerRadius = 16
        layer.masksToBounds = true
        layer.borderWidth = 0.5
        layer.borderColor = UIColor(white: 1, alpha: 0.25).cgColor
    }
}
