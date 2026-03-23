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

-- ============================================================
-- INDEXES (these make the algorithm fast)
-- ============================================================

-- Spatial index — makes ST_DWithin use the index, not scan every row
CREATE INDEX idx_pharmacies_location ON pharmacies USING GIST (location);

-- Only query open pharmacies
CREATE INDEX idx_pharmacies_open ON pharmacies (is_open) WHERE is_open = TRUE;

-- Brand → medicine lookup
CREATE INDEX idx_brands_medicine ON brands (medicine_id);

-- Inventory: the main workhorse index
CREATE INDEX idx_inventory_pharm_brand ON inventory (pharmacy_id, brand_id);

-- Price lookup optimization
CREATE INDEX idx_inventory_pharm_brand_price ON inventory (pharmacy_id, brand_id, price);

-- ============================================================
-- SUPABASE RPC FUNCTION (the actual algorithm)
-- This is what your Python backend calls
-- ============================================================

CREATE OR REPLACE FUNCTION search_pharmacies(
    user_lng    DOUBLE PRECISION,
    user_lat    DOUBLE PRECISION,
    radius_m    INTEGER DEFAULT 7000,
    med_ids     UUID[] DEFAULT '{}',
    med_qtys    INTEGER[] DEFAULT '{}',
    total_meds  INTEGER DEFAULT 0,
    max_results INTEGER DEFAULT 10
)
RETURNS TABLE (
    pharmacy_id       UUID,
    pharmacy_name     TEXT,
    distance_meters   NUMERIC,
    matched_medicines INTEGER,
    total_required    INTEGER,
    is_full_match     BOOLEAN,
    total_price       NUMERIC,
    items             JSONB
)
LANGUAGE sql STABLE
AS $$
    WITH
    -- Step 1: Find nearby OPEN pharmacies using spatial index
    nearby AS (
        SELECT
            p.id,
            p.name,
            ST_Distance(
                p.location,
                ST_SetSRID(ST_MakePoint(user_lng, user_lat), 4326)::geography
            ) AS dist
        FROM pharmacies p
        WHERE p.is_open = TRUE
          AND ST_DWithin(
                p.location,
                ST_SetSRID(ST_MakePoint(user_lng, user_lat), 4326)::geography,
                radius_m
              )
    ),
