"""Tests of play.py's parts that need no build:  python -m unittest discover -s tests -p "test_*.py" """

import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import play  # noqa: E402

STATE = b"screen-state 1\npages 1 display 0 write 0 read 0\np 00*640\nend\n"


class EntriesTest(unittest.TestCase):
    def test_states_digests_and_stopped(self):
        data = b"digest 0123456789ABCDEF\n" + STATE + b"stopped k line 3: no prompt in time\n"
        self.assertEqual(
            play.entries(data),
            [b"digest 0123456789ABCDEF", STATE, b"stopped k line 3: no prompt in time"],
        )

    def test_a_state_cut_short_is_kept(self):
        self.assertEqual(play.entries(b"screen-state 1\np 00\n"), [b"screen-state 1\np 00\n"])

    def test_empty(self):
        self.assertEqual(play.entries(b""), [])


class DigestTest(unittest.TestCase):
    def test_fnv1a64_known_values(self):
        self.assertEqual(play.fnv1a64(b""), 0xCBF29CE484222325)
        self.assertEqual(play.fnv1a64(b"a"), 0xAF63DC4C8601EC8C)

    def test_a_digest_matches_its_state(self):
        digest = play.as_digest(STATE)
        self.assertTrue(play.same(digest, STATE))
        self.assertTrue(play.same(STATE, digest))
        self.assertFalse(play.same(b"digest 0000000000000000", STATE))

    def test_first_difference(self):
        a = [b"digest 1", STATE]
        self.assertIsNone(play.first_difference(a, [b"digest 1", play.as_digest(STATE)]))
        self.assertEqual(play.first_difference(a, [b"digest 2", STATE]), 0)
        self.assertEqual(play.first_difference(a, a[:1]), 1)


class CheckpointsTest(unittest.TestCase):
    def test_repeat_blocks_are_unrolled(self):
        keys = "\n".join([
            "digest",          # 1
            "repeat 2",        # 2
            "play until 2:M",  # 3
            "state  # here",   # 4
            "repeat 2",        # 5
            "digest",          # 6
            "end",             # 7
            "end",             # 8
            "state",           # 9
            "repeat space",    # 10
        ])
        self.assertEqual(play.checkpoints(keys), [1, 4, 6, 6, 4, 6, 6, 9])

    def test_describe(self):
        keys = Path("k.keys")
        self.assertIn("line 9", play.describe(1, [1, 9], keys))
        self.assertIn("the state at exit", play.describe(2, [1, 9], keys))


