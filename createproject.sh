#!/bin/sh

# --- CONFIG ---
PROJECT_NAME=${1:-myproject}

echo "🚀 Creating Python project: $PROJECT_NAME"

# 1. Create project structure
mkdir -p "$PROJECT_NAME/src"

# 2. Create virtual environment
echo "📦 Creating .venv..."
python3 -m venv "$PROJECT_NAME/.venv"

# 3. Activate virtual environment
echo "⚡ Activating .venv..."
. "$PROJECT_NAME/.venv/bin/activate"

# 4. Create meaningful Python example (Weather fetcher)
cat > "$PROJECT_NAME/src/main.py" << 'EOF'
import requests

def get_weather(city="London"):
    url = f"https://wttr.in/{city}?format=j1"

    print(f"🌦  Fetching weather for: {city}")
    try:
        response = requests.get(url, timeout=5)
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
EOF

# 5. Create requirements.txt
echo "requests==2.31.0" > "$PROJECT_NAME/requirements.txt"

# 6. Install dependencies
pip install --upgrade pip
pip install -r "$PROJECT_NAME/requirements.txt"

# 7. Instructions
echo "✅ Project created successfully!"
echo
echo "📁 Folder structure:"
echo "$PROJECT_NAME/"
echo "  ├── src/main.py      ← meaningful sample: fetch weather"
echo "  ├── .venv/"
echo "  ├── requirements.txt"
echo
echo "👉 Activate:"
echo "     source $PROJECT_NAME/.venv/bin/activate"
echo
echo "👉 Run the app:"
echo "     python3 $PROJECT_NAME/src/main.py"
echo
echo "🎉 Done!"
