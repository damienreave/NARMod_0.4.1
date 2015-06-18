module(..., package.seeall)
require "util"


function boolToStr(bool)
	if bool == true then
		return "true"
	elseif bool == false then
		return "false"
	else
		return nil
	end
end


function startingItems()
	for _,player in pairs(game.players) do
		player.insert{name="iron-plate", count=200}
		player.insert{name="iron-chest", count=10}
		player.insert{name="small-electric-pole", count=32}
		player.insert{name="basic-inserter", count=50}
		player.insert{name="solar-panel", count=54}
		player.insert{name="cokery", count=5}
		player.insert{name="basic-transport-belt", count=50}
		player.insert{name="steam-engine", count=5}
		player.insert{name="boiler", count=32}
		player.insert{name="lab", count=10}
		player.insert{name="pipe", count=64}
		player.insert{name="basic-mining-drill", count=32}
		player.insert{name="basic-transport-belt-to-ground", count=32}
		player.insert{name="pipe-to-ground", count=20}
		player.insert{name="basic-splitter", count=20}
		player.insert{name="oil-refinery", count=8}
		player.insert{name="offshore-pump", count=8}
		player.insert{name="smart-inserter", count=32}
		player.insert{name="bioreactor", count=32}
		player.insert{name="storage-tank-2", count=32}
		player.insert{name="biolab", count=10}
	end
end


function startingResearch()
	for _,player in pairs(game.players) do
		player.force.technologies["coal-processing"].researched = true
		player.force.technologies["fertilizer"].researched = true
		player.force.technologies["advanced-biotechnology"].researched = true
		player.force.technologies["medicine"].researched = true
		player.force.technologies["advanced-treefarming"].researched = true
		player.force.technologies["organic-plastic"].researched = true
		player.force.technologies["biological-warfare"].researched = true
	end
end


function initTables()
	if glob.treefarm ~= nil then
		migration100()
		return
	end
	glob.treefarm = {}

	glob.treefarm.field =
	{
		--[[
		example entry:
		[1] =
		entity = pointer to field entity,
		fertAmount = fraction of a single fertilizer-item (1 item can fertilize 10 seeds),
		nextUpdate = next update in ticks
		]]
	}

	glob.treefarm.fieldmk2 =
	{
		--[[
		example entry:
		[1] =
		entity = pointer to field entity,
		active = bool to indicate if field is active/working,
		areaRadius = the radius of the used area (can be modified in-game),
		fertAmount = fraction of a single fertilizer-item (1 item can fertilize 10 seeds),
		nextUpdate = next update in ticks
		]]
	}

	glob.treefarm.tmpData =
	{
		--contains data that have to be saved just temporary
	}

	glob.treefarm.seedTypes =
	{
		basicTrees = {}
		-- other types can be added via script-interface
	}

	-- example how a "type"-table looks like
	glob.treefarm.seedTypes.basicTrees =
	{
		states =
		{
			"germling",
			"very-small-tree",
			"small-tree",
			"medium-tree",
			"mature-tree"
		},
		output = {"raw-wood", 5},
		efficiency = 
		{
			["grass"] = 1.00,
			["grass-medium"] = 1.00,
			["grass-dry"] = 0.90,
			["dirt"] = 0.75,
			["dirt-dark"] = 0.75,
			["hills"] = 0.50,
			["sand"] = 0.30,
			["sand-dark"] = 0.30,

			["other"] = 0.01
		},
		basicGrowingTime = 3600,
		randomGrowingTime = 1800,
		fertilizerBoost = 1.00
	}

	glob.treefarm.isGrowing =
	{
		-- a by number indexed table that contains all info related to entities of this type
		-- it is ordered with the first element will be upgraded next
		basicTrees =
		{
			--[[
			example entry:
			[1] =
			{
				entity = pointer to the entity,
				state = current growing state,
				efficiency = store efficiency to avoid recalculating all the time
				fertilized = bool if fertilizer was used while planting
				nextUpdate = stores the tick when the next state-update will happen
			}
			--]]
		}
	}

	glob.treefarm.version = "1.1.5"

end


