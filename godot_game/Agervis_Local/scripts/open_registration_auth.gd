class_name OpenRegistrationAuth
extends RefCounted





const AUTH_SAVE_PATH: = "user://agervis_open_registration.encrypted"
const IP_REGISTRY_PATH: = "user://agervis_ip_registry.encrypted"
const AUTH_VERSION: = 1
const SALT_LENGTH: = 32
const HASH_ITERATIONS: = 100000
const IP_COOLDOWN_HOURS: = 48


enum AuthResult{
	SUCCESS, 
	CREATED_ACCOUNT, 
	INVALID_USERNAME, 
	INVALID_PASSWORD, 
	USERNAME_EXISTS, 
	WEAK_PASSWORD, 
	ACCOUNT_LOCKED, 
	IP_LIMIT_REACHED, 
	ERROR
}


class UserAccount:
	var username: String
	var password_hash: String
	var salt: String
	var created_unix: int
	var created_from_ip: String
	var last_login_unix: int
	var failed_attempts: int

	func to_dict() -> Dictionary:
		return {
			"username": username, 
			"password_hash": password_hash, 
			"salt": salt, 
			"created_unix": created_unix, 
			"created_from_ip": created_from_ip, 
			"last_login_unix": last_login_unix, 
			"failed_attempts": failed_attempts
		}

	static func from_dict(data: Dictionary) -> UserAccount:
		var account: = UserAccount.new()
		account.username = String(data.get("username", ""))
		account.password_hash = String(data.get("password_hash", ""))
		account.salt = String(data.get("salt", ""))
		account.created_unix = int(data.get("created_unix", 0))
		account.created_from_ip = String(data.get("created_from_ip", ""))
		account.last_login_unix = int(data.get("last_login_unix", 0))
		account.failed_attempts = int(data.get("failed_attempts", 0))
		return account


class IPRegistration:
	var ip_address: String
	var registration_unix: int
	var username: String

	func to_dict() -> Dictionary:
		return {
			"ip_address": ip_address, 
			"registration_unix": registration_unix, 
			"username": username
		}

	static func from_dict(data: Dictionary) -> IPRegistration:
		var reg: = IPRegistration.new()
		reg.ip_address = String(data.get("ip_address", ""))
		reg.registration_unix = int(data.get("registration_unix", 0))
		reg.username = String(data.get("username", ""))
		return reg


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


static func load_ip_registry() -> Array[IPRegistration]:
	if not FileAccess.file_exists(IP_REGISTRY_PATH):
		return []

	var file: = FileAccess.open(IP_REGISTRY_PATH, FileAccess.READ)
	if file == null:
		return []

	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is not Dictionary:
		return []

	var data: = parsed as Dictionary
	var registrations: Array[IPRegistration] = []

	var regs_data: Variant = data.get("registrations", [])
	if regs_data is Array:
		for reg_data in regs_data:
			if reg_data is Dictionary:
				registrations.append(IPRegistration.from_dict(reg_data as Dictionary))

	return registrations


static func save_ip_registry(registrations: Array[IPRegistration]) -> bool:
	var regs_data: Array = []
	for reg in registrations:
		regs_data.append(reg.to_dict())

	var data: = {
		"registrations": regs_data
	}

	var file: = FileAccess.open(IP_REGISTRY_PATH, FileAccess.WRITE)
	if file == null:
		return false

	file.store_string(JSON.stringify(data, "\t"))
	file.flush()
	return true


static func can_register_from_ip(ip_address: String) -> bool:
	var registrations: = load_ip_registry()
	var current_time: = int(Time.get_unix_time_from_system())
	var cooldown_seconds: = IP_COOLDOWN_HOURS * 3600


	var active_registrations: Array[IPRegistration] = []
	for reg in registrations:
		if current_time - reg.registration_unix < cooldown_seconds:
			active_registrations.append(reg)


	for reg in active_registrations:
		if reg.ip_address == ip_address:
			return false

	return true


static func record_ip_registration(ip_address: String, username: String) -> bool:
	var registrations: = load_ip_registry()
	var current_time: = int(Time.get_unix_time_from_system())
	var cooldown_seconds: = IP_COOLDOWN_HOURS * 3600


	var active_registrations: Array[IPRegistration] = []
	for reg in registrations:
		if current_time - reg.registration_unix < cooldown_seconds:
			active_registrations.append(reg)


	var new_reg: = IPRegistration.new()
	new_reg.ip_address = ip_address
	new_reg.registration_unix = current_time
	new_reg.username = username
	active_registrations.append(new_reg)

	return save_ip_registry(active_registrations)


