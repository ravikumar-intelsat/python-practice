#!/bin/bash

# CRUD Service Project Setup Script
# This script creates a complete CRUD service project with FastAPI

set -e

PROJECT_NAME="crud-service"
CURRENT_DIR=$(pwd)

echo "🚀 Creating CRUD Service Project..."
echo "=================================="

# Create project directory
mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME"

echo "✅ Created project directory: $PROJECT_NAME"

# Create main.py
cat > main.py << 'EOF'
from fastapi import FastAPI, HTTPException
from fastapi.responses import JSONResponse
from typing import List, Optional
from pydantic import BaseModel, Field
from datetime import datetime
import json
import os

# Initialize FastAPI app with Swagger documentation
app = FastAPI(
    title="CRUD Service API",
    description="A simple CRUD service with in-memory JSON file storage",
    version="1.0.0",
    docs_url="/swagger",
    redoc_url="/redoc"
)

# JSON file path for data storage
DATA_FILE = "data.json"

# Pydantic models
class ItemCreate(BaseModel):
    name: str = Field(..., min_length=1, max_length=100, description="Item name")
    description: Optional[str] = Field(None, max_length=500, description="Item description")
    price: float = Field(..., gt=0, description="Item price (must be positive)")

class ItemUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=1, max_length=100)
    description: Optional[str] = Field(None, max_length=500)
    price: Optional[float] = Field(None, gt=0)

class Item(ItemCreate):
    id: int
    created_at: str
    updated_at: str

# Helper functions for JSON file operations
def load_data() -> List[dict]:
    """Load data from JSON file"""
    if os.path.exists(DATA_FILE):
        try:
            with open(DATA_FILE, 'r') as f:
                return json.load(f)
        except (json.JSONDecodeError, IOError):
            return []
    return []

def save_data(data: List[dict]) -> None:
    """Save data to JSON file"""
    with open(DATA_FILE, 'w') as f:
        json.dump(data, f, indent=2)

def get_next_id(data: List[dict]) -> int:
    """Get the next available ID"""
    if not data:
        return 1
    return max(item.get('id', 0) for item in data) + 1

# CRUD Operations
@app.get("/", tags=["Root"])
async def root():
    """Root endpoint"""
    return {
        "message": "Welcome to CRUD Service API",
        "docs": "/swagger",
        "redoc": "/redoc"
    }

@app.post("/items", response_model=Item, status_code=201, tags=["Items"])
async def create_item(item: ItemCreate):
    """Create a new item"""
    data = load_data()
    new_id = get_next_id(data)
    now = datetime.now().isoformat()
    
    new_item = {
        "id": new_id,
        "name": item.name,
        "description": item.description,
        "price": item.price,
        "created_at": now,
        "updated_at": now
    }
    
    data.append(new_item)
    save_data(data)
    return new_item

@app.get("/items", response_model=List[Item], tags=["Items"])
async def get_all_items():
    """Get all items"""
    data = load_data()
    return data

@app.get("/items/{item_id}", response_model=Item, tags=["Items"])
async def get_item(item_id: int):
    """Get a specific item by ID"""
    data = load_data()
    item = next((item for item in data if item.get('id') == item_id), None)
    
    if not item:
        raise HTTPException(status_code=404, detail=f"Item with ID {item_id} not found")
    
    return item

@app.put("/items/{item_id}", response_model=Item, tags=["Items"])
async def update_item(item_id: int, item_update: ItemUpdate):
    """Update an existing item"""
    data = load_data()
    item_index = next((i for i, item in enumerate(data) if item.get('id') == item_id), None)
    
    if item_index is None:
        raise HTTPException(status_code=404, detail=f"Item with ID {item_id} not found")
    
    # Update only provided fields
    existing_item = data[item_index]
    update_data = item_update.model_dump(exclude_unset=True)
    
    for key, value in update_data.items():
        existing_item[key] = value
    
    existing_item['updated_at'] = datetime.now().isoformat()
    save_data(data)
    
    return existing_item

@app.delete("/items/{item_id}", status_code=204, tags=["Items"])
async def delete_item(item_id: int):
    """Delete an item by ID"""
    data = load_data()
    item_index = next((i for i, item in enumerate(data) if item.get('id') == item_id), None)
    
    if item_index is None:
        raise HTTPException(status_code=404, detail=f"Item with ID {item_id} not found")
    
    data.pop(item_index)
    save_data(data)
    return None

@app.delete("/items", status_code=204, tags=["Items"])
async def delete_all_items():
    """Delete all items"""
    save_data([])
    return None

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
EOF

echo "✅ Created main.py"

# Create requirements.txt
cat > requirements.txt << 'EOF'
fastapi==0.104.1
uvicorn[standard]==0.24.0
pydantic==2.5.0
EOF

echo "✅ Created requirements.txt"

# Create README.md
cat > README.md << 'EOF'
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
EOF

echo "✅ Created README.md"

# Create .gitignore
cat > .gitignore << 'EOF'
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
venv/
env/
ENV/
.venv

# Data files
data.json

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db
EOF

echo "✅ Created .gitignore"

# Make setup.sh executable
chmod +x setup.sh

echo ""
echo "✨ Project setup complete!"
echo "=========================="
echo ""
echo "Next steps:"
echo "1. cd $PROJECT_NAME"
echo "2. python3 -m venv venv"
echo "3. source venv/bin/activate"
echo "4. pip install -r requirements.txt"
echo "5. uvicorn main:app --reload"
echo ""
echo "Then visit http://localhost:8000/swagger to see the API documentation!"

