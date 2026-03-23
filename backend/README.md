# Pharmacy Search Algorithm

Find the cheapest nearby pharmacy for a list of medicines — in **one database call**.

---

## What's in this folder

| File | What it is | Where it goes |
|------|-----------|---------------|
| `01_supabase_schema.sql` | Database tables, indexes, and the search function | Run once in **Supabase SQL Editor** |
| `02_pharmacy_search.py` | The Python algorithm (single file) | Add to your **Railway Python backend** |
| `03_example_endpoint.py` | Shows how to wire it into FastAPI/Flask | Reference — copy what you need |
| `04_integration_prompt.md` | Detailed prompt for your Flutter developer | Give to teammate as-is |

---

## How the algorithm works

```
User sends: { lat, lng, medicines: [{id, qty}, ...] }
                    │
                    ▼
        Python backend (Railway)
        Calls ONE Supabase RPC function
                    │
                    ▼
      ┌─────────────────────────────────┐
      │   PostgreSQL does EVERYTHING:   │
      │                                 │
      │  1. ST_DWithin → nearby open    │
      │     pharmacies (spatial index)  │
      │                                 │
      │  2. JOIN inventory + brands     │
      │     → find matching stock       │
      │                                 │
      │  3. DISTINCT ON → cheapest      │
      │     brand per medicine          │
      │                                 │
      │  4. GROUP BY pharmacy           │
      │     → total price, item list    │
      │                                 │
      │  5. ORDER BY full_match,        │
      │     price ASC, distance ASC     │
      └─────────────────────────────────┘
                    │
                    ▼
        Python splits results into:
        - best_match (cheapest full match)
        - alternatives (other full matches)
        - partial_matches (if no full match)
        - suggestion (helpful text)
                    │
                    ▼
        JSON response → Flutter app
```

---

## Setup steps

### 1. Supabase (one-time)

1. Go to your Supabase project → **SQL Editor**
2. Paste the entire contents of `01_supabase_schema.sql`
3. Click **Run**
4. Verify: go to **Table Editor** — you should see 4 tables: `pharmacies`, `medicines`, `brands`, `inventory`

### 2. Railway (backend)

1. Add `02_pharmacy_search.py` to your existing Python project
2. Set these **environment variables** in Railway:
   - `SUPABASE_URL` → your Supabase project URL (e.g. `https://xxxxx.supabase.co`)
   - `SUPABASE_ANON_KEY` → your Supabase anon key
3. Add `httpx` to your `requirements.txt` if not already there
4. Import and use the `search_pharmacies()` function in your API endpoint (see `03_example_endpoint.py`)

### 3. Flutter app

Give `04_integration_prompt.md` to whoever is building the Flutter frontend. It explains exactly what API to call and what response to expect.

---

## Database structure

```
pharmacies
├── id (UUID, auto-generated)
├── name ("City Pharmacy")
├── latitude (6.9271)
├── longitude (79.8612)
├── is_open (true/false)
└── location (auto-set from lat/lng — DO NOT set manually)

medicines
├── id (UUID)
└── generic_name ("Paracetamol")

brands
├── id (UUID)
├── medicine_id → medicines.id
└── brand_name ("Panadol")

inventory
├── id (UUID)
├── pharmacy_id → pharmacies.id
├── brand_id → brands.id
├── price (350.00)
└── quantity (50)
```

**Key relationship:** medicine → has many brands → each brand stocked at pharmacies via inventory.

Example: "Paracetamol" (medicine) → "Panadol", "Calpol", "Tylenol" (brands) → each pharmacy has different brands at different prices.

---

## API request/response

### Request
```json
POST /api/search-pharmacy

{
  "latitude": 6.9271,
  "longitude": 79.8612,
  "radius_meters": 7000,
  "medicines": [
    { "medicine_id": "uuid-of-paracetamol", "quantity": 2 },
    { "medicine_id": "uuid-of-amoxicillin", "quantity": 1 }
  ]
}
```

### Response (full match found)
```json
{
  "best_match": {
    "pharmacy_id": "abc-123",
    "pharmacy_name": "City Pharmacy",
    "distance_meters": 1234.5,
    "is_full_match": true,
    "matched_medicines": 2,
    "total_required": 2,
    "total_price": 850.00,
    "items": [
      {
        "medicine_id": "uuid-paracetamol",
        "brand_id": "uuid-panadol",
        "brand_name": "Panadol",
        "price": 350.00,
        "quantity": 2
      },
      {
        "medicine_id": "uuid-amoxicillin",
        "brand_id": "uuid-amoxil",
        "brand_name": "Amoxil",
        "price": 150.00,
        "quantity": 1
      }
    ]
  },
  "alternatives": [],
  "partial_matches": [],
  "suggestion": null
}
```

### Response (no full match)
```json
{
  "best_match": null,
  "alternatives": [],
  "partial_matches": [
    {
      "pharmacy_id": "def-456",
      "pharmacy_name": "MediPlus",
      "distance_meters": 2100.3,
      "is_full_match": false,
      "matched_medicines": 1,
      "total_required": 2,
      "total_price": 350.00,
      "items": [...]
    }
  ],
  "suggestion": "No single pharmacy has all 2 medicines. MediPlus covers 1/2. Consider splitting your order across pharmacies."
}
```
