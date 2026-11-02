class_name AgervisRoomObjects
extends RefCounted









const SCHEMA_VERSION: = 1

const ROOM_OBJECTS: = {
	"tutorial:guidance": [
		{"local_id": "counselor", "object_id": "npc.guidance_counselor", "graphic_id": "character.ms_vale.v1", "fixture_id": "tutorial_counselor", "position": Vector2(500, 175), "depth": 175.0, "priority": 1, "interactive": true, "action_id": "tutorial_counselor", "label": "MS. VALE", "radius": 92.0, "phase": "tutorial"}, 
		{"local_id": "bookshelf", "object_id": "fixture.bookshelf", "graphic_id": "fixture.guidance.bookshelf.v1", "position": Vector2(31, 230), "depth": 230.0, "priority": 0, "interactive": false, "solid_rect": Rect2(5, 170, 52, 120), "phase": "tutorial"}, 
		{"local_id": "plant_pot", "object_id": "fixture.plant_pot", "graphic_id": "fixture.guidance.plant.v1", "position": Vector2(95, 305), "depth": 305.0, "priority": 0, "interactive": false, "solid_rect": Rect2(79, 293, 32, 26), "phase": "tutorial"}, 
		{"local_id": "career_poster", "object_id": "fixture.career_poster", "graphic_id": "fixture.guidance.career_poster.v1", "position": Vector2(164, 181), "depth": 181.0, "priority": 0, "interactive": false, "solid_rect": Rect2(75, 147, 178, 68), "phase": "tutorial"}, 
	], 
	"tutorial:orientation": [
		{"local_id": "pike", "object_id": "npc.law_officer", "graphic_id": "character.officer_pike.v1", "fixture_id": "tutorial_pike", "position": Vector2(639, 190), "depth": 190.0, "priority": 1, "interactive": true, "action_id": "tutorial_pike", "label": "OFFICER PIKE", "radius": 82.0, "phase": "tutorial"}, 
		{"local_id": "detainee", "object_id": "npc.restrained_guest", "graphic_id": "character.tutorial_detainee.v1", "fixture_id": "tutorial_detainee", "position": Vector2(680, 190), "depth": 190.0, "priority": 1, "interactive": true, "action_id": "tutorial_detainee", "label": "DOZ'S FATHER - RESTRAINED", "radius": 82.0, "phase": "tutorial"}, 
	], 
	"tutorial:orientation_hall": [
		{"local_id": "directory", "object_id": "fixture.school_directory", "graphic_id": "fixture.school_directory.v1", "position": Vector2(280, 185), "depth": 185.0, "priority": 0, "interactive": false}, 
		{"local_id": "trophy_case", "object_id": "fixture.trophy_case", "graphic_id": "fixture.school_trophy.v1", "render_mode": "workstation", "position": Vector2(620, 200), "depth": 200.0, "priority": 2, "interactive": false, "body": "#5d6258", "solid_rect": Rect2(545, 188, 150, 30)}, 
		{"local_id": "bench", "object_id": "furniture.hall_bench", "graphic_id": "fixture.school_bench.v1", "render_mode": "workstation", "position": Vector2(920, 270), "depth": 270.0, "priority": 2, "interactive": false, "body": "#4d4d48", "solid_rect": Rect2(830, 255, 180, 30)}, 
	], 
	"tutorial:hall_a": [
		{"local_id": "student_guide", "object_id": "npc.tutorial_student_guide", "graphic_id": "character.tutorial_student_guide.v1", "fixture_id": "tutorial_student_guide", "position": Vector2(170, 190), "depth": 190.0, "priority": 1, "interactive": true, "action_id": "tutorial_student_guide", "label": "HALLWAY STUDENT", "radius": 86.0, "phase": "tutorial"}, 
		{"local_id": "doz", "object_id": "npc.tutorial_child", "graphic_id": "character.doz.v1", "fixture_id": "tutorial_doz", "position": Vector2(315, 215), "depth": 215.0, "priority": 1, "interactive": true, "action_id": "tutorial_doz", "label": "DOZ", "radius": 82.0, "phase": "tutorial"}, 
		{"local_id": "water_fountain", "object_id": "fixture.water_fountain", "graphic_id": "fixture.school_fountain.v1", "position": Vector2(640, 195), "depth": 195.0, "priority": 0, "interactive": false}, 
		{"local_id": "lockers", "object_id": "fixture.school_lockers", "graphic_id": "fixture.school_lockers.v1", "position": Vector2(880, 185), "depth": 185.0, "priority": 0, "interactive": false}, 
	], 
	"tutorial:hall_b": [
		{"local_id": "lockers_left", "object_id": "fixture.school_lockers", "graphic_id": "fixture.school_lockers.left.v1", "position": Vector2(220, 185), "depth": 185.0, "priority": 0, "interactive": false}, 
		{"local_id": "bulletin", "object_id": "fixture.bulletin_board", "graphic_id": "fixture.school_bulletin.v1", "position": Vector2(520, 180), "depth": 180.0, "priority": 0, "interactive": false}, 
		{"local_id": "water_fountain", "object_id": "fixture.water_fountain", "graphic_id": "fixture.school_fountain.v1", "position": Vector2(780, 195), "depth": 195.0, "priority": 0, "interactive": false}, 
	], 
	"tutorial:career_wing": [
		{"local_id": "career_posters", "object_id": "fixture.career_posters", "graphic_id": "fixture.school_career_wall.v1", "position": Vector2(260, 180), "depth": 180.0, "priority": 0, "interactive": false}, 
		{"local_id": "scholarship_display", "object_id": "fixture.scholarship_display", "graphic_id": "fixture.school_scholarship_display.v1", "position": Vector2(680, 185), "depth": 185.0, "priority": 0, "interactive": false}, 
		{"local_id": "bench", "object_id": "furniture.hall_bench", "graphic_id": "fixture.school_bench.v1", "render_mode": "workstation", "position": Vector2(920, 260), "depth": 260.0, "priority": 2, "interactive": false, "body": "#4d4d48", "solid_rect": Rect2(830, 245, 180, 30)}, 
	], 
	"tutorial:service_exit": [
		{"local_id": "exit_sign", "object_id": "fixture.exit_sign", "graphic_id": "fixture.exit_sign.v1", "position": Vector2(500, 120), "depth": 120.0, "priority": 0, "interactive": false}, 
		{"local_id": "trash_bin", "object_id": "fixture.trash_bin", "graphic_id": "fixture.industrial_bin.v1", "render_mode": "workstation", "position": Vector2(280, 245), "depth": 245.0, "priority": 2, "interactive": false, "body": "#3a4240", "solid_rect": Rect2(240, 230, 80, 32)}, 
	], 
	"tutorial:gym_a": [
		{"local_id": "left_goal", "object_id": "fixture.school_basketball_goal", "graphic_id": "fixture.school.agility_goal.clean.left.v1", "render_mode": "gym_goal", "position": Vector2(82, 175), "depth": 112.0, "priority": 0, "interactive": false, "mirrored": false, "condition": "clean", "phase": "tutorial"}, 
		{"local_id": "controls_coach", "object_id": "npc.tutorial_controls_coach", "graphic_id": "character.tutorial_controls_coach.v1", "fixture_id": "tutorial_controls_coach", "position": Vector2(220, 190), "depth": 190.0, "priority": 1, "interactive": true, "action_id": "tutorial_controls_coach", "label": "MOVEMENT COACH", "radius": 92.0, "phase": "tutorial", "skill_name": "Agility"}, 
	], 
	"tutorial:gym_b": [
		{"local_id": "right_goal", "object_id": "fixture.school_basketball_goal", "graphic_id": "fixture.school.agility_goal.clean.right.v1", "render_mode": "gym_goal", "position": Vector2(930, 175), "depth": 112.0, "priority": 0, "interactive": false, "mirrored": true, "condition": "clean", "phase": "tutorial"}, 
		{"local_id": "rope", "object_id": "training.agility_rope", "graphic_id": "fixture.school.agility_rope.clean.v1", "render_mode": "gym_obstacle", "position": Vector2(250, 215), "depth": 205.0, "priority": 2, "interactive": true, "action_id": "gym_obstacle", "label": "ROPE CLIMB", "prompt": "climb practice rope", "radius": 112.0, "obstacle_kind": "rope", "training_id": "agility_gym_rope", "stamina": 8.0, "condition": "clean", "phase": "tutorial"}, 
		{"local_id": "ledge", "object_id": "training.agility_ledge", "graphic_id": "fixture.school.agility_ledge.clean.v1", "render_mode": "gym_obstacle", "position": Vector2(525, 210), "depth": 210.0, "priority": 2, "interactive": true, "action_id": "gym_obstacle", "label": "LEDGE WALK", "prompt": "cross practice ledge", "radius": 118.0, "obstacle_kind": "ledge", "training_id": "agility_gym_ledge", "stamina": 7.0, "condition": "clean", "solid_rect": Rect2(455, 202, 140, 28), "phase": "tutorial"}, 
		{"local_id": "vault", "object_id": "training.agility_vault", "graphic_id": "fixture.school.agility_vault.clean.v1", "render_mode": "gym_obstacle", "position": Vector2(730, 215), "depth": 215.0, "priority": 2, "interactive": true, "action_id": "gym_obstacle", "label": "PADDED VAULT", "prompt": "vault practice horse", "radius": 112.0, "obstacle_kind": "vault", "training_id": "agility_gym_vault", "stamina": 9.0, "condition": "clean", "solid_rect": Rect2(675, 202, 110, 30), "phase": "tutorial"}, 
	], 
	"school:guidance": [
		{"local_id": "counselor", "object_id": "npc.guidance_counselor", "graphic_id": "character.ms_vale.v1", "fixture_id": "tutorial_counselor", "position": Vector2(500, 175), "depth": 175.0, "priority": 1, "interactive": true, "action_id": "tutorial_counselor", "label": "MS. VALE", "radius": 92.0, "phase": "tutorial"}, 
		{"local_id": "bookshelf", "object_id": "fixture.bookshelf", "graphic_id": "fixture.guidance.bookshelf.v1", "position": Vector2(31, 230), "depth": 230.0, "priority": 0, "interactive": false, "solid_rect": Rect2(5, 170, 52, 120)}, 
		{"local_id": "plant_pot", "object_id": "fixture.plant_pot", "graphic_id": "fixture.guidance.plant.v1", "position": Vector2(95, 305), "depth": 305.0, "priority": 0, "interactive": false, "solid_rect": Rect2(79, 293, 32, 26)}, 
		{"local_id": "career_poster", "object_id": "fixture.career_poster", "graphic_id": "fixture.guidance.career_poster.v1", "position": Vector2(164, 181), "depth": 181.0, "priority": 0, "interactive": false, "solid_rect": Rect2(75, 147, 178, 68)}, 
	], 
	"school:orientation": [
		{"local_id": "pike", "object_id": "npc.law_officer", "graphic_id": "character.officer_pike.v1", "fixture_id": "tutorial_pike", "position": Vector2(654, 190), "depth": 190.0, "priority": 1, "interactive": true, "action_id": "tutorial_pike", "label": "OFFICER PIKE", "radius": 90.0, "phase": "tutorial"}, 
		{"local_id": "detainee", "object_id": "npc.restrained_guest", "graphic_id": "character.tutorial_detainee.v1", "fixture_id": "tutorial_detainee", "position": Vector2(740, 190), "depth": 190.0, "priority": 1, "interactive": true, "action_id": "tutorial_detainee", "label": "RESTRAINED DETAINEE", "radius": 90.0, "phase": "tutorial"}, 
		{"local_id": "desk", "object_id": "furniture.classroom_desk", "graphic_id": "fixture.school_desk.v1", "render_mode": "workstation", "position": Vector2(280, 292), "depth": 292.0, "priority": 2, "interactive": false, "body": "#5a5d58", "solid_rect": Rect2(230, 277, 100, 32)}, 
	], 
	"school:hall_a": [
		{"local_id": "lockers", "object_id": "fixture.school_lockers", "graphic_id": "fixture.school_lockers.v1", "position": Vector2(340, 185), "depth": 185.0, "priority": 0, "interactive": false}, 
		{"local_id": "water_fountain", "object_id": "fixture.water_fountain", "graphic_id": "fixture.school_fountain.v1", "position": Vector2(640, 195), "depth": 195.0, "priority": 0, "interactive": false}, 
		{"local_id": "notice", "object_id": "fixture.bulletin_board", "graphic_id": "fixture.school_bulletin.v1", "position": Vector2(880, 180), "depth": 180.0, "priority": 0, "interactive": false}, 
	], 
	"school:hall_b": [
		{"local_id": "lockers", "object_id": "fixture.school_lockers", "graphic_id": "fixture.school_lockers.left.v1", "position": Vector2(280, 185), "depth": 185.0, "priority": 0, "interactive": false}, 
		{"local_id": "bench", "object_id": "furniture.hall_bench", "graphic_id": "fixture.school_bench.v1", "render_mode": "workstation", "position": Vector2(620, 270), "depth": 270.0, "priority": 2, "interactive": false, "body": "#4d4d48", "solid_rect": Rect2(530, 255, 180, 30)}, 
	], 
	"school:career_wing": [
		{"local_id": "career_wall", "object_id": "fixture.career_posters", "graphic_id": "fixture.school_career_wall.v1", "position": Vector2(220, 180), "depth": 180.0, "priority": 0, "interactive": false}, 
		{"local_id": "scholarship_board", "object_id": "fixture.scholarship_display", "graphic_id": "fixture.school_scholarship_display.v1", "position": Vector2(740, 185), "depth": 185.0, "priority": 0, "interactive": false}, 
	], 
	"school:service_exit": [
		{"local_id": "exit_sign", "object_id": "fixture.exit_sign", "graphic_id": "fixture.exit_sign.v1", "position": Vector2(500, 120), "depth": 120.0, "priority": 0, "interactive": false}, 
		{"local_id": "mop_bucket", "object_id": "fixture.mop_bucket", "graphic_id": "fixture.janitor_bucket.v1", "render_mode": "workstation", "position": Vector2(820, 250), "depth": 250.0, "priority": 2, "interactive": false, "body": "#5a5d52", "solid_rect": Rect2(780, 235, 80, 32)}, 
	], 
	"school:gym_a": [
		{"local_id": "left_goal", "object_id": "fixture.school_basketball_goal", "graphic_id": "fixture.school.agility_goal.aged.left.v1", "render_mode": "gym_goal", "position": Vector2(82, 175), "depth": 112.0, "priority": 0, "interactive": false, "mirrored": false, "condition": "aged"}, 
		{"local_id": "coach", "object_id": "npc.classroom_teacher", "graphic_id": "character.classroom_teacher.agility.v1", "render_mode": "classroom_teacher", "position": Vector2(220, 190), "depth": 190.0, "priority": 1, "interactive": true, "action_id": "school_teacher", "label": "COACH SWITCH", "radius": 92.0, "skill_name": "Agility"}, 
	], 
	"school:gym_b": [
		{"local_id": "right_goal", "object_id": "fixture.school_basketball_goal", "graphic_id": "fixture.school.agility_goal.aged.right.v1", "render_mode": "gym_goal", "position": Vector2(930, 175), "depth": 112.0, "priority": 0, "interactive": false, "mirrored": true, "condition": "aged"}, 
		{"local_id": "rope", "object_id": "training.agility_rope", "graphic_id": "fixture.school.agility_rope.aged.v1", "render_mode": "gym_obstacle", "position": Vector2(250, 215), "depth": 205.0, "priority": 2, "interactive": true, "action_id": "gym_obstacle", "label": "ROPE CLIMB", "prompt": "climb practice rope", "radius": 112.0, "obstacle_kind": "rope", "training_id": "agility_gym_rope", "stamina": 8.0, "condition": "aged"}, 
		{"local_id": "ledge", "object_id": "training.agility_ledge", "graphic_id": "fixture.school.agility_ledge.aged.v1", "render_mode": "gym_obstacle", "position": Vector2(525, 210), "depth": 210.0, "priority": 2, "interactive": true, "action_id": "gym_obstacle", "label": "LEDGE WALK", "prompt": "cross practice ledge", "radius": 118.0, "obstacle_kind": "ledge", "training_id": "agility_gym_ledge", "stamina": 7.0, "condition": "aged", "solid_rect": Rect2(455, 202, 140, 28)}, 
		{"local_id": "vault", "object_id": "training.agility_vault", "graphic_id": "fixture.school.agility_vault.aged.v1", "render_mode": "gym_obstacle", "position": Vector2(730, 215), "depth": 215.0, "priority": 2, "interactive": true, "action_id": "gym_obstacle", "label": "PADDED VAULT", "prompt": "vault practice horse", "radius": 112.0, "obstacle_kind": "vault", "training_id": "agility_gym_vault", "stamina": 9.0, "condition": "aged", "solid_rect": Rect2(675, 202, 110, 30)}, 
	], 
	"school:safety": [
		{"local_id": "permit_desk", "object_id": "service.permit_desk", "graphic_id": "fixture.school_safety_desk.v1", "fixture_id": "school_safety", "position": Vector2(500, 220), "depth": 220.0, "priority": 2, "interactive": true, "action_id": "school_safety", "label": "SAFETY PERMIT DESK", "radius": 120.0, "solid_rect": Rect2(416, 185, 168, 35)}, 
	], 
	"school:scholarship": [
		{"local_id": "exchange", "object_id": "service.scholarship_exchange", "graphic_id": "fixture.school_scholarship.wall.v2", "render_mode": "scholarship_exchange", "position": Vector2(500, 220), "depth": 220.0, "priority": 2, "interactive": true, "action_id": "school_scholarship", "label": "SCHOLARSHIP EXCHANGE", "radius": 120.0, "solid_rect": Rect2(441, 185, 118, 35)}, 
	], 

	"home:communal": [
		{"local_id": "couch_hobo", "object_id": "furniture.worn_couch_occupied", "graphic_id": "fixture.home_couch.hobo.v1", "render_mode": "couch_with_hobo", "position": Vector2(240, 210), "depth": 210.0, "priority": 2, "interactive": false, "solid_rect": Rect2(148, 190, 184, 34)}, 
		{"local_id": "tv", "object_id": "furniture.fatback_television", "graphic_id": "fixture.home_tv.fatback.v1", "render_mode": "fatback_tv", "position": Vector2(296, 285), "depth": 285.0, "priority": 2, "interactive": false, "solid_rect": Rect2(216, 270, 160, 30)}, 
		{"local_id": "bulletin", "object_id": "fixture.bulletin_board", "graphic_id": "fixture.home_bulletin.v1", "position": Vector2(150, 180), "depth": 180.0, "priority": 0, "interactive": false}, 
		{"local_id": "lamp", "object_id": "fixture.floor_lamp", "graphic_id": "fixture.home_lamp.v1", "position": Vector2(880, 205), "depth": 205.0, "priority": 1, "interactive": false}, 
	], 
	"home:utility": [
		{"local_id": "cupboard", "object_id": "fixture.kitchen_cupboard", "graphic_id": "fixture.home_cupboard.v1", "fixture_id": "home_cupboard", "render_mode": "workstation", "position": Vector2(100, 185), "depth": 185.0, "priority": 1, "interactive": true, "action_id": "home_cupboard", "label": "CUPBOARD", "radius": 70.0, "body": "#5a4e42", "solid_rect": Rect2(50, 170, 100, 32)}, 
		{"local_id": "stove", "object_id": "fixture.old_stove", "graphic_id": "fixture.home_stove.v1", "fixture_id": "home_stove", "render_mode": "workstation", "position": Vector2(200, 205), "depth": 205.0, "priority": 2, "interactive": true, "action_id": "home_cooking", "label": "STOVE - COOKING", "radius": 95.0, "body": "#4a4a44", "solid_rect": Rect2(130, 190, 140, 32)}, 
		{"local_id": "sink", "object_id": "fixture.utility_sink", "graphic_id": "fixture.home_sink.v1", "fixture_id": "home_sink", "render_mode": "workstation", "position": Vector2(420, 195), "depth": 195.0, "priority": 2, "interactive": false, "body": "#656561", "solid_rect": Rect2(365, 185, 110, 28)}, 
		{"local_id": "refrigerator", "object_id": "fixture.old_refrigerator", "graphic_id": "fixture.home_fridge.v1", "fixture_id": "home_refrigerator", "render_mode": "workstation", "position": Vector2(560, 215), "depth": 215.0, "priority": 2, "interactive": true, "action_id": "home_refrigerator", "label": "REFRIGERATOR", "radius": 70.0, "body": "#e8e4dc", "accent": "#4a4a44", "solid_rect": Rect2(510, 185, 100, 58)}, 
		{"local_id": "washer", "object_id": "fixture.coin_washer", "graphic_id": "fixture.home_washer.v1", "fixture_id": "home_washer", "render_mode": "workstation", "position": Vector2(755, 215), "depth": 215.0, "priority": 2, "interactive": true, "action_id": "home_washer", "label": "WASHER", "radius": 70.0, "body": "#5a615e", "solid_rect": Rect2(695, 200, 120, 32)}, 
		{"local_id": "dryer", "object_id": "fixture.coin_dryer", "graphic_id": "fixture.home_dryer.v1", "fixture_id": "home_dryer", "render_mode": "workstation", "position": Vector2(860, 215), "depth": 215.0, "priority": 2, "interactive": true, "action_id": "home_dryer", "label": "DRYER", "radius": 70.0, "body": "#5a615e", "solid_rect": Rect2(800, 200, 120, 32)}, 
	], 
	"home:resident_hall": [
		{"local_id": "door_6a", "object_id": "fixture.resident_door", "graphic_id": "fixture.home_door.6a.v1", "position": Vector2(220, 180), "depth": 180.0, "priority": 0, "interactive": false}, 
		{"local_id": "door_6b", "object_id": "fixture.resident_door", "graphic_id": "fixture.home_door.6b.v1", "position": Vector2(500, 180), "depth": 180.0, "priority": 0, "interactive": false}, 
		{"local_id": "door_6c", "object_id": "fixture.resident_door", "graphic_id": "fixture.home_door.6c.v1", "position": Vector2(780, 180), "depth": 180.0, "priority": 0, "interactive": false}, 
		{"local_id": "bench", "object_id": "furniture.hall_bench", "graphic_id": "fixture.home_bench.v1", "render_mode": "workstation", "position": Vector2(450, 275), "depth": 275.0, "priority": 2, "interactive": false, "body": "#4d4238", "solid_rect": Rect2(360, 260, 180, 30)}, 
	], 

	"home:lobby": [
		{"local_id": "intake", "object_id": "service.group_home_intake", "graphic_id": "fixture.group_home_intake.v1", "render_mode": "group_home_intake", "position": Vector2(690, 205), "depth": 205.0, "priority": 2, "interactive": false, "solid_rect": Rect2(600, 197, 180, 30)}, 
		{"local_id": "notice_board", "object_id": "fixture.notice_board", "graphic_id": "fixture.lobby_notices.v1", "position": Vector2(180, 185), "depth": 185.0, "priority": 0, "interactive": false}, 
	], 
	"home:caseworker": [
		{"local_id": "caseworker_office", "object_id": "npc.group_home_caseworker", "graphic_id": "fixture.group_home_caseworker_office.v1", "render_mode": "group_home_caseworker", "position": Vector2(500, 205), "depth": 205.0, "priority": 2, "interactive": true, "action_id": "home_caseworker", "label": "CASEWORKER", "radius": 120.0, "solid_rect": Rect2(400, 197, 200, 28)}, 
	], 
	"home:bed_6b": [
		{"local_id": "bed", "object_id": "furniture.bed", "graphic_id": "fixture.bed_6b.v2", "fixture_id": "home_bed", "position": Vector2(260, 215), "depth": 215.0, "priority": 2, "interactive": true, "action_id": "home_sleep", "label": "SLEEP - BED 6B", "radius": 105.0, "solid_rect": Rect2(168, 183, 184, 62)}, 
		{"local_id": "stash", "object_id": "storage.local_stash", "graphic_id": "fixture.home_stash.v1", "fixture_id": "home_stash", "position": Vector2(610, 215), "depth": 215.0, "priority": 2, "interactive": true, "action_id": "home_stash", "label": "LOCAL STASH", "radius": 105.0, "solid_rect": Rect2(545, 185, 130, 55)}, 
	], 

	"store:sales": [
		{"local_id": "jerseys", "object_id": "display.wall_merchandise", "graphic_id": "fixture.store_jerseys.v2", "fixture_id": "store_jerseys", "fixture_index": 3, "render_size": Vector2(120, 150), "position": Vector2(480, 190), "depth": 174.0, "priority": 2, "interactive": false}, 
		{"local_id": "wall_stock", "object_id": "display.wall_merchandise", "graphic_id": "fixture.store_wall_stock.v2", "fixture_id": "store_wall_stock", "fixture_index": 0, "render_size": Vector2(170, 160), "position": Vector2(635, 195), "depth": 174.0, "priority": 2, "interactive": true, "action_id": "store_stock", "label": "STOCK SHELVES", "radius": 105.0, "solid_rect": Rect2(550, 182, 170, 33)}, 
		{"local_id": "cooler", "object_id": "fixture.drink_cooler", "graphic_id": "fixture.store_cooler.v2", "fixture_id": "store_cooler", "fixture_index": 2, "render_size": Vector2(150, 175), "position": Vector2(795, 195), "depth": 195.0, "priority": 2, "interactive": false, "solid_rect": Rect2(720, 182, 150, 33)}, 
		{"local_id": "boss", "object_id": "npc.employer", "graphic_id": "character.boss.v1", "fixture_id": "store_boss", "position": Vector2(175, 188), "depth": 188.0, "priority": 1, "interactive": true, "action_id": "store_boss", "label": "BOSS", "radius": 82.0}, 
		{"local_id": "counter", "object_id": "fixture.guarded_counter", "graphic_id": "fixture.store_counter.v2", "fixture_id": "store_counter", "position": Vector2(180, 205), "depth": 205.0, "priority": 2, "interactive": false, "solid_rect": Rect2(90, 190, 180, 32)}, 
		{"local_id": "employee_register", "object_id": "workstation.cash_register", "graphic_id": "fixture.store_register.v1", "render_mode": "content", "position": Vector2(105, 205), "depth": 205.0, "priority": 2, "interactive": true, "action_id": "store_register", "label": "EMPLOYEE REGISTER", "radius": 58.0}, 
		{"local_id": "cleaning", "object_id": "workstation.cleaning", "graphic_id": "fixture.store_cleaning.v2", "fixture_id": "store_cleaning", "fixture_index": 5, "render_size": Vector2(80, 125), "position": Vector2(470, 270), "depth": 270.0, "priority": 2, "interactive": true, "action_id": "store_clean", "label": "CLEANING STATION", "radius": 62.0, "solid_rect": Rect2(430, 247, 80, 33)}, 
	], 
	"store:stockroom": [
		{"local_id": "stock_crates", "object_id": "fixture.stock_crates", "graphic_id": "fixture.stock_crates.placeholder.v1", "render_mode": "workstation", "position": Vector2(285, 205), "depth": 205.0, "priority": 2, "interactive": false, "label": "STOCK CRATES", "body": "#66523c", "solid_rect": Rect2(185, 197, 200, 28)}, 
		{"local_id": "receiving", "object_id": "workstation.receiving", "graphic_id": "fixture.receiving.placeholder.v1", "render_mode": "workstation", "position": Vector2(650, 205), "depth": 205.0, "priority": 2, "interactive": true, "action_id": "store_stockroom", "label": "PIPE / RECEIVING", "radius": 120.0, "body": "#4a5650", "solid_rect": Rect2(550, 197, 200, 28)}, 
	], 
	"store:safe": [
		{"local_id": "deposit_safe", "object_id": "service.deposit_safe", "graphic_id": "fixture.deposit_safe.placeholder.v1", "render_mode": "workstation", "position": Vector2(485, 215), "depth": 215.0, "priority": 2, "interactive": true, "action_id": "store_safe", "label": "DEPOSIT SAFE", "radius": 150.0, "body": "#485052", "solid_rect": Rect2(385, 207, 200, 28)}, 
	], 
	"store:dvr": [
		{"local_id": "dvr", "object_id": "service.camera_dvr", "graphic_id": "fixture.store_dvr.placeholder.v1", "render_mode": "workstation", "position": Vector2(490, 215), "depth": 215.0, "priority": 2, "interactive": true, "action_id": "store_dvr", "label": "STORE DVR", "radius": 150.0, "body": "#334447", "solid_rect": Rect2(390, 207, 200, 28)}, 
	], 

	"restaurant:dining": [
		{"local_id": "front_counter", "object_id": "service.restaurant_front_counter", "graphic_id": "fixture.restaurant_front_counter.composite.v2", "render_mode": "restaurant_front_counter", "position": Vector2(300, 205), "depth": 205.0, "priority": 2, "interactive": true, "action_id": "restaurant_counter", "label": "MISS ALIBI", "radius": 125.0, "body": "#725345", "accent": "#9a7054", "solid_rect": Rect2(200, 175, 300, 57)}, 
	], 
	"restaurant:kitchen": [
		{"local_id": "prep", "object_id": "workstation.kitchen_prep", "graphic_id": "fixture.kitchen_prep.wall.v2", "render_mode": "restaurant_prep_wall", "position": Vector2(680, 205), "depth": 205.0, "priority": 2, "interactive": true, "action_id": "restaurant_prep", "label": "KITCHEN PREP LINE", "radius": 130.0, "body": "#725345", "accent": "#9a7054", "solid_rect": Rect2(590, 190, 180, 20)}, 
	], 
	"restaurant:office": [
		{"local_id": "receipts", "object_id": "storage.business_records", "graphic_id": "fixture.office_receipts.placeholder.v1", "render_mode": "workstation", "position": Vector2(500, 205), "depth": 205.0, "priority": 2, "interactive": false, "label": "OFFICE RECEIPTS", "body": "#5e5046", "solid_rect": Rect2(400, 197, 200, 28)}, 
		{"local_id": "dvr", "object_id": "service.camera_dvr", "graphic_id": "fixture.restaurant_dvr.office.v1", "render_mode": "restaurant_office_dvr", "position": Vector2(735, 205), "depth": 205.0, "priority": 2, "interactive": true, "action_id": "restaurant_dvr", "label": "ALIBI DVR", "radius": 125.0, "body": "#334447", "camera_channels": ["ALIBIS-EXTERIOR", "ALIBIS-OFFICE"], "solid_rect": Rect2(635, 197, 200, 28)}, 
		{"local_id": "camera_right", "object_id": "surveillance.wall_camera", "graphic_id": "fixture.camera.quality_3.right_wall.v1", "render_mode": "camera", "position": Vector2(875, 100), "depth": 100.0, "priority": 2, "interactive": false, "quality": 3, "camera_id": "ALIBIS-OFFICE", "mount": "right_wall"}, 
	], 
	"restaurant:delivery": [
		{"local_id": "rack", "object_id": "service.delivery_rack", "graphic_id": "fixture.delivery_rack.placeholder.v1", "render_mode": "workstation", "position": Vector2(500, 215), "depth": 215.0, "priority": 2, "interactive": true, "action_id": "restaurant_delivery", "label": "SEALED DELIVERY RACK", "radius": 130.0, "body": "#705a49", "solid_rect": Rect2(400, 207, 200, 28)}, 
	], 

	"bank:lobby": [
		{"local_id": "camera_left", "object_id": "surveillance.wall_camera", "graphic_id": "fixture.camera.quality_5.v1", "render_mode": "camera", "position": Vector2(145, 100), "depth": 100.0, "priority": 2, "interactive": false, "quality": 5}, 
		{"local_id": "camera_right", "object_id": "surveillance.wall_camera", "graphic_id": "fixture.camera.quality_5.v1", "render_mode": "camera", "position": Vector2(835, 100), "depth": 100.0, "priority": 2, "interactive": false, "quality": 5}, 
		{"local_id": "vault_door", "object_id": "security.bank_vault_door", "graphic_id": "fixture.bank_vault_door.v1", "render_mode": "bank_vault", "position": Vector2(300, 155), "depth": 155.0, "priority": 2, "interactive": false, "solid_rect": Rect2(225, 128, 150, 62)}, 
		{"local_id": "teller_counter", "object_id": "service.bank_teller", "graphic_id": "fixture.bank_counter_integrated_teller.v1", "render_mode": "bank_counter", "position": Vector2(390, 200), "depth": 200.0, "priority": 2, "interactive": true, "action_id": "bank_teller", "label": "BANK TELLER", "radius": 105.0, "solid_rect": Rect2(70, 155, 650, 45)}, 
		{"local_id": "queue_upper", "object_id": "fixture.bank_stanchion_run", "graphic_id": "fixture.bank_stanchion.upper.v1", "render_mode": "bank_stanchion", "position": Vector2(380, 220), "depth": 220.0, "priority": 2, "interactive": false, "solid_rect": Rect2(110, 220, 540, 12)}, 
		{"local_id": "job_deposit", "object_id": "service.job_deposit_box", "graphic_id": "fixture.bank_job_deposit.v1", "render_mode": "bank_deposit_box", "position": Vector2(820, 225), "depth": 225.0, "priority": 2, "interactive": true, "action_id": "bank_job_deposit", "label": "SEALED JOB DEPOSIT", "radius": 88.0, "solid_rect": Rect2(785, 195, 70, 45)}, 
		{"local_id": "queue_lower", "object_id": "fixture.bank_stanchion_run", "graphic_id": "fixture.bank_stanchion.lower.v1", "render_mode": "bank_stanchion", "position": Vector2(490, 255), "depth": 255.0, "priority": 2, "interactive": false, "solid_rect": Rect2(220, 255, 540, 12)}, 
		{"local_id": "security_patrol", "object_id": "workstation.security_patrol", "graphic_id": "fixture.bank_security_patrol.v1", "render_mode": "bank_patrol", "position": Vector2(745, 285), "depth": 285.0, "priority": 0, "interactive": false}, 
	], 
	"hospital:intake": [
		{"local_id": "discharge_window", "object_id": "service.hospital_discharge_window", "graphic_id": "fixture.hospital_discharge.window.v2", "render_mode": "hospital_discharge_window", "position": Vector2(650, 205), "depth": 205.0, "priority": 2, "interactive": true, "action_id": "hospital_discharge", "label": "DISCHARGE WINDOW", "radius": 92.0, "solid_rect": Rect2(560, 190, 180, 35)}, 
	], 
	"hospital:ward": [
		{"local_id": "bed_top_left", "object_id": "service.stabilization_bed", "graphic_id": "fixture.hospital_bed.corner.v2", "render_mode": "hospital_stabilization_bed", "position": Vector2(250, 150), "depth": 150.0, "priority": 2, "interactive": true, "action_id": "hospital_stabilize", "label": "STABILIZATION", "radius": 92.0, "solid_rect": Rect2(165, 135, 170, 30)}, 
		{"local_id": "bed_top_right", "object_id": "furniture.hospital_stabilization_bed", "graphic_id": "fixture.hospital_bed.corner.v2", "render_mode": "hospital_stabilization_bed", "position": Vector2(800, 150), "depth": 150.0, "priority": 2, "interactive": false, "patient_id": "subscription", "patient_name": "MR. FREE TRIAL", "solid_rect": Rect2(715, 135, 170, 30)}, 
		{"local_id": "bed_bottom_left", "object_id": "furniture.hospital_stabilization_bed", "graphic_id": "fixture.hospital_bed.corner.v2", "render_mode": "hospital_stabilization_bed", "position": Vector2(250, 285), "depth": 285.0, "priority": 2, "interactive": false, "patient_id": "appeal", "patient_name": "MARA APPEAL", "solid_rect": Rect2(165, 270, 170, 30)}, 
		{"local_id": "bed_bottom_right", "object_id": "furniture.hospital_stabilization_bed", "graphic_id": "fixture.hospital_bed.corner.v2", "render_mode": "hospital_stabilization_bed", "position": Vector2(800, 285), "depth": 285.0, "priority": 2, "interactive": false, "patient_id": "docket", "patient_name": "DOCKET LEE", "solid_rect": Rect2(715, 270, 170, 30)}, 
		{"local_id": "nurse", "object_id": "npc.medical_worker", "graphic_id": "character.nurse_patch.cart.v1", "render_mode": "hospital_nurse_cart", "position": Vector2(540, 150), "depth": 150.0, "priority": 1, "interactive": false}, 
	], 
	"hospital:pharmacy": [
		{"local_id": "dropoff", "object_id": "service.pharmacy_dropoff", "graphic_id": "fixture.hospital_pharmacy.dropoff.v2", "render_mode": "hospital_pharmacy_dropoff", "position": Vector2(300, 205), "depth": 205.0, "priority": 2, "interactive": false}, 
		{"local_id": "pickup", "object_id": "service.pharmacy_pickup", "graphic_id": "fixture.hospital_pharmacy.pickup.v2", "render_mode": "hospital_pharmacy_pickup", "position": Vector2(700, 205), "depth": 205.0, "priority": 2, "interactive": true, "action_id": "hospital_pharmacy", "label": "PHARMACY PICKUP", "radius": 92.0, "solid_rect": Rect2(620, 190, 160, 35)}, 
	], 

	"jail:booking": [
		{"local_id": "guard", "object_id": "npc.jail_guard", "graphic_id": "character.jail_guard.v1", "fixture_id": "jail_guard", "position": Vector2(840, 130), "depth": 130.0, "priority": 1, "interactive": true, "action_id": "jail_bribe", "label": "BOOKING GUARD", "radius": 72.0}, 
		{"local_id": "booking_desk", "object_id": "fixture.booking_desk", "graphic_id": "fixture.jail_booking_desk.v1", "render_mode": "workstation", "position": Vector2(240, 205), "depth": 205.0, "priority": 2, "interactive": false, "body": "#4a5158", "solid_rect": Rect2(150, 190, 180, 32)}, 
		{"local_id": "camera", "object_id": "surveillance.wall_camera", "graphic_id": "fixture.camera.quality_4.v1", "render_mode": "camera", "position": Vector2(620, 95), "depth": 95.0, "priority": 2, "interactive": false, "quality": 4}, 
	], 
	"jail:tier": [
		{"local_id": "bunk_left", "object_id": "fixture.jail_bunk", "graphic_id": "fixture.jail_bunk.v1", "render_mode": "workstation", "position": Vector2(180, 210), "depth": 210.0, "priority": 2, "interactive": false, "body": "#3a4240", "solid_rect": Rect2(110, 195, 140, 32)}, 
		{"local_id": "bunk_right", "object_id": "fixture.jail_bunk", "graphic_id": "fixture.jail_bunk.v1", "render_mode": "workstation", "position": Vector2(920, 215), "depth": 215.0, "priority": 2, "interactive": false, "body": "#3a4240", "solid_rect": Rect2(850, 200, 140, 32)}, 
		{"local_id": "toilet", "object_id": "fixture.jail_toilet", "graphic_id": "fixture.jail_toilet.v1", "render_mode": "workstation", "position": Vector2(520, 205), "depth": 205.0, "priority": 2, "interactive": false, "body": "#666863", "solid_rect": Rect2(490, 195, 60, 28)}, 
		{"local_id": "notice", "object_id": "fixture.jail_notice", "graphic_id": "fixture.jail_rules.v1", "position": Vector2(720, 180), "depth": 180.0, "priority": 0, "interactive": false}, 
	], 
	"jail:west_tier": [
		{"local_id": "bunk_1", "object_id": "fixture.jail_bunk", "graphic_id": "fixture.jail_bunk.v1", "render_mode": "workstation", "position": Vector2(240, 212), "depth": 212.0, "priority": 2, "interactive": false, "body": "#3a4240", "solid_rect": Rect2(170, 197, 140, 32)}, 
		{"local_id": "bunk_2", "object_id": "fixture.jail_bunk", "graphic_id": "fixture.jail_bunk.v1", "render_mode": "workstation", "position": Vector2(780, 218), "depth": 218.0, "priority": 2, "interactive": false, "body": "#3a4240", "solid_rect": Rect2(710, 203, 140, 32)}, 
	], 
	"jail:labor": [
		{"local_id": "sock_bag", "object_id": "workstation.jail_labor", "graphic_id": "fixture.jail_sock_bag.placeholder.v1", "render_mode": "workstation", "position": Vector2(180, 205), "depth": 205.0, "priority": 2, "interactive": true, "action_id": "jail_labor", "label": "DIRTY SOCK BAG", "radius": 100.0, "body": "#60605a", "solid_rect": Rect2(80, 197, 200, 28)}, 
	], 
	"jail:education": [
		{"local_id": "desk", "object_id": "workstation.jail_education", "graphic_id": "fixture.jail_education.placeholder.v1", "render_mode": "workstation", "position": Vector2(400, 205), "depth": 205.0, "priority": 2, "interactive": true, "action_id": "jail_education", "label": "TIER EDUCATION DESK", "radius": 100.0, "body": "#5e594f", "solid_rect": Rect2(300, 197, 200, 28)}, 
	], 
	"jail:infirmary": [
		{"local_id": "window", "object_id": "service.jail_infirmary", "graphic_id": "fixture.jail_window.v1", "render_mode": "window", "position": Vector2(600, 215), "depth": 215.0, "priority": 2, "interactive": true, "action_id": "jail_infirmary", "label": "TIER INFIRMARY", "radius": 100.0, "jail_variant": true}, 
	], 
	"jail:recovery": [
		{"local_id": "circle", "object_id": "workstation.recovery_group", "graphic_id": "fixture.recovery_circle.placeholder.v1", "render_mode": "workstation", "position": Vector2(760, 205), "depth": 205.0, "priority": 2, "interactive": true, "action_id": "jail_recovery", "label": "RECOVERY CIRCLE", "radius": 100.0, "body": "#59655d", "solid_rect": Rect2(660, 197, 200, 28)}, 
	], 

	"apartment:floor_1": [
		{"local_id": "plant", "object_id": "fixture.hallway_plant", "graphic_id": "fixture.apartment_plant.v1", "position": Vector2(220, 240), "depth": 240.0, "priority": 1, "interactive": false}, 
		{"local_id": "fire_ext", "object_id": "fixture.fire_extinguisher", "graphic_id": "fixture.fire_ext.v1", "position": Vector2(480, 180), "depth": 180.0, "priority": 0, "interactive": false}, 
		{"local_id": "exit_sign", "object_id": "fixture.exit_sign", "graphic_id": "fixture.exit_sign.v1", "position": Vector2(750, 120), "depth": 120.0, "priority": 0, "interactive": false}, 
	], 
	"apartment:floor_2": [
		{"local_id": "plant", "object_id": "fixture.hallway_plant", "graphic_id": "fixture.apartment_plant.v1", "position": Vector2(280, 245), "depth": 245.0, "priority": 1, "interactive": false}, 
		{"local_id": "notice", "object_id": "fixture.apartment_notice", "graphic_id": "fixture.apartment_notice.v1", "position": Vector2(620, 180), "depth": 180.0, "priority": 0, "interactive": false}, 
	], 
	"apartment:floor_3": [
		{"local_id": "bench", "object_id": "furniture.hall_bench", "graphic_id": "fixture.apartment_bench.v1", "render_mode": "workstation", "position": Vector2(400, 265), "depth": 265.0, "priority": 2, "interactive": false, "body": "#4a4d48", "solid_rect": Rect2(310, 250, 180, 30)}, 
		{"local_id": "exit_sign", "object_id": "fixture.exit_sign", "graphic_id": "fixture.exit_sign.v1", "position": Vector2(780, 120), "depth": 120.0, "priority": 0, "interactive": false}, 
	], 
	"apartment:floor_4": [
		{"local_id": "plant", "object_id": "fixture.hallway_plant", "graphic_id": "fixture.apartment_plant.v1", "position": Vector2(340, 238), "depth": 238.0, "priority": 1, "interactive": false}, 
		{"local_id": "fire_ext", "object_id": "fixture.fire_extinguisher", "graphic_id": "fixture.fire_ext.v1", "position": Vector2(720, 180), "depth": 180.0, "priority": 0, "interactive": false}, 
	], 
	"apartment:floor_5": [
		{"local_id": "notice", "object_id": "fixture.apartment_notice", "graphic_id": "fixture.apartment_notice.v1", "position": Vector2(480, 180), "depth": 180.0, "priority": 0, "interactive": false}, 
		{"local_id": "exit_sign", "object_id": "fixture.exit_sign", "graphic_id": "fixture.exit_sign.v1", "position": Vector2(850, 120), "depth": 120.0, "priority": 0, "interactive": false}, 
	], 
	"apartment:floor_6": [
		{"local_id": "plant", "object_id": "fixture.hallway_plant", "graphic_id": "fixture.apartment_plant.v1", "position": Vector2(260, 242), "depth": 242.0, "priority": 1, "interactive": false}, 
		{"local_id": "bench", "object_id": "furniture.hall_bench", "graphic_id": "fixture.apartment_bench.v1", "render_mode": "workstation", "position": Vector2(650, 268), "depth": 268.0, "priority": 2, "interactive": false, "body": "#4a4d48", "solid_rect": Rect2(560, 253, 180, 30)}, 
	], 
	"apartment:roof": [
		{"local_id": "hvac_unit", "object_id": "fixture.hvac_unit", "graphic_id": "fixture.rooftop_hvac.v1", "render_mode": "workstation", "position": Vector2(340, 210), "depth": 210.0, "priority": 2, "interactive": false, "body": "#525a58", "solid_rect": Rect2(260, 190, 160, 42)}, 
		{"local_id": "vent_stack", "object_id": "fixture.vent_stack", "graphic_id": "fixture.rooftop_vent.v1", "position": Vector2(680, 195), "depth": 195.0, "priority": 1, "interactive": false}, 
		{"local_id": "access_door", "object_id": "fixture.roof_access", "graphic_id": "fixture.roof_door.v1", "position": Vector2(920, 185), "depth": 185.0, "priority": 0, "interactive": false}, 
	], 
	"apartment:lobby": [
		{"local_id": "leasing", "object_id": "service.leasing_desk", "graphic_id": "fixture.apartment_leasing.composite.v2", "render_mode": "apartment_leasing_composite", "position": Vector2(225, 205), "depth": 205.0, "priority": 2, "interactive": true, "action_id": "apartment_leasing", "label": "MR. LEDGER", "radius": 120.0, "body": "#5b564e", "accent": "#806b56", "solid_rect": Rect2(135, 150, 180, 82)}, 
	], 
	"apartment:security": [
		{"local_id": "desk", "object_id": "service.security_desk", "graphic_id": "fixture.security_desk.placeholder.v1", "render_mode": "workstation", "position": Vector2(500, 205), "depth": 205.0, "priority": 2, "interactive": true, "action_id": "apartment_security", "label": "SECURITY OFFICE", "radius": 120.0, "body": "#5a635f", "solid_rect": Rect2(400, 197, 200, 28)}, 
	], 
	"apartment:unit": [
		{"local_id": "customize", "object_id": "workstation.player_home_customize", "graphic_id": "fixture.home_customize.placeholder.v1", "render_mode": "workstation", "position": Vector2(340, 205), "depth": 205.0, "priority": 2, "interactive": true, "action_id": "player_home_customize", "label": "ROOM CUSTOMIZATION", "radius": 120.0, "body": "#59615d", "accent": "#313735", "solid_rect": Rect2(245, 197, 190, 30)}, 
		{"local_id": "stash", "object_id": "storage.player_home", "graphic_id": "fixture.player_home_stash.placeholder.v1", "render_mode": "workstation", "position": Vector2(680, 205), "depth": 205.0, "priority": 2, "interactive": true, "action_id": "player_home_stash", "label": "PRIVATE STORAGE", "radius": 120.0, "body": "#66584e", "accent": "#302b27", "solid_rect": Rect2(590, 197, 180, 30)}, 
	], 
	"apartment:stairs": [
		{"local_id": "elevator", "object_id": "transport.apartment_elevator", "graphic_id": "fixture.apartment_elevator.wall.v3", "render_mode": "wall_apartment_elevator", "position": Vector2(500, 205), "depth": 205.0, "priority": 0, "interactive": true, "action_id": "apartment_elevator", "label": "ELEVATOR", "radius": 120.0, "body": "#575a5b", "accent": "#9a8566", "solid_rect": Rect2(400, 197, 200, 28)}, 
	], 

	"social:lobby": [
		{"local_id": "guide", "object_id": "npc.social_services_guide", "graphic_id": "character.caseworker_jan.v1", "fixture_id": "social_worker", "position": Vector2(230, 165), "depth": 165.0, "priority": 1, "interactive": true, "action_id": "social_lobby", "label": "CASEWORKER JAN", "radius": 105.0}, 
	], 
	"social:forms": [
		{"local_id": "forms", "object_id": "service.forms_window", "graphic_id": "fixture.social_forms.window.v2", "render_mode": "social_forms", "position": Vector2(500, 135), "depth": 135.0, "priority": 2, "interactive": true, "action_id": "social_forms", "label": "FORMS WINDOW", "radius": 120.0}, 
	], 
	"social:casework": [
		{"local_id": "caseworker", "object_id": "npc.caseworker", "graphic_id": "character.caseworker_jan.v1", "fixture_id": "social_caseworker", "position": Vector2(500, 165), "depth": 165.0, "priority": 1, "interactive": true, "action_id": "social_casework", "label": "CASEWORKER", "radius": 120.0}, 
		{"local_id": "desk", "object_id": "service.caseworker_desk", "graphic_id": "fixture.social_casework.desk.v2", "render_mode": "social_casework_desk", "position": Vector2(500, 205), "depth": 205.0, "priority": 2, "interactive": false, "label": "CASEWORKER DESK", "body": "#5b5b52", "accent": "#737064", "solid_rect": Rect2(400, 197, 200, 28)}, 
	], 
	"social:records": [
		{"local_id": "files", "object_id": "storage.case_files", "graphic_id": "fixture.case_files.placeholder.v1", "render_mode": "workstation", "position": Vector2(500, 205), "depth": 205.0, "priority": 2, "interactive": true, "action_id": "social_records", "label": "RESTRICTED RECORDS", "radius": 120.0, "body": "#6d6b55", "solid_rect": Rect2(400, 197, 200, 28)}, 
	], 

	"barber:floor": [
		{"local_id": "owner", "object_id": "npc.barber", "graphic_id": "character.sol_barber.v1", "fixture_id": "barber_owner", "position": Vector2(250, 165), "depth": 165.0, "priority": 1, "interactive": true, "action_id": "barber_services", "label": "SOL", "radius": 105.0}, 
		{"local_id": "chair", "object_id": "furniture.barber_chair", "graphic_id": "fixture.barber_chair.v2", "render_mode": "barber_chair", "position": Vector2(390, 220), "depth": 220.0, "priority": 2, "interactive": false, "solid_rect": Rect2(335, 185, 110, 45)}, 
		{"local_id": "station", "object_id": "service.barber_station", "graphic_id": "fixture.barber_style_wall.v2", "render_mode": "barber_style_wall", "position": Vector2(610, 170), "depth": 170.0, "priority": 2, "interactive": true, "action_id": "barber_style_wall", "label": "STYLE DISPLAY", "radius": 130.0}, 
	], 

	"laundromat:floor": [
		{"local_id": "attendant", "object_id": "npc.employer", "graphic_id": "character.dell_laundry.v1", "fixture_id": "laundry_attendant", "position": Vector2(220, 165), "depth": 165.0, "priority": 1, "interactive": true, "action_id": "laundry_wash", "label": "DELL", "radius": 105.0}, 
		{"local_id": "washers", "object_id": "workstation.washers", "graphic_id": "fixture.laundry_washers.v1", "fixture_id": "laundry_washers", "position": Vector2(345, 215), "render_size": Vector2(175, 130), "depth": 215.0, "priority": 2, "interactive": false, "solid_rect": Rect2(255, 205, 180, 30)}, 
		{"local_id": "table", "object_id": "workstation.folding_table", "graphic_id": "fixture.laundry_table.v1", "fixture_id": "laundry_table", "position": Vector2(680, 225), "depth": 225.0, "priority": 2, "interactive": true, "action_id": "laundry_fold", "label": "FOLDING TABLE", "radius": 105.0, "solid_rect": Rect2(565, 208, 230, 35)}, 
	], 
	"laundromat:office": [
		{"local_id": "safe", "object_id": "service.office_safe", "graphic_id": "fixture.laundry_safe.wall.v2", "render_mode": "laundry_office_safe", "position": Vector2(300, 165), "depth": 165.0, "priority": 2, "interactive": true, "action_id": "laundry_safe", "label": "OFFICE SAFE", "radius": 105.0, "solid_rect": Rect2(245, 185, 110, 30)}, 
		{"local_id": "capone", "object_id": "npc.capone", "graphic_id": "character.capone.suit.v1", "render_mode": "runtime_actor", "actor_id": "laundry_capone", "position": Vector2(420, 165), "depth": 165.0, "priority": 1, "interactive": false, "label": "CAPONE"}, 
		{"local_id": "union_member_1", "object_id": "npc.union_defender", "graphic_id": "character.union_defender.suit.charcoal.v1", "render_mode": "runtime_actor", "actor_id": "laundry_union_1", "position": Vector2(760, 150), "roam_points": [Vector2(760, 150), Vector2(925, 150), Vector2(845, 150)], "depth": 150.0, "priority": 1, "interactive": false, "label": "UNION MEMBER"}, 
		{"local_id": "union_member_2", "object_id": "npc.union_defender", "graphic_id": "character.union_defender.suit.navy.v1", "render_mode": "runtime_actor", "actor_id": "laundry_union_2", "position": Vector2(920, 160), "roam_points": [Vector2(920, 150), Vector2(945, 180), Vector2(915, 150)], "depth": 160.0, "priority": 1, "interactive": false, "label": "UNION MEMBER"}, 
		{"local_id": "union_member_3", "object_id": "npc.union_defender", "graphic_id": "character.union_defender.suit.olive.v1", "render_mode": "runtime_actor", "actor_id": "laundry_union_3", "position": Vector2(760, 285), "roam_points": [Vector2(760, 285), Vector2(925, 285), Vector2(845, 285)], "depth": 285.0, "priority": 1, "interactive": false, "label": "UNION MEMBER"}, 
		{"local_id": "union_member_4", "object_id": "npc.union_defender", "graphic_id": "character.union_defender.suit.burgundy.v1", "render_mode": "runtime_actor", "actor_id": "laundry_union_4", "position": Vector2(920, 280), "roam_points": [Vector2(920, 280), Vector2(945, 285), Vector2(915, 250)], "depth": 280.0, "priority": 1, "interactive": false, "label": "UNION MEMBER"}, 
		{"local_id": "money_desk", "object_id": "fixture.guarded_money_desk", "graphic_id": "fixture.laundry_money_desk.piles.v1", "render_mode": "laundry_money_desk", "position": Vector2(775, 220), "depth": 220.0, "priority": 2, "interactive": true, "action_id": "laundry_money_desk", "label": "GUARDED MONEY DESK", "radius": 105.0, "solid_rect": Rect2(675, 202, 200, 38), "stealth_defense": 20, "success_cap": 0.9}, 
	], 

	"pawn:sales": [
		{"local_id": "broker", "object_id": "npc.pawn_broker", "graphic_id": "character.mara_pawn.v1", "fixture_id": "pawn_broker", "position": Vector2(245, 165), "depth": 165.0, "priority": 1, "interactive": true, "action_id": "pawn_counter", "label": "MARA", "radius": 105.0}, 
		{"local_id": "counter", "object_id": "fixture.pawn_counter", "graphic_id": "fixture.pawn_counter.composite.v2", "render_mode": "pawn_counter", "position": Vector2(315, 205), "depth": 205.0, "priority": 2, "interactive": false, "solid_rect": Rect2(145, 190, 340, 35)}, 
		{"local_id": "case", "object_id": "display.pawn_case", "graphic_id": "fixture.pawn_case.v2", "render_mode": "pawn_display_case", "position": Vector2(685, 215), "depth": 215.0, "priority": 2, "interactive": true, "action_id": "pawn_case", "label": "DISPLAY CASE", "radius": 125.0, "solid_rect": Rect2(535, 195, 300, 35)}, 
	], 
	"pawn:records": [
		{"local_id": "records", "object_id": "storage.ownership_records", "graphic_id": "fixture.case_files.restored.v2", "render_mode": "pawn_records_files", "position": Vector2(600, 205), "depth": 205.0, "priority": 2, "interactive": true, "action_id": "pawn_records", "label": "OWNERSHIP RECORDS", "radius": 125.0, "solid_rect": Rect2(480, 190, 240, 35)}, 
	], 

	"precinct:lobby": [
		{"local_id": "camera_left", "object_id": "surveillance.wall_camera", "graphic_id": "fixture.precinct_camera.left_wall.v1", "render_mode": "camera", "position": Vector2(145, 100), "depth": 100.0, "priority": 2, "interactive": false, "quality": 5, "camera_id": "PRECINCT-LOBBY", "mount": "left_wall"}, 
		{"local_id": "camera_right", "object_id": "surveillance.wall_camera", "graphic_id": "fixture.precinct_camera.right_wall.v1", "render_mode": "camera", "position": Vector2(875, 100), "depth": 100.0, "priority": 2, "interactive": false, "quality": 5, "camera_id": "PRECINCT-LOBBY", "mount": "right_wall"}, 
		{"local_id": "clerk", "object_id": "npc.precinct_clerk", "graphic_id": "character.clerk_vega.v1", "fixture_id": "precinct_clerk", "position": Vector2(220, 165), "depth": 165.0, "priority": 1, "interactive": false}, 
	], 
	"precinct:booking": [
		{"local_id": "desk", "object_id": "service.booking_desk", "graphic_id": "fixture.precinct_booking.v1", "fixture_id": "precinct_booking", "position": Vector2(220, 205), "depth": 205.0, "priority": 2, "interactive": true, "action_id": "precinct_booking", "label": "BOOKING DESK", "radius": 100.0, "solid_rect": Rect2(125, 150, 210, 82)}, 
	], 
	"precinct:evidence": [
		{"local_id": "intake", "object_id": "service.evidence_intake", "graphic_id": "fixture.precinct_evidence.v1", "fixture_id": "precinct_evidence", "position": Vector2(500, 205), "depth": 205.0, "priority": 2, "interactive": true, "action_id": "precinct_evidence", "label": "EVIDENCE INTAKE", "radius": 100.0, "solid_rect": Rect2(410, 150, 195, 82)}, 
	], 
	"precinct:holding": [
		{"local_id": "intake", "object_id": "service.holding_intake", "graphic_id": "fixture.precinct_holding.placeholder.v1", "render_mode": "workstation", "position": Vector2(750, 205), "depth": 205.0, "priority": 2, "interactive": true, "action_id": "precinct_holding", "label": "HOLDING INTAKE", "radius": 100.0, "body": "#4a5158", "solid_rect": Rect2(650, 197, 200, 28)}, 
	], 

	"pillmill:waiting": [
		{"local_id": "window", "object_id": "service.pharmacy_window", "graphic_id": "fixture.pharmacy_window.v2", "render_mode": "window", "position": Vector2(760, 205), "depth": 205.0, "priority": 2, "interactive": true, "action_id": "pillmill_fill", "label": "PRESCRIPTION WINDOW", "radius": 120.0}, 
	], 
	"pillmill:exam": [
		{"local_id": "doctor", "object_id": "npc.prescriber", "graphic_id": "character.dr_feelbetter.v1", "fixture_id": "pillmill_doctor", "position": Vector2(500, 165), "depth": 165.0, "priority": 1, "interactive": true, "action_id": "pillmill_prescriber", "label": "DR. FEELBETTER", "radius": 105.0}, 
		{"local_id": "desk", "object_id": "service.prescriber_desk", "graphic_id": "fixture.pillmill_desk.v1", "fixture_id": "pillmill_desk", "position": Vector2(500, 205), "depth": 205.0, "priority": 2, "interactive": false, "solid_rect": Rect2(395, 150, 210, 82)}, 
	], 

	"clinic:waiting": [
		{"local_id": "worker", "object_id": "npc.clinic_worker", "graphic_id": "character.counselor_reese.v1", "fixture_id": "clinic_worker", "position": Vector2(245, 165), "depth": 165.0, "priority": 1, "interactive": true, "action_id": "clinic_enroll", "label": "COUNSELOR REESE", "radius": 105.0}, 
		{"local_id": "desk", "object_id": "service.clinic_desk", "graphic_id": "fixture.clinic_desk.v1", "fixture_id": "clinic_desk", "position": Vector2(245, 205), "depth": 205.0, "priority": 2, "interactive": false, "solid_rect": Rect2(140, 150, 210, 82)}, 
		{"local_id": "window", "object_id": "service.dosing_window", "graphic_id": "fixture.pharmacy_window.v2", "render_mode": "window", "position": Vector2(760, 205), "depth": 205.0, "priority": 2, "interactive": true, "action_id": "clinic_fill", "label": "DOSING WINDOW", "radius": 120.0}, 
	], 
	"clinic:intake": [
		{"local_id": "intake", "object_id": "service.clinic_intake", "graphic_id": "fixture.clinic_intake.placeholder.v1", "render_mode": "workstation", "position": Vector2(500, 205), "depth": 205.0, "priority": 2, "interactive": true, "action_id": "clinic_enroll", "label": "CLINIC INTAKE", "radius": 120.0, "body": "#668076", "solid_rect": Rect2(400, 197, 200, 28)}, 
	], 
	"clinic:meeting": [
		{"local_id": "meeting", "object_id": "workstation.recovery_group", "graphic_id": "fixture.recovery_circle.placeholder.v1", "render_mode": "workstation", "position": Vector2(500, 205), "depth": 205.0, "priority": 2, "interactive": true, "action_id": "clinic_meeting", "label": "RECOVERY MEETING", "radius": 120.0, "body": "#68776d", "solid_rect": Rect2(400, 197, 200, 28)}, 
	], 
}

