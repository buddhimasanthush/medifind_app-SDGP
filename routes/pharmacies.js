const express = require("express");
const router = express.Router();
const db = require("../models");
const { Pharmacy } = db;


router.get("/nearby", async (req, res) => {
  try {
    const lat = Number(req.query.lat);
    const lng = Number(req.query.lng);

    
    const minResults = Number(req.query.minResults ?? 1);

    // validate input
    if (!Number.isFinite(lat) || !Number.isFinite(lng)) {
      return res.status(400).json({ error: "lat and lng are required numbers" });
    }
    if (!Number.isFinite(minResults) || minResults < 1) {
      return res.status(400).json({ error: "minResults must be a number >= 1" });
    }

    // 1km -> 10km radii 
    const radiiKm = [1, 2, 3, 4, 5, 7, 10];

    
    const pharmacies = await Pharmacy.findAll();

   
    const withDistance = pharmacies
      .map((p) => {
        const plat = Number(p.latitude);
        const plng = Number(p.longitude);

        
        if (!Number.isFinite(plat) || !Number.isFinite(plng)) return null;

        const distanceKm = haversineKm(lat, lng, plat, plng);
        return { ...p.toJSON(), distanceKm };
      })
      .filter(Boolean)
      .sort((a, b) => a.distanceKm - b.distanceKm);

    
    let final = [];
    let usedRadiusKm = null;

    for (const rKm of radiiKm) {
      final = withDistance.filter((x) => x.distanceKm <= rKm).slice(0, 50);
      usedRadiusKm = rKm;

      
      if (final.length >= minResults) break;
    }

    
    if (final.length === 0) {
      return res.json({
        radiusUsedKm: null,
        radiusKm: null, 
        count: 0,
        pharmacies: [],
      });
    }

    return res.json({
      radiusUsedKm: usedRadiusKm, 
      radiusKm: usedRadiusKm,     
      count: final.length,
      pharmacies: final,
    });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: "Something went wrong" });
  }
});

// ✅ helper function for distance (km)
function haversineKm(lat1, lon1, lat2, lon2) {
  const R = 6371; // earth radius in km
  const toRad = (x) => (x * Math.PI) / 180;

  const dLat = toRad(lat2 - lat1);
  const dLon = toRad(lon2 - lon1);

  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(toRad(lat1)) *
      Math.cos(toRad(lat2)) *
      Math.sin(dLon / 2) *
      Math.sin(dLon / 2);

  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}



router.get("/", async (req, res) => {
  try {
    const pharmacies = await Pharmacy.findAll();
    res.json(pharmacies);
  } catch (err) {
    res.status(500).json({ error: "Something went wrong" });
  }
});
router.get("/search-medicine", async (req, res) => {
  try {

    const { name, lat, lng } = req.query;

    if (!name || !lat || !lng) {
      return res.status(400).json({
        error: "name, lat, lng required"
      });
    }

    const medicine = await db.Medicine.findOne({
      where: { name }
    });

    if (!medicine) {
      return res.json({
        message: "Medicine not found"
      });
    }

    const inventories = await db.Inventory.findAll({
      where: { medicineId: medicine.id },
      include: [
        { model: db.Pharmacy }
      ]
    });

    const results = inventories.map(item => {

      const pharmacy = item.Pharmacy;

      const distance = haversineKm(
        Number(lat),
        Number(lng),
        Number(pharmacy.latitude),
        Number(pharmacy.longitude)
      );

      return {
        pharmacyName: pharmacy.name,
        address: pharmacy.address,
        medicine: medicine.name,
        price: item.price,
        quantity: item.quantity,
        distanceKm: distance
      };

    }).sort((a,b)=>a.distanceKm-b.distanceKm);

    res.json(results);

  } catch (error) {

    console.error(error);

    res.status(500).json({
      error: "Search failed"
    });

  }
});

router.get("/:id", async (req, res) => {
  try {
    const pharmacy = await Pharmacy.findByPk(req.params.id);
    if (!pharmacy) return res.status(404).json({ error: "Pharmacy not found" });
    res.json(pharmacy);
  } catch (err) {
    res.status(500).json({ error: "Something went wrong" });
  }
});

router.post("/", async (req, res) => {
  try {
    const newPharmacy = await Pharmacy.create(req.body);
    res.status(201).json(newPharmacy);
  } catch (err) {
    res.status(500).json({ error: "Something went wrong" });
  }
});

router.put("/:id", async (req, res) => {
  try {
    const pharmacy = await Pharmacy.findByPk(req.params.id);
    if (!pharmacy) return res.status(404).json({ error: "Pharmacy not found" });
    await pharmacy.update(req.body);
    res.json(pharmacy);
  } catch (err) {
    res.status(500).json({ error: "Something went wrong" });
  }
});

router.delete("/:id", async (req, res) => {
  try {
    const pharmacy = await Pharmacy.findByPk(req.params.id);
    if (!pharmacy) return res.status(404).json({ error: "Pharmacy not found" });
    await pharmacy.destroy();
    res.json({ message: "Pharmacy deleted" });
  } catch (err) {
    res.status(500).json({ error: "Something went wrong" });
  }
});

module.exports = router;