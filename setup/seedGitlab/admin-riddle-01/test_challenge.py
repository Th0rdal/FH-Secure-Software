import pytest
import stat
from pathlib import Path

try:
    from config_writer import SecureConfigWriter
except ImportError:
    pytest.fail("Konnte 'config_writer.py' nicht finden.")

@pytest.fixture
def test_file_path(tmp_path: Path) -> Path:

    return tmp_path / "test_config.ini"


# prüft Berechtigungen für "Gruppe" und "Andere" <= 644
def test_permissions_are_restricted_for_group_and_other(test_file_path: Path):
    
    writer = SecureConfigWriter(test_file_path)
    test_secret = "pytest-secret-value"

    try:
        writer.write_config(secret=test_secret)
    except Exception as e:
        pytest.fail(f"Funktion 'write_config' abgestürtzt: {e}")
    
    assert test_file_path.exists(), "Die Konfigurationsdatei wurde nicht erstellt."

    try:
        file_stat = test_file_path.stat()
        
        # nur permissions holen
        permissions = stat.S_IMODE(file_stat.st_mode)
    except OSError as e:
        pytest.fail(f"Konnte die Dateiberechtigungen nicht lesen: {e}")

    # Definiere verbotene Bits
    forbidden_bits = (
        stat.S_IWGRP |  # Group Write
        stat.S_IXGRP |  # Group Execute
        stat.S_IWOTH |  # Other Write
        stat.S_IXOTH    # Other Execute
    )
    

    # prüfen mit bitweisen UND-Verknüpfung    
    assert (permissions & forbidden_bits) == 0, (
        f"FEHLGESCHLAGEN \n"
    )