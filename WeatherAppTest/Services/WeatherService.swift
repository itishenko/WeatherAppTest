import Foundation

enum WeatherError: LocalizedError {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case serverError(Int)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Неверный URL"
        case .networkError(let error):
            return "Ошибка сети: \(error.localizedDescription)"
        case .decodingError:
            return "Не удалось обработать данные о погоде"
        case .serverError(let code):
            return "Ошибка сервера: \(code)"
        }
    }
}

final class WeatherService {
    static let shared = WeatherService()

    private let apiKey = "fa8b3df74d4042b9aa7135114252304"
    private let logTag = "[WeatherAPI]"

    private init() {}

    func fetchForecast(lat: Double, lon: Double) async throws -> ForecastWeatherResponse {
        let urlString = "https://api.weatherapi.com/v1/forecast.json?key=\(apiKey)&q=\(lat),\(lon)&days=3"
        guard let url = URL(string: urlString) else {
            throw WeatherError.invalidURL
        }

        logRequest(url: url)

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(from: url)
        } catch {
            logError(error)
            throw WeatherError.networkError(error)
        }

        logResponse(data: data, response: response)

        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            throw WeatherError.serverError(httpResponse.statusCode)
        }

        do {
            return try JSONDecoder().decode(ForecastWeatherResponse.self, from: data)
        } catch {
            throw WeatherError.decodingError(error)
        }
    }

    // MARK: - Logging

    private func logRequest(url: URL) {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            print("\(logTag) → GET \(url.absoluteString)")
            return
        }
        let maskedItems = components.queryItems?.map { item in
            item.name == "key" ? URLQueryItem(name: "key", value: "***") : item
        }
        components.queryItems = maskedItems
        let sanitized = components.url?.absoluteString ?? url.absoluteString
        print("\(logTag) → GET \(sanitized)")
    }

    private func logResponse(data: Data, response: URLResponse) {
        let status = (response as? HTTPURLResponse)?.statusCode ?? 0
        let size = data.count
        print("\(logTag) ← \(status) \(size) bytes")

        if let json = String(data: data, encoding: .utf8) {
            let preview = json.count > 500 ? String(json.prefix(500)) + "…" : json
            print("\(logTag) body: \(preview)")
        }
    }

    private func logError(_ error: Error) {
        print("\(logTag) ✗ \(error.localizedDescription)")
    }
}

