import Foundation

struct ForecastWeatherResponse: Decodable {
    let location: WeatherLocation
    let current: CurrentWeather
    let forecast: Forecast
}

struct WeatherLocation: Decodable {
    let name: String
    let region: String
    let country: String
    let lat: Double
    let lon: Double
}

struct CurrentWeather: Decodable {
    let tempC: Double
    let feelslikeC: Double
    let humidity: Int
    let windKph: Double
    let windDir: String
    let uv: Double
    let condition: WeatherCondition
    let isDay: Int

    enum CodingKeys: String, CodingKey {
        case tempC = "temp_c"
        case feelslikeC = "feelslike_c"
        case humidity
        case windKph = "wind_kph"
        case windDir = "wind_dir"
        case uv
        case condition
        case isDay = "is_day"
    }
}

struct WeatherCondition: Decodable {
    let text: String
    let icon: String
    let code: Int
}

struct Forecast: Decodable {
    let forecastday: [ForecastDay]
}

struct ForecastDay: Decodable {
    let date: String
    let day: DaySummary
    let hour: [HourWeather]
}

struct DaySummary: Decodable {
    let maxtempC: Double
    let mintempC: Double
    let condition: WeatherCondition
    let dailyChanceOfRain: Int

    enum CodingKeys: String, CodingKey {
        case maxtempC = "maxtemp_c"
        case mintempC = "mintemp_c"
        case condition
        case dailyChanceOfRain = "daily_chance_of_rain"
    }
}

struct HourWeather: Decodable {
    let timeEpoch: Int
    let time: String
    let tempC: Double
    let condition: WeatherCondition
    let chanceOfRain: Int
    let isDay: Int

    enum CodingKeys: String, CodingKey {
        case timeEpoch = "time_epoch"
        case time
        case tempC = "temp_c"
        case condition
        case chanceOfRain = "chance_of_rain"
        case isDay = "is_day"
    }
}
