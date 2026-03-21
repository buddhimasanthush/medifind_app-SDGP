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

module.exports = router;
