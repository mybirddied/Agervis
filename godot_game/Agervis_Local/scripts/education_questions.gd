class_name AgervisEducationQuestions
extends RefCounted



const QUESTIONS = [
	{"subject": "Math", "question": "A deposit has three $20 bills and five $10 bills. What is the total?", "answers": ["$90", "$110", "$130"], "correct": 1}, 
	{"subject": "Math", "question": "A cashier works 6 hours at $12 per hour. Gross pay is...", "answers": ["$62", "$72", "$82"], "correct": 1}, 
	{"subject": "Math", "question": "One quarter of 80 is...", "answers": ["16", "20", "24"], "correct": 1}, 
	{"subject": "Math", "question": "A $45 item is discounted by $5. The new price is...", "answers": ["$40", "$41", "$50"], "correct": 0}, 
	{"subject": "Math", "question": "A bus arrives every 15 minutes. Four intervals equal...", "answers": ["45 minutes", "60 minutes", "75 minutes"], "correct": 1}, 
	{"subject": "Math", "question": "Which fraction is equal to one half?", "answers": ["2/4", "2/3", "3/5"], "correct": 0}, 
	{"subject": "Math", "question": "The average of 6, 8, and 10 is...", "answers": ["7", "8", "9"], "correct": 1}, 
	{"subject": "Math", "question": "A rectangle is 5 feet long and 3 feet wide. Its area is...", "answers": ["8 square feet", "15 square feet", "16 square feet"], "correct": 1}, 
	{"subject": "Math", "question": "If 3 notebooks cost $9 total, one notebook costs...", "answers": ["$2", "$3", "$6"], "correct": 1}, 
	{"subject": "Math", "question": "A balance changes from $120 to $85. How much was spent?", "answers": ["$25", "$35", "$45"], "correct": 1}, 
	{"subject": "Math", "question": "Ten percent of $250 is...", "answers": ["$20", "$25", "$50"], "correct": 1}, 
	{"subject": "Math", "question": "Solve: 4x = 28.", "answers": ["x = 6", "x = 7", "x = 8"], "correct": 1}, 
	{"subject": "Reading", "question": "Which sentence states a fact rather than an opinion?", "answers": ["The store opens at 8.", "The store is depressing.", "The clerk is annoying."], "correct": 0}, 
	{"subject": "Reading", "question": "A warning says 'Do not mix with alcohol.' Its main purpose is to...", "answers": ["Entertain", "Prevent harm", "Advertise"], "correct": 1}, 
	{"subject": "Reading", "question": "Which source is most useful for confirming a posted bus schedule?", "answers": ["A transit timetable", "A stranger's guess", "An old movie"], "correct": 0}, 
	{"subject": "Reading", "question": "In 'The rain stopped, so the game resumed,' what caused the game to resume?", "answers": ["The rain stopped", "The game ended", "The field closed"], "correct": 0}, 
	{"subject": "Reading", "question": "Which is the clearest revision?", "answers": ["He went there fastly.", "He quickly went there.", "Him went quick there."], "correct": 1}, 
	{"subject": "Reading", "question": "A paragraph's main idea is...", "answers": ["Its central point", "Its longest word", "Its final comma"], "correct": 0}, 
	{"subject": "Reading", "question": "Which word best signals a contrast?", "answers": ["Therefore", "However", "Similarly"], "correct": 1}, 
	{"subject": "Reading", "question": "Which sentence uses an apostrophe correctly?", "answers": ["The clerks coat is wet.", "The clerk's coat is wet.", "The clerks' coat is wet."], "correct": 1}, 
	{"subject": "Science", "question": "Water freezes at what temperature on the Celsius scale?", "answers": ["0 degrees", "32 degrees", "100 degrees"], "correct": 0}, 
	{"subject": "Science", "question": "Which organ pumps blood through the body?", "answers": ["Lung", "Heart", "Kidney"], "correct": 1}, 
	{"subject": "Science", "question": "Plants use sunlight to help make food through...", "answers": ["Photosynthesis", "Evaporation", "Erosion"], "correct": 0}, 
	{"subject": "Science", "question": "Which state of matter has a fixed volume but takes the shape of its container?", "answers": ["Solid", "Liquid", "Gas"], "correct": 1}, 
	{"subject": "Science", "question": "The force pulling objects toward Earth is...", "answers": ["Gravity", "Friction", "Electricity"], "correct": 0}, 
	{"subject": "Science", "question": "Which is a renewable energy source?", "answers": ["Coal", "Solar", "Gasoline"], "correct": 1}, 
	{"subject": "Science", "question": "A hypothesis should be...", "answers": ["Testable", "Secret", "Guaranteed true"], "correct": 0}, 
	{"subject": "Health", "question": "Which action most directly reduces infection spread?", "answers": ["Hand washing", "Skipping sleep", "Sharing cups"], "correct": 0}, 
	{"subject": "Health", "question": "If a person may be overdosing, the safest first response includes...", "answers": ["Leave them alone", "Call emergency help", "Make them walk"], "correct": 1}, 
	{"subject": "Health", "question": "Tolerance means a person may need more of a substance to get...", "answers": ["The same effect", "More sleep", "A clean record"], "correct": 0}, 
	{"subject": "Civics", "question": "Which document generally authorizes a property search?", "answers": ["A warrant", "A rumor", "A uniform"], "correct": 0}, 
	{"subject": "Civics", "question": "The main purpose of a jury is to...", "answers": ["Write laws", "Evaluate a case", "Run elections"], "correct": 1}, 
	{"subject": "Civics", "question": "Which branch commonly interprets laws?", "answers": ["Judicial", "Legislative", "Executive"], "correct": 0}, 
	{"subject": "Civics", "question": "A local election is usually decided by...", "answers": ["Eligible voters", "One employer", "A random store"], "correct": 0}, 
	{"subject": "Civics", "question": "Due process is meant to require government to use...", "answers": ["Fair legal procedures", "Faster rumors", "Private favors"], "correct": 0}, 
	{"subject": "Civics", "question": "A conflict of interest exists when an official's decision may benefit...", "answers": ["Their private interest", "Public notice", "A calendar"], "correct": 0}, 
	{"subject": "Civics", "question": "Which level of government commonly manages city streets?", "answers": ["Local government", "A private classroom", "A foreign court"], "correct": 0}, 
	{"subject": "Legal literacy", "question": "Which source is independent evidence?", "answers": ["The same copied rumor", "A separate camera", "A louder accusation"], "correct": 1}, 
	{"subject": "Legal literacy", "question": "Chain of custody records...", "answers": ["Who handled evidence", "Who won an election", "Who owns a sidewalk"], "correct": 0}, 
	{"subject": "Legal literacy", "question": "Deleting a recording may remove the clip but still leave...", "answers": ["An audit gap", "No trace at all", "A diploma"], "correct": 0}, 
	{"subject": "Finance", "question": "If gross income is $200 and costs are $140, net income is...", "answers": ["$40", "$60", "$340"], "correct": 1}, 
	{"subject": "Finance", "question": "Interest paid on a savings account generally causes the balance to...", "answers": ["Increase", "Disappear", "Become evidence"], "correct": 0}, 
	{"subject": "Finance", "question": "Which expense is usually fixed each month?", "answers": ["Rent", "Impulse snacks", "Random fines"], "correct": 0}, 
	{"subject": "Finance", "question": "A budget is primarily a plan for...", "answers": ["Income and spending", "Changing weather", "Court testimony"], "correct": 0}, 
	{"subject": "Finance", "question": "A receipt is useful because it documents...", "answers": ["A transaction", "A rumor", "A person's mood"], "correct": 0}, 
	{"subject": "Finance", "question": "Insurance usually pools many people's payments to cover...", "answers": ["Specified losses", "Every inconvenience", "Guaranteed profit"], "correct": 0}, 
	{"subject": "Finance", "question": "Borrowing $100 and repaying $110 means the extra $10 is...", "answers": ["Interest", "Inventory", "A scholarship"], "correct": 0}, 
	{"subject": "Work", "question": "A pay stub normally shows wages and...", "answers": ["Deductions", "Weather", "Test scores"], "correct": 0}, 
	{"subject": "Work", "question": "Which response best handles an unclear work instruction?", "answers": ["Ask for clarification", "Invent a policy", "Hide the task"], "correct": 0}, 
	{"subject": "Work", "question": "A credential mainly demonstrates...", "answers": ["Verified qualification", "Guaranteed honesty", "Unlimited access"], "correct": 0}, 
	{"subject": "Digital literacy", "question": "A strong password is best described as...", "answers": ["Long and unique", "Your first name", "The word password"], "correct": 0}, 
	{"subject": "Digital literacy", "question": "A message demanding immediate payment through a strange link may be...", "answers": ["Phishing", "A diploma", "A weather alert"], "correct": 0}, 
	{"subject": "Digital literacy", "question": "Metadata can describe a file's time, source, or...", "answers": ["Location", "Moral value", "Future verdict"], "correct": 0}, 
	{"subject": "Digital literacy", "question": "Two-factor authentication adds...", "answers": ["Another verification step", "A second username", "Public access"], "correct": 0}, 
	{"subject": "Evidence", "question": "A camera timestamp that disagrees with a witness should be...", "answers": ["Investigated", "Automatically erased", "Treated as a confession"], "correct": 0}, 
	{"subject": "Evidence", "question": "Corroboration means information is...", "answers": ["Supported by another source", "Repeated by one person", "Written in capital letters"], "correct": 0}, 
	{"subject": "Evidence", "question": "Which observation is most specific?", "answers": ["A person entered at 9:14", "Something happened", "The block felt weird"], "correct": 0}, 
	{"subject": "Life skills", "question": "Before signing a contract, a person should first...", "answers": ["Read its terms", "Assume it is fair", "Lose their copy"], "correct": 0}, 
	{"subject": "Life skills", "question": "A smoke alarm's main purpose is to...", "answers": ["Warn of possible fire", "Measure rent", "Unlock a door"], "correct": 0}, 
	{"subject": "Life skills", "question": "When two medicines may interact, the safest source to consult is...", "answers": ["A pharmacist or clinician", "An anonymous boast", "A vending machine"], "correct": 0}, 
]




