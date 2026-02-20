import Foundation
import CoreLocation

enum WeatherState {
    case loading
    case loaded(ForecastWeatherResponse)
    case error(String)
}

@MainActor
final class WeatherViewModel {
    var onStateChanged: ((WeatherState) -> Void)?

    private(set) var state: WeatherState = .loading {
        didSet { onStateChanged?(state) }
    }

    func loadWeather() {
        state = .loading
        LocationService.shared.requestLocation { [weak self] location in
            Task { @MainActor [weak self] in
                await self?.fetchWeather(lat: location.coordinate.latitude, lon: location.coordinate.longitude)
            }
        } onDenied: { [weak self] in
            // Fallback to Moscow
            Task { @MainActor [weak self] in
                await self?.fetchWeather(lat: 55.7558, lon: 37.6173)
            }
        }
    }

    private func fetchWeather(lat: Double, lon: Double) async {
        do {
            let response = try await WeatherService.shared.fetchForecast(lat: lat, lon: lon)
            state = .loaded(response)
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    func hourlyItems(from response: ForecastWeatherResponse) -> [HourWeather] {
        let now = Date()
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: now)

        var items: [HourWeather] = []

        if let today = response.forecast.forecastday.first {
            let remaining = today.hour.filter { hour in
                let date = Date(timeIntervalSince1970: TimeInterval(hour.timeEpoch))
                return calendar.component(.hour, from: date) >= currentHour
            }
            items.append(contentsOf: remaining)
        }

        if response.forecast.forecastday.count > 1 {
            items.append(contentsOf: response.forecast.forecastday[1].hour)
        }

        return items
    }
}
