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

    def test_synthetic_generator_writes_beside_script(self):
        generator = (EXAMPLES / "01-info" / "generate.py").read_text(encoding="utf-8")
        self.assertIn("Path(__file__).resolve().parent / \"synthetic.txt\"", generator)
        self.assertIn("Path(sys.argv[1]).expanduser().resolve()", generator)
        self.assertIn("output.parent.mkdir(parents=True, exist_ok=True)", generator)

    def test_info_example_avoids_pipefail_prone_output_truncation(self):
        script = (EXAMPLES / "01-info" / "info.sh").read_text(encoding="utf-8")
        self.assertIn('pdal info --summary "$DIR/synthetic.las" > "$SUMMARY"', script)
        self.assertIn("count != 12", script)
        self.assertNotIn("| head", script)

    def test_pipeline_input_and_output_are_reproducible(self):
        import json
        pipeline = json.loads((EXAMPLES / "03-pipeline-json" / "pipeline.json").read_text(encoding="utf-8"))
        self.assertEqual(pipeline["pipeline"][0]["filename"], "synthetic.txt")
        self.assertIn('"$TMP_DIR/synthetic.txt"', script)
        self.assertIn('cp "$DIR/pipeline.json" "$TMP_DIR/pipeline.json"', script)
        self.assertEqual(pipeline["pipeline"][-1]["filename"], "sorted.las")
        script = (EXAMPLES / "03-pipeline-json" / "run.sh").read_text(encoding="utf-8")
        self.assertIn("rows != sorted(rows)", script)
        self.assertIn("count != 12", script)

    def test_writer_config_comes_from_environment_and_is_temporary(self):
        script = (EXAMPLES / "04-pgpointcloud-writer" / "run.sh").read_text(encoding="utf-8")
        for variable in ("PGHOST", "PGDATABASE", "PGUSER", "PGPASSWORD", "PGSCHEMA", "PGTABLE"):
            with self.subTest(variable=variable):
                self.assertIn(f"${{{variable}:?set {variable}}}", script)
        self.assertIn("mktemp -d", script)
        self.assertIn("trap 'rm -rf", script)
        self.assertIn("pipeline.configured.json", script)
        self.assertIn("conninfo(", script)
        self.assertIn('readers[0]["filename"] = os.environ["PDAL_FIXTURE"]', script)
        self.assertIn('generate.py" "$TMP_DIR/synthetic.txt"', script)
        self.assertNotIn('cp ../01-info/synthetic.txt "$DIR/synthetic.txt"', script)
        self.assertNotIn("echo \"$PGPASSWORD\"", script)

    def test_workflow_is_isolated_and_database_stage_is_explicitly_optional(self):
        script = (EXAMPLES / "05-full-workflow" / "workflow.sh").read_text(encoding="utf-8")
        self.assertIn("mktemp -d", script)
        self.assertIn("trap 'rm -rf", script)
        self.assertNotIn("rm -f synthetic", script)
        self.assertIn("PDAL_PGPOINTCLOUD_PIPELINE", script)
        self.assertIn("SKIP: database stage not run", script)
        self.assertIn("values != sorted(values)", script)
        self.assertIn('generate.py" "$TMP_DIR/synthetic.txt"', script)
        self.assertNotIn('cp "$DIR/../01-info/synthetic.txt" "$TMP_DIR/synthetic.txt"', script)

    def test_each_pattern_has_documentation_and_artifact(self):
        for name in sorted(EXPECTED):
            with self.subTest(pattern=name):
                directory = EXAMPLES / name
                self.assertTrue((directory / "README.md").is_file())
                artifacts = [p for p in directory.iterdir() if p.suffix in {".sh", ".py", ".json"}]
                self.assertTrue(artifacts, f"{name} has no runnable or pipeline artifact")


if __name__ == "__main__":
    unittest.main()
