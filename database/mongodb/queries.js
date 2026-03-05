// MongoDB Queries
// Run these inside mongosh after loading data

use("energy_db");

// Query 1: Latest record
// Returns the most recent hour of data in the collection
db.energy_hourly.findOne(
    {},
    { timestamp: 1, "price.actual": 1, "load.actual": 1, energy_summary: 1 },
    { sort: { timestamp: -1 } }
);

// Query 2: Records by date range
// Returns first 5 hours of January 2015
db.energy_hourly.find(
    {
        timestamp: {
            $gte: new Date("2015-01-01T00:00:00Z"),
            $lte: new Date("2015-01-07T23:00:00Z")
        }
    },
    {
        timestamp: 1,
        "price.actual": 1,
        "load.actual": 1,
        "energy_summary.total_renewable_mw": 1,
        "energy_summary.total_fossil_mw": 1
    }
).sort({ timestamp: 1 }).limit(5);

// Query 3: Peak solar generation hours
// Returns top 5 hours with highest solar output
db.energy_hourly.find(
    { "generation.solar.mw": { $gt: 4000 } },
    { timestamp: 1, "generation.solar": 1, "price.actual": 1 }
).sort({ "generation.solar.mw": -1 }).limit(5);

// Query 4: Yearly summary — price, load, renewable vs fossil
// Aggregates average price, load and generation mix per year
db.energy_hourly.aggregate([
    {
        $group: {
            _id: { year: { $year: "$timestamp" } },
            avg_price:     { $avg: "$price.actual" },
            avg_load:      { $avg: "$load.actual" },
            avg_renewable: { $avg: "$energy_summary.total_renewable_mw" },
            avg_fossil:    { $avg: "$energy_summary.total_fossil_mw" }
        }
    },
    {
        $project: {
            _id: 0,
            year:          "$_id.year",
            avg_price:     { $round: ["$avg_price",     2] },
            avg_load:      { $round: ["$avg_load",      2] },
            avg_renewable: { $round: ["$avg_renewable", 2] },
            avg_fossil:    { $round: ["$avg_fossil",    2] }
        }
    },
    { $sort: { year: 1 } }
]);

// Query 5: Hours where renewables outperformed fossil generation
// Counts renewable-dominant hours per year and avg price during those hours
db.energy_hourly.aggregate([
    {
        $match: {
            $expr: {
                $gt: ["$energy_summary.total_renewable_mw",
                      "$energy_summary.total_fossil_mw"]
            }
        }
    },
    {
        $group: {
            _id: { year: { $year: "$timestamp" } },
            hours_renewable_dominant:           { $sum: 1 },
            avg_price_when_renewable_dominates: { $avg: "$price.actual" }
        }
    },
    {
        $project: {
            _id: 0,
            year:                               "$_id.year",
            hours_renewable_dominant:           1,
            avg_price_when_renewable_dominates: {
                $round: ["$avg_price_when_renewable_dominates", 2]
            }
        }
    },
    { $sort: { year: 1 } }
]);
