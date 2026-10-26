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

    def test_each_pattern_has_documentation_and_artifact(self):
        for name in sorted(EXPECTED):
            with self.subTest(pattern=name):
                directory = EXAMPLES / name
                self.assertTrue((directory / "README.md").is_file())
                artifacts = [p for p in directory.iterdir() if p.suffix in {".sh", ".py", ".json"}]
                self.assertTrue(artifacts, f"{name} has no runnable or pipeline artifact")


if __name__ == "__main__":
    unittest.main()
