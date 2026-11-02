class_name Build9Systems
extends RefCounted

const BUILD_NAME: = "BUILD 9  /  PRIVATE ONLINE ALPHA"
const PROTOCOL_VERSION: = 9
const DEFAULT_PORT: = 24860
const MAX_PLAYERS: = 5

const CONTENT_NOTICE_LINES: = [
	"Agervis contains grimly humorous depictions of violence, crime, substance addiction, overdose, simulated gambling, incarceration, exploitation, psychological distress, permanent injury, death, and institutional neglect.", 
	"These subjects may be disturbing. The city has responded by documenting that.", 
	"Agervis does not endorse criminal conduct or substance use. Nothing presented is medical, legal, or safety advice. Online dialogue is supplied by adult players and may be unfiltered.", 
	"The city has reviewed this warning, laminated it, and considers the situation handled.", 
]

const SECOND_FUNCTIONS: = {
	"Certified Courier": {
		"path": "CIVILIAN", 
		"requirements": {"Enterprise": 5, "Agility": 4, "deliveries": 3, "credential": "SECONDARY EDUCATION"}, 
		"benefits": "Secure bag, commercial routes, employee entrances, and higher delivery pay.", 
	}, 
	"Loss Prevention Officer": {
		"path": "LAW", 
		"requirements": {"Safety": 5, "Awareness": 5, "patrols": 3, "credential": "Basic Security Orientation"}, 
		"benefits": "Store alerts, camera access, witnessed-theft detention, and evidence bonuses.", 
	}, 
	"Lookout": {
		"path": "CRIMINAL", 
		"requirements": {"Awareness": 5, "Stealth": 5, "criminal_errands": 3, "credential": "Underworld Contact"}, 
		"benefits": "Camera coverage, patrol estimates, warning signals, and prepared escape routes.", 
	}, 
}

const EMPLOYER_STANDING: = ["APPLICANT", "NEW HIRE", "RELIABLE", "KEYHOLDER", "SENIOR EMPLOYEE"]

const CORE_COURSES: = [
	{"id": "reasoning", "name": "APPLIED READING + REASONING", "skills": ["Intelligence"]}, 
	{"id": "civics", "name": "CIVICS + PAPERWORK", "skills": ["Civics", "Influence"]}, 
	{"id": "health", "name": "HEALTH + FIRST AID", "skills": ["Medicine", "Safety"]}, 
	{"id": "physical", "name": "PHYSICAL EDUCATION + NAVIGATION", "skills": ["Endurance", "Agility"]}, 
]

const LAUNDRY_ITEMS: = [
	{"name": "STATE BLUES", "bin": "WASH"}, 
	{"name": "DIRTY SOCK BAG", "bin": "WASH"}, 
	{"name": "DRY TOWELS", "bin": "FOLD"}, 
	{"name": "PROPERTY BAG 6B", "bin": "RETURN"}, 
	{"name": "WET SHEETS", "bin": "DRY"}, 
	{"name": "BIOHAZARD SHIRT", "bin": "CONTAMINATED"}, 
	{"name": "DRY UNIFORM", "bin": "FOLD"}, 
	{"name": "SEALED PROPERTY", "bin": "RETURN"}, 
	{"name": "WASHED BLANKET", "bin": "DRY"}, 
	{"name": "UNKNOWN DAMP ITEM", "bin": "CONTAMINATED"}, 
]

const LAUNDRY_BINS: = ["WASH", "DRY", "FOLD", "RETURN", "CONTAMINATED"]