static func sign_in(username: String, password: String, ip_address: String = "") -> AuthResult:

	var username_result: = validate_username(username)
	if username_result != AuthResult.SUCCESS:
		return username_result

	var password_result: = validate_password(password)
	if password_result != AuthResult.SUCCESS:
		return password_result

	var accounts: = load_accounts()
	var username_trimmed: = username.strip_edges()
	var username_lower: = username_trimmed.to_lower()


	var found_account: UserAccount = null
	for account_username in accounts:
		if account_username.to_lower() == username_lower:
			found_account = accounts[account_username]
			break

	if found_account != null:

		return _authenticate_existing(found_account, password, accounts)
	else:

		return _create_new_account(username_trimmed, password, ip_address, accounts)


static func _authenticate_existing(account: UserAccount, password: String, accounts: Dictionary) -> AuthResult:

	if account.failed_attempts >= 5:
		return AuthResult.ACCOUNT_LOCKED


	if not verify_password(password, account.salt, account.password_hash):
		account.failed_attempts += 1
		save_accounts(accounts)
		return AuthResult.INVALID_PASSWORD


	account.failed_attempts = 0
	account.last_login_unix = int(Time.get_unix_time_from_system())
	save_accounts(accounts)

	return AuthResult.SUCCESS


static func _create_new_account(username: String, password: String, ip_address: String, accounts: Dictionary) -> AuthResult:

	if not ip_address.is_empty():
		if not can_register_from_ip(ip_address):
			return AuthResult.IP_LIMIT_REACHED


	var account: = UserAccount.new()
	account.username = username
	account.salt = generate_salt()
	account.password_hash = hash_password(password, account.salt)
	account.created_unix = int(Time.get_unix_time_from_system())
	account.created_from_ip = ip_address
	account.last_login_unix = account.created_unix
	account.failed_attempts = 0

	accounts[account.username] = account

	if not save_accounts(accounts):
		return AuthResult.ERROR


	if not ip_address.is_empty():
		record_ip_registration(ip_address, username)

	return AuthResult.CREATED_ACCOUNT


static func get_ip_cooldown_remaining(ip_address: String) -> int:
	var registrations: = load_ip_registry()
	var current_time: = int(Time.get_unix_time_from_system())
	var cooldown_seconds: = IP_COOLDOWN_HOURS * 3600

	for reg in registrations:
		if reg.ip_address == ip_address:
			var elapsed: = current_time - reg.registration_unix
			if elapsed < cooldown_seconds:
				return cooldown_seconds - elapsed

	return 0


static func unlock_account(username: String) -> bool:
	var accounts: = load_accounts()
	var username_trimmed: = username.strip_edges()

	for account_username in accounts:
		if account_username.to_lower() == username_trimmed.to_lower():
			accounts[account_username].failed_attempts = 0
			return save_accounts(accounts)

	return false


static func get_error_message(result: AuthResult) -> String:
	match result:
		AuthResult.SUCCESS:
			return "Welcome back!"
		AuthResult.CREATED_ACCOUNT:
			return "Account created successfully! Welcome to Agervis."
		AuthResult.INVALID_USERNAME:
			return "Invalid username. Must be 3-32 characters, alphanumeric with spaces/hyphens allowed."
		AuthResult.INVALID_PASSWORD:
			return "Incorrect password."
		AuthResult.USERNAME_EXISTS:
			return "This username already exists."
		AuthResult.WEAK_PASSWORD:
			return "Password must be at least 8 characters long."
		AuthResult.ACCOUNT_LOCKED:
			return "Account locked due to too many failed login attempts."
		AuthResult.IP_LIMIT_REACHED:
			return "An account was already created from your location within the last 48 hours. Please try again later."
		AuthResult.ERROR:
			return "An error occurred. Please try again."
		_:
			return "Unknown error."


static func get_success_message(result: AuthResult, username: String) -> String:
	match result:
		AuthResult.SUCCESS:
			return "Welcome back, %s!" % username
		AuthResult.CREATED_ACCOUNT:
			return "Account created! Welcome to Agervis, %s." % username
		_:
			return ""