class ScriptTest(unittest.TestCase):
    def load(self, text):
        with tempfile.TemporaryDirectory() as d:
            path = Path(d) / "s.keys"
            path.write_text(text)
            return play.load_script(path)

    def test_setup_lines(self):
        s = self.load("#! seed 42\n#! cfg side=2 difficult=1\n#! timeout 60\n# a comment\nkey space\n")
        self.assertEqual(s.seed, "42")
        self.assertEqual(s.timeout, 60)
        self.assertEqual(s.cfg["side"], "2")
        self.assertEqual(s.cfg["difficult"], "1")
        self.assertEqual(s.cfg["quiet"], "0")

    def test_unknown_field(self):
        with self.assertRaises(play.SetupError):
            self.load("#! cfg colour=3\n")

    def test_unknown_setup_line(self):
        with self.assertRaises(play.SetupError):
            self.load("#! speed 3\n")

    def test_program_and_files(self):
        s = self.load("#! program cs\n#! files RANDOM.CIV MAXSKORS\n#! files generalz\n")
        self.assertEqual(s.program, "cs")
        self.assertEqual(s.files, ["RANDOM.CIV", "MAXSKORS", "generalz"])
        self.assertEqual(self.load("key space\n").program, "cw")

    def test_unknown_program(self):
        with self.assertRaises(play.SetupError):
            self.load("#! program demo\n")

    def test_file_entries(self):
        with tempfile.TemporaryDirectory() as d:
            (Path(d) / "generalz").write_bytes(b"a\r\nb\r\n")
            (Path(d) / "lf.txt").write_bytes(b"a\nb\n")
            lines = play.file_entries(Path(d), ["GENERALZ", "lf.txt", "none.dat"]).decode().splitlines()
            # CRLF and LF give the same hash; the name matches whatever its case.
            self.assertEqual(lines[0].split()[:2], ["file", "GENERALZ"])
            self.assertEqual(lines[0].split()[2], lines[1].split()[2])
            self.assertEqual(lines[2], "file none.dat missing")
            # Each line is an entry of its own, after the states.
            self.assertEqual(play.entries(STATE + "\n".join(lines).encode() + b"\n")[1:],
                             [line.encode() for line in lines])

    def test_file_entries_in_a_folder(self):
        with tempfile.TemporaryDirectory() as d:
            (Path(d) / "Scenarios").mkdir()
            (Path(d) / "Scenarios" / "bullrun1.civ").write_bytes(b"a\n")
            names = ["scenarios/BULLRUN1.CIV", "scenarios/none.civ", "nofolder/a.civ", "Scenarios"]
            lines = play.file_entries(Path(d), names).decode().splitlines()
            # Each part matches whatever its case; a folder is not a file.
            self.assertEqual(lines[0].split()[:2], ["file", "scenarios/BULLRUN1.CIV"])
            self.assertEqual(lines[1:], ["file scenarios/none.civ missing",
                                         "file nofolder/a.civ missing", "file Scenarios missing"])

    def test_files_only_after_a_run_that_ended_well(self):
        with tempfile.TemporaryDirectory() as d:
            (Path(d) / "a.dat").write_bytes(b"a\n")
            script = self.load("#! files a.dat\n")
            ok = play.with_files(play.Run(script, "c", "", 0, STATE, Path(d)), Path(d))
            self.assertTrue(play.entries(ok.state)[-1].startswith(b"file a.dat "))
            # A stopped run keeps "stopped" as its last entry, so the reason for the failure shows.
            stopped = STATE + b"stopped k line 3: no prompt in time\n"
            bad = play.with_files(play.Run(script, "c", "", 125, stopped, Path(d)), Path(d))
            self.assertEqual(bad.state, stopped)
            self.assertIn("no prompt in time", play.run_problem(bad))

    def test_cfg_lines_in_lodecfg_order(self):
        with tempfile.TemporaryDirectory() as d:
            (Path(d) / "Prefer.cfg").write_text("old")
            play.write_cfg(Path(d), dict(play.CFG_FIELDS))
            # The copy of the repo's file goes, whatever the case of its name.
            self.assertEqual([p.name for p in Path(d).iterdir()], ["PREFER.CFG"])
            self.assertEqual((Path(d) / "PREFER.CFG").read_text(),
                             "1,3,18,3,0,3\n5,10,100\n3,2,1,1,1,1,3,1\n")


class CopyDataTest(unittest.TestCase):
    def test_data_files_and_test_data(self):
        with tempfile.TemporaryDirectory() as d:
            game, data, work = Path(d) / "game", Path(d) / "data", Path(d) / "work"
            for folder in (game, data, work):
                folder.mkdir()
            (game / "BULLRUN1.CIV").write_text("map")
            (game / "CIVWAR25.BAS").write_text("source")
            (game / "CW.DOC").write_text("manual")
            (game / "cw.exe").write_text("build")
            (game / "GENERALZ").write_text("repo")
            (data / "GENERALZ").write_text("test data")
            play.copy_data(work, game, data)
            self.assertEqual(sorted(p.name for p in work.iterdir()), ["BULLRUN1.CIV", "GENERALZ"])
            self.assertEqual((work / "GENERALZ").read_text(), "test data")

    def test_no_test_data_folder(self):
        with tempfile.TemporaryDirectory() as d:
            game, work = Path(d) / "game", Path(d) / "work"
            game.mkdir()
            work.mkdir()
            (game / "MAXSKORS").write_text("x")
            play.copy_data(work, game, Path(d) / "none")
            self.assertEqual([p.name for p in work.iterdir()], ["MAXSKORS"])


