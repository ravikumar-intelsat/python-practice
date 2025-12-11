import requests

def get_weather(city="London"):
    url = f"https://wttr.in/{city}?format=j1"

    print(f"🌦  Fetching weather for: {city}")
    try:
        response = requests.get(url, timeout=20)
        response.raise_for_status()
    except Exception as e:
        print("❌ Error fetching weather:", e)
        return

    data = response.json()

    # Extract important fields
    current = data["current_condition"][0]
    temp = current["temp_C"]
    feels = current["FeelsLikeC"]
    humidity = current["humidity"]
    desc = current["weatherDesc"][0]["value"]

    print(f"\nWeather in {city}:")
    print(f"🌡 Temperature : {temp}°C")
    print(f"🥵 Feels Like : {feels}°C")
    print(f"💧 Humidity    : {humidity}%")
    print(f"🌥 Condition   : {desc}")


if __name__ == "__main__":
    get_weather("New York")