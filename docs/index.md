# IDOWeatherSDK 使用指南

SDK在线地址：[https://github.com/idoosmart/Weather_SDK.git](https://github.com/idoosmart/Weather_SDK.git)

## 1. Android 使用指南

### 1.1 集成 SDK

将 SDK AAR 文件 (`library-release.aar`) 复制到你的 Android 项目的 `libs` 目录中。

在 `build.gradle.kts` 中添加依赖：

```kotlin
dependencies {
    implementation(files("libs/library-release.aar"))
    // 依赖库 (如果 SDK 未包含)
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.7.3")
    implementation("org.jetbrains.kotlinx:kotlinx-datetime:0.5.0")
    implementation("io.ktor:ktor-client-core:2.3.7")
    implementation("io.ktor:ktor-client-okhttp:2.3.7")
}
```

### 1.2 初始化

在使用 SDK 之前，必须先进行注册。

```kotlin
import com.idoosmart.weather.IDOWeatherSDK

// 在 Application onCreate 或 Activity 中初始化
// appKey: 你的应用密钥
// countryCode: 国家代码 (例如: 中国 86, 美国 1, 印度 91)
IDOWeatherSDK.register(appKey = "your-app-key", countryCode = 86)

// 开启日志 (可选)
IDOWeatherSDK.setEnableLog(true)
```

### 1.3 获取天气

> **重要**: SDK 返回原始 JSON 字符串 (`WeatherApiResult<String>`)，调用方需要自行解析 JSON 数据。

```kotlin
import com.idoosmart.weather.model.WeatherRequest
import kotlinx.coroutines.launch

// 构造请求
val request = WeatherRequest.Builder()
    .longitude("116.4074")
    .latitude("39.9042")
    .type(1) // 1: IBM, 2: QWeather
    .build()

lifecycleScope.launch {
    val result = IDOWeatherSDK.getWeather(request)
    
    result.fold(
        onSuccess = { jsonString -> 
            // jsonString 是原始 JSON 响应字符串
            println("原始 JSON: $jsonString")
            // 解析 JSON 示例 (需要自行处理)
            // val json = JSONObject(jsonString)
            // val temp = json.getJSONObject("result").getInt("temperature")
        },
        onFailure = { error ->
            println("请求失败: ${error.message}")
        }
    )
}
```

## 2. iOS 使用指南

### 2.1 集成 SDK

1. 将 `IDOWeatherSDK.xcframework` 拖入到 Xcode 项目中。
2. 确保在 "General" -> "Frameworks, Libraries, and Embedded Content" 中选择 "Embed & Sign"。

### 2.2 初始化

在使用 SDK 之前，必须先进行注册。

```swift
import IDOWeatherSDK

// 在 AppDelegate 或使用前初始化
IDOWeatherSDK.shared.register(appKey: "your-app-key", countryCode: 86)

// 开启日志 (可选)
IDOWeatherSDK.shared.setEnableLog(enable: true)
```

### 2.3 获取天气

> **重要**: SDK 返回原始 JSON 字符串 (`WeatherApiResult<String>`)，调用方需要自行解析 JSON 数据。

```swift
import IDOWeatherSDK

let request = WeatherRequest.Builder()
    .longitude(lon: "116.4074")
    .latitude(lat: "39.9042")
    .type(type: 1)
    .build()

IDOWeatherSDK.shared.getWeather(request: request) { result, error in
    if let jsonString = result?.getOrNull() {
        // jsonString 是原始 JSON 响应字符串
        print("原始 JSON: \(jsonString)")
        // 解析 JSON 示例 (需要自行处理)
        // if let data = jsonString.data(using: .utf8),
        //    let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
        //     print(json)
        // }
    } else if let weatherError = result?.errorOrNull() {
        print("请求失败: \(weatherError.message)")
    } else {
        print("Error: \(error?.localizedDescription ?? "Unknown")")
    }
}
```

## 3. JSON 响应结构

SDK 返回原始 JSON 字符串，以下是 JSON 响应的结构说明，供调用方解析时参考。

### WeatherRequest (天气请求参数)

| 字段名 | 类型 | 必填 | 说明 |
| :--- | :--- | :--- | :--- |
| longitude | String | 是 | 经度 |
| latitude | String | 是 | 纬度 |
| type | Int | 否 | 天气查询类型：1 使用IBM天气接口数据，2 使用和风天气数据，默认传 1 |
| code | String | 否 | 国家编码（美国 001 中国 86 法国 33 德国 49 英国 44 印度 91 墨西哥52 西班牙34，其他国家默认走美国空气质量标准） |
| city | String | 否 | 城市，后端做缓存用（缓存1小时） |
| district | String | 否 | 区 |
| extend | Map<String, String> | 否 | 扩展参数 |

### WeatherResponse (天气响应数据)

| 字段名 | 类型 | 说明 |
| :--- | :--- | :--- |
| status | Int | 状态码 (0 成功) |
| message | String | 响应消息 |
| result | WeatherResult? | 天气结果数据 |

### WeatherResult (天气结果详情)

| 字段名 | 类型 | 说明 |
| :--- | :--- | :--- |
| type | Int | 天气类型：<br>0:未知<br>1:白天晴, 2:多云, 3:阴天<br>4:雨, 5:暴雨, 6:雷阵雨, 18:阵雨<br>7:雪, 8:雨夹雪<br>9:台风, 10:沙尘暴, 17:阴霾<br>11:夜间晴, 12:夜间多云, 19:云<br>13:热, 14:冷<br>15:微风, 16:大风 |
| lastTime | String? | 最后更新时间 |
| temperature | Int | 实时温度 |
| maxTemperature | Int | 最高温度 |
| minTemperature | Int | 最低温度 |
| humidity | Int | 湿度 |
| sunriseTimeLocal | String? | 日出时间 |
| sunsetTimeLocal | String? | 日落时间 |
| uvDescription | String? | 紫外线描述 |
| uvIndex | Int | 紫外线等级 (-2=不可用，-1=无报告，0~2=低，3~5=中等，6~7=高，8~10=非常高，11~16=极端) |
| windSpeed | Int | 风速 |
| windLevel | Int | 风力等级 |
| windDirection | Int | 风向 |
| precipChance | Int | 今日降水概率 |
| futureWeatherInfo | `List<FutureWeatherInfo>` | 未来7天白天天气数据 |
| hour48WeatherInfos | `List<Hour48WeatherInfo>` | 未来48小时天气数据 |
| qpfSnow | Double | 积雪量，单位：厘米 |
| snowRange | String? | 积雪厚度，单位：厘米 |
| pressure | Double | 大气压强：百帕 |
| weatherQualityInfo | WeatherQualityInfo? | 空气质量信息 |
| moonPhase | String? | 月相 |
| moonriseTimeLocal | String? | 月出时间 |
| moonsetTimeLocal | String? | 月落时间 |
| moonPhaseCode | String? | 月相code |
| homeDisplay | Boolean? | 是否显示首页天气小窗口 |
| exerciseDisplay | Boolean? | 是否锻炼页显示天气小窗口 |
| future14WeatherInfo | `List<FutureWeatherInfo>` | 未来14天天气数据 |
| hour72WeatherInfo | `List<Hour48WeatherInfo>` | 未来72小时天气数据 |

### FutureWeatherInfo (未来天气信息)

| 字段名 | 类型 | 说明 |
| :--- | :--- | :--- |
| dayOfWeek | String | 星期几 |
| type | Int | 天气类型 |
| maxTemperature | Int | 最高温度 |
| minTemperature | Int | 最低温度 |
| sunriseTimeLocal | String? | 日出时间 |
| sunsetTimeLocal | String? | 日落时间 |
| uvDescription | String? | 紫外线描述 |
| uvIndex | Int | 紫外线等级 |

### Hour48WeatherInfo (小时天气信息)

| 字段名 | 类型 | 说明 |
| :--- | :--- | :--- |
| hour | String | 时间 |
| type | Int | 天气类型 |
| temperature | Int | 温度 |
| precipChance | Int | 降雨概率 |
| uvIndex | Int | 紫外线等级 |
| windSpeed | Double | 风速 |
| windUnit | String? | 风速单位 |
| windLevelCode | String? | 风力等级编码 (0:微风, 1:3-4级, 2:4-5级, 3:5-6级, 4:6-7级, 5:7-8级, 6:8-9级, 7:9-10级, 8:10-11级, 9:11-12级) |

### WeatherQualityInfo (空气质量信息)

| 字段名 | 类型 | 说明 |
| :--- | :--- | :--- |
| airQualityCategory | String? | 空气质量描述 |
| airQualityIndex | Int? | 空气质量指数 |
| color | String? | 当前国家应选择渲染颜色 |
| code | String? | 当前国家编码 |

## 4. 错误处理

SDK 可能会返回以下类型的错误：

- `NetworkError`: 网络连接问题
- `TimeoutError`: 请求超时
- `ServerError`: 服务器响应 5xx
- `RateLimitError`: 请求过于频繁
- `ValidationError`: 参数错误


## 5. 示例 json

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
