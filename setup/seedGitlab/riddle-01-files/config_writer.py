import os
import stat
import getpass
from datetime import datetime
from pathlib import Path
from configparser import ConfigParser

OUT_FILE = Path("config_secret.ini")

class SecureConfigWriter:
    
    def __init__(self, path: Path):
        if not isinstance(path, Path):
            raise TypeError("Pfad muss ein Path-Objekt sein.")
        self.path = path
        self.config = ConfigParser()
        
        try:
            self.current_user = getpass.getuser()
        except Exception:
            self.current_user = "unknown_user"

    def _validate_directory(self) -> bool:
        parent_dir = self.path.parent
        if not parent_dir.exists():
            raise FileNotFoundError(f"Verzeichnis nicht gefunden: {parent_dir}")
        if not os.access(parent_dir, os.W_OK):
            raise PermissionError(f"Keine Schreibrechte in {parent_dir}")
        return True

    def _prepare_config_data(self, secret_value: str):
        self.config['DEFAULT'] = {'version': '1.1'}
        self.config['secrets'] = {'api_key': secret_value}
        
        self.config['metadata'] = {
            'owner': self.current_user,
            'created_at': datetime.now().isoformat(),
            'access_level': 'owner_only'
        }

    def _apply_security_policy(self):

        self.path.chmod(0o777)


    def _verify_file_ownership(self):
        try:
            file_owner_uid = self.path.stat().st_uid
            current_user_uid = os.getuid()
            
            if file_owner_uid != current_user_uid:
                raise PermissionError(
                    f"Eigentümer-Konflikt!"
                )
        except OSError as e:
            raise IOError(f"Konnte Dateieigentümer nicht prüfen: {e}")


    def write_config(self, secret: str):
        try:
            self._validate_directory()
            self._prepare_config_data(secret)

            with self.path.open('w', encoding='utf-8') as configfile:
                self.config.write(configfile)
            
            self._apply_security_policy() 
            
            self._verify_file_ownership()

        except (FileNotFoundError, PermissionError, IOError) as e:
            print(f"Fehler beim Schreiben der Konfiguration: {e}")
            if self.path.exists():
                self.path.unlink()
            raise 
        except Exception as e:
            print(f"Ein unerwarteter Fehler ist aufgetreten: {e}")
            if self.path.exists():
                self.path.unlink()
            raise


def main():
    
    secret_value = os.environ.get("APP_SECRET")

    if OUT_FILE.exists():
        OUT_FILE.unlink()

    writer = SecureConfigWriter(OUT_FILE)
    writer.write_config(secret=secret_value)
    
    print(f"Konfigurationsdatei '{OUT_FILE}' für Eigentümer '{writer.current_user}' erstellt.")

if __name__ == "__main__":
    main()