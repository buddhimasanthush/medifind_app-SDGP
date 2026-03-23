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