static func room_key(area_name: String, room_id: String) -> String:
	return "%s:%s" % [area_name, room_id]

static func _phase_matches(record: Dictionary, phase: String) -> bool:
	var required: = String(record.get("phase", ""))
	return required.is_empty() or required == phase

static func classroom_teacher_name(skill_name: String) -> String:
	match skill_name:
		"Intelligence": return "DR. INDEX"
		"Endurance": return "MR. LONGHAUL"
		"Agility": return "COACH SWITCH"
		"Fighting": return "COACH MERCER"
		"Firearms": return "MS. SIGHTS"
		"Stealth": return "MR. QUIET"
		"Awareness": return "MS. NOTICE"
		"Safety": return "MR. GUARDRAIL"
		"Medicine": return "NURSE MERCY"
		"Influence": return "MS. TERMS"
		"Enterprise": return "MR. MARGIN"
		"Civics": return "MS. DOCKET"
	return "%s TEACHER" % skill_name.to_upper()

static func records_for(area_name: String, room_id: String, phase: String = "adult") -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var key: = room_key(area_name, room_id)
	for source in ROOM_OBJECTS.get(key, []):
		var record: Dictionary = (source as Dictionary).duplicate(true)
		if not _phase_matches(record, phase):
			continue
		record["owner_room"] = key
		record["instance_id"] = "%s/%s" % [key, String(record.get("local_id", "missing"))]
		record["visible"] = true
		result.append(record)
	if area_name in ["tutorial", "school"] and room_id.begins_with("class_"):
		var skill_name: = room_id.trim_prefix("class_").replace("_", " ").capitalize()
		result.append({
			"local_id": "teacher", "object_id": "npc.classroom_teacher", "instance_id": "%s/teacher" % key, 
			"graphic_id": "character.classroom_teacher.%s.v1" % skill_name.to_lower().replace(" ", "_"), "render_mode": "classroom_teacher", "owner_room": key, 
			"position": Vector2(220, 190), "depth": 190.0, "priority": 1, "visible": true, 
			"interactive": true, "action_id": "school_teacher", "label": classroom_teacher_name(skill_name), "radius": 92.0, 
			"skill_name": skill_name, 
		})
		result.append({
			"local_id": "study", "object_id": "workstation.skill_study", "instance_id": "%s/study" % key, 
			"graphic_id": "fixture.school.classroom_study_desk.%s.v1" % skill_name.to_lower().replace(" ", "_"), "render_mode": "classroom_study_desk", "owner_room": key, 
			"position": Vector2(810, 220), "depth": 220.0, "priority": 2, "visible": true, 
			"interactive": true, "action_id": "school_skill", "label": "%s STUDY" % skill_name.to_upper(), "radius": 120.0, 
			"skill_name": skill_name, "solid_rect": Rect2(735, 195, 150, 35), 


			"render_y_offset": 30.0 if skill_name == "Civics" else 10.0, 
		})
		if skill_name == "Endurance":
			var condition: = "clean" if area_name == "tutorial" else "aged"
			result.append({
				"local_id": "weighted_cart", "object_id": "training.endurance_weighted_cart", "instance_id": "%s/weighted_cart" % key, 
				"graphic_id": "fixture.school.endurance_weighted_cart.%s.v1" % condition, "render_mode": "endurance_station", "owner_room": key, 
				"position": Vector2(510, 220), "depth": 220.0, "priority": 2, "visible": true, 
				"interactive": true, "action_id": "endurance_station", "label": "WEIGHTED SUPPLY CART", "prompt": "push weighted supply cart", "radius": 90.0, 
				"skill_name": "Endurance", "station_kind": "weighted_cart", "duration_seconds": 3.5, "stamina_cost": 8.0, "xp_reward": 55, 
				"condition": condition, "solid_rect": Rect2(455, 198, 110, 32), 
			})
			result.append({
				"local_id": "stair_step", "object_id": "training.endurance_stair_step", "instance_id": "%s/stair_step" % key, 
				"graphic_id": "fixture.school.endurance_stair_step.%s.v1" % condition, "render_mode": "endurance_station", "owner_room": key, 
				"position": Vector2(655, 220), "depth": 220.0, "priority": 2, "visible": true, 
				"interactive": true, "action_id": "endurance_station", "label": "TIMED STAIR-STEP", "prompt": "use timed stair-step station", "radius": 90.0, 
				"skill_name": "Endurance", "station_kind": "stair_step", "duration_seconds": 5.0, "stamina_cost": 10.0, "xp_reward": 65, 
				"condition": condition, "solid_rect": Rect2(605, 198, 100, 32), 
			})
		if skill_name == "Firearms":
			var condition: = "clean" if area_name == "tutorial" else "aged"
			result.append({
				"local_id": "disposition_dummy", "object_id": "training.firearms_disposition_dummy", "instance_id": "%s/disposition_dummy" % key, 
				"graphic_id": "fixture.school.firearms_disposition_dummy.%s.v1" % condition, "render_mode": "firearms_disposition_dummy", "owner_room": key, 
				"position": Vector2(600, 220), "depth": 220.0, "priority": 2, "visible": true, 
				"interactive": true, "action_id": "firearms_disposition_dummy", "label": "DISPOSITION DUMMY", "prompt": "practice with disposition dummy", "radius": 90.0, 
				"skill_name": "Firearms", "condition": condition, "solid_rect": Rect2(555, 195, 90, 35), 
			})
		if skill_name == "Medicine":
			var condition: = "clean" if area_name == "tutorial" else "aged"
			result.append({
				"local_id": "response_kit", "object_id": "training.medicine_response_kit", "instance_id": "%s/response_kit" % key, 
				"graphic_id": "fixture.school.medicine_response_kit.%s.v1" % condition, "render_mode": "medicine_response_kit", "owner_room": key, 
				"position": Vector2(600, 220), "depth": 220.0, "priority": 2, "visible": true, 
				"interactive": true, "action_id": "medicine_response_kit", "label": "EMERGENCY RESPONSE KIT", "prompt": "use emergency response kit", "radius": 100.0, 
				"skill_name": "Medicine", "condition": condition, 
			})
		if skill_name == "Stealth":
			var condition: = "clean" if area_name == "tutorial" else "aged"
			result.append({
				"local_id": "demonstration_camera", "object_id": "training.stealth_demonstration_camera", "instance_id": "%s/demonstration_camera" % key, 
				"graphic_id": "fixture.school.stealth_demonstration_camera.%s.v1" % condition, "render_mode": "camera", "owner_room": key, 
				"position": Vector2(600, 95), "depth": 95.0, "priority": 0, "visible": true, 
				"interactive": true, "action_id": "stealth_demonstration_camera", "label": "DEMONSTRATION CAMERA", "prompt": "inspect demonstration camera", "radius": 200.0, 
				"skill_name": "Stealth", "condition": condition, "quality": 3, 
			})
	return result

