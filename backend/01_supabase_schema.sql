-- ============================================================
-- PHARMA FINDER — SUPABASE DATABASE SCHEMA
-- Run this ONCE in Supabase SQL Editor (supabase.com → SQL Editor)
-- ============================================================

-- Step 1: Enable PostGIS (needed for location queries)
CREATE EXTENSION IF NOT EXISTS postgis;

-- ============================================================
-- TABLES
-- ============================================================

-- Pharmacies
CREATE TABLE pharmacies (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name        TEXT NOT NULL,
    latitude    DOUBLE PRECISION NOT NULL,
    longitude   DOUBLE PRECISION NOT NULL,
    is_open     BOOLEAN NOT NULL DEFAULT TRUE,
    location    GEOGRAPHY(POINT, 4326) NOT NULL,
    created_at  TIMESTAMPTZ DEFAULT now()
);

-- Auto-set geography column from lat/lng
CREATE OR REPLACE FUNCTION set_pharmacy_location()
RETURNS TRIGGER AS $$
BEGIN
    NEW.location := ST_SetSRID(ST_MakePoint(NEW.longitude, NEW.latitude), 4326)::geography;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_pharmacy_location
    BEFORE INSERT OR UPDATE OF latitude, longitude ON pharmacies
    FOR EACH ROW EXECUTE FUNCTION set_pharmacy_location();

-- Medicines (generic drugs like "Paracetamol", "Amoxicillin")
CREATE TABLE medicines (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    generic_name    TEXT NOT NULL UNIQUE,
    created_at      TIMESTAMPTZ DEFAULT now()
);

-- Brands (commercial names like "Panadol" → Paracetamol)
CREATE TABLE brands (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    medicine_id     UUID NOT NULL REFERENCES medicines(id) ON DELETE CASCADE,
    brand_name      TEXT NOT NULL,
    created_at      TIMESTAMPTZ DEFAULT now()
);

-- Inventory (what each pharmacy stocks)
CREATE TABLE inventory (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    pharmacy_id     UUID NOT NULL REFERENCES pharmacies(id) ON DELETE CASCADE,
    brand_id        UUID NOT NULL REFERENCES brands(id) ON DELETE CASCADE,
    price           NUMERIC(10, 2) NOT NULL CHECK (price > 0),
    quantity        INTEGER NOT NULL DEFAULT 0 CHECK (quantity >= 0),
    updated_at      TIMESTAMPTZ DEFAULT now(),
    UNIQUE (pharmacy_id, brand_id)
);
