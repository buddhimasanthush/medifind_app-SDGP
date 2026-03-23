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

---

### B. Flutter: Build the pharmacy search feature screens

Follow the existing **features-based architecture** in the Vello app. Create a new feature folder:

```
lib/
  features/
    pharmacy_search/
      data/
        pharmacy_search_repository.dart
      models/
        pharmacy_result.dart
        medicine_request.dart
        search_response.dart
      screens/
        pharmacy_search_screen.dart
        pharmacy_result_screen.dart
      widgets/
        medicine_selector.dart
        pharmacy_card.dart
```

#### B1. Models

**`medicine_request.dart`**
```dart
class MedicineRequest {
  final String medicineId;
  final int quantity;

  MedicineRequest({required this.medicineId, required this.quantity});

  Map<String, dynamic> toJson() => {
    'medicine_id': medicineId,
    'quantity': quantity,
  };
}
```

**`pharmacy_result.dart`**
```dart
class SelectedItem {
  final String medicineId;
  final String brandId;
  final String brandName;
  final double price;
  final int quantity;

  SelectedItem({
    required this.medicineId,
    required this.brandId,
    required this.brandName,
    required this.price,
    required this.quantity,
  });

  factory SelectedItem.fromJson(Map<String, dynamic> json) => SelectedItem(
    medicineId: json['medicine_id'],
    brandId: json['brand_id'],
    brandName: json['brand_name'],
    price: (json['price'] as num).toDouble(),
    quantity: json['quantity'],
  );
}

class PharmacyResult {
  final String pharmacyId;
  final String pharmacyName;
  final double distanceMeters;
  final bool isFullMatch;
  final int matchedMedicines;
  final int totalRequired;
  final double totalPrice;
  final List<SelectedItem> items;

  PharmacyResult({
    required this.pharmacyId,
    required this.pharmacyName,
    required this.distanceMeters,
    required this.isFullMatch,
    required this.matchedMedicines,
    required this.totalRequired,
    required this.totalPrice,
    required this.items,
  });

  factory PharmacyResult.fromJson(Map<String, dynamic> json) => PharmacyResult(
    pharmacyId: json['pharmacy_id'],
    pharmacyName: json['pharmacy_name'],
    distanceMeters: (json['distance_meters'] as num).toDouble(),
    isFullMatch: json['is_full_match'],
    matchedMedicines: json['matched_medicines'],
    totalRequired: json['total_required'],
    totalPrice: (json['total_price'] as num).toDouble(),
    items: (json['items'] as List)
        .map((i) => SelectedItem.fromJson(i))
        .toList(),
  );
}
```

**`search_response.dart`**
```dart
class SearchResponse {
  final PharmacyResult? bestMatch;
  final List<PharmacyResult> alternatives;
  final List<PharmacyResult> partialMatches;
  final String? suggestion;

  SearchResponse({
    this.bestMatch,
    this.alternatives = const [],
    this.partialMatches = const [],
    this.suggestion,
  });

  factory SearchResponse.fromJson(Map<String, dynamic> json) => SearchResponse(
    bestMatch: json['best_match'] != null
        ? PharmacyResult.fromJson(json['best_match'])
        : null,
    alternatives: (json['alternatives'] as List? ?? [])
        .map((a) => PharmacyResult.fromJson(a))
        .toList(),
    partialMatches: (json['partial_matches'] as List? ?? [])
        .map((p) => PharmacyResult.fromJson(p))
        .toList(),
    suggestion: json['suggestion'],
  );

  bool get hasFullMatch => bestMatch != null;
}
```

#### B2. Repository

**`pharmacy_search_repository.dart`**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class PharmacySearchRepository {
  // Replace with your Railway backend URL
  static const String _baseUrl = 'https://your-railway-app.up.railway.app';

  Future<SearchResponse> searchPharmacies({
    required double latitude,
    required double longitude,
    required List<MedicineRequest> medicines,
    int radiusMeters = 7000,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/search-pharmacy'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'latitude': latitude,
        'longitude': longitude,
        'radius_meters': radiusMeters,
        'medicines': medicines.map((m) => m.toJson()).toList(),
      }),
    );

    if (response.statusCode == 200) {
      return SearchResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Search failed: ${response.statusCode}');
    }
  }
}
```

#### B3. Screens — what they should do

**`pharmacy_search_screen.dart`** (the main screen):
1. Get user's current location using `geolocator` package
2. Show a medicine selector — user picks medicines from a searchable list (query the `medicines` table from Supabase directly for autocomplete) and sets quantity for each
3. "Search" button calls the repository
4. Show a loading indicator while searching
5. Navigate to result screen with the response

**`pharmacy_result_screen.dart`** (results):
1. If `response.hasFullMatch`:
   - Show the best pharmacy as a highlighted card (name, distance in km, total price in LKR)
   - Show the items list (brand name, price × quantity)
   - Below that, show alternatives as smaller cards
2. If `!response.hasFullMatch`:
   - Show the suggestion text prominently
   - Show partial matches as cards with a "X/Y medicines available" badge
3. Optional: show pharmacy location on a map using `google_maps_flutter`

**`pharmacy_card.dart`** (reusable widget):
- Shows: pharmacy name, distance (convert meters to km: `(distance / 1000).toStringAsFixed(1)` km), total price in LKR
- Badge: "All medicines available" (green) or "3/5 available" (orange)
- Expandable section showing the item-by-item breakdown

---

### C. Flutter: Medicine selector

The user needs to search and select medicines. Query the `medicines` table from Supabase directly (this is just a simple lookup, not the search algorithm):

```dart
// In the Flutter app — fetch medicine list for autocomplete
final response = await Supabase.instance.client
    .from('medicines')
    .select('id, generic_name')
    .ilike('generic_name', '%$query%')
    .limit(20);
```

Use a `SearchableDropdown` or `TypeAheadField` widget. Each selected medicine gets a quantity stepper (default 1).

---

### D. Permissions

The Flutter app needs location permission. Add to `AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

And to `Info.plist` for iOS:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to find nearby pharmacies</string>
```

Use the `geolocator` package to get current position:
```dart
final position = await Geolocator.getCurrentPosition(
  desiredAccuracy: LocationAccuracy.high,
);
// position.latitude, position.longitude
```