function migration100()
	for _,player in pairs(game.players) do
		player.force.resettechnologies()
		player.force.resetrecipes()
	end
	local tmpFieldEntities = {}
	local tmpFieldmk2Entities = {}
	local tmpGrowingTrees = {}

	if glob.treefarm.field ~= nil then
		for index, fieldEnt in ipairs(glob.treefarm.field) do
			if fieldEnt.valid then
				local tmpFieldTable =
				{
					["entity"] = fieldEnt,
					["fertAmount"] = 0,
					["nextUpdate"] = game.tick + 60 + math.ceil(math.random() * 120)
				}
				table.insert(tmpFieldEntities, tmpFieldTable)
				local fieldPos = {x = fieldEnt.position.x, y = fieldEnt.position.y}
				local grownEntities = game.findentitiesfiltered{area = {fieldPos, {fieldPos.x + 8, fieldPos.y + 8}}, type = "tree"}
				for _,tree in ipairs(grownEntities) do
					tree.destroy()
					fieldEnt.getinventory(1).insert{name = "raw-wood", count = 5}
				end
			end
		end
	end

	if glob.treefarm.efficiency ~= nil then
		glob.treefarm.efficiency = nil
	end

	if glob.treefarm.tick ~= nil then
		glob.treefarm.tick = nil
	end

	if (glob.treefarm.fieldmk2 ~= nil) and (glob.treefarm.fieldmk2.entities ~= nil) then
		for index, fieldEnt in ipairs(glob.treefarm.fieldmk2.entities) do
			local tmpFieldTable =
			{
				["entity"] = fieldEnt,
				["active"] = glob.treefarm.fieldmk2.active[index],
				["areaRadius"] = glob.treefarm.fieldmk2.area[index],
				["fertAmount"] = 0,
				["nextUpdate"] = game.tick + 60 + math.ceil(math.random() * 120)
			}
			table.insert(tmpFieldmk2Entities, tmpFieldTable)
		end
	end

	if glob.treefarm.growingTrees ~= nil then
		for index, treeEnt in ipairs(glob.treefarm.growingTrees.entities) do
			local tmpTreeTable =
			{
				["entity"] = treeEnt,
				["state"] = glob.treefarm.growingTrees.status[index],
				["efficiency"] = glob.treefarm.growingTrees.efficiency[index],
				["fertilized"] = false,
				["nextUpdate"] = game.tick + math.ceil(math.random() * 3600)
			}
			if tmpTreeTable.state > 5 then tmpTreeTable.state = 5 end
			table.insert(tmpGrowingTrees, tmpTreeTable)
		end
	end

	if (glob.treefarm.fieldmk2 ~= nil) and (glob.treefarm.fieldmk2.tmpIndex ~= nil) then
		glob.treefarm.fieldmk2.tmpIndex = nil
	end

	glob.treefarm = {}
	glob.treefarm.field = {}
	glob.treefarm.fieldmk2 = {}
	glob.treefarm.tmpData = {}
	glob.treefarm.seedTypes ={basicTrees = {}}
	glob.treefarm.seedTypes.basicTrees =
	{
		states =
		{
			"germling",
			"very-small-tree",
			"small-tree",
			"medium-tree",
			"mature-tree"
		},
		output = {"raw-wood", 5},
		efficiency = 
		{
			["grass"] = 1.00,
			["grass-medium"] = 1.00,
			["grass-dry"] = 0.90,
			["dirt"] = 0.75,
			["dirt-dark"] = 0.75,
			["hills"] = 0.50,
			["sand"] = 0.30,
			["sand-dark"] = 0.30,

			["other"] = 0
		},
		basicGrowingTime = 3600,
		randomGrowingTime = 1800,
		fertilizerBoost = 1.00
	}
	glob.treefarm.isGrowing = {basicTrees = {}}

	glob.treefarm.field = table.deepcopy(tmpFieldEntities)
	glob.treefarm.fieldmk2 = table.deepcopy(tmpFieldmk2Entities)
	glob.treefarm.isGrowing.basicTrees = table.deepcopy(tmpGrowingTrees)

	glob.treefarm.version = "1.0.0"
end

function migration102()
	for _,player in pairs(game.players) do
		player.force.resettechnologies()
		player.force.resetrecipes()

		if player.force.technologies["fertilizer"].researched == true then
			player.force.recipes["biomass-0"].enabled = true
		end
		glob.treefarm.version = "1.0.2"
	end
end

function migration110()
	for _,player in pairs(game.players) do
		player.force.resettechnologies()
		player.force.resetrecipes()
	end

	glob.treefarm.version = "1.1.0"
end

function migration111()
	for _,player in pairs(game.players) do
		player.force.resettechnologies()
		player.force.resetrecipes()
	end

	for index, field in ipairs(glob.treefarm.fieldmk2) do
		if glob.treefarm.fieldmk2[index].roboport == nil then
			local tmpRoboport = game.createentity{name = "fieldroboport10",
											  	  position = field.entity.position,
											  	  force = game.frces.player}
			glob.treefarm.fieldmk2[index].roboport = tmpRoboport
		end
		if glob.treefarm.fieldmk2[index].logChest == nil then
			local tmpLogChest = game.createentity{name = "logistic-chest-requester",
										   	 	  position = { x = field.entity.position.x + 0,
										   					   y = field.entity.position.y + 1},
												  force = game.frces.player}
			tmpLogChest.destructible = false
			tmpLogChest.minable = false
			-- LOG CONDITION
			tmpLogChest.setrequestslot({name="raw-wood", count = 1000}, 1)
			glob.treefarm.fieldmk2[index].logChest = tmpLogChest
		end
	end

	glob.treefarm.version = "1.1.1"
