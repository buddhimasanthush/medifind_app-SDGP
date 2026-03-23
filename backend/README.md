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
