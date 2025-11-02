use challenge_lib::hash::*;

use bcrypt::verify;
use std::collections::HashMap;

#[test]
fn test_registration_stores_hashed_password() {

    let mut db: Database = HashMap::new();
    let test_user = NewUser {
        username: "testuser".to_string(),
        password: "SecurePassword123!".to_string(),
    };
    let original_password = test_user.password.clone();

    // Funktion aus main file
    let registration_result = register_user(&mut db, test_user);

    assert!(registration_result.is_ok(), "Registrierung fehlgeschlagen");

    let stored_data = db.get("testuser");
    assert!(stored_data.is_some(), "Benutzer nicht in DB eingefügt");

    let stored_value = stored_data.unwrap();

    // Schlägt fehl wenn Klartext
    assert_ne!(
        stored_value,
        &original_password,
        "FEHLGESCHLAGEN: Klartext"
    );

    // Prüft gültigen Hash
    let is_valid_hash = verify(&original_password, stored_value).unwrap_or(false);
    assert!(
        is_valid_hash,
        "FEHLGESCHLAGEN: kein gültiger Hash"
    );
}