const express = require("express");
const router = express.Router();
const { Doctor } = require("../models");

// GET all doctors
router.get("/", async (req, res) => {
  try {
    const doctors = await Doctor.findAll();
    res.json(doctors);
  } catch (err) {
    res.status(500).json({ error: "Something went wrong" });
  }
});

// GET doctor by id
router.get("/:id", async (req, res) => {
  try {
    const doctor = await Doctor.findByPk(req.params.id);
    if (!doctor) return res.status(404).json({ error: "Doctor not found" });
    res.json(doctor);
  } catch (err) {
    res.status(500).json({ error: "Something went wrong" });
  }
});

// CREATE doctor
router.post("/", async (req, res) => {
  try {
    const newDoctor = await Doctor.create(req.body);
    res.status(201).json(newDoctor);
  } catch (err) {
    res.status(500).json({ error: "Something went wrong" });
  }
});

module.exports = router;
