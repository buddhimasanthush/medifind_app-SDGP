"""
example_endpoint.py — Shows how to use pharmacy_search.py in your backend.

Copy the relevant parts into your existing route file.
Works with FastAPI, Flask, or any Python framework.
"""

# ════════════════════════════════════════════════════
# OPTION A: FastAPI (recommended for async)
# ════════════════════════════════════════════════════

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from pharmacy_search import (
    search_pharmacies,
    MedicineRequest,
    response_to_dict,
)

app = FastAPI()


class SearchRequestBody(BaseModel):
    latitude: float
    longitude: float
    radius_meters: int = 7000
    medicines: list[dict]  # [{"medicine_id": "uuid", "quantity": 2}]


@app.post("/api/search-pharmacy")
async def search_pharmacy(body: SearchRequestBody):
    try:
        meds = [
            MedicineRequest(
                medicine_id=m["medicine_id"],
                quantity=m["quantity"],
            )
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


# ════════════════════════════════════════════════════
# OPTION B: Flask (if you're using Flask)
# ════════════════════════════════════════════════════

# import asyncio
# from flask import Flask, request, jsonify
#
# app = Flask(__name__)
#
# @app.route("/api/search-pharmacy", methods=["POST"])
# def search_pharmacy():
#     body = request.get_json()
#     meds = [
#         MedicineRequest(m["medicine_id"], m["quantity"])
#         for m in body["medicines"]
#     ]
#     result = asyncio.run(search_pharmacies(
#         latitude=body["latitude"],
#         longitude=body["longitude"],
#         medicines=meds,
#         radius_meters=body.get("radius_meters", 7000),
#     ))
#     return jsonify(response_to_dict(result))
