import unittest
from pathlib import Path

ROOT = Path(__file__).parents[1]
EXAMPLES = ROOT / "examples"
EXPECTED = {
    "01-info",
    "02-translate",
    "03-pipeline-json",
    "04-pgpointcloud-writer",
    "05-full-workflow",
}


class ExampleInventoryTests(unittest.TestCase):
    def test_all_five_patterns_are_present(self):
        actual = {path.name for path in EXAMPLES.iterdir() if path.is_dir()}
        self.assertEqual(actual, EXPECTED)

    def test_translate_pattern_asserts_round_trip_counts(self):
        script = (EXAMPLES / "02-translate" / "translate.sh").read_text(encoding="utf-8")
        self.assertIn("las_count != 12", script)
        self.assertIn("laz_count != las_count", script)
        self.assertIn("text_rows != las_count", script)
        self.assertIn("set -euo pipefail", script)

    def test_pipeline_json_fixtures_are_valid_and_have_expected_stages(self):
        import json
        first = json.loads((EXAMPLES / "03-pipeline-json" / "pipeline.json").read_text(encoding="utf-8"))
        types = [stage.get("type") for stage in first["pipeline"]]
        self.assertEqual(types, ["readers.text", "filters.sort", "writers.las"])
        writer = json.loads((EXAMPLES / "04-pgpointcloud-writer" / "pipeline.json").read_text(encoding="utf-8"))
        stages = writer["pipeline"]
        self.assertEqual([stage.get("type") for stage in stages], ["readers.text", "writers.pgpointcloud"])
        self.assertIn("CHANGEME", stages[1]["connection"])
        self.assertIn("CHANGEME", stages[1]["schema"])
        self.assertIn("CHANGEME", stages[1]["table"])

    def test_writer_config_comes_from_environment_and_is_temporary(self):
        script = (EXAMPLES / "04-pgpointcloud-writer" / "run.sh").read_text(encoding="utf-8")
        for variable in ("PGHOST", "PGDATABASE", "PGUSER", "PGPASSWORD", "PGSCHEMA", "PGTABLE"):
            with self.subTest(variable=variable):
                self.assertIn(f"${{{variable}:?set {variable}}}", script)
        self.assertIn("mktemp -d", script)
        self.assertIn("trap 'rm -rf", script)
        self.assertIn("pipeline.configured.json", script)
        self.assertNotIn("echo \"$PGPASSWORD\"", script)

    def test_workflow_does_not_delete_callers_files_or_claim_database_success(self):
        script = (EXAMPLES / "05-full-workflow" / "workflow.sh").read_text(encoding="utf-8")
        self.assertIn("mktemp -d", script)
        self.assertIn("trap 'rm -rf", script)
        self.assertNotIn("rm -f synthetic", script)
        self.assertIn("PDAL_PGPOINTCLOUD_PIPELINE", script)
        self.assertIn("SKIP: database stage not run", script)

    def test_info_script_avoids_curl_or_head_pipeline_under_pipefail(self):
        script = (EXAMPLES / "01-info" / "info.sh").read_text(encoding="utf-8")
        self.assertIn("pdal info --metadata synthetic.las >", script)
        self.assertNotIn("| head", script)

    def test_each_pattern_has_documentation_and_artifact(self):
        for name in sorted(EXPECTED):
            with self.subTest(pattern=name):
                directory = EXAMPLES / name
                self.assertTrue((directory / "README.md").is_file())
                artifacts = [p for p in directory.iterdir() if p.suffix in {".sh", ".py", ".json"}]
                self.assertTrue(artifacts, f"{name} has no runnable or pipeline artifact")


if __name__ == "__main__":
    unittest.main()
