# CRUD Service API

A simple CRUD (Create, Read, Update, Delete) service built with FastAPI and in-memory JSON file storage.

## Features

- ✅ Full CRUD operations for items
- ✅ FastAPI with automatic Swagger documentation
- ✅ In-memory JSON file storage
- ✅ Pydantic models for data validation
- ✅ RESTful API design

## Installation

1. Create a virtual environment (recommended):
```bash
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

2. Install dependencies:
```bash
pip install -r requirements.txt
```

## Running the Application

Start the server:
```bash
uvicorn main:app --reload
```

Or run directly:
```bash
python main.py
```

The API will be available at:
- **API**: http://localhost:8000
- **Swagger UI**: http://localhost:8000/swagger
- **ReDoc**: http://localhost:8000/redoc

## API Endpoints

### Root
- `GET /` - Welcome message and API information

### Items
- `POST /items` - Create a new item
- `GET /items` - Get all items
- `GET /items/{item_id}` - Get a specific item by ID
- `PUT /items/{item_id}` - Update an item
- `DELETE /items/{item_id}` - Delete an item by ID
- `DELETE /items` - Delete all items

## Example Usage

### Create an item
```bash
curl -X POST "http://localhost:8000/items" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Laptop",
    "description": "High-performance laptop",
    "price": 999.99
  }'
```

### Get all items
```bash
curl "http://localhost:8000/items"
```

### Get a specific item
```bash
curl "http://localhost:8000/items/1"
```

### Update an item
```bash
curl -X PUT "http://localhost:8000/items/1" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Gaming Laptop",
    "price": 1299.99
  }'
```

### Delete an item
```bash
curl -X DELETE "http://localhost:8000/items/1"
```

## Data Storage

Data is stored in a `data.json` file in the project root. This file is automatically created when you create your first item.

## Project Structure

```
crud-service/
├── main.py           # FastAPI application and CRUD endpoints
├── requirements.txt  # Python dependencies
├── README.md        # This file
├── setup.sh         # Project setup script
└── data.json        # JSON data file (created automatically)
```

## License

MIT
