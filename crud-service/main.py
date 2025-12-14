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
