// MongoDB Collection Design
// Database: energy_db
// Collection: energy_hourly

// DESIGN RATIONALE:
// Each document represents one hour of grid data.
// Load, price, and all 20 generation sources are embedded
// in a single document — no joins needed.
// The energy_summary field pre-computes renewable vs fossil
// totals per hour for efficient querying.
// Timestamps are stored in UTC — raw CSV contained timezone
// offsets (+01:00) which were stripped during loading.

// SAMPLE DOCUMENT
{
    timestamp: ISODate("2015-01-01T00:00:00Z"),
    load: {
        actual:   25385,
        forecast: 26118
    },
    price: {
        actual:    65.41,
        day_ahead: 50.1
    },
    generation: {
        biomass:                   { mw: 447  },
        fossil_brown_coal:         { mw: 329  },
        fossil_coal_derived_gas:   { mw: 0    },
        fossil_gas:                { mw: 4844 },
        fossil_hard_coal:          { mw: 4821 },
        fossil_oil:                { mw: 162  },
        fossil_oil_shale:          { mw: 0    },
        fossil_peat:               { mw: 0    },
        geothermal:                { mw: 0    },
        hydro_pumped_storage_cons: { mw: 863  },
        hydro_run_of_river:        { mw: 1051 },
        hydro_water_reservoir:     { mw: 1899 },
        marine:                    { mw: 0    },
        nuclear:                   { mw: 7096 },
        other:                     { mw: 43   },
        other_renewable:           { mw: 73   },
        solar:                     { mw: 49,  forecast_mw: 17   },
        waste:                     { mw: 196  },
        wind_offshore:             { mw: 0    },
        wind_onshore:              { mw: 6378, forecast_mw: 6436 }
    },
    energy_summary: {
        total_renewable_mw:  9897,
        total_fossil_mw:     10156,
        total_generation_mw: 28251
    }
}
