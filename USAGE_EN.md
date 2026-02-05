# IDOWeatherSDK Usage Guide

## 1. SDK Integration

### Android

Copy the SDK AAR file (`library-release.aar`) into your Android project's `libs` directory.

Add dependencies in your `build.gradle.kts`:

```kotlin
dependencies {
    implementation(files("libs/library-release.aar"))
    // Dependencies (if not included in SDK)
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.7.3")
    implementation("org.jetbrains.kotlinx:kotlinx-datetime:0.5.0")
    implementation("io.ktor:ktor-client-core:2.3.7")
    implementation("io.ktor:ktor-client-okhttp:2.3.7")
}
```

### iOS

1. Drag `IDOWeatherSDK.xcframework` into your Xcode project.
2. Ensure "Embed & Sign" is selected in "General" -> "Frameworks, Libraries, and Embedded Content".

## 2. Initialization

You must register the SDK before using it.

### Android (Kotlin)

```kotlin
import com.idoosmart.weather.IDOWeatherSDK

// Initialize in Application onCreate or Activity
// appKey: Your application key
// countryCode: Country code (e.g., China 86, USA 1, India 91)
IDOWeatherSDK.register(appKey = "your-app-key", countryCode = 86)

// Enable Logging (Optional)
IDOWeatherSDK.setEnableLog(true)
```

### iOS (Swift)

```swift
import IDOWeatherSDK

// Initialize in AppDelegate or before use
IDOWeatherSDK.shared.register(appKey: "your-app-key", countryCode: 86)

// Enable Logging (Optional)
IDOWeatherSDK.shared.setEnableLog(enable: true)
```

## 3. Fetch Weather

> **Important**: The SDK returns a raw JSON string (`WeatherApiResult<String>`). The caller needs to parse the JSON data manually.

### Android (Kotlin)

```kotlin
import com.idoosmart.weather.model.WeatherRequest
import kotlinx.coroutines.launch

// Build Request
val request = WeatherRequest.Builder()
    .longitude("116.4074")
    .latitude("39.9042")
    .type(1) // 1: IBM, 2: QWeather
    .build()

lifecycleScope.launch {
    val result = IDOWeatherSDK.getWeather(request)
    
    result.fold(
        onSuccess = { jsonString -> 
            // jsonString is the raw JSON response string
            println("Raw JSON: $jsonString")
            // JSON Parsing Example (Handle manually)
            // val json = JSONObject(jsonString)
            // val temp = json.getJSONObject("result").getInt("temperature")
        },
        onFailure = { error ->
            println("Request failed: ${error.message}")
        }
    )
}
```

### iOS (Swift)

```swift
import IDOWeatherSDK

let request = WeatherRequest.Builder()
    .longitude(lon: "116.4074")
    .latitude(lat: "39.9042")
    .type(type: 1)
    .build()

IDOWeatherSDK.shared.getWeather(request: request) { result, error in
    if let jsonString = result?.getOrNull() {
        // jsonString is the raw JSON response string
        print("Raw JSON: \(jsonString)")
        // JSON Parsing Example (Handle manually)
        // if let data = jsonString.data(using: .utf8),
        //    let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
        //     print(json)
        // }
    } else if let weatherError = result?.errorOrNull() {
        print("Request failed: \(weatherError.message)")
    } else {
        print("Error: \(error?.localizedDescription ?? "Unknown")")
    }
}
```

## 4. JSON Response Structure

The SDK returns a raw JSON string. Below is the structure description of the JSON response for reference during parsing.

### WeatherRequest (Weather Request Parameters)

| Field Name | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| longitude | String | Yes | Longitude |
| latitude | String | Yes | Latitude |
| type | Int | No | Weather query type: 1 for IBM weather data, 2 for QWeather data. Default is 1. |
| code | String | No | Country code (USA 001, China 86, France 33, Germany 49, UK 44, India 91, Mexico 52, Spain 34; others default to USA air quality standards) |
| city | String | No | City, used for caching on backend (cached for 1 hour) |
| district | String | No | District |
| extend | Map<String, String> | No | Extended parameters |

### WeatherResponse (Weather Response Data)

