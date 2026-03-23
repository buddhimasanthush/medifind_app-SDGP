# Integration Prompt — Pharmacy Search Algorithm into Vello Flutter App

> Give this entire document to Claude/ChatGPT/Cursor when integrating the pharmacy search feature into the Flutter mobile application.

---

## Context

We are building **Vello**, a personal finance management Flutter mobile application targeting the Sri Lankan market. We have added a **pharmacy search feature** that helps users find the cheapest nearby pharmacy for their medicine list.

**Our stack:**
- **Frontend:** Flutter (Dart) — features-based architecture
- **Backend:** Python (FastAPI), hosted on **Railway**
- **Database:** **Supabase** (PostgreSQL with PostGIS enabled)
- **Auth:** Supabase OTP email authentication (already implemented)

The pharmacy search algorithm is **already built and ready**. Your job is to integrate it into the Flutter app and connect it to the existing Python backend.

---

## What already exists (DO NOT rebuild these)

### 1. Supabase database tables (already created via SQL)

```
pharmacies (id, name, latitude, longitude, is_open, location)
medicines  (id, generic_name)
brands     (id, medicine_id, brand_name)
inventory  (id, pharmacy_id, brand_id, price, quantity)
```

There is also a Supabase RPC function called `search_pharmacies` that takes user location + medicine list and returns the optimal pharmacy results. **The Python backend calls this function — the Flutter app does NOT call it directly.**

### 2. Python backend file: `pharmacy_search.py`

This file contains:
- `search_pharmacies(latitude, longitude, medicines, radius_meters)` — async function that calls the Supabase RPC and returns structured results
- `response_to_dict(response)` — converts the result to a JSON-serializable dictionary
- Data classes: `MedicineRequest`, `PharmacyResult`, `SelectedItem`, `SearchResponse`

**The backend is deployed on Railway** with these env vars already set:
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

---

## What you need to build

### A. Backend: Add the API endpoint to the existing Railway Python server

Add a new POST endpoint to the existing FastAPI app:

**Endpoint:** `POST /api/search-pharmacy`

**Request body:**
```json
{
  "latitude": 6.9271,
  "longitude": 79.8612,
  "radius_meters": 7000,
  "medicines": [
    { "medicine_id": "uuid-string", "quantity": 2 },
    { "medicine_id": "uuid-string", "quantity": 1 }
  ]
}
```

**Response body (success — full match):**
```json
{
  "best_match": {
    "pharmacy_id": "uuid",
    "pharmacy_name": "City Pharmacy",
    "distance_meters": 1234.5,
    "is_full_match": true,
    "matched_medicines": 2,
    "total_required": 2,
    "total_price": 850.00,
    "items": [
      {
        "medicine_id": "uuid",
        "brand_id": "uuid",
        "brand_name": "Panadol",
        "price": 350.00,
        "quantity": 2
      }
    ]
  },
  "alternatives": [ ... ],
  "partial_matches": [],
  "suggestion": null
}
```

**Response body (no full match — partial results):**
```json
{
  "best_match": null,
  "alternatives": [],
  "partial_matches": [
    {
      "pharmacy_id": "uuid",
      "pharmacy_name": "MediPlus",
      "distance_meters": 2100.3,
      "is_full_match": false,
      "matched_medicines": 1,
      "total_required": 2,
      "total_price": 350.00,
      "items": [ ... ]
    }
  ],
  "suggestion": "No single pharmacy has all 2 medicines. MediPlus covers 1/2. Consider splitting your order across pharmacies."
}
```

**Implementation:**
```python
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from pharmacy_search import search_pharmacies, MedicineRequest, response_to_dict

class SearchRequestBody(BaseModel):
    latitude: float
    longitude: float
    radius_meters: int = 7000
    medicines: list[dict]

@app.post("/api/search-pharmacy")
async def search_pharmacy(body: SearchRequestBody):
    try:
        meds = [
            MedicineRequest(m["medicine_id"], m["quantity"])
            for m in body.medicines
        ]
        result = await search_pharmacies(
            latitude=body.latitude,
            longitude=body.longitude,
            medicines=meds,
            radius_meters=body.radius_meters,
        )
        return response_to_dict(result)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
```

Make sure `httpx` is in `requirements.txt`.