const RECOVERY_SESSIONS: = [
	{
		"statements": [
			{"speaker": "DOZ", "line": "The first hit felt like control. Everything after that was proving I still had it."}, 
			{"speaker": "MARA", "line": "I thought maintenance strips were surrender. Turns out withdrawal was the thing demanding surrender."}, 
			{"speaker": "FACILITATOR", "line": "Understanding what a substance actually does helps separate fact from what the ritual promised."}, 
		], 
		"prompts": [
			{"question": "What do maintenance strips reduce?", "answers": ["Withdrawal symptoms and cravings", "Intelligence permanently", "The need for all medical care"], "correct": 0}, 
			{"question": "What did DOZ describe feeling from the first use?", "answers": ["Immediate regret", "A sense of control", "Nothing memorable"], "correct": 1}, 
			{"question": "Which statement reflects harm reduction?", "answers": ["Maintenance strips prevent overdose death, not addiction.", "All substance use has identical consequences.", "Recovery requires suffering to count."], "correct": 0}, 
		], 
	}, 
	{
		"statements": [
			{"speaker": "LEN", "line": "I kept using because stopping hurt. Then I kept using because everything hurt either way."},
			{"speaker": "RAE", "line": "Reversal spray brought me back twice. I was mad both times. I'm here, so I got over it."},
			{"speaker": "FACILITATOR", "line": "Opioid reversal medication stops overdose. It does not reverse the conditions that led there."},
		],
		"prompts": [
			{"question": "What does reversal medication reverse?", "answers": ["Addiction itself", "Opioid overdose effects", "All types of poisoning"], "correct": 1},
			{"question": "Why was RAE initially upset after revival?", "answers": ["It caused permanent harm", "It interrupted the high during overdose", "It was expensive"], "correct": 1},
			{"question": "Which understanding shows attention to harm reduction?", "answers": ["Reversal medication saves lives without solving addiction.", "Using reversal spray means recovery failed.", "Overdose survivors deserved it."], "correct": 0},
		],
	}, 
	{
		"statements": [
			{"speaker": "NIKO", "line": "The pills kept me awake for shifts. Then they kept me awake instead of shifts."}, 
			{"speaker": "VEE", "line": "I knew blow's purity varied by dealer. I didn't plan around what varied meant for my dose."}, 
			{"speaker": "FACILITATOR", "line": "Stimulants increase focus and energy short-term. Dependency and crashes follow repeated use."}, 
		], 
		"prompts": [
			{"question": "What risk comes from inconsistent drug purity?", "answers": ["Overdose from unexpected potency", "It always becomes safer", "No real danger exists"], "correct": 0}, 
			{"question": "What did NIKO's pills originally help with?", "answers": ["Staying awake for work shifts", "Treating diagnosed illness", "Social anxiety"], "correct": 0}, 
			{"question": "Which reflects understanding stimulant risks?", "answers": ["Higher doses reverse negative effects permanently.", "Tolerance builds, crashes worsen, dependency develops.", "Stimulants have no medical use ever."], "correct": 1}, 
		], 
	}, 
	{
		"statements": [
			{"speaker": "TAYE", "line": "I thought herb was harmless because nobody died from it directly. Harmless and helpful aren't the same."}, 
			{"speaker": "QUINN", "line": "Comfort doses at the clinic kept me stable enough to show up. That counted more than being fixed."}, 
			{"speaker": "FACILITATOR", "line": "Medication-assisted treatment reduces harm and overdose risk. It is treatment, not moral failure."}, 
		], 
		"prompts": [
			{"question": "What is the purpose of comfort doses?", "answers": ["To get high legally", "To reduce withdrawal and stabilize patients", "To replace all therapy"], "correct": 1}, 
			{"question": "What did TAYE learn about herb?", "answers": ["Low lethality does not mean no consequences", "It cures all conditions", "It is always completely safe"], "correct": 0},
			{"question": "Which statement reflects evidence-based treatment?", "answers": ["Maintenance medication enables stability and reduces death.", "Real recovery requires total abstinence immediately.", "Medication-assisted treatment is just trading addictions."], "correct": 0}, 
		], 
	}, 
	{
		"statements": [
			{"speaker": "IRIS", "line": "I carried reversal spray because I knew my friends wouldn't stop. Saving them didn't fix them, but dead can't recover."},
			{"speaker": "CAM", "line": "Focus capsules worked until I needed them to feel normal. Then they worked until I couldn't sleep without something else."},
			{"speaker": "FACILITATOR", "line": "Recognizing patterns in use, tolerance, and consequences is self-awareness, not self-blame."},
		],
		"prompts": [
			{"question": "Why did IRIS carry reversal spray?", "answers": ["To enable drug use", "To reverse overdoses and save lives", "To sell for profit"], "correct": 1},
			{"question": "What happened with CAM's prescribed stimulants?", "answers": ["They worked perfectly forever", "Tolerance grew and dependence developed", "Nothing significant"], "correct": 1},
			{"question": "Which reflects harm reduction principles?", "answers": ["Carrying reversal medication saves lives without endorsing use.", "Helping overdose victims enables their addiction.", "Only abstinence deserves medical support."], "correct": 0},
		],
	}, 
]

static func temporary_question_reward(choice_count: int, wrong_cost: int = 2) -> int:
	return maxi(0, choice_count - 1) * wrong_cost

static func random_guess_expected_score(choice_count: int, wrong_cost: int = 2) -> float:
	if choice_count < 2:
		return 0.0
	var reward: = float(temporary_question_reward(choice_count, wrong_cost))
	return reward / float(choice_count) - float(wrong_cost) * float(choice_count - 1) / float(choice_count)

static func invitation_token_valid(token: String) -> bool:
	if token.length() < 16 or token.length() > 64:
		return false
	for character in token:
		if character not in "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_":
			return false
	return true
