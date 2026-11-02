class_name AgervisAuthSystem
extends RefCounted




const AUTH_SAVE_PATH: = "user://agervis_credentials.encrypted"
const AUTH_VERSION: = 1
const SALT_LENGTH: = 32
const HASH_ITERATIONS: = 100000


enum AuthResult{
	SUCCESS, 
	INVALID_USERNAME, 
	INVALID_PASSWORD, 
	USERNAME_EXISTS, 
	WEAK_PASSWORD, 
	ACCOUNT_LOCKED, 
	ERROR
}


class UserAccount:
	var username: String
	var password_hash: String
	var salt: String
	var created_unix: int
	var last_login_unix: int
	var failed_attempts: int

	func to_dict() -> Dictionary:
		return {
			"username": username, 
			"password_hash": password_hash, 
			"salt": salt, 
			"created_unix": created_unix, 
			"last_login_unix": last_login_unix, 
			"failed_attempts": failed_attempts
		}

	static func from_dict(data: Dictionary) -> UserAccount:
		var account: = UserAccount.new()
		account.username = String(data.get("username", ""))
		account.password_hash = String(data.get("password_hash", ""))
		account.salt = String(data.get("salt", ""))
		account.created_unix = int(data.get("created_unix", 0))
		account.last_login_unix = int(data.get("last_login_unix", 0))
		account.failed_attempts = int(data.get("failed_attempts", 0))
		return account


static func validate_password(password: String) -> AuthResult:
	if password.length() < 8:
		return AuthResult.WEAK_PASSWORD

	return AuthResult.SUCCESS


static func validate_username(username: String) -> AuthResult:
	var cleaned: = username.strip_edges()
	if cleaned.is_empty() or cleaned.length() < 3:
		return AuthResult.INVALID_USERNAME
	if cleaned.length() > 32:
		return AuthResult.INVALID_USERNAME

	for character in cleaned:
		if not (character.is_valid_identifier() or character == " " or character == "-"):
			return AuthResult.INVALID_USERNAME
	return AuthResult.SUCCESS


static func generate_salt() -> String:
	var crypto: = Crypto.new()
	var random_bytes: = crypto.generate_random_bytes(SALT_LENGTH)
	return random_bytes.hex_encode()


static func hash_password(password: String, salt: String) -> String:
	var crypto: = Crypto.new()
	var salt_bytes: = salt.hex_decode()
	var password_bytes: = password.to_utf8_buffer()

	var hash: = crypto.hmac_digest(HashingContext.HASH_SHA256, salt_bytes, password_bytes)

	for _iteration in range(HASH_ITERATIONS - 1):
		hash = crypto.hmac_digest(HashingContext.HASH_SHA256, salt_bytes, hash)
	return hash.hex_encode()


static func verify_password(password: String, salt: String, stored_hash: String) -> bool:
	var computed_hash: = hash_password(password, salt)

	if computed_hash.length() != stored_hash.length():
		return false
	var matches: = true
	for index in range(computed_hash.length()):
		if computed_hash[index] != stored_hash[index]:
			matches = false
	return matches


static func load_accounts() -> Dictionary:
	if not FileAccess.file_exists(AUTH_SAVE_PATH):
		return {}

	var file: = FileAccess.open(AUTH_SAVE_PATH, FileAccess.READ)
	if file == null:
		return {}

	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is not Dictionary:
		return {}

	var accounts: Dictionary = {}
	var data: = parsed as Dictionary

	if int(data.get("version", 0)) != AUTH_VERSION:
		return {}

	var accounts_data: Variant = data.get("accounts", {})
	if accounts_data is Dictionary:
		for username in accounts_data:
			var account_data: Variant = accounts_data[username]
			if account_data is Dictionary:
				accounts[username] = UserAccount.from_dict(account_data as Dictionary)

	return accounts


