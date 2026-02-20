import UIKit

extension UIImageView {
    func loadWeatherIcon(from urlString: String) {
        let fullURL = urlString.hasPrefix("//") ? "https:" + urlString : urlString
        guard let url = URL(string: fullURL) else { return }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async { self?.image = image }
        }.resume()
    }
}
