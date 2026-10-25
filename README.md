# PDAL Cookbook

<!-- ZQM-START -->
<!-- markdownlint-disable MD033 -->
<p align="center">
  <strong>ZQM Computing — Geospatial Engineering & Scientific Computing</strong><br>
  <a href="https://github.com/ZQM-Computing">ZQM Computing</a>
</p>
<!-- markdownlint-enable MD033 -->
<!-- ZQM-END -->

![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)

A **PDAL cookbook** for point-cloud pipelines, translation, and pgPointCloud ingest. Patterns are drawn from the ZQM fleet's PDAL 2.10.0 installs (bundled with the QGIS stack) and its sample-LAS validation work. It is intended for Geospatial engineers and LiDAR practitioners who move point clouds between files and databases. Validate each pattern against your own data, software versions, and operating environment before adopting it.

## Repository role and status

**Status:** Active, public — seeding. Pattern passes land in follow-up work from fleet-verified setups; the tables below list what is planned, not what is already written.

**What this repository is:** PDAL patterns — see the table below.

**What it contributes:** Part of the ZQM Computing geospatial portfolio. The umbrella index for the series is [geospatial-cookbooks](https://github.com/ZQM-Computing/geospatial-cookbooks).

**Standing:** This repository is maintained independently. Automated checks cover only the paths and environments configured in its workflows; they do not establish production readiness or operational certification.

## Who this is for

Geospatial engineers and LiDAR practitioners who move point clouds between files and databases.

## Prerequisites

- PDAL 2.10.0
- A sample LAS/LAZ file, or your own point-cloud data
- Bash

## Patterns (planned)

| # | Example | What it will demonstrate |
|---|---------|--------------------------|
| 01 | `01-info` | Inspecting point clouds: counts, bounds, dimensions, and SRS |
| 02 | `02-translate` | Translating between LAS, LAZ, and text formats |
| 03 | `03-pipeline-json` | Writing and running PDAL pipeline JSON files |
| 04 | `04-pgpointcloud-writer` | Writing point-cloud patches into pgPointCloud (see pgpointcloud-cookbook) |
| 05 | `05-full-workflow` | End-to-end: file → pipeline → database |

## Repository layout

```text
pdal-cookbook/
├── examples/          # pattern passes, landing in follow-up work
├── README.md
└── LICENSE
```

## Roadmap

- First pattern pass: the first two table rows
- Second pass: the remaining rows, from fleet-verified setups

## Contributing

A contributing guide lands with the first pattern pass. Report security issues to <zqmcomputing@gmail.com> — please do not open a public issue for those.

## More from this series

- [pgpointcloud-cookbook](https://github.com/ZQM-Computing/pgpointcloud-cookbook) — Point-cloud storage in Postgres, PDAL ingest, patch queries
- [geoserver-cookbook](https://github.com/ZQM-Computing/geoserver-cookbook) — Publishing, styling, federation, and securing OGC services
- [postgis-cookbook](https://github.com/ZQM-Computing/postgis-cookbook) — Spatial indexing, joins & KNN, SRID management, vector tiles
