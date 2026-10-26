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

    def test_info_example_avoids_pipefail_prone_output_truncation(self):
        script = (EXAMPLES / "01-info" / "info.sh").read_text(encoding="utf-8")
        self.assertIn('pdal info --summary "$DIR/synthetic.las" > "$SUMMARY"', script)
        self.assertIn("count != 12", script)
        self.assertNotIn("| head", script)

    def test_pipeline_input_and_output_are_reproducible(self):
        import json
        pipeline = json.loads((EXAMPLES / "03-pipeline-json" / "pipeline.json").read_text(encoding="utf-8"))
        self.assertEqual(pipeline["pipeline"][0]["filename"], "../01-info/synthetic.txt")
        self.assertEqual(pipeline["pipeline"][-1]["filename"], "sorted.las")
        script = (EXAMPLES / "03-pipeline-json" / "run.sh").read_text(encoding="utf-8")
        self.assertIn("rows != sorted(rows)", script)
        self.assertIn("count != 12", script)

    def test_each_pattern_has_documentation_and_artifact(self):
        for name in sorted(EXPECTED):
            with self.subTest(pattern=name):
                directory = EXAMPLES / name
                self.assertTrue((directory / "README.md").is_file())
                artifacts = [p for p in directory.iterdir() if p.suffix in {".sh", ".py", ".json"}]
                self.assertTrue(artifacts, f"{name} has no runnable or pipeline artifact")


if __name__ == "__main__":
    unittest.main()