static func save_accounts(accounts: Dictionary) -> bool:
	var accounts_data: Dictionary = {}
	for username in accounts:
		var account: UserAccount = accounts[username]
		accounts_data[username] = account.to_dict()

	var data: = {
		"version": AUTH_VERSION, 
		"accounts": accounts_data
	}

	var file: = FileAccess.open(AUTH_SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return false

	file.store_string(JSON.stringify(data, "\t"))
	file.flush()
	return true


static func create_account(username: String, password: String) -> AuthResult:
	var username_result: = validate_username(username)
	if username_result != AuthResult.SUCCESS:
		return username_result

	var password_result: = validate_password(password)
	if password_result != AuthResult.SUCCESS:
		return password_result

	var accounts: = load_accounts()
	var username_lower: = username.strip_edges().to_lower()


	for existing_username in accounts:
		if existing_username.to_lower() == username_lower:
			return AuthResult.USERNAME_EXISTS


	var account: = UserAccount.new()
	account.username = username.strip_edges()
	account.salt = generate_salt()
	account.password_hash = hash_password(password, account.salt)
	account.created_unix = int(Time.get_unix_time_from_system())
	account.last_login_unix = 0
	account.failed_attempts = 0

	accounts[account.username] = account

	if not save_accounts(accounts):
		return AuthResult.ERROR

	return AuthResult.SUCCESS


static func authenticate(username: String, password: String) -> AuthResult:
	var accounts: = load_accounts()
	var username_trimmed: = username.strip_edges()


	var found_account: UserAccount = null
	for account_username in accounts:
		if account_username.to_lower() == username_trimmed.to_lower():
			found_account = accounts[account_username]
			break

	if found_account == null:
		return AuthResult.INVALID_USERNAME


	if found_account.failed_attempts >= 5:
		return AuthResult.ACCOUNT_LOCKED


	if not verify_password(password, found_account.salt, found_account.password_hash):
		found_account.failed_attempts += 1
		save_accounts(accounts)
		return AuthResult.INVALID_PASSWORD


	found_account.failed_attempts = 0
	found_account.last_login_unix = int(Time.get_unix_time_from_system())
	save_accounts(accounts)

	return AuthResult.SUCCESS


static func change_password(username: String, old_password: String, new_password: String) -> AuthResult:

	var auth_result: = authenticate(username, old_password)
	if auth_result != AuthResult.SUCCESS:
		return auth_result


	var password_result: = validate_password(new_password)
	if password_result != AuthResult.SUCCESS:
		return password_result

	var accounts: = load_accounts()
	var username_trimmed: = username.strip_edges()


	var found_account: UserAccount = null
	for account_username in accounts:
		if account_username.to_lower() == username_trimmed.to_lower():
			found_account = accounts[account_username]
			break

	if found_account == null:
		return AuthResult.ERROR


	found_account.salt = generate_salt()
	found_account.password_hash = hash_password(new_password, found_account.salt)

	if not save_accounts(accounts):
		return AuthResult.ERROR

	return AuthResult.SUCCESS


static func unlock_account(username: String) -> bool:
	var accounts: = load_accounts()
	var username_trimmed: = username.strip_edges()

	for account_username in accounts:
		if account_username.to_lower() == username_trimmed.to_lower():
			accounts[account_username].failed_attempts = 0
			return save_accounts(accounts)

	return false


static func has_accounts() -> bool:
	var accounts: = load_accounts()
	return not accounts.is_empty()


static func get_error_message(result: AuthResult) -> String:
	match result:
		AuthResult.SUCCESS:
			return "Success"
		AuthResult.INVALID_USERNAME:
			return "Invalid username. Must be 3-32 characters, alphanumeric with spaces/hyphens allowed."
		AuthResult.INVALID_PASSWORD:
			return "Incorrect password."
		AuthResult.USERNAME_EXISTS:
			return "This username already exists. Please choose a different one."
		AuthResult.WEAK_PASSWORD:
			return "Password must be at least 8 characters long."
		AuthResult.ACCOUNT_LOCKED:
			return "Account locked due to too many failed login attempts. Contact support."
		AuthResult.ERROR:
			return "An error occurred. Please try again."
		_:
			return "Unknown error."