class CoverageTest(unittest.TestCase):
    UNIT = (
        "coverage 2\n"
        "file\t0\taaaa\trules_test.bas.test-entry.bas\n"
        "file\t1\tbbbb\trules_test.bas\n"
        "file\t2\tcccc\t../civwar2b.bm\n"
        "0\t3\t1\t1\t\n"
        "1\t9\t1\t1\t\n"
        "2\t10\t1\t1\tLEN\n"
        "2\t11\t1\t0\t\n"
        "end\n"
    )

    def test_rebase_keeps_only_the_games_files(self):
        self.assertEqual(
            play.rebase_records(self.UNIT * 2),
            ("coverage 2\nfile\t2\tcccc\tcivwar2b.bm\n2\t10\t1\t1\tLEN\n2\t11\t1\t0\t\nend\n") * 2,
        )

    def test_reached_only_by_the_unit_tests(self):
        with tempfile.TemporaryDirectory() as d:
            unit, script = Path(d) / "unit.txt", Path(d) / "script.txt"
            unit.write_text(play.rebase_records(self.UNIT), encoding="latin-1")
            # The script ran line 11, which the unit tests did not, and not line 10, which they did.
            script.write_text(
                "coverage 2\nfile\t5\tcccc\tcivwar2b.bm\n5\t10\t1\t0\t\n5\t11\t1\t4\t\nend\n", encoding="latin-1"
            )
            self.assertEqual(play.reached_only_by(unit, [script]), 1)
            self.assertEqual(play.statement_counts([unit, script])[("civwar2b.bm", 11, 1)], 4)

    def test_sub_table_names_the_main_module_of_the_program(self):
        with tempfile.TemporaryDirectory() as d:
            counts = Path(d) / "cs.txt"
            counts.write_text("coverage 2\nfile\t1\tcccc\tCIVSET24.BAS\n1\t50\t1\t2\t\nend\n", encoding="latin-1")
            # Line 50 of CIVSET24.BAS is in its main module, before its first SUB.
            self.assertIn("(main module)", play.sub_table([counts], "civset24.bas"))


class MakeScriptsTest(unittest.TestCase):
    FILES = ["$AVE1.CIV", "$AVE2.CIV", "$AVE3.CIV", "$AVE4.CIV", "$AVE5.CIV", "&A.CIV", "B.CIV",
             "C.CIV", "D.CIV", "E.CIV"]

    def test_pick_keys_moves_from_the_fifth_file(self):
        import make_scripts
        self.assertEqual(make_scripts.pick_keys("$AVE5.CIV", self.FILES), [])
        self.assertEqual(make_scripts.pick_keys("C.CIV", self.FILES),
                         ["key right", "prompt", "key right", "prompt", "key right", "prompt"])
        self.assertEqual(make_scripts.pick_keys("E.CIV", self.FILES), ["key down", "prompt", "key right", "prompt"])
        with self.assertRaises(ValueError):
            make_scripts.pick_keys("$AVE2.CIV", self.FILES)

    def test_script_names(self):
        import make_scripts
        self.assertEqual(make_scripts.script_name("rest", "BULLRUN1.CIV", 2), "rest-bullrun1-union")
        self.assertEqual(make_scripts.script_name("rest", "&STONES.CIV", 1), "rest-and-stones-confederate")
        self.assertEqual(make_scripts.script_name("auto", "Shiloh.civ", 1), "auto-shiloh")

    def test_units_and_checkpoints(self):
        import make_scripts
        lines = ["digest", *make_scripts.units(3), *make_scripts.ending(True)]
        # One digest before, three for the units, then the time limit, the results, the Hall of
        # Fame, the main menu and the Quit menu.
        self.assertEqual(len(play.checkpoints("\n".join(lines))), 1 + 3 + 5)
        self.assertEqual(make_scripts.units(0), [])
        self.assertEqual(len(play.checkpoints("\n".join(make_scripts.ending(False)))), 3)


if __name__ == "__main__":
    unittest.main()