| Field Name | Type | Description |
| :--- | :--- | :--- |
| status | Int | Status code (0 for success) |
| message | String | Response message |
| result | WeatherResult? | Weather result data |

### WeatherResult (Weather Result Details)

| Field Name | Type | Description |
| :--- | :--- | :--- |
| type | Int | Weather Type:<br>0:Unknown<br>1:Sunny (Day), 2:Cloudy, 3:Overcast<br>4:Rain, 5:Heavy Rain, 6:Thunderstorm, 18:Shower<br>7:Snow, 8:Sleet<br>9:Typhoon, 10:Sandstorm, 17:Haze<br>11:Sunny (Night), 12:Cloudy (Night), 19:Cloud<br>13:Hot, 14:Cold<br>15:Breeze, 16:Gale |
| lastTime | String? | Last update time |
| temperature | Int | Real-time temperature |
| maxTemperature | Int | Max temperature |
| minTemperature | Int | Min temperature |
| humidity | Int | Humidity |
| sunriseTimeLocal | String? | Sunrise time |
| sunsetTimeLocal | String? | Sunset time |
| uvDescription | String? | UV description |
| uvIndex | Int | UV Index (-2=Unavailable, -1=No Report, 0~2=Low, 3~5=Moderate, 6~7=High, 8~10=Very High, 11~16=Extreme) |
| windSpeed | Int | Wind speed |
| windLevel | Int | Wind level |
| windDirection | Int | Wind direction |
| precipChance | Int | Precipitation chance today |
| futureWeatherInfo | List<FutureWeatherInfo> | Future 7 days weather data (Daytime) |
| hour48WeatherInfos | List<Hour48WeatherInfo> | Future 48 hours weather data |
| qpfSnow | Double | Snowfall amount, unit: cm |
| snowRange | String? | Snow depth, unit: cm |
| pressure | Double | Atmospheric pressure: hPa |
| weatherQualityInfo | WeatherQualityInfo? | Air quality info |
| moonPhase | String? | Moon phase |
| moonriseTimeLocal | String? | Moonrise time |
| moonsetTimeLocal | String? | Moonset time |
| moonPhaseCode | String? | Moon phase code |
| homeDisplay | Boolean? | show weather widget on home page |
| exerciseDisplay | Boolean? | show weather widget on exercise page |
| future14WeatherInfo | List<FutureWeatherInfo> | Future 14 days weather data |
| hour72WeatherInfo | List<Hour48WeatherInfo> | Future 72 hours weather data |

### FutureWeatherInfo (Future Weather Info)

| Field Name | Type | Description |
| :--- | :--- | :--- |
| dayOfWeek | String | Day of week |
| type | Int | Weather type |
| maxTemperature | Int | Max temperature |
| minTemperature | Int | Min temperature |
| sunriseTimeLocal | String? | Sunrise time |
| sunsetTimeLocal | String? | Sunset time |
| uvDescription | String? | UV description |
| uvIndex | Int | UV index |

### Hour48WeatherInfo (Hourly Weather Info)

| Field Name | Type | Description |
| :--- | :--- | :--- |
| hour | String | Time |
| type | Int | Weather type |
| temperature | Int | Temperature |
| precipChance | Int | Rain probability |
| uvIndex | Int | UV index |
| windSpeed | Double | Wind speed |
| windUnit | String? | Wind speed unit |
| windLevelCode | String? | Wind level code (0:Breeze, 1:3-4, 2:4-5, 3:5-6, 4:6-7, 5:7-8, 6:8-9, 7:9-10, 8:10-11, 9:11-12) |

### WeatherQualityInfo (Air Quality Info)

| Field Name | Type | Description |
| :--- | :--- | :--- |
| airQualityCategory | String? | Air quality category |
| airQualityIndex | Int? | Air quality index |
| color | String? | Render color for current country |
| code | String? | Current country code |

## 5. Error Handling

The SDK may return the following types of errors:
- `NetworkError`: Network connection issue
- `TimeoutError`: Request timeout
- `ServerError`: Server response 5xx
- `RateLimitError`: Request too frequent
- `ValidationError`: Parameter error
