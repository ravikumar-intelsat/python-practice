import requests
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry

def get_weather(city="London"):
    if not city:
        print("❌ No city provided!")
        return

    url = f"https://wttr.in/{city}?format=j1"
    print(f"🌦  Fetching weather for: {city}")

    # Retry setup
    session = requests.Session()
    retry = Retry(
        total=5,                # Retry 5 times if request fails
        backoff_factor=1,       # Wait 1s, 2s, 4s...
        status_forcelist=[500, 502, 503, 504]
    )
    adapter = HTTPAdapter(max_retries=retry)
    session.mount("https://", adapter)

    try:
        response = session.get(url, timeout=15)  # Increased timeout
        response.raise_for_status()
    except requests.exceptions.Timeout:
        print("❌ Error: The request timed out.")
        return
    except requests.exceptions.ConnectionError:
        print("❌ Error: Failed to connect to wttr.in (network issue).")
        return
    except Exception as e:
        print("❌ Error fetching weather:", e)
        return

    try:
        data = response.json()
    except ValueError:
        print("❌ Error: Failed to parse JSON from wttr.in")
        return

    # Extract info safely
    try:
        current = data["current_condition"][0]
        temp = current.get("temp_C", "N/A")
        feels = current.get("FeelsLikeC", "N/A")
        humidity = current.get("humidity", "N/A")
        desc = current.get("weatherDesc", [{"value": "N/A"}])[0]["value"]
    except Exception:
        print("❌ Error: Unexpected data format from wttr.in")
        return

    print(f"\nWeather in {city}:")
    print(f"🌡 Temperature : {temp}°C")
    print(f"🥵 Feels Like : {feels}°C")
    print(f"💧 Humidity    : {humidity}%")
    print(f"🌥 Condition   : {desc}")


if __name__ == "__main__":
    get_weather("New York")
