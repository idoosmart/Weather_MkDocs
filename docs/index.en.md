# IDOWeatherSDK Usage Guide

SDK Online Address: [https://github.com/idoosmart/Weather_SDK.git](https://github.com/idoosmart/Weather_SDK.git)

## 1. Android Guide

### 1.1 SDK Integration

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

### 1.2 Initialization

You must register the SDK before using it.

```kotlin
import com.idoosmart.weather.IDOWeatherSDK

// Initialize in Application onCreate or Activity
// appKey: Your application key
// countryCode: Country code (e.g., China 86, USA 1, India 91)
IDOWeatherSDK.register(appKey = "your-app-key", countryCode = 86)

// Enable Logging (Optional)
IDOWeatherSDK.setEnableLog(true)
```

### 1.3 Fetch Weather

> **Important**: The SDK returns a raw JSON string (`WeatherApiResult<String>`). The caller needs to parse the JSON data manually.

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

## 2. iOS Guide

### 2.1 SDK Integration

1. Drag `IDOWeatherSDK.xcframework` into your Xcode project.
2. Ensure "Embed & Sign" is selected in "General" -> "Frameworks, Libraries, and Embedded Content".

### 2.2 Initialization

You must register the SDK before using it.

```swift
import IDOWeatherSDK

// Initialize in AppDelegate or before use
IDOWeatherSDK.shared.register(appKey: "your-app-key", countryCode: 86)

// Enable Logging (Optional)
IDOWeatherSDK.shared.setEnableLog(enable: true)
```

### 2.3 Fetch Weather

> **Important**: The SDK returns a raw JSON string (`WeatherApiResult<String>`). The caller needs to parse the JSON data manually.

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

## 3. JSON Response Structure

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
| futureWeatherInfo | `List<FutureWeatherInfo>` | Future 7 days weather data (Daytime) |
| hour48WeatherInfos | `List<Hour48WeatherInfo>` | Future 48 hours weather data |
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
| future14WeatherInfo | `List<FutureWeatherInfo>` | Future 14 days weather data |
| hour72WeatherInfo | `List<Hour48WeatherInfo>` | Future 72 hours weather data |

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

## 4. Error Handling

The SDK may return the following types of errors:

- `NetworkError`: Network connection issue
- `TimeoutError`: Request timeout
- `ServerError`: Server response 5xx
- `RateLimitError`: Request too frequent
- `ValidationError`: Parameter error

## 5. Example JSON

```json
{
    "status": 200,
    "message": "Ok",
    "result": {
        "type": 2,
        "lastTime": "2026-02-05 15:24:18",
        "temperature": 1,
        "maxTemperature": 2,
        "minTemperature": -8,
        "humidity": 16,
        "futureWeatherInfo": [
            {
                "dayOfWeek": "Friday",
                "type": 2,
                "maxTemperature": -2,
                "minTemperature": -9,
                "sunriseTimeLocal": "2026-02-06 07:19:00",
                "sunsetTimeLocal": "2026-02-06 17:39:00",
                "uvDescription": null,
                "uvIndex": 3
            },
            {
                "dayOfWeek": "Saturday",
                "type": 2,
                "maxTemperature": 0,
                "minTemperature": -9,
                "sunriseTimeLocal": "2026-02-07 07:18:00",
                "sunsetTimeLocal": "2026-02-07 17:40:00",
                "uvDescription": null,
                "uvIndex": 3
            },
            {
                "dayOfWeek": "Sunday",
                "type": 1,
                "maxTemperature": 3,
                "minTemperature": -5,
                "sunriseTimeLocal": "2026-02-08 07:16:00",
                "sunsetTimeLocal": "2026-02-08 17:41:00",
                "uvDescription": null,
                "uvIndex": 8
            },
            {
                "dayOfWeek": "Monday",
                "type": 2,
                "maxTemperature": 5,
                "minTemperature": -2,
                "sunriseTimeLocal": "2026-02-09 07:15:00",
                "sunsetTimeLocal": "2026-02-09 17:42:00",
                "uvDescription": null,
                "uvIndex": 3
            },
            {
                "dayOfWeek": "Tuesday",
                "type": 1,
                "maxTemperature": 7,
                "minTemperature": -4,
                "sunriseTimeLocal": "2026-02-10 07:14:00",
                "sunsetTimeLocal": "2026-02-10 17:44:00",
                "uvDescription": null,
                "uvIndex": 8
            },
            {
                "dayOfWeek": "Wednesday",
                "type": 1,
                "maxTemperature": 7,
                "minTemperature": -3,
                "sunriseTimeLocal": "2026-02-11 07:13:00",
                "sunsetTimeLocal": "2026-02-11 17:45:00",
                "uvDescription": null,
                "uvIndex": 8
            },
            {
                "dayOfWeek": "Thursday",
                "type": 2,
                "maxTemperature": 9,
                "minTemperature": -1,
                "sunriseTimeLocal": "2026-02-12 07:12:00",
                "sunsetTimeLocal": "2026-02-12 17:46:00",
                "uvDescription": null,
                "uvIndex": 3
            }
        ],
        "sunriseTimeLocal": "2026-02-05 07:20:00",
        "sunsetTimeLocal": "2026-02-05 17:38:00",
        "uvDescription": "Weaker",
        "uvIndex": 1,
        "windSpeed": 37,
        "windLevel": 5,
        "windDirection": 8,
        "precipChance": 0,
        "hour48WeatherInfos": [
            {
                "hour": "2026-02-05T16:00:00+08:00",
                "type": 2,
                "temperature": 2,
                "precipChance": 0,
                "uvIndex": 1,
                "windSpeed": 18.0,
                "windUnit": "km/h",
                "windLevelCode": "1"
            },
            {
                "hour": "2026-02-05T17:00:00+08:00",
                "type": 2,
                "temperature": 1,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 14.4,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-05T18:00:00+08:00",
                "type": 2,
                "temperature": 0,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 14.4,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-05T19:00:00+08:00",
                "type": 11,
                "temperature": -1,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 14.4,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-05T20:00:00+08:00",
                "type": 11,
                "temperature": -3,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 14.4,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-05T21:00:00+08:00",
                "type": 2,
                "temperature": -3,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 18.0,
                "windUnit": "km/h",
                "windLevelCode": "1"
            },
            {
                "hour": "2026-02-05T22:00:00+08:00",
                "type": 2,
                "temperature": -3,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 10.8,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-05T23:00:00+08:00",
                "type": 2,
                "temperature": -4,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 10.8,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-06T00:00:00+08:00",
                "type": 2,
                "temperature": -5,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 10.8,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-06T01:00:00+08:00",
                "type": 2,
                "temperature": -5,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 10.8,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-06T02:00:00+08:00",
                "type": 2,
                "temperature": -6,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 7.2,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-06T03:00:00+08:00",
                "type": 2,
                "temperature": -7,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 10.8,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-06T04:00:00+08:00",
                "type": 2,
                "temperature": -7,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 10.8,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-06T05:00:00+08:00",
                "type": 2,
                "temperature": -8,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 10.8,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-06T06:00:00+08:00",
                "type": 2,
                "temperature": -8,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 7.2,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-06T07:00:00+08:00",
                "type": 2,
                "temperature": -8,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 7.2,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-06T08:00:00+08:00",
                "type": 2,
                "temperature": -8,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 7.2,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-06T09:00:00+08:00",
                "type": 2,
                "temperature": -7,
                "precipChance": 0,
                "uvIndex": 1,
                "windSpeed": 7.2,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-06T10:00:00+08:00",
                "type": 2,
                "temperature": -6,
                "precipChance": 0,
                "uvIndex": 1,
                "windSpeed": 10.8,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-06T11:00:00+08:00",
                "type": 2,
                "temperature": -5,
                "precipChance": 0,
                "uvIndex": 1,
                "windSpeed": 10.8,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-06T12:00:00+08:00",
                "type": 2,
                "temperature": -4,
                "precipChance": 0,
                "uvIndex": 1,
                "windSpeed": 10.8,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-06T13:00:00+08:00",
                "type": 2,
                "temperature": -3,
                "precipChance": 0,
                "uvIndex": 1,
                "windSpeed": 10.8,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-06T14:00:00+08:00",
                "type": 1,
                "temperature": -2,
                "precipChance": 0,
                "uvIndex": 1,
                "windSpeed": 10.8,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-06T15:00:00+08:00",
                "type": 1,
                "temperature": -2,
                "precipChance": 0,
                "uvIndex": 1,
                "windSpeed": 10.8,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-06T16:00:00+08:00",
                "type": 1,
                "temperature": -2,
                "precipChance": 0,
                "uvIndex": 1,
                "windSpeed": 10.8,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-06T17:00:00+08:00",
                "type": 1,
                "temperature": -4,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 10.8,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-06T18:00:00+08:00",
                "type": 11,
                "temperature": -5,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 7.2,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-06T19:00:00+08:00",
                "type": 11,
                "temperature": -5,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 7.2,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-06T20:00:00+08:00",
                "type": 11,
                "temperature": -5,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 7.2,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-06T21:00:00+08:00",
                "type": 11,
                "temperature": -6,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 7.2,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-06T22:00:00+08:00",
                "type": 11,
                "temperature": -6,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 7.2,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-06T23:00:00+08:00",
                "type": 11,
                "temperature": -6,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 7.2,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-07T00:00:00+08:00",
                "type": 11,
                "temperature": -7,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 7.2,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-07T01:00:00+08:00",
                "type": 11,
                "temperature": -7,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 7.2,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-07T02:00:00+08:00",
                "type": 11,
                "temperature": -8,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 10.8,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-07T03:00:00+08:00",
                "type": 11,
                "temperature": -8,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 10.8,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-07T04:00:00+08:00",
                "type": 11,
                "temperature": -9,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 10.8,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-07T05:00:00+08:00",
                "type": 11,
                "temperature": -9,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 7.2,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-07T06:00:00+08:00",
                "type": 11,
                "temperature": -9,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 7.2,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-07T07:00:00+08:00",
                "type": 11,
                "temperature": -9,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 7.2,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-07T08:00:00+08:00",
                "type": 1,
                "temperature": -9,
                "precipChance": 0,
                "uvIndex": 1,
                "windSpeed": 7.2,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-07T09:00:00+08:00",
                "type": 1,
                "temperature": -6,
                "precipChance": 0,
                "uvIndex": 2,
                "windSpeed": 10.8,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-07T10:00:00+08:00",
                "type": 1,
                "temperature": -4,
                "precipChance": 0,
                "uvIndex": 2,
                "windSpeed": 10.8,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-07T11:00:00+08:00",
                "type": 1,
                "temperature": -3,
                "precipChance": 0,
                "uvIndex": 3,
                "windSpeed": 10.8,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-07T12:00:00+08:00",
                "type": 1,
                "temperature": -1,
                "precipChance": 0,
                "uvIndex": 3,
                "windSpeed": 10.8,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-07T13:00:00+08:00",
                "type": 1,
                "temperature": 0,
                "precipChance": 0,
                "uvIndex": 3,
                "windSpeed": 10.8,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-07T14:00:00+08:00",
                "type": 1,
                "temperature": 0,
                "precipChance": 0,
                "uvIndex": 1,
                "windSpeed": 10.8,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-07T15:00:00+08:00",
                "type": 1,
                "temperature": 0,
                "precipChance": 0,
                "uvIndex": 2,
                "windSpeed": 10.8,
                "windUnit": "km/h",
                "windLevelCode": "0"
            }
        ],
        "qpfSnow": 0.0,
        "snowRange": "0",
        "pressure": 1029.0,
        "weatherQualityInfo": {
            "airQualityIndex": 20,
            "airQualityCategory": "Excellent",
            "color": "1",
            "code": "Ozone"
        },
        "moonPhase": "WaningGibbous",
        "moonriseTimeLocal": "2026-02-05 21:25:35",
        "moonsetTimeLocal": "2026-02-06 09:16:35",
        "moonPhaseCode": "WNG",
        "future14WeatherInfo": [
            {
                "dayOfWeek": "Friday",
                "type": 2,
                "maxTemperature": -2,
                "minTemperature": -9,
                "sunriseTimeLocal": "2026-02-06 07:19:00",
                "sunsetTimeLocal": "2026-02-06 17:39:00",
                "uvDescription": null,
                "uvIndex": 3
            },
            {
                "dayOfWeek": "Saturday",
                "type": 2,
                "maxTemperature": 0,
                "minTemperature": -9,
                "sunriseTimeLocal": "2026-02-07 07:18:00",
                "sunsetTimeLocal": "2026-02-07 17:40:00",
                "uvDescription": null,
                "uvIndex": 3
            },
            {
                "dayOfWeek": "Sunday",
                "type": 1,
                "maxTemperature": 3,
                "minTemperature": -5,
                "sunriseTimeLocal": "2026-02-08 07:16:00",
                "sunsetTimeLocal": "2026-02-08 17:41:00",
                "uvDescription": null,
                "uvIndex": 8
            },
            {
                "dayOfWeek": "Monday",
                "type": 2,
                "maxTemperature": 5,
                "minTemperature": -2,
                "sunriseTimeLocal": "2026-02-09 07:15:00",
                "sunsetTimeLocal": "2026-02-09 17:42:00",
                "uvDescription": null,
                "uvIndex": 3
            },
            {
                "dayOfWeek": "Tuesday",
                "type": 1,
                "maxTemperature": 7,
                "minTemperature": -4,
                "sunriseTimeLocal": "2026-02-10 07:14:00",
                "sunsetTimeLocal": "2026-02-10 17:44:00",
                "uvDescription": null,
                "uvIndex": 8
            },
            {
                "dayOfWeek": "Wednesday",
                "type": 1,
                "maxTemperature": 7,
                "minTemperature": -3,
                "sunriseTimeLocal": "2026-02-11 07:13:00",
                "sunsetTimeLocal": "2026-02-11 17:45:00",
                "uvDescription": null,
                "uvIndex": 8
            },
            {
                "dayOfWeek": "Thursday",
                "type": 2,
                "maxTemperature": 9,
                "minTemperature": -1,
                "sunriseTimeLocal": "2026-02-12 07:12:00",
                "sunsetTimeLocal": "2026-02-12 17:46:00",
                "uvDescription": null,
                "uvIndex": 3
            },
            {
                "dayOfWeek": "Friday",
                "type": 2,
                "maxTemperature": 11,
                "minTemperature": 0,
                "sunriseTimeLocal": "2026-02-13 07:11:00",
                "sunsetTimeLocal": "2026-02-13 17:47:00",
                "uvDescription": null,
                "uvIndex": 3
            },
            {
                "dayOfWeek": "Saturday",
                "type": 2,
                "maxTemperature": 12,
                "minTemperature": -1,
                "sunriseTimeLocal": "2026-02-14 07:09:00",
                "sunsetTimeLocal": "2026-02-14 17:48:00",
                "uvDescription": null,
                "uvIndex": 3
            },
            {
                "dayOfWeek": "Sunday",
                "type": 2,
                "maxTemperature": 8,
                "minTemperature": -3,
                "sunriseTimeLocal": "2026-02-15 07:08:00",
                "sunsetTimeLocal": "2026-02-15 17:50:00",
                "uvDescription": null,
                "uvIndex": 3
            },
            {
                "dayOfWeek": "Monday",
                "type": 2,
                "maxTemperature": 9,
                "minTemperature": 0,
                "sunriseTimeLocal": "2026-02-16 07:07:00",
                "sunsetTimeLocal": "2026-02-16 17:51:00",
                "uvDescription": null,
                "uvIndex": 3
            },
            {
                "dayOfWeek": "Tuesday",
                "type": 2,
                "maxTemperature": 9,
                "minTemperature": 0,
                "sunriseTimeLocal": "2026-02-17 07:06:00",
                "sunsetTimeLocal": "2026-02-17 17:52:00",
                "uvDescription": null,
                "uvIndex": 3
            },
            {
                "dayOfWeek": "Wednesday",
                "type": 1,
                "maxTemperature": 13,
                "minTemperature": 2,
                "sunriseTimeLocal": "2026-02-18 07:04:00",
                "sunsetTimeLocal": "2026-02-18 17:53:00",
                "uvDescription": null,
                "uvIndex": 8
            },
            {
                "dayOfWeek": "Thursday",
                "type": 2,
                "maxTemperature": 11,
                "minTemperature": -5,
                "sunriseTimeLocal": "2026-02-19 07:03:00",
                "sunsetTimeLocal": "2026-02-19 17:54:00",
                "uvDescription": null,
                "uvIndex": 3
            }
        ],
        "hour72WeatherInfo": [
            {
                "hour": "2026-02-05T16:00:00+08:00",
                "type": 2,
                "temperature": 2,
                "precipChance": 0,
                "uvIndex": 1,
                "windSpeed": 18.0,
                "windUnit": "km/h",
                "windLevelCode": "1"
            },
            {
                "hour": "2026-02-05T17:00:00+08:00",
                "type": 2,
                "temperature": 1,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 14.4,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-05T18:00:00+08:00",
                "type": 2,
                "temperature": 0,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 14.4,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-05T19:00:00+08:00",
                "type": 11,
                "temperature": -1,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 14.4,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-05T20:00:00+08:00",
                "type": 11,
                "temperature": -3,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 14.4,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-05T21:00:00+08:00",
                "type": 2,
                "temperature": -3,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 18.0,
                "windUnit": "km/h",
                "windLevelCode": "1"
            },
            {
                "hour": "2026-02-05T22:00:00+08:00",
                "type": 2,
                "temperature": -3,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 10.8,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-05T23:00:00+08:00",
                "type": 2,
                "temperature": -4,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 10.8,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-06T00:00:00+08:00",
                "type": 2,
                "temperature": -5,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 10.8,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-06T01:00:00+08:00",
                "type": 2,
                "temperature": -5,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 10.8,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-06T02:00:00+08:00",
                "type": 2,
                "temperature": -6,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 7.2,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-06T03:00:00+08:00",
                "type": 2,
                "temperature": -7,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 10.8,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-06T04:00:00+08:00",
                "type": 2,
                "temperature": -7,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 10.8,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-06T05:00:00+08:00",
                "type": 2,
                "temperature": -8,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 10.8,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-06T06:00:00+08:00",
                "type": 2,
                "temperature": -8,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 7.2,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-06T07:00:00+08:00",
                "type": 2,
                "temperature": -8,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 7.2,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-06T08:00:00+08:00",
                "type": 2,
                "temperature": -8,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 7.2,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-06T09:00:00+08:00",
                "type": 2,
                "temperature": -7,
                "precipChance": 0,
                "uvIndex": 1,
                "windSpeed": 7.2,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-06T10:00:00+08:00",
                "type": 2,
                "temperature": -6,
                "precipChance": 0,
                "uvIndex": 1,
                "windSpeed": 10.8,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-06T11:00:00+08:00",
                "type": 2,
                "temperature": -5,
                "precipChance": 0,
                "uvIndex": 1,
                "windSpeed": 10.8,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-06T12:00:00+08:00",
                "type": 2,
                "temperature": -4,
                "precipChance": 0,
                "uvIndex": 1,
                "windSpeed": 10.8,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-06T13:00:00+08:00",
                "type": 2,
                "temperature": -3,
                "precipChance": 0,
                "uvIndex": 1,
                "windSpeed": 10.8,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-06T14:00:00+08:00",
                "type": 1,
                "temperature": -2,
                "precipChance": 0,
                "uvIndex": 1,
                "windSpeed": 10.8,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-06T15:00:00+08:00",
                "type": 1,
                "temperature": -2,
                "precipChance": 0,
                "uvIndex": 1,
                "windSpeed": 10.8,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-06T16:00:00+08:00",
                "type": 1,
                "temperature": -2,
                "precipChance": 0,
                "uvIndex": 1,
                "windSpeed": 10.8,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-06T17:00:00+08:00",
                "type": 1,
                "temperature": -4,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 10.8,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-06T18:00:00+08:00",
                "type": 11,
                "temperature": -5,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 7.2,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-06T19:00:00+08:00",
                "type": 11,
                "temperature": -5,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 7.2,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-06T20:00:00+08:00",
                "type": 11,
                "temperature": -5,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 7.2,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-06T21:00:00+08:00",
                "type": 11,
                "temperature": -6,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 7.2,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-06T22:00:00+08:00",
                "type": 11,
                "temperature": -6,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 7.2,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-06T23:00:00+08:00",
                "type": 11,
                "temperature": -6,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 7.2,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-07T00:00:00+08:00",
                "type": 11,
                "temperature": -7,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 7.2,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-07T01:00:00+08:00",
                "type": 11,
                "temperature": -7,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 7.2,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-07T02:00:00+08:00",
                "type": 11,
                "temperature": -8,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 10.8,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-07T03:00:00+08:00",
                "type": 11,
                "temperature": -8,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 10.8,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-07T04:00:00+08:00",
                "type": 11,
                "temperature": -9,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 10.8,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-07T05:00:00+08:00",
                "type": 11,
                "temperature": -9,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 7.2,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-07T06:00:00+08:00",
                "type": 11,
                "temperature": -9,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 7.2,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-07T07:00:00+08:00",
                "type": 11,
                "temperature": -9,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 7.2,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-07T08:00:00+08:00",
                "type": 1,
                "temperature": -9,
                "precipChance": 0,
                "uvIndex": 1,
                "windSpeed": 7.2,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-07T09:00:00+08:00",
                "type": 1,
                "temperature": -6,
                "precipChance": 0,
                "uvIndex": 2,
                "windSpeed": 10.8,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-07T10:00:00+08:00",
                "type": 1,
                "temperature": -4,
                "precipChance": 0,
                "uvIndex": 2,
                "windSpeed": 10.8,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-07T11:00:00+08:00",
                "type": 1,
                "temperature": -3,
                "precipChance": 0,
                "uvIndex": 3,
                "windSpeed": 10.8,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-07T12:00:00+08:00",
                "type": 1,
                "temperature": -1,
                "precipChance": 0,
                "uvIndex": 3,
                "windSpeed": 10.8,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-07T13:00:00+08:00",
                "type": 1,
                "temperature": 0,
                "precipChance": 0,
                "uvIndex": 3,
                "windSpeed": 10.8,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-07T14:00:00+08:00",
                "type": 1,
                "temperature": 0,
                "precipChance": 0,
                "uvIndex": 1,
                "windSpeed": 10.8,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-07T15:00:00+08:00",
                "type": 1,
                "temperature": 0,
                "precipChance": 0,
                "uvIndex": 2,
                "windSpeed": 10.8,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-07T16:00:00+08:00",
                "type": 1,
                "temperature": 0,
                "precipChance": 0,
                "uvIndex": 1,
                "windSpeed": 7.2,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-07T17:00:00+08:00",
                "type": 1,
                "temperature": 0,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 7.2,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-07T18:00:00+08:00",
                "type": 11,
                "temperature": -2,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 10.8,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-07T19:00:00+08:00",
                "type": 11,
                "temperature": -3,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 10.8,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-07T20:00:00+08:00",
                "type": 11,
                "temperature": -4,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 10.8,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-07T21:00:00+08:00",
                "type": 11,
                "temperature": -4,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 18.0,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-07T22:00:00+08:00",
                "type": 11,
                "temperature": -4,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 14.4,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-07T23:00:00+08:00",
                "type": 11,
                "temperature": -4,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 10.8,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-08T00:00:00+08:00",
                "type": 11,
                "temperature": -6,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 10.8,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-08T01:00:00+08:00",
                "type": 11,
                "temperature": -6,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 10.8,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-08T02:00:00+08:00",
                "type": 11,
                "temperature": -7,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 10.8,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-08T03:00:00+08:00",
                "type": 11,
                "temperature": -8,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 10.8,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-08T04:00:00+08:00",
                "type": 11,
                "temperature": -8,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 7.2,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-08T05:00:00+08:00",
                "type": 11,
                "temperature": -9,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 7.2,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-08T06:00:00+08:00",
                "type": 11,
                "temperature": -9,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 7.2,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-08T07:00:00+08:00",
                "type": 11,
                "temperature": -8,
                "precipChance": 0,
                "uvIndex": 0,
                "windSpeed": 7.2,
                "windUnit": "km/h",
                "windLevelCode": "0"
            },
            {
                "hour": "2026-02-08T08:00:00+08:00",
                "type": 1,
                "temperature": -11,
                "precipChance": 0,
                "uvIndex": 1,
                "windSpeed": 5.6,
                "windUnit": "km/h",
                "windLevelCode": null
            },
            {
                "hour": "2026-02-08T09:00:00+08:00",
                "type": 1,
                "temperature": -7,
                "precipChance": 0,
                "uvIndex": 2,
                "windSpeed": 5.6,
                "windUnit": "km/h",
                "windLevelCode": null
            },
            {
                "hour": "2026-02-08T10:00:00+08:00",
                "type": 1,
                "temperature": -4,
                "precipChance": 0,
                "uvIndex": 2,
                "windSpeed": 7.4,
                "windUnit": "km/h",
                "windLevelCode": null
            },
            {
                "hour": "2026-02-08T11:00:00+08:00",
                "type": 1,
                "temperature": -2,
                "precipChance": 0,
                "uvIndex": 3,
                "windSpeed": 7.4,
                "windUnit": "km/h",
                "windLevelCode": null
            },
            {
                "hour": "2026-02-08T12:00:00+08:00",
                "type": 1,
                "temperature": 0,
                "precipChance": 0,
                "uvIndex": 3,
                "windSpeed": 11.1,
                "windUnit": "km/h",
                "windLevelCode": null
            },
            {
                "hour": "2026-02-08T13:00:00+08:00",
                "type": 1,
                "temperature": 0,
                "precipChance": 0,
                "uvIndex": 3,
                "windSpeed": 13.0,
                "windUnit": "km/h",
                "windLevelCode": null
            },
            {
                "hour": "2026-02-08T14:00:00+08:00",
                "type": 1,
                "temperature": 2,
                "precipChance": 0,
                "uvIndex": 2,
                "windSpeed": 14.8,
                "windUnit": "km/h",
                "windLevelCode": null
            },
            {
                "hour": "2026-02-08T15:00:00+08:00",
                "type": 1,
                "temperature": 3,
                "precipChance": 0,
                "uvIndex": 2,
                "windSpeed": 14.8,
                "windUnit": "km/h",
                "windLevelCode": null
            }
        ],
        "homeDisplay": null,
        "exerciseDisplay": null
    }
}
```
