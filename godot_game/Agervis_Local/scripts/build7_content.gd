class_name Build7Content
extends RefCounted




const STREET_WIDTH: = 10550.0
const BUS_STOP_X: = 10200.0

const BUILDINGS: Array[Dictionary] = [
	{"id": "home", "x": 300.0, "width": 500.0, "label": "MUNICIPAL\nGROUP HOME", "color": "#5d7069", "wall": 0}, 
	{"id": "apartment", "x": 980.0, "width": 510.0, "label": "MERCY COURT\nAPARTMENTS", "color": "#665c58", "wall": 2}, 
	{"id": "school", "x": 1660.0, "width": 560.0, "label": "PUBLIC SCHOOL\nGED / SAFETY", "color": "#655f73", "wall": 3}, 
	{"id": "social", "x": 2340.0, "width": 520.0, "label": "DEPARTMENT OF\nHUMAN OBSTACLES", "color": "#6f705e", "wall": 4}, 
	{"id": "restaurant", "x": 3040.0, "width": 540.0, "label": "ALIBI'S\nALL-DAY CARRYOUT", "color": "#785548", "wall": 5}, 
	{"id": "debugshop", "x": 3650.0, "width": 180.0, "label": "DEBUG\nHUT", "color": "#ff1493", "wall": 0}, 
	{"id": "barber", "x": 3720.0, "width": 500.0, "label": "SECOND LOOK\nBARBER + BEAUTY", "color": "#526c68", "wall": 0}, 
	{"id": "laundromat", "x": 4380.0, "width": 520.0, "label": "SPIN CYCLE\nLAUNDRY", "color": "#546776", "wall": 1}, 
	{"id": "store", "x": 5100.0, "width": 560.0, "label": "BOSS'S\nCORNER STORE", "color": "#82684d", "wall": 2}, 
	{"id": "pawn", "x": 5820.0, "width": 520.0, "label": "PREVIOUSLY YOURS\nPAWN", "color": "#745e48", "wall": 3}, 
	{"id": "hospital", "x": 6540.0, "width": 570.0, "label": "MUNICIPAL\nCONSEQUENCE WARD", "color": "#58706d", "wall": 4}, 
	{"id": "precinct", "x": 7280.0, "width": 570.0, "label": "DEPARTMENT OF\nPUBLIC REASSURANCE", "color": "#4f6473", "wall": 5}, 
	{"id": "bank", "x": 8020.0, "width": 570.0, "label": "FIRST MUNICIPAL\nBANK", "color": "#50636b", "wall": 1}, 
	{"id": "pillmill", "x": 8700.0, "width": 520.0, "label": "DR. FEELBETTER\nPAIN + FOCUS", "color": "#79645b", "wall": 2}, 
	{"id": "clinic", "x": 9380.0, "width": 560.0, "label": "CONTINUING CARE\nOUTCOME CENTER", "color": "#5d7067", "wall": 4}, 
	{"id": "courthouse", "x": 10060.0, "width": 520.0, "label": "MUNICIPAL\nCOURTHOUSE", "color": "#6b6358", "wall": 3}, 
]

const ENTRY_POSITIONS: = {
	"home": Vector2(300, 215), "apartment": Vector2(980, 215), 
	"school": Vector2(1660, 215), "social": Vector2(2340, 215), 
	"restaurant": Vector2(3040, 215), "debugshop": Vector2(3650, 215), "barber": Vector2(3720, 215), 
	"laundromat": Vector2(4380, 215), "store": Vector2(5100, 215), 
	"pawn": Vector2(5820, 215), "hospital": Vector2(6540, 215), 
	"precinct": Vector2(7280, 215), "bank": Vector2(8020, 215), 
	"pillmill": Vector2(8700, 215), "clinic": Vector2(9380, 215), 
	"courthouse": Vector2(10060, 215), 
}

const INTERIOR_TINTS: = {
	"apartment": "#81736c", "social": "#8b8b72", "restaurant": "#936c58", 
	"barber": "#6f8a85", "laundromat": "#6d8390", "pawn": "#806c55", 
	"precinct": "#687e8a", "pillmill": "#8c756a", "clinic": "#789087", 
	"debugshop": "#ff69b4", 
}

