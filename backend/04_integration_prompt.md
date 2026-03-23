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