end

function migration112()
	for _,player in pairs(game.players) do
		player.force.resettechnologies()
		player.force.resetrecipes()


		for _, fieldEnt in ipairs (glob.treefarm.field) do
			local tmpEnt = game.createentity{name = "field-2", position = fieldEnt.entity.position, force = game.forces.player}
			fieldEnt.entity.destroy()
			fieldEnt.entity = tmpEnt
		end

		if player.force.technologies["coal-processing"].researched == true then
			player.force.recipes["charcoal"].enabled = true
			player.force.recipes["coal"].enabled = true
			player.force.recipes["coke-coal"].enabled = true
			player.force.recipes["ash"].enabled = true
			player.force.recipes["cokery"].enabled = true
		end

		if player.force.technologies["fertilizer"].researched == true then
			player.force.recipes["biolab"].enabled = true
			player.force.recipes["stone-crusher"].enabled = true
			player.force.recipes["crushed-stone"].enabled = true
			player.force.recipes["liquid-air"].enabled = true
			player.force.recipes["liquid-nitrogen"].enabled = true
			player.force.recipes["fill-liquid-nitrogen-barrel"].enabled = true
			player.force.recipes["empty-liquid-nitrogen-barrel"].enabled = true
			player.force.recipes["phosphate"].enabled = true
			player.force.recipes["potassium"].enabled = true
			player.force.recipes["fertilizer1"].enabled = true
			player.force.recipes["fertilizer2"].enabled = true
		end

		if player.force.technologies["advanced-biotechnology"].researched == true then
			player.force.recipes["bioreactor"].enabled = true
			player.force.recipes["biomass-0"].enabled = true
			player.force.recipes["biomass-1"].enabled = true
			player.force.recipes["liquid-co2"].enabled = true
			player.force.recipes["cellulose"].enabled = true
			player.force.recipes["charcoal2"].enabled = true
			player.force.recipes["methanol1"].enabled = true
		end

		if player.force.technologies["organic-plastic"].researched == true then
			player.force.recipes["treefarm-mod-platic"].enabled = true
		end

		if player.force.technologies["medicine"].researched == true then
			player.force.recipes["nutrients"].enabled = true
			player.force.recipes["medicine"].enabled = true
		end

		if player.force.technologies["advanced-treefarming"].researched == true then
			player.force.recipes["fieldmk2"].enabled = true
		end

		if player.force.technologies["biological-warfare"].researched == true then
			player.force.recipes["glue"].enabled = true
			player.force.recipes["glue-rocket"].enabled = true
			player.force.recipes["glue-capsule"].enabled = true
			player.force.recipes["glue-turret"].enabled = true
			player.force.recipes["tf-flame-thrower-ammo"].enabled = true
		end

		glob.treefarm.version = "1.1.2"
	end
end


function migration114()
	for _, fieldEnt in ipairs (glob.treefarm.fieldmk2) do
		if fieldEnt.logChest ~= nil then
			fieldEnt.logChest.destroy()
			fieldEnt.logChest = nil
		end

		if fieldEnt.roboport ~= nil then
			fieldEnt.roboport.destroy()
			fieldEnt.roboport = nil
		end
	end

	glob.treefarm.version = "1.1.4"
end


function migration115()
	for _,player in pairs(game.players) do
		player.force.resettechnologies()
		player.force.resetrecipes()
	end

	glob.treefarm.version = "1.1.5"
end


function migration116()
	for _,player in pairs(game.players) do
		player.force.resettechnologies()
		player.force.resetrecipes()
	end

	glob.treefarm.version = "1.1.6"
end


function migration117()
	for _,player in pairs(game.players) do
		player.force.resettechnologies()
		player.force.resetrecipes()
	end

	for _, field in ipairs (glob.treefarm.field) do
		if field.lastSeedPos == nil then
			field.lastSeedPos = {x = 2, y = 1}
		end
	end

	for _, field in ipairs (glob.treefarm.fieldmk2) do
		if field.lastSeedPos == nil then
			field.lastSeedPos = {x = -field.areaRadius, y = -field.areaRadius}
		end

		if field.toBeHarvested == nil then
			field.toBeHarvested = {}
		end
	end


	glob.treefarm.version = "1.1.7"
end

function migration119()

	for _, treeTypes in pairs(glob.treefarm.seedTypes) do
		if treeTypes.efficiency.other == 0 then
			treeTypes.efficiency.other = 0.01
		end
	end

	for _, treeTypes in pairs(glob.treefarm.isGrowing) do
		for _, tree in ipairs(treeTypes) do
			if tree.efficiency == 0 then
				tree.efficiency = 1
				tree.nextUpdate = game.tick + 60
			end
		end
	end

	glob.treefarm.version = "1.1.9"
end