const ITEM_DATA: = {
	"Group Home Key": {"kind": "KEY", "tag": "CLEAN", "description": "Opens the building. It does not persuade the residents."}, 
	"Phone": {"kind": "TOOL", "tag": "CLEAN", "description": "Local chat, contacts, and eventually a record somebody will subpoena."}, 
	"Prepared Tool": {"kind": "TOOL", "tag": "QUESTIONABLE", "description": "Preparation for a decision that will be described as spontaneous."}, 
	"Cafeteria Voucher": {"kind": "VOUCHER", "tag": "CLEAN", "description": "Redeemable for food with an educational aftertaste."}, 
	"Student Transit Pass": {"kind": "PASS", "tag": "CLEAN", "description": "A laminated argument against one transportation fee."}, 
	"Reflective Scholarship Backpack": {"kind": "GEAR", "tag": "CLEAN", "description": "Visible to traffic, institutions, and people who notice useful bags."}, 
	"Honor Roll Jacket": {"kind": "CLOTHING", "tag": "CLEAN", "description": "Academic achievement with pockets."}, 
	"Stolen Store Goods": {"kind": "GOODS", "tag": "STOLEN", "description": "Merchandise whose ownership history is still emotionally attached."}, 
	"Sealed Dime Bag": {"kind": "PACKAGE", "tag": "DIRTY", "description": "A sealed delivery. Curiosity converts trust into evidence."}, 
	"Sealed Quarter Bag": {"kind": "PACKAGE", "tag": "DIRTY", "description": "A larger sealed delivery issued after Moth mistakes repetition for character."}, 
	"Herb Ounce (28 g)": {"kind": "SUBSTANCE", "tag": "CONTRABAND", "description": "Wholesale herb inventory. Possession is simpler than explaining the margin."},
	"Herb Quarter Pound (4 oz)": {"kind": "SUBSTANCE", "tag": "CONTRABAND", "description": "Four ounces of wholesale herb and several future conversations with evidence storage."},
	"Herb Half Pound (8 oz)": {"kind": "SUBSTANCE", "tag": "CONTRABAND", "description": "Eight ounces of wholesale herb. The bag has become an operational opinion."},
	"Herb Pound (16 oz)": {"kind": "SUBSTANCE", "tag": "CONTRABAND", "description": "A pound of wholesale herb. Nobody carrying it is merely running an errand."}, 
	"Powder (point)": {"kind": "SUBSTANCE", "tag": "CONTRABAND", "description": "A 0.1 g dose. Its quality is unknown until a qualified Resident analyzes it."},
	"Powder (½gram)": {"kind": "SUBSTANCE", "tag": "CONTRABAND", "description": "A 0.5 g package. Its quality is unknown until a qualified Resident analyzes it."},
	"Powder (gram)": {"kind": "SUBSTANCE", "tag": "CONTRABAND", "description": "A 1 g package. Its quality is unknown until a qualified Resident analyzes it."},
	"Powder (8-ball)": {"kind": "SUBSTANCE", "tag": "CONTRABAND", "description": "A 3.5 g wholesale package. Its quality is unknown until a qualified Resident analyzes it."},
	"Powder (cue ball)": {"kind": "SUBSTANCE", "tag": "CONTRABAND", "description": "A 7 g wholesale package. Its quality is unknown until a qualified Resident analyzes it."},
	"Powder (½ zip)": {"kind": "SUBSTANCE", "tag": "CONTRABAND", "description": "A 14 g wholesale package. Its quality is unknown until a qualified Resident analyzes it."},
	"Powder (¾ zip)": {"kind": "SUBSTANCE", "tag": "CONTRABAND", "description": "A 21 g wholesale package. Its quality is unknown until a qualified Resident analyzes it."},
	"Powder (zip)": {"kind": "SUBSTANCE", "tag": "CONTRABAND", "description": "A 28 g wholesale package. The quantity is visible; the purity still requires a laboratory."},
	"Powder (QP)": {"kind": "SUBSTANCE", "tag": "CONTRABAND", "description": "A 112 g quarter-pound package. Its quality is unknown until a qualified Resident analyzes it."},
	"Powder (HP)": {"kind": "SUBSTANCE", "tag": "CONTRABAND", "description": "A 224 g half-pound package. Its quality is unknown until a qualified Resident analyzes it."},
	"Powder (¾P)": {"kind": "SUBSTANCE", "tag": "CONTRABAND", "description": "A 336 g three-quarter-pound package. Its quality is unknown until a qualified Resident analyzes it."},
	"Powder (P)": {"kind": "SUBSTANCE", "tag": "CONTRABAND", "description": "A 448 g pound package. Its quality is unknown until a qualified Resident analyzes it."}, 
	"Entrusted Deposit Bag": {"kind": "DEPOSIT", "tag": "TRUSTED", "description": "Business cash expected at the bank with the same amount and carrier."}, 
	"Restaurant Deposit": {"kind": "DEPOSIT", "tag": "TRUSTED", "description": "Alibi's dinner receipts, including receipts nobody remembers printing."}, 
	"Laundry Deposit": {"kind": "DEPOSIT", "tag": "TRUSTED", "description": "Coins and folded bills made heavy by everybody else's errands."}, 
	"Pawn Ticket": {"kind": "DOCUMENT", "tag": "CLEAN", "description": "Proof that an item changed hands under fluorescent supervision."}, 
	"Benefits Packet": {"kind": "DOCUMENT", "tag": "CLEAN", "description": "Nine pages confirming that help requires stamina."}, 
	"Apartment Application": {"kind": "DOCUMENT", "tag": "CLEAN", "description": "A request for walls whose approval depends on other walls."}, 
	# Pharmaceutical substances - prescription packs
	"Blackout™ (7-pack)": {"kind": "SUBSTANCE", "tag": "CONTROLLED", "description": "Seven-day supply. Bars prescribed for anxiety. Authenticity unknown until pressed."},
	"Blackout™ (30-pack)": {"kind": "SUBSTANCE", "tag": "CONTROLLED", "description": "Thirty-day supply. Bars prescribed for anxiety. Authenticity unknown until pressed."},
	"Blackout™ (90-pack)": {"kind": "SUBSTANCE", "tag": "CONTROLLED", "description": "Ninety-day supply. Bars prescribed for anxiety. Authenticity unknown until pressed."},
	"Blackout™ (single)": {"kind": "SUBSTANCE", "tag": "CONTROLLED", "description": "One bar from a blister pack. Delusions of sobriety for 15 seconds."},

	"NeverDone™ (7-pack)": {"kind": "SUBSTANCE", "tag": "CONTROLLED", "description": "Seven-day supply. Maintenance gel-caps. Authenticity unknown until pressed."},
	"NeverDone™ (30-pack)": {"kind": "SUBSTANCE", "tag": "CONTROLLED", "description": "Thirty-day supply. Maintenance gel-caps. Authenticity unknown until pressed."},
	"NeverDone™ (90-pack)": {"kind": "SUBSTANCE", "tag": "CONTROLLED", "description": "Ninety-day supply. Maintenance gel-caps. Authenticity unknown until pressed."},
	"NeverDone™ (single)": {"kind": "SUBSTANCE", "tag": "CONTROLLED", "description": "One gel-cap from a blister pack. Liquid handcuffs for 12 minutes."},

	"Subscriptxone™ (7-pack)": {"kind": "SUBSTANCE", "tag": "CONTROLLED", "description": "Seven-day supply. Maintenance pouches. Authenticity unknown until pressed."},
	"Subscriptxone™ (30-pack)": {"kind": "SUBSTANCE", "tag": "CONTROLLED", "description": "Thirty-day supply. Maintenance pouches. Authenticity unknown until pressed."},
	"Subscriptxone™ (90-pack)": {"kind": "SUBSTANCE", "tag": "CONTROLLED", "description": "Ninety-day supply. Maintenance pouches. Authenticity unknown until pressed."},
	"Subscriptxone™ (single)": {"kind": "SUBSTANCE", "tag": "CONTROLLED", "description": "One pouch from a box. Maintenance for 10 minutes."},

	"Addictrall XR™ (7-pack)": {"kind": "SUBSTANCE", "tag": "CONTROLLED", "description": "Seven-day supply. Focus capsules. Authenticity unknown until pressed."},
	"Addictrall XR™ (30-pack)": {"kind": "SUBSTANCE", "tag": "CONTROLLED", "description": "Thirty-day supply. Focus capsules. Authenticity unknown until pressed."},
	"Addictrall XR™ (90-pack)": {"kind": "SUBSTANCE", "tag": "CONTROLLED", "description": "Ninety-day supply. Focus capsules. Authenticity unknown until pressed."},
	"Addictrall XR™ (single)": {"kind": "SUBSTANCE", "tag": "CONTROLLED", "description": "One capsule from a blister pack. Hyper-focus for 6 minutes."},

	"Vassalium™ (7-pack)": {"kind": "SUBSTANCE", "tag": "CONTROLLED", "description": "Seven-day supply. Muscle relaxer caplets. Authenticity unknown until pressed."},
	"Vassalium™ (30-pack)": {"kind": "SUBSTANCE", "tag": "CONTROLLED", "description": "Thirty-day supply. Muscle relaxer caplets. Authenticity unknown until pressed."},
	"Vassalium™ (90-pack)": {"kind": "SUBSTANCE", "tag": "CONTROLLED", "description": "Ninety-day supply. Muscle relaxer caplets. Authenticity unknown until pressed."},
	"Vassalium™ (single)": {"kind": "SUBSTANCE", "tag": "CONTROLLED", "description": "One caplet from a blister pack. Muscle relaxer for 5 minutes."},

	"Rebillin™ (7-pack)": {"kind": "SUBSTANCE", "tag": "CONTROLLED", "description": "Seven-day supply. Appetite suppressant tabs. Authenticity unknown until pressed."},
	"Rebillin™ (30-pack)": {"kind": "SUBSTANCE", "tag": "CONTROLLED", "description": "Thirty-day supply. Appetite suppressant tabs. Authenticity unknown until pressed."},
	"Rebillin™ (90-pack)": {"kind": "SUBSTANCE", "tag": "CONTROLLED", "description": "Ninety-day supply. Appetite suppressant tabs. Authenticity unknown until pressed."},
	"Rebillin™ (single)": {"kind": "SUBSTANCE", "tag": "CONTROLLED", "description": "One tab from a blister pack. Stimulation for 5 minutes."},

	"Paper (10-pack)": {"kind": "SUBSTANCE", "tag": "CONTRABAND", "description": "Ten blotter strips. Authenticity unknown until pressed."},
	"Paper (single)": {"kind": "SUBSTANCE", "tag": "CONTRABAND", "description": "One blotter strip. Tracers and visual distortion for 5 minutes."},

	"Syrup (pint)": {"kind": "SUBSTANCE", "tag": "CONTROLLED", "description": "Sixteen ounces. The seal ensures authenticity until broken."},
	"Syrup (oz)": {"kind": "SUBSTANCE", "tag": "CONTROLLED", "description": "One ounce from a broken pint. Leaning and sluggish effects."},

	"Revivar (10-pack)": {"kind": "CONTINGENCY", "tag": "CLEAN", "description": "Ten spray pods. Emergency overdose reversal. It prevents a death, not a consequence."},
	"Revivar (single)": {"kind": "CONTINGENCY", "tag": "CLEAN", "description": "One spray pod. Reverses opioid overdose instantly. Violent reset included."},

	# Street substances - packaged by weight
	"China (1g)": {"kind": "SUBSTANCE", "tag": "CONTRABAND", "description": "One gram in a vial. Breaks into 10 doses. Lethal without reversal."},
	"China (0.1g dose)": {"kind": "SUBSTANCE", "tag": "CONTRABAND", "description": "One loose 0.1g dose. Triage heal with 15-second overdose clock."},

	"Tar (1g)": {"kind": "SUBSTANCE", "tag": "CONTRABAND", "description": "One gram in foil bind. Breaks into 10 doses. The nod and lethargy."},
	"Tar (0.1g dose)": {"kind": "SUBSTANCE", "tag": "CONTRABAND", "description": "One loose 0.1g prep. Instant vitality restore with 30-second lethargy."},

	"Crystal (1g)": {"kind": "SUBSTANCE", "tag": "CONTRABAND", "description": "One gram in a baggie. Breaks into 10 points. Tweaking with body degradation."},
	"Crystal (0.1g dose)": {"kind": "SUBSTANCE", "tag": "CONTRABAND", "description": "One loose 0.1g point. Muscle and attack speed boost for 3 minutes."},

	"Rock (1g)": {"kind": "SUBSTANCE", "tag": "CONTRABAND", "description": "One gram in a vial. Breaks into 10 hits. Bell-ringer with the crash."},
	"Rock (0.1g dose)": {"kind": "SUBSTANCE", "tag": "CONTRABAND", "description": "One loose 0.1g hit. Muscle boost and special attack regen for 15 seconds."},

	"Special (1g)": {"kind": "SUBSTANCE", "tag": "CONTRABAND", "description": "One gram in a baggie. Breaks into 10 bumps. K-hole damage reflection."},
	"Special (0.1g dose)": {"kind": "SUBSTANCE", "tag": "CONTRABAND", "description": "One loose 0.1g bump. Damage reflection with 4-second sensory disconnect."},

	"Dust (1g)": {"kind": "SUBSTANCE", "tag": "CONTRABAND", "description": "One gram in a baggie. Breaks into 10 doses. Juggernaut with tissue damage."},
	"Dust (0.1g dose)": {"kind": "SUBSTANCE", "tag": "CONTRABAND", "description": "One loose 0.1g dose. CC reduction and muscle boost. Disables healing items."},

	"Caps (1g)": {"kind": "SUBSTANCE", "tag": "CONTRABAND", "description": "One gram in a baggie. Breaks into 10 doses. Ego death reduces aggro."},
	"Caps (0.1g dose)": {"kind": "SUBSTANCE", "tag": "CONTRABAND", "description": "One loose 0.1g dose. NPCs ignore you for 45 seconds. Minimap disabled."},

	"Herb (1g)": {"kind": "SUBSTANCE", "tag": "CONTRABAND", "description": "One gram in a baggie. Breaks into 10 bowls. Medication with couch-lock."},
	"Herb (0.1g dose)": {"kind": "SUBSTANCE", "tag": "CONTRABAND", "description": "One loose 0.1g bowl. Composure and run energy regen for 5 minutes."},

	# Weapons
	"Worn Revolver": {"kind": "WEAPON", "tag": "ILLEGAL", "description": "Six chambers. The grip remembers someone else's sweat."},
	"Pipe Wrench": {"kind": "WEAPON", "tag": "TOOL", "description": "Heavy adjustable wrench. Plumbing tool with negotiation capacity."},
	"Bolt Cutters": {"kind": "WEAPON", "tag": "TOOL", "description": "Long-handled cutters. Opens locks and closes arguments."},
	"Box Cutter": {"kind": "WEAPON", "tag": "TOOL", "description": "Retractable utility blade. Warehouse standard and street backup."},
	"Kitchen Knife": {"kind": "WEAPON", "tag": "TOOL", "description": "Chef's knife. Cuts vegetables and credibility."},
	"Baseball Bat": {"kind": "WEAPON", "tag": "SPORTING", "description": "Wooden bat. No ball required."},
	"Crowbar": {"kind": "WEAPON", "tag": "TOOL", "description": "Pry bar. Opens doors and closes distance."},
	"Tire Iron": {"kind": "WEAPON", "tag": "TOOL", "description": "Lug wrench. Automotive tool with persuasive weight."},

	# Legacy items kept for compatibility
	"Clinic Comfort Dose": {"kind": "SUBSTANCE", "tag": "CONTROLLED", "description": "A monitored dose whose brochure uses the word freedom cautiously."},
}

static func building(area_id: String) -> Dictionary:
	for entry in BUILDINGS:
		if String(entry["id"]) == area_id:
			return entry
	return {}

static func item_info(item_name: String) -> Dictionary:
	return ITEM_DATA.get(item_name, {"kind": "ITEM", "tag": "CLEAN", "description": "A physical item with an ordinary amount of history."})
