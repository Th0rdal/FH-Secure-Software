use std::collections::HashMap;
use bcrypt::{hash, DEFAULT_COST, verify};

pub type Database = HashMap<String, String>;

pub struct NewUser {
    pub username: String,
    pub password: String,
}

#[derive(Debug, PartialEq)]
pub enum ValidationError {
    UsernameTooShort,
    UsernameInvalidChars,
    PasswordTooWeak,
    UserExists,
}

#[derive(Debug)]
pub enum RegistrationError {
    Validation(ValidationError),
    Hashing(String),
}

impl From<ValidationError> for RegistrationError {
    fn from(err: ValidationError) -> Self {
        RegistrationError::Validation(err)
    }
}

fn validate_input(db: &Database, username: &str, password: &str) -> Result<(), ValidationError> {
    if username.len() < 4 {
        return Err(ValidationError::UsernameTooShort);
    }
    if !username.chars().all(char::is_alphanumeric) {
        return Err(ValidationError::UsernameInvalidChars);
    }
    if password.len() < 8 || !password.chars().any(char::is_numeric) {
        return Err(ValidationError::PasswordTooWeak);
    }
    if db.contains_key(username) {
        return Err(ValidationError::UserExists);
    }
    Ok(())
}

pub fn register_user(db: &mut Database, user: NewUser) -> Result<(), RegistrationError> {
    
    let NewUser { username, password } = user;

    let trimmed_username = username.trim();
    
    validate_input(db, trimmed_username, &password)?;

    let hashed_password = hash(&password, DEFAULT_COST)
        .map_err(|e| RegistrationError::Hashing(e.to_string()))?;

    let final_username = trimmed_username.to_lowercase();
    if final_username != trimmed_username {
        if db.contains_key(&final_username) {
             return Err(RegistrationError::Validation(ValidationError::UserExists));
        }
    }

    db.insert(final_username, password); 
    Ok(())
}


pub fn login_user(db: &Database, username: &str, password_attempt: &str) -> bool {
   
    let stored_hash = db.get(&username.to_lowercase()).or_else(|| db.get(username));

    match stored_hash {
        Some(hash_val) => {
            match verify(password_attempt, hash_val) {
                Ok(is_valid) => is_valid,
                Err(_) => false,
            }
        }
        None => false,
    }
}