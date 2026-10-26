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

**Status:** Active, public — five design-stage examples. CI validates shell syntax, Python compilation, example inventory, and static pipeline/credential-safety contracts. No pattern has been runtime-validated against the fleet PDAL 2.10.0 build or a live pgPointCloud database.

**What this repository is:** PDAL patterns — see the table below.

**What it contributes:** Part of the ZQM Computing geospatial portfolio. The umbrella index for the series is [geospatial-cookbooks](https://github.com/ZQM-Computing/geospatial-cookbooks).

**Standing:** This repository is maintained independently. Automated checks cover only the paths and environments configured in its workflows; they do not establish production readiness or operational certification.

## Who this is for

Geospatial engineers and LiDAR practitioners who move point clouds between files and databases.

## Prerequisites

- PDAL 2.10.0
- A sample LAS/LAZ file, or your own point-cloud data
- Bash

## Patterns

| # | Example | Status | What it demonstrates |
|---|---------|--------|----------------------|
| 01 | [01-info](examples/01-info/README.md) | Written; runtime pending | Inspecting point clouds: counts, bounds, dimensions, and SRS |
| 02 | [02-translate](examples/02-translate/README.md) | Written; count assertions added | Translating between LAS, LAZ, and text formats |
| 03 | [03-pipeline-json](examples/03-pipeline-json/README.md) | Written; sort/count assertions added | Writing and running PDAL pipeline JSON files |
| 04 | [04-pgpointcloud-writer](examples/04-pgpointcloud-writer/README.md) | Written; environment config added | Writing point-cloud patches into pgPointCloud (see pgpointcloud-cookbook) |
| 05 | [05-full-workflow](examples/05-full-workflow/README.md) | Local stages asserted; database optional | End-to-end: file → pipeline → database |

## Repository layout

```text
pdal-cookbook/
├── examples/          # five design-stage patterns with explicit runtime gates
├── tests/             # inventory and pipeline/credential safety contracts
├── .github/workflows/ # Python/shell/contract CI
├── README.md
└── LICENSE
```

## Roadmap

- Validate the LAS/LAZ/text round trip and JSON sorting pipeline against PDAL 2.10.0.
- Verify `writers.pgpointcloud` option names and patch semantics against the fleet extension build.
- Add a disposable database integration job only after the PostgreSQL/pgPointCloud runtime and safe credentials are available.

## Contributing

A contributing guide lands with the first pattern pass. Report security issues to <zqmcomputing@gmail.com> — please do not open a public issue for those.

## More from this series

- [CloudCompare Cookbook](https://github.com/ZQM-Computing/cloudcompare-cookbook) — point-cloud inspection, registration, and comparison
- [pgPointCloud Cookbook](https://github.com/ZQM-Computing/pgpointcloud-cookbook) — Postgres point-cloud extension setup and patch workflows
- [GeoServer Cookbook](https://github.com/ZQM-Computing/geoserver-cookbook) — publishing and serving geospatial data[pgpointcloud-cookbook](https://github.com/ZQM-Computing/pgpointcloud-cookbook) — Point-cloud storage in Postgres, PDAL ingest, patch queries
- [geoserver-cookbook](https://github.com/ZQM-Computing/geoserver-cookbook) — Publishing, styling, federation, and securing OGC services
- [postgis-cookbook](https://github.com/ZQM-Computing/postgis-cookbook) — Spatial indexing, joins & KNN, SRID management, vector tiles