static func editor_source(room_layouts: Dictionary) -> Dictionary:


	var result: Dictionary = {}
	for area_value in room_layouts.keys():
		var area_name: = String(area_value)
		var room_values: Variant = room_layouts[area_value]
		if not room_values is Array:
			continue
		for room_value in room_values as Array:
			if not room_value is Dictionary:
				continue
			var room_name: = String((room_value as Dictionary).get("id", ""))
			if room_name.is_empty():
				continue
			var phase: = "tutorial" if area_name == "tutorial" else "adult"
			result[room_key(area_name, room_name)] = records_for(area_name, room_name, phase)
	return result

static func interactive_records(area_name: String, room_id: String, phase: String = "adult") -> Array[Dictionary]:
	return records_for(area_name, room_id, phase).filter( func(record: Dictionary): return bool(record.get("interactive", false)))

static func collision_rects(area_name: String, room_id: String, phase: String = "adult") -> Array[Rect2]:
	var result: Array[Rect2] = []
	for record in records_for(area_name, room_id, phase):
		var solid: Variant = record.get("solid_rect", null)
		if solid is Rect2:
			result.append(solid as Rect2)
	return result

static func audit(room_layouts: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	var known_rooms: Dictionary = {}
	for area_value in room_layouts:
		var area_name: = String(area_value)
		for room_value in room_layouts[area_value]:
			known_rooms[room_key(area_name, String(room_value.get("id", "")))] = true
	var instance_ids: Dictionary = {}
	for key_value in ROOM_OBJECTS:
		var key: = String(key_value)
		if key not in known_rooms:
			errors.append("Room-object owner does not exist: %s" % key)
		var local_ids: Dictionary = {}
		for source_value in ROOM_OBJECTS[key_value]:
			var source: Dictionary = source_value
			var local_id: = String(source.get("local_id", ""))
			var instance_id: = "%s/%s" % [key, local_id]
			if local_id.is_empty():
				errors.append("%s has an object without local_id" % key)
			if local_id in local_ids:
				errors.append("%s duplicates local_id %s" % [key, local_id])
			local_ids[local_id] = true
			if instance_id in instance_ids:
				errors.append("Duplicate InstanceID: %s" % instance_id)
			instance_ids[instance_id] = true
			for required in ["object_id", "graphic_id", "position"]:
				if not source.has(required) or (source[required] is String and String(source[required]).is_empty()):
					errors.append("%s is missing %s" % [instance_id, required])
			if bool(source.get("interactive", false)):
				for required in ["action_id", "label", "radius"]:
					if not source.has(required) or (source[required] is String and String(source[required]).is_empty()):
						errors.append("Interactive %s is missing %s" % [instance_id, required])
			if source.has("solid_rect") and not (source["solid_rect"] is Rect2):
				errors.append("%s solid_rect is not a Rect2" % instance_id)



	for area_value in room_layouts:
		var generated_area: = String(area_value)
		if generated_area not in ["tutorial", "school"]:
			continue
		var generated_phase: = "tutorial" if generated_area == "tutorial" else "adult"
		for room_value in room_layouts[area_value]:
			var generated_room: = String(Dictionary(room_value).get("id", ""))
			if not generated_room.begins_with("class_"):
				continue
			var generated_key: = room_key(generated_area, generated_room)
			var generated_local_ids: Dictionary = {}
			for record_value in records_for(generated_area, generated_room, generated_phase):
				var record: Dictionary = record_value
				var local_id: = String(record.get("local_id", ""))
				var instance_id: = String(record.get("instance_id", "%s/%s" % [generated_key, local_id]))
				if local_id.is_empty():
					errors.append("%s has a generated object without local_id" % generated_key)
				if local_id in generated_local_ids:
					errors.append("%s duplicates generated local_id %s" % [generated_key, local_id])
				generated_local_ids[local_id] = true
				if instance_id in instance_ids:
					errors.append("Duplicate generated InstanceID: %s" % instance_id)
				instance_ids[instance_id] = true
				for required in ["object_id", "graphic_id", "position", "owner_room", "instance_id"]:
					if not record.has(required) or (record[required] is String and String(record[required]).is_empty()):
						errors.append("%s is missing generated %s" % [instance_id, required])
				if String(record.get("owner_room", "")) != generated_key:
					errors.append("%s has the wrong generated owner_room" % instance_id)
				if bool(record.get("interactive", false)):
					for required in ["action_id", "label", "radius"]:
						if not record.has(required) or (record[required] is String and String(record[required]).is_empty()):
							errors.append("Interactive generated %s is missing %s" % [instance_id, required])
				if record.has("solid_rect") and not (record["solid_rect"] is Rect2):
					errors.append("%s generated solid_rect is not a Rect2" % instance_id)
	return errors
