require ("prototypes.pipeConnectors")
require ("util")

data:extend(
{

-- TREEFARM

	{
		type = "item",
		name = "field",
		icon = "__NARMod__/graphics/icons/field.png",
		flags = {"goes-to-quickbar"},
		subgroup = "organic-fields",
		order = "a[field]",
		place_result = "field-2",
		stack_size = 1
	},

	{
		type = "furnace",
		name = "field-2",
		max_health = 100,
		icon = "__NARMod__/graphics/icons/field.png",
		flags = {"placeable-neutral", "player-creation"},
		crafting_categories = {"treefarm-mod-dummy"},
		minable = {mining_time = 1,result = "field"},
		collision_box = {{-0.65,-0.75},{0.40,0.25}},
		selection_box = {{0.0,-1.0},{8.0,8.0}},
		result_inventory_size = 1,
		energy_usage = "180kW",
		crafting_speed = 1,
		source_inventory_size = 1,
		energy_source =
		{
			type = "burner",
			effectivity = 1,
			fuel_inventory_size = 1
		},
		animation =
		{
			filename = "__NARMod__/graphics/entity/field/field.png",
			priority = "extra-high",
			width = 512,
			height = 512,
			frame_count = 1,
			shift = {0.0, -0.25}
		},
		working_visualisations =
		{
			filename = "__NARMod__/graphics/icons/empty.png",
			priority = "extra-high",
			width = 32,
			height = 32,
			frame_count = 1,
			shift = {0.0, 0.0}
		}
	},
	
	{
		type = "recipe",
		name = "field",
		ingredients = {{"wooden-chest",1},{"burner-inserter",1}},
		result = "field",
		energy_required = 10,
		result_count = 1,
		enabled = "true"
	},
	
	{
		type = "item",
		name = "fieldmk2",
		icon = "__NARMod__/graphics/icons/fieldmk2.png",
		flags = {"goes-to-quickbar"},
		subgroup = "organic-fields",
		order = "a[fieldmk2]",
		place_result = "fieldmk2Overlay",
		stack_size = 1
	},
	
	{
		type = "smart-container",
		name = "field",
		max_health = 100,
		order = "a[field]",
		icon = "__NARMod__/graphics/icons/field.png",
		flags = {"placeable-neutral", "player-creation"},
		minable = {mining_time = 1,result = "field"},
		collision_box = {{-0.65,-0.75},{0.40,0.25}},
		selection_box = {{0.0,-1.0},{8.0,8.0}},
		inventory_size = 3,
		picture = 	{
						filename = "__NARMod__/graphics/entity/field/field.png",
						priority = "extra-high",
						width = 512,
						height = 512,
						shift = {0.00, -0.25}
					}
	},

	-- FIELD-MK2
	{
		type = "logistic-container",
		name = "fieldmk2",
		logistic_mode = "requester",
		order = "a[fieldmk2]",
		max_health = 100,
		icon = "__NARMod__/graphics/icons/fieldmk2.png",
		flags = {"placeable-neutral", "player-creation"},
		minable = {mining_time = 1,result = "fieldmk2"},
		collision_box = {{-0.7, -0.7}, {0.7, 0.7}},
		selection_box = {{-1, -1}, {1, 1}},
		drawing_box = {{-2.8, -0.5}, {0.5, 0.5}},
		inventory_size = 2,
		picture = 	{
						filename = "__NARMod__/graphics/entity/fieldmk2/fieldmk2.png",
						priority = "extra-high",
						width = 70,
						height = 170,
						shift = {0.0, -1.5}
					}
	},

	{
		type = "container",
		name = "fieldmk2Overlay",
		max_health = 100,
		icon = "__NARMod__/graphics/icons/fieldmk2.png",
		flags = {"placeable-neutral", "player-creation"},
		minable = {mining_time = 1,result = "fieldmk2"},
		collision_box = {{-0.7, -0.7}, {0.7, 0.7}},
		selection_box = {{-1, -1}, {1, 1}},
		inventory_size = 1,
		picture = 	{
						filename = "__NARMod__/graphics/entity/fieldmk2/fieldmk2Overlay.png",
						priority = "extra-high",
						width = 640,
						height = 640,
						shift = {0.0, 0.0}
					}
	},
	
		{
		type = "recipe",
		name = "fieldmk2",
		ingredients = {
			{"advanced-circuit",20},
			{"copper-cable",40},
			{"steel-plate",20}
		},
		result = "fieldmk2",
		energy_required = 30,
		result_count = 1,
		enabled = "false"
	},
	
	-- COKERY

	{
		type = "item",
		name = "cokery",
		icon = "__NARMod__/graphics/icons/cokery.png",
		flags = {"goes-to-quickbar"},
		subgroup = "alt-production",
		order = "a[cokery]",
		place_result = "cokery",
		stack_size = 5
	},
	
		{
		type = "recipe",
		name = "cokery",
		ingredients = {
			{"iron-plate",10},
			{"iron-gear-wheel",5},
			{"stone-furnace",2}
		},
		result = "cokery",
		energy_required = 10,
		result_count = 1,
		enabled = "false"
	},

{
		type = "assembling-machine",
		name = "cokery",
		icon = "__NARMod__/graphics/icons/cokery.png",
		flags = {"placeable-neutral","placeable-player", "player-creation"},
		minable = {hardness = 0.2, mining_time = 0.5, result = "cokery"},
		max_health = 200,
		corpse = "big-remnants",
		resistances = {{type = "fire", percent = 70}},
		collision_box = {{-1.4, -2.0}, {1.4, 2.4}},
		selection_box = {{-1.5, -2.5}, {1.5, 2.5}},
		module_slots = 2,
		allowed_effects = {"consumption", "speed"},

		animation =
		{
			north =
			{
				filename = "__NARMod__/graphics/entity/cokery/cokery-idle.png",
				width = 100,
				height = 160,
				frame_count = 1,
				line_length = 1,
				shift = {0, 0}
			},
			south =
			{
				filename = "__NARMod__/graphics/entity/cokery/cokery-idle.png",
				width = 100,
				height = 160,
				frame_count = 1,
				line_length = 1,
				shift = {0, 0}
			},
			west =
			{
				filename = "__NARMod__/graphics/entity/cokery/cokery-idle.png",
				width = 100,
				height = 160,
				frame_count = 1,
				line_length = 1,
				shift = {0, 0}
			},
			east =
			{
				filename = "__NARMod__/graphics/entity/cokery/cokery-idle.png",
				width = 100,
				height = 160,
				frame_count = 1,
				line_length = 1,
				shift = {0, 0}
			}				
		},
		working_visualisations =
		{

			{
				north_position = { 0.0,  0.0},
				south_position = { 0.0,  0.0},
				west_position  = { 0.0,  0.0},	--{ 1.3, -2.0},
				east_position  = { 0.0,  0.0},	--{ 1.3, -2.0},
			
				animation =
				{
					filename = "__NARMod__/graphics/entity/cokery/cokery-anim.png",
					frame_count = 28,
					line_length = 14,
					width = 100,
					height = 160,
					scale = 1.0,
					shift = {0, 0},
					animation_speed = 0.1
				}
			}
		},
		crafting_categories = {"cokery-crafting"},
		energy_source =
		{
			type = "electric",
			input_priority = "secondary",
			usage_priority = "secondary-input",
			emissions = 6 / 3
		},
		energy_usage = "6W",
		crafting_speed = 2,
		ingredient_count = 1
	},

	-- BIOREACTOR
	
	{
		type = "item",
		name = "bioreactor",
		icon = "__NARMod__/graphics/icons/bioreactor.png",
		flags = {"goes-to-quickbar"},
		subgroup = "organic-production",
		order = "a[bioreactor]",
		place_result = "bioreactor",
		stack_size = 3
	},
	
		{
		type = "recipe",
		name = "bioreactor",
		ingredients = {
			{"assembling-machine-2",1},
			{"storage-tank-2",4},
			{"steel-plate",5},
			{"electronic-circuit",10}
		},
		result = "bioreactor",
		energy_required = 20,
		enabled = "false",
		result_count = 1
	},

-- HYDROPONIC FARM
	
	
	
	{
		type = "item",
		name = "hydroponic-farm",
		icon = "__NARMod__/graphics/icons/hydroponic-farm.png",
		flags = {"goes-to-quickbar"},
		subgroup = "organic-production",
		order = "a[hydroponic-farm]",
		place_result = "hydroponic-farm",
		stack_size = 3
	},

{
		type = "assembling-machine",
		name = "bioreactor",
		icon = "__NARMod__/graphics/icons/bioreactor.png",
		flags = {"placeable-neutral", "player-creation"},
		minable = {hardness = 0.2, mining_time = 0.5, result = "bioreactor"},
		max_health = 100,
		corpse = "big-remnants",
		fluid_boxes =
		{
			{
				production_type = "input",
				pipe_picture = assembler2pipepicturesBioreactor(),
				pipe_covers = pipecoverspicturesBioreactor(),
				base_area = 10,
				base_level = -1,
				pipe_connections = {{ type="input", position = {0, -2} }}
			},
			{
				production_type = "input",
				pipe_picture = assembler2pipepicturesBioreactor(),
				pipe_covers = pipecoverspicturesBioreactor(),
				base_area = 10,
				base_level = -1,
				pipe_connections = {{ type="input", position = {2, 0} }}
			},
			{
				production_type = "input",
				pipe_picture = assembler2pipepicturesBioreactor(),
				pipe_covers = pipecoverspicturesBioreactor(),
				base_area = 10,
				base_level = -1,
				pipe_connections = {{ type="input", position = {0, 2} }}
			},


			{
				production_type = "output",
				pipe_picture = assembler2pipepicturesBioreactor(),
				pipe_covers = pipecoverspicturesBioreactor(),
				base_area = 10,
				base_level = 1,
				pipe_connections = {{ type="output", position = {-2, -1} }}
			},
			{
				production_type = "output",
				pipe_picture = assembler2pipepicturesBioreactor(),
				pipe_covers = pipecoverspicturesBioreactor(),
				base_area = 10,
				base_level = 1,
				pipe_connections = {{ type="output", position = {-2, 1} }}
			},
			off_when_no_fluid_recipe = false
		},
		collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
		selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
		animation =
		{
			filename = "__NARMod__/graphics/entity/bioreactor/bioreactor.png",
			priority = "high",
			width = 128,
			height = 150,
			frame_count = 26,
			line_length = 13,
			animation_speed = 0.4,
			shift = {0.55, -0.33}
		},
		energy_source =
		{
			type = "electric",
			usage_priority = "secondary-input"
		},
		crafting_categories = {"bioreactor-crafting"},
		ingredient_count = 8,
		crafting_speed = 1,
		energy_usage = "10kW"
	},

	-- HYDROPONIC FARM

	{
		type = "assembling-machine",
		name = "hydroponic-farm",
		icon = "__NARMod__/graphics/icons/hydroponic-farm.png",
		flags = {"placeable-neutral","placeable-player", "player-creation"},
		minable = {hardness = 0.2, mining_time = 0.5, result = "hydroponic-farm"},
		max_health = 300,
		corpse = "big-remnants",
		collision_box = {{-1.4, -1.4}, {1.4, 1.4}},
		selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
		module_slots = 2,
		allowed_effects = {"consumption", "speed", "productivity", "pollution"},
		animation =
		{
			filename = "__NARMod__/graphics/entity/hydroponic-farm/hydroponic-farm.png",
			priority = "extra-high",
			width = 99,
			height = 107,
			frame_count = 1,
			shift = {0.0, 0.0}
		},
		crafting_speed = 1,
		energy_source =
		{
			type = "electric",
			usage_priority = "secondary-input"
		},
		energy_usage = "180kW",
		ingredient_count = 4,
		crafting_categories = {"hydroponic-farm-crafting"},
		fluid_boxes =
		{
			{
				production_type = "input",
				pipe_covers = pipecoverspictures(),
				base_area = 10,
				base_level = -1,
				pipe_connections = {{ type="input", position = {-1, -2} }}
			},
			{
				production_type = "input",
				pipe_covers = pipecoverspictures(),
				base_area = 10,
				base_level = -1,
				pipe_connections = {{ type="input", position = {1, -2} }}
			},
			{
				production_type = "output",
				pipe_covers = pipecoverspictures(),
				base_level = 1,
				pipe_connections = {{ position = {-1, 2} }}
			},
			{
				production_type = "output",
				pipe_covers = pipecoverspictures(),
				base_level = 1,
				pipe_connections = {{ position = {1, 2} }}
			}
		}
	},
	
		{
		type = "recipe",
		name = "hydroponic-farm",
		ingredients =
		{
			{"steel-plate",20},
			{"storage-tank-2",4},
			{"glass-plate", 10},
			{"pipe", 10},
			{"air-compressor", 2},
		},
		energy_required = 10,
		result = "hydroponic-farm",
		enabled = "false",
		result_count = 1
	},


}
)