const SKILL_QUESTIONS: = {
	"Intelligence": [
		{"subject": "Intelligence", "question": "A P.A.T.H. file makes a claim with no source. What is the sensible first step?", "answers": ["Look for supporting evidence", "Repeat it louder", "File it as fact", "Ignore every source"], "correct": 0}, 
		{"subject": "Intelligence", "question": "A total does not match the listed numbers. What should you do?", "answers": ["Check the arithmetic", "Sign it anyway", "Delete the list", "Ask the wall"], "correct": 0}, 
	], 
	"Endurance": [
		{"subject": "Endurance", "question": "Before a long run, the safest first choice is to...", "answers": ["Warm up and pace yourself", "Sprint at full speed", "Skip water", "Carry more than you can hold"], "correct": 0}, 
		{"subject": "Endurance", "question": "If your stamina is nearly gone, the useful move is to...", "answers": ["Recover before the next obstacle", "Force another sprint", "Pretend the meter is decorative", "Pick a fight"], "correct": 0}, 
	], 
	"Agility": [
		{"subject": "Agility", "question": "When landing from a low drop, you should...", "answers": ["Bend your knees", "Lock your knees", "Land on one toe", "Close your eyes"], "correct": 0}, 
		{"subject": "Agility", "question": "A climb route has a weak rail. The best first decision is to...", "answers": ["Check the route and stamina", "Assume it is safe", "Run into it sideways", "Throw your bag first"], "correct": 0}, 
	], 
	"Fighting": [
		{"subject": "Fighting", "question": "When somebody is angry and close, the first useful goal is to...", "answers": ["Make space and read the situation", "Swing without looking", "Stand cornered", "Drop your balance"], "correct": 0}, 
		{"subject": "Fighting", "question": "Good defense begins by protecting your...", "answers": ["Balance and awareness", "Rumor score", "Inventory labels", "Hair color"], "correct": 0}, 
	], 
	"Firearms": [
		{"subject": "Firearms", "question": "A firearm should stay pointed...", "answers": ["In a safe direction", "At the ceiling for comedy", "At a friend", "At your own foot"], "correct": 0}, 
		{"subject": "Firearms", "question": "Your finger belongs off the trigger until...", "answers": ["You have made a safe, deliberate decision", "You are showing somebody the grip", "You are cleaning it", "You are walking past a camera"], "correct": 0}, 
	], 
	"Stealth": [
		{"subject": "Stealth", "question": "The safest way to move through a crowded place is to...", "answers": ["Notice exits and avoid collisions", "Run into everybody", "Stare at one spot", "Announce every step"], "correct": 0}, 
		{"subject": "Stealth", "question": "A live camera records an offense. What can that recording create?", "answers": ["Evidence and Heat", "Automatic guilt without review", "A harmless decoration", "A private thought"], "correct": 0}, 
	], 
	"Awareness": [
		{"subject": "Awareness", "question": "In an unfamiliar room, it helps to notice...", "answers": ["Exits and people nearby", "Only the floor", "Nothing until trouble starts", "Your reflection"], "correct": 0}, 
		{"subject": "Awareness", "question": "A sound changes behind you. A good response is to...", "answers": ["Check your surroundings", "Keep staring forward", "Drop your phone", "Assume it is weather"], "correct": 0}, 
	], 
	"Safety": [
		{"subject": "Safety", "question": "Before entering a restricted room for work, you should...", "answers": ["Confirm you are authorized", "Borrow a uniform", "Hope the door knows you", "Ask a stranger to guess"], "correct": 0}, 
		{"subject": "Safety", "question": "An incident report is most useful when it records...", "answers": ["Specific observed details", "Only a feeling", "A rumor with extra punctuation", "Nothing inconvenient"], "correct": 0}, 
	], 
	"Medicine": [
		{"subject": "Medicine", "question": "If somebody may be having an overdose, the safe first response includes...", "answers": ["Calling emergency help", "Leaving them alone", "Making them run", "Waiting for a rumor"], "correct": 0}, 
		{"subject": "Medicine", "question": "Medication instructions matter because...", "answers": ["Drugs can have effects and risks", "Labels are decorative", "Every dose is identical for everyone", "Receipts change biology"], "correct": 0}, 
	], 
	"Chemistry": [
		{"subject": "Chemistry", "question": "Before combining two unknown substances, the safest first step is to...", "answers": ["Identify them and check their hazards", "Mix a small amount by hand", "Smell both closely", "Ask which color looks safer"], "correct": 0}, 
		{"subject": "Chemistry", "question": "A labeled sample is more useful than an unlabeled one because the label...", "answers": ["Preserves its identity and handling information", "Makes it react faster", "Guarantees it is harmless", "Replaces protective equipment"], "correct": 0}, 
	], 
	"Cooking": [
		{"subject": "Cooking", "question": "Before preparing food, the useful first step is to...", "answers": ["Clean your hands and work area", "Taste every ingredient", "Turn on every burner", "Hide the expiration labels"], "correct": 0},
		{"subject": "Cooking", "question": "Raw food should stay away from ready-to-eat food mainly to...", "answers": ["Prevent cross-contamination", "Keep the counter symmetrical", "Make both foods colder", "Reduce the number of plates"], "correct": 0},
	],
	"Greenthumb": [
		{"subject": "Greenthumb", "question": "A seedling's growth depends heavily on receiving the right amount of...", "answers": ["Compliments", "Sunlight and water", "Noise", "Sharp objects"], "correct": 1},
		{"subject": "Greenthumb", "question": "An unidentified plant should be checked against references before handling because...", "answers": ["It might listen to you", "Plants prefer anonymity", "Identification slows all growth", "Some plants are toxic or dangerous"], "correct": 3},
	],
	"Vehicle": [
		{"subject": "Vehicle", "question": "Before operating any vehicle, a sensible first check is to verify...", "answers": ["Your favorite song is playing", "Nobody is watching", "Brakes, steering, and fuel level", "The steering wheel is loose"], "correct": 2},
		{"subject": "Vehicle", "question": "A warning light on a vehicle's dashboard should typically be...", "answers": ["Covered with tape", "Investigated before ignoring it", "Used as a nightlight", "Assumed to be decorative"], "correct": 1},
	],
	"Influence": [
		{"subject": "Influence", "question": "To persuade someone responsibly, start by...", "answers": ["Listening to what they need", "Talking over them", "Inventing a threat", "Changing the subject"], "correct": 0}, 
		{"subject": "Influence", "question": "A promise is more credible when it is...", "answers": ["Specific and possible", "Vague and dramatic", "Louder than facts", "Signed by a stranger"], "correct": 0}, 
	], 
	"Enterprise": [
		{"subject": "Enterprise", "question": "A business needs a record of sales mainly to...", "answers": ["Track money and stock", "Make receipts mysterious", "Avoid all math", "Decorate a safe"], "correct": 0}, 
		{"subject": "Enterprise", "question": "Before taking a job task, you should know...", "answers": ["What result is expected", "Only the pay rumor", "Who is watching", "Which answer sounds coolest"], "correct": 0}, 
	], 
	"Civics": [
		{"subject": "Civics", "question": "A warrant generally authorizes...", "answers": ["A specified legal search", "Any rumor somebody repeats", "A new job title", "A private favor"], "correct": 0}, 
		{"subject": "Civics", "question": "A fair complaint is easier to review when it includes...", "answers": ["Dates and specific facts", "Only insults", "A different person's story", "No details at all"], "correct": 0}, 
		{"subject": "Civics", "question": "At Heat 25, an active case first becomes...", "answers": ["A lead", "Probable cause", "Proof", "An automatic conviction"], "correct": 0}, 
		{"subject": "Civics", "question": "At Heat 50, a qualified LEO may use...", "answers": ["Temporary detention for review", "Automatic conviction", "Permanent punishment", "Property seizure without a record"], "correct": 0}, 
		{"subject": "Civics", "question": "At Heat 55, the case reaches...", "answers": ["Probable cause supporting a warrant", "Proof beyond review", "No legal significance", "Automatic release"], "correct": 0}, 
		{"subject": "Civics", "question": "At Heat 90, the case is classified as...", "answers": ["Proof", "A rumor", "A private favor", "Temporary detention only"], "correct": 0}, 
		{"subject": "Civics", "question": "At Heat 100, a qualified LEO may arrest without...", "answers": ["A separate warrant", "Lawful authority", "An identified Resident", "A custody record"], "correct": 0}, 
		{"subject": "Civics", "question": "An explicit warrant below Heat 100 may...", "answers": ["Authorize an arrest", "Erase the case", "Create M.A.R.K.", "Guarantee a conviction"], "correct": 0}, 
		{"subject": "Civics", "question": "M.A.R.K. changes permanent-harm odds, but it does not replace...", "answers": ["Lawful cause for arrest", "A clothing layer", "A job title", "A room identifier"], "correct": 0}, 
		{"subject": "Civics", "question": "Surrender during custody may reduce sentence consequences, but it does not...", "answers": ["Erase evidence or legal cause", "End the struggle sooner", "Record cooperation", "Affect processing"], "correct": 0}, 
		{"subject": "Civics", "question": "Offering an official a bribe may create...", "answers": ["Bribery evidence and more Heat", "Automatic immunity", "A valid warrant dismissal", "Home-territory protection"], "correct": 0}, 
		{"subject": "Civics", "question": "Home territory provides faster help and a small witness-response advantage, but not...", "answers": ["Immunity or altered d16 odds", "A familiar location", "Nearby relationships", "A housing record"], "correct": 0}, 
	], 
}

static func questions_for_skill(skill_name: String) -> Array:
	return Array(SKILL_QUESTIONS.get(skill_name, [])).duplicate(true)
