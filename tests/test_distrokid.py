from pipelines import Pipeline
import pytest
import pandas
from pathlib import Path

#Get Home Directory
p = str(Path('.').resolve().parents[0]) + "/data/DistroKid.tsv"

class TestDistrokid:

    #Is Pipeline Importable?
    def test_import(self):
        try:
            from src.pipelines import Distrokid
            distrokid = Distrokid(p)
            assert 1

        except:
            assert 0
    