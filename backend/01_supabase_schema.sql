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
