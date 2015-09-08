require "utils"
require "defines"
require "interfaces"

remote.add_interface("narmod",
{
  Regenerate = function()
	game.regenerate_entity("tin-ore")
	game.regenerate_entity("zinc-ore")
	game.regenerate_entity("tungsten-ore")
	game.regenerate_entity("gold-ore")
	game.regenerate_entity("bauxite-ore")
	game.regenerate_entity("lead-ore")
	game.regenerate_entity("rutile-ore")
	game.regenerate_entity("quartz")
	game.regenerate_entity("uraninite-ore")
	game.regenerate_entity("fluorite-ore")
  end
}
)

local seedTypeLookUpTable = {}
function createSeedTypeLookUpTable()
	for seedTypeName, seedType in pairs(global.treefarm.seedTypes) do
		for _, stateName in pairs(seedType.states) do
			seedTypeLookUpTable[stateName] = seedTypeName
		end
	end	
end


game.on_init(function()
	utils.initTables()

	for _, treeTypes in pairs(global.treefarm.seedTypes) do
		if treeTypes.efficiency.other == 0 then
			treeTypes.efficiency.other = 0.01
		end
	end

	for seedTypeName, seedTypeInfo in pairs (global.treefarm.seedTypes) do
		if game.item_prototypes[seedTypeInfo.states[1]] == nil then
			global.treefarm.isGrowing[seedTypeName] = nil
			global.treefarm.seedTypes[seedTypeName] = nil
		end
	end

	createSeedTypeLookUpTable()
end)


game.on_load(function()

	for _, treeTypes in pairs(global.treefarm.seedTypes) do
		if treeTypes.efficiency.other == 0 then
			treeTypes.efficiency.other = 0.01
		end
	end

	for seedTypeName, seedTypeInfo in pairs (global.treefarm.seedTypes) do
		if game.item_prototypes[seedTypeInfo.states[1]] == nil then
			global.treefarm.isGrowing[seedTypeName] = nil
			global.treefarm.seedTypes[seedTypeName] = nil
		end
	end

	createSeedTypeLookUpTable()

end)


game.on_event(defines.events.on_player_mined_item, function(event)
	if event.item_stack.name == "field" then
		for index, field in ipairs(global.treefarm.field) do
			if not field.entity.valid then
				table.remove(global.treefarm.field, index)
				return
			end
		end
	elseif event.item_stack.name == "fieldmk2" then
		for index, field in ipairs(global.treefarm.fieldmk2) do
			if not field.entity.valid then
				table.remove(global.treefarm.fieldmk2, index)
				return
			end
		end
	end
end)


game.on_event(defines.events.on_robot_mined, function(event)
	if event.item_stack.name == "field" then
		for index, field in ipairs(global.treefarm.field) do
			if not field.entity.valid then
				table.remove(global.treefarm.field, index)
				return
			end
		end
	elseif event.item_stack.name == "fieldmk2" then
		for index, field in ipairs(global.treefarm.fieldmk2) do
			if not field.entity.valid then
				table.remove(global.treefarm.fieldmk2, index)
				return
			end
		end
	end
end)


game.on_event(defines.events.on_entity_died, function(event)
	if event.entity.name == "field-2" then
		for index,entInfo in ipairs(global.treefarm.field) do
			if  entInfo.entity.equals(event.entity) then
				table.remove(global.treefarm.field, index)
				return
			end
		end
	elseif event.entity.name == "fieldmk2" then
		for index,entInfo in ipairs(global.treefarm.fieldmk2) do
			if  entInfo.entity.equals(event.entity) then
				table.remove(global.treefarm.fieldmk2, index)
				return
			end
		end
	end
end)


game.on_event(defines.events.on_put_item, function(event)

	for playerIndex,player in pairs(game.players) do
		if (player ~= nil) and (player.selected ~= nil) then
			if player.selected.name == "fieldmk2" then
				for index, entInfo in ipairs(global.treefarm.fieldmk2) do
					if entInfo.entity.equals(player.selected) then
						global.treefarm.tmpData.fieldmk2Index = index
						showFieldmk2GUI(index, playerIndex)
					end
				end
			end
		end
	end
end)


game.on_event(defines.events.on_built_entity, function(event)

	local player = game.players[event.player_index]

	if event.created_entity.name == "field-2" then
		if canPlaceField(event.created_entity) ~= true then
			player.insert{name = "field", count = 1}
			event.created_entity.destroy()
			player.print({"msg_buildingFail"})
			return
		else
			local entInfo =
			{
				entity = event.created_entity,
				fertAmount = 0,
				lastSeedPos = {x = 2, y = 1},
				nextUpdate = event.tick + 60
			}
			table.insert(global.treefarm.field, entInfo)
			return
		end
	elseif event.created_entity.type == "tree" then
		local currentSeedTypeName = seedTypeLookUpTable[event.created_entity.name]
		if currentSeedTypeName ~= nil then
			local newEfficiency = calcEfficiency(event.created_entity, false)
			local deltaTime = math.ceil((math.random() * global.treefarm.seedTypes[currentSeedTypeName].randomGrowingTime + global.treefarm.seedTypes[currentSeedTypeName].basicGrowingTime) / newEfficiency)
			local nextUpdateIn = event.tick + deltaTime
			local entInfo =
			{
				entity = event.created_entity,
				state = 1,
				efficiency = newEfficiency,
				nextUpdate = nextUpdateIn
			}
			placeSeedIntoList(entInfo, currentSeedTypeName)
			return
		end
	elseif event.created_entity.name == "fieldmk2Overlay" then
		local ent = game.create_entity{name = "fieldmk2",
									  position = event.created_entity.position,
									  force = game.forces.player}
		local entInfo =
		{
			entity = ent,
			active = true,
			areaRadius = 9,
			fertAmount = 0,
			lastSeedPos = {x = -9, y = -9},
			toBeHarvested = {},
			nextUpdate = event.tick + 60
		}
		table.insert(global.treefarm.fieldmk2, entInfo)

		global.treefarm.tmpData.fieldmk2Index = #global.treefarm.fieldmk2
		showFieldmk2GUI(#global.treefarm.fieldmk2, event.player_index)
		event.created_entity.destroy()
		return
	end
end)


game.on_event(defines.events.on_gui_click, function(event)
	local index = global.treefarm.tmpData.fieldmk2Index
	local player = game.players[event.element.player_index]
	if event.element.name == "okButton" then
		if player.gui.center.fieldmk2Root ~= nil then
			player.gui.center.fieldmk2Root.destroy()
			destroyOverlay()
		end
	elseif event.element.name == "toggleActiveBut" then
		if global.treefarm.fieldmk2[index].active == true then
			global.treefarm.fieldmk2[index].active = false
			mk2CancelDecontruction(global.treefarm.fieldmk2[index])
			player.gui.center.fieldmk2Root.fieldmk2Table.colLabel2.caption = "not active"
		else
			global.treefarm.fieldmk2[index].active = true
			mk2MarkDeconstruction(global.treefarm.fieldmk2[index])
			player.gui.center.fieldmk2Root.fieldmk2Table.colLabel2.caption = "active"
		end
		destroyOverlay()
		createOverlay(global.treefarm.fieldmk2[index])
	elseif event.element.name == "incAreaBut" then
		if global.treefarm.fieldmk2[index].areaRadius < 9 then
			global.treefarm.fieldmk2[index].areaRadius = global.treefarm.fieldmk2[index].areaRadius + 1
			destroyOverlay()
			createOverlay(global.treefarm.fieldmk2[index])
		end
		player.gui.center.fieldmk2Root.fieldmk2Table.areaLabel2.caption = global.treefarm.fieldmk2[index].areaRadius
	elseif event.element.name == "decAreaBut" then
		if global.treefarm.fieldmk2[index].areaRadius > 1 then
			global.treefarm.fieldmk2[index].areaRadius = global.treefarm.fieldmk2[index].areaRadius - 1
			destroyOverlay()
			createOverlay(global.treefarm.fieldmk2[index])
		end
		player.gui.center.fieldmk2Root.fieldmk2Table.areaLabel2.caption = global.treefarm.fieldmk2[index].areaRadius
	end
end)


game.on_event(defines.events.on_tick, function(event)
	if (global.treefarm.requestLookUpTableUpdate == true) then
		createSeedTypeLookUpTable()
		global.treefarm.requestLookUpTableUpdate = false
	end

	for _, seedType in pairs(global.treefarm.isGrowing) do
		if (seedType[1] ~= nil) and (event.tick >= seedType[1].nextUpdate)then
			local removedEntity = table.remove(seedType, 1)
			
			local seedTypeName
			local newState
			if removedEntity.entity.valid then
				seedTypeName = seedTypeLookUpTable[removedEntity.entity.name]
				newState = removedEntity.state + 1

				if newState <= #global.treefarm.seedTypes[seedTypeName].states then
					local tmpPos = removedEntity.entity.position
					local newEnt = game.get_surface(1).create_entity{name = global.treefarm.seedTypes[seedTypeLookUpTable[removedEntity.entity.name]].states[newState], position = tmpPos}
					removedEntity.entity.destroy()
					local deltaTime = math.ceil((math.random() * global.treefarm.seedTypes[seedTypeName].randomGrowingTime + global.treefarm.seedTypes[seedTypeName].basicGrowingTime) / removedEntity.efficiency)
					local updatedEntry =
					{
						entity = newEnt,
						state = newState,
						efficiency = removedEntity.efficiency,
						nextUpdate = event.tick + deltaTime
					}
					placeSeedIntoList(updatedEntry, seedTypeName)
				elseif (isInMk2Range(removedEntity.entity.position)) then
					removedEntity.entity.order_deconstruction(game.forces.player)
				end
			end
		end
	end


	if (global.treefarm.field[1] ~= nil) and (event.tick >= global.treefarm.field[1].nextUpdate) then
		if global.treefarm.field[1].entity.valid then
			fieldMaintainer(event.tick)
		else
			table.remove(global.treefarm.field, 1)
		end
	end

	if (global.treefarm.fieldmk2[1] ~= nil) and (event.tick >= global.treefarm.fieldmk2[1].nextUpdate) then
		if global.treefarm.fieldmk2[1].entity.valid then
			if not anyPlayerHasOpenUI() then
				if global.treefarm.fieldmk2[1].active == true then
					fieldmk2Maintainer(event.tick)
				else
					global.treefarm.fieldmk2[1].nextUpdate = event.tick + 60
					local field = table.remove(global.treefarm.fieldmk2, 1)
					table.insert(global.treefarm.fieldmk2, field)
				end
			end
		else
			table.remove(global.treefarm.fieldmk2, 1)
		end
	end
end)


function anyPlayerHasOpenUI()
	for _, player in ipairs(game.players) do
		if player.gui.center.fieldmk2Root ~= nil then
			return true
		end
	end
	return false
end


function mk2MarkDeconstruction(field)

	local fieldPos = {x = field.entity.position.x, y = field.entity.position.y}
	local areaPosMin = {x = fieldPos.x - field.areaRadius - 1, y = fieldPos.y - field.areaRadius - 1}
	local areaPosMax = {x = fieldPos.x + field.areaRadius + 1, y = fieldPos.y + field.areaRadius + 1}
	local tmpEntities = game.find_entitiesfiltered{area = {areaPosMin, areaPosMax}, type = "tree"}

	if #tmpEntities > 0 then
		for i = 1, #tmpEntities do
			for _, seedType in pairs(global.treefarm.seedTypes) do
				if (tmpEntities[i].name == seedType.states[#seedType.states]) and (tmpEntities[i].to_be_deconstructed(game.forces.player) == false) then
					tmpEntities[i].order_deconstruction(game.forces.player)
				end
			end
		end
	end
end

function mk2CancelDecontruction(field)
	local fieldPos = {x = field.entity.position.x, y = field.entity.position.y}
	local areaPosMin = {x = fieldPos.x - field.areaRadius - 1, y = fieldPos.y - field.areaRadius - 1}
	local areaPosMax = {x = fieldPos.x + field.areaRadius + 1, y = fieldPos.y + field.areaRadius + 1}
	local tmpEntities = game.find_entitiesfiltered{area = {areaPosMin, areaPosMax}, type = "tree"}

	if #tmpEntities > 0 then
		for i = 1, #tmpEntities do
			for _, seedType in pairs(global.treefarm.seedTypes) do
				if (tmpEntities[i].name == seedType.states[#seedType.states]) and (tmpEntities[i].to_be_deconstructed(game.forces.player) == true) then
					tmpEntities[i].cancel_deconstruction(game.forces.player)
				end
			end
		end
	end
end


function isInMk2Range(plantPos)
	for _, field in ipairs(global.treefarm.fieldmk2) do
		if field.active == true then
			local fieldPos = {x = field.entity.position.x, y = field.entity.position.y}
			local areaPosMin = {x = fieldPos.x - field.areaRadius - 1, y = fieldPos.y - field.areaRadius - 1}
			local areaPosMax = {x = fieldPos.x + field.areaRadius + 1, y = fieldPos.y + field.areaRadius + 1}
			if (plantPos.x >= areaPosMin.x) and
					(plantPos.x <= areaPosMax.x) and
		   			(plantPos.y >= areaPosMin.y) and
		   			(plantPos.y <= areaPosMax.y) then
		   		return true
			end
		end
	end
	return false
end

function calcEfficiency(entity, fertilizerApplied)
	local seedType = seedTypeLookUpTable[entity.name]
	local currentTilename = game.get_surface(1).get_tile(entity.position.x, entity.position.y).name

	local efficiency
	if global.treefarm.seedTypes[seedType].efficiency[currentTilename] == nil then
		return global.treefarm.seedTypes[seedType].efficiency.other
	else
		efficiency = global.treefarm.seedTypes[seedType].efficiency[currentTilename]
		if fertilizerApplied then
			return efficiency + global.treefarm.seedTypes[seedType].fertilizerBoost
		else
			return efficiency
		end
	end
end


function placeSeedIntoList(entInfo, seedTypeName)
	if #global.treefarm.isGrowing[seedTypeName] > 1 then
		for i = #global.treefarm.isGrowing[seedTypeName], 1, -1 do
			if global.treefarm.isGrowing[seedTypeName][i].nextUpdate <= entInfo.nextUpdate then
				table.insert(global.treefarm.isGrowing[seedTypeName], i + 1, entInfo)
				return
			end
		end
		table.insert(global.treefarm.isGrowing[seedTypeName], 1,  entInfo)
		return
	elseif #global.treefarm.isGrowing[seedTypeName] == 1 then
		if global.treefarm.isGrowing[seedTypeName][1].nextUpdate > entInfo.nextUpdate then
			table.insert(global.treefarm.isGrowing[seedTypeName], 1,  entInfo)
			return
		else
			table.insert(global.treefarm.isGrowing[seedTypeName], entInfo)
			return
		end
	else
		table.insert(global.treefarm.isGrowing[seedTypeName], entInfo)
		return
	end
	table.insert(global.treefarm.isGrowing[seedTypeName], entInfo)
end


function fieldMaintainer(tick)
	-- SEEDPLANTING --
	local seedInInv = {name ="DUMMY", amount = "DUMMY"}
	for _,seedType in pairs(global.treefarm.seedTypes) do
		local newAmount = global.treefarm.field[1].entity.get_inventory(1).get_item_count(seedType.states[1])
		if newAmount > 0 then
			seedInInv =
			{
				name = seedType.states[1],
				amount = newAmount
			}
			break
		end
	end

	local seedPos = false
	if seedInInv.name ~= "DUMMY" then
		local fieldPos = {x = global.treefarm.field[1].entity.position.x, y = global.treefarm.field[1].entity.position.y}
		
		local placed = false
		if global.treefarm.field[1].lastSeedPos == nil then
			global.treefarm.field[1].lastSeedPos = {x = 2, y = 1}
		end
		local lastPos = {x = global.treefarm.field[1].lastSeedPos.x, y = global.treefarm.field[1].lastSeedPos.y}
		for dx = lastPos.x, 7 do
			for dy = 1, 7 do
				if (game.get_surface(1).can_place_entity{name = "germling", position = {fieldPos.x + dx - 0.5, fieldPos.y + dy - 0.5}}) then
					seedPos = {x = fieldPos.x + dx - 0.5, y = fieldPos.y + dy - 0.5}
					placed = true
					global.treefarm.field[1].lastSeedPos = {x = dx, y = dy}
					break
				end
			end
			if placed == true then
				break
			end
		end

		if (placed == false) and (lastPos.x ~= 2) then
			for dx = 2, lastPos.x - 1 do
				for dy = 1, 7 do
					if (game.get_surface(1).can_place_entity{name = "germling", position = {fieldPos.x + dx - 0.5, fieldPos.y + dy - 0.5}}) then
						seedPos = {x = fieldPos.x + dx - 0.5, y = fieldPos.y + dy - 0.5}
						placed = true
						global.treefarm.field[1].lastSeedPos = {x = dx, y = dy}
						break
					end
				end
				if placed == true then
					break
				end
			end
		end

		if seedPos ~= false then

			local seedTypeName = seedTypeLookUpTable[seedInInv.name]
			local newEntity = game.get_surface(1).create_entity{name = seedInInv.name, position = seedPos}
			local newFertilized = false

			if (global.treefarm.field[1].fertAmount <= 0) and (global.treefarm.field[1].entity.get_inventory(2).get_item_count("fertilizer") > 0) then
				global.treefarm.field[1].fertAmount = 1
				global.treefarm.field[1].entity.get_inventory(2).remove{name = "fertilizer", count = 1}
			end

			if global.treefarm.field[1].fertAmount >= 0.1 then
				global.treefarm.field[1].fertAmount = global.treefarm.field[1].fertAmount - 0.1
				newFertilized = true
				if global.treefarm.field[1].fertAmount < 0.1 then
					global.treefarm.field[1].fertAmount = 0
				end
			end
 
			local newEfficiency = calcEfficiency(newEntity, newFertilized)
			local entInfo =
			{
				entity = newEntity,
				state = 1,
				efficiency = newEfficiency,
				nextUpdate = tick + math.ceil((math.random() * global.treefarm.seedTypes[seedTypeName].randomGrowingTime + global.treefarm.seedTypes[seedTypeName].basicGrowingTime) / newEfficiency)
			}
			global.treefarm.field[1].entity.get_inventory(1).remove{name = seedInInv.name, count = 1}
			placeSeedIntoList(entInfo, seedTypeName)
		end
	end

	-- HARVESTING --
	local fieldPos = {x = global.treefarm.field[1].entity.position.x, y = global.treefarm.field[1].entity.position.y}
	local grownEntities = game.get_surface(1).find_entities_filtered{area = {fieldPos, {fieldPos.x + 8, fieldPos.y + 8}}, type = "tree"}
	for _,entity in ipairs(grownEntities) do
		for _,seedType in pairs(global.treefarm.seedTypes) do
			if entity.name == seedType.states[#seedType.states] then
				local output = {name = seedType.output[1], amount = seedType.output[2]}
				if (global.treefarm.field[1].entity.get_inventory(3).can_insert{name = output.name, count = output.amount}) and (50 - global.treefarm.field[1].entity.get_inventory(3).get_item_count(output.name) >= output.amount) then
					global.treefarm.field[1].entity.get_inventory(3).insert{name = output.name, count = output.amount}
					entity.destroy()
				end
				global.treefarm.field[1].nextUpdate = tick + 60
				local field = table.remove(global.treefarm.field, 1)
				table.insert(global.treefarm.field, field)
				return
			end
		end
	end
	global.treefarm.field[1].nextUpdate = tick + 60
	local field = table.remove(global.treefarm.field, 1)
	table.insert(global.treefarm.field, field)
end


function fieldmk2Maintainer(tick)
	-- SEEDPLANTING --
	local seedInInv = {name ="DUMMY", amount = "DUMMY"}
	for _,seedType in pairs(global.treefarm.seedTypes) do
		local newAmount = global.treefarm.fieldmk2[1].entity.get_item_count(seedType.states[1])
		if newAmount > 0 then
			seedInInv =
			{
				name = seedType.states[1],
				amount = newAmount
			}
			break
		end
	end

	local seedPos = false
	if seedInInv.name ~= "DUMMY" then
		if global.treefarm.fieldmk2[1].lastSeedPos == nil then
			global.treefarm.fieldmk2[1].lastSeedPos = {x = -global.treefarm.fieldmk2[1].areaRadius, y = -global.treefarm.fieldmk2[1].areaRadius}
		end
		local fieldPos = {x = global.treefarm.fieldmk2[1].entity.position.x, y = global.treefarm.fieldmk2[1].entity.position.y}
		
		local placed = false
		local lastPos = {x = global.treefarm.fieldmk2[1].lastSeedPos.x, y = global.treefarm.fieldmk2[1].lastSeedPos.y}
		
		if lastPos.x < -global.treefarm.fieldmk2[1].areaRadius then
			lastPos.x = -global.treefarm.fieldmk2[1].areaRadius
		elseif lastPos.x > global.treefarm.fieldmk2[1].areaRadius then
			lastPos.x = global.treefarm.fieldmk2[1].areaRadius
		end

		if lastPos.y < -global.treefarm.fieldmk2[1].areaRadius then
			lastPos.y = -global.treefarm.fieldmk2[1].areaRadius
		elseif lastPos.y > global.treefarm.fieldmk2[1].areaRadius then
			lastPos.y = global.treefarm.fieldmk2[1].areaRadius
		end


		for dx = lastPos.x, global.treefarm.fieldmk2[1].areaRadius do
			for dy = -global.treefarm.fieldmk2[1].areaRadius, global.treefarm.fieldmk2[1].areaRadius do
				if (game.can_place_entity{name = "germling", position = {fieldPos.x + dx - 0.5, fieldPos.y + dy - 0.5}}) then
					seedPos = {x = fieldPos.x + dx - 0.5, y = fieldPos.y + dy - 0.5}
					placed = true
					global.treefarm.fieldmk2[1].lastSeedPos = {x = dx, y = dy}
					break
				end
			end
			if placed == true then
				break
			end
		end

		if (placed == false) and (lastPos.x ~= -global.treefarm.fieldmk2[1].areaRadius) then
			for dx = -global.treefarm.fieldmk2[1].areaRadius, lastPos.x - 1 do
				for dy = -global.treefarm.fieldmk2[1].areaRadius, global.treefarm.fieldmk2[1].areaRadius do
					if (game.can_place_entity{name = "germling", position = {fieldPos.x + dx - 0.5, fieldPos.y + dy - 0.5}}) then
						seedPos = {x = fieldPos.x + dx - 0.5, y = fieldPos.y + dy - 0.5}
						placed = true
						global.treefarm.fieldmk2[1].lastSeedPos = {x = dx, y = dy}
						break
					end
				end
				if placed == true then
					break
				end
			end
		end

		if seedPos ~= false then

			local seedTypeName = seedTypeLookUpTable[seedInInv.name]
			local newEntity = game.create_entity{name = seedInInv.name, position = seedPos}
			local newFertilized = false

			if (global.treefarm.fieldmk2[1].fertAmount <= 0) and (global.treefarm.fieldmk2[1].entity.get_inventory(1).get_item_count("fertilizer") > 0) then
				global.treefarm.fieldmk2[1].fertAmount = 1
				global.treefarm.fieldmk2[1].entity.get_inventory(1).remove{name = "fertilizer", count = 1}
			end

			if global.treefarm.fieldmk2[1].fertAmount >= 0.1 then
				global.treefarm.fieldmk2[1].fertAmount = global.treefarm.fieldmk2[1].fertAmount - 0.1
				newFertilized = true
				if global.treefarm.fieldmk2[1].fertAmount < 0.1 then
					global.treefarm.fieldmk2[1].fertAmount = 0
				end
			end
 
			local newEfficiency = calcEfficiency(newEntity, newFertilized)
			local entInfo =
			{
				entity = newEntity,
				state = 1,
				efficiency = newEfficiency,
				nextUpdate = tick + math.ceil((math.random() * global.treefarm.seedTypes[seedTypeName].randomGrowingTime + global.treefarm.seedTypes[seedTypeName].basicGrowingTime) / newEfficiency)
			}
			global.treefarm.fieldmk2[1].entity.get_inventory(1).remove{name = seedInInv.name, count = 1}
			placeSeedIntoList(entInfo, seedTypeName)
		end
	end


	-- HARVESTING --
	-- is done in tree-growing function --

	global.treefarm.fieldmk2[1].nextUpdate = tick + 60
	local field = table.remove(global.treefarm.fieldmk2, 1)
	table.insert(global.treefarm.fieldmk2, field)
end


function canPlaceSeed(entInfo)
	local fieldPos = {x = entInfo.entity.position.x, y = entInfo.entity.position.y}
	if entInfo.entity.name == "fieldmk2" then
		local pos = {x = entInfo.entity.position.x, y = entInfo.entity.position.y}
		for dx = -entInfo.areaRadius, entInfo.areaRadius + 1 do
			for dy = -entInfo.areaRadius, entInfo.areaRadius + 1 do
				if (game.can_place_entity{name = "germling", position = {pos.x + dx - 0.5, pos.y + dy - 0.5}}) then
					local tmpPos = {x = pos.x + dx - 0.5, y = pos.y + dy - 0.5}
					return tmpPos
				end
			end
		end
		return false
	end
end


function canPlaceField(field)
	local fPosX, fPosY = field.position.x, field.position.y
	for x = 1, 7 do
		for y = 0, 7 do
			if (x == 0) and ( y == 0) then
				--do nothing
			else
				if not game.get_surface(1).can_place_entity{name="wooden-chest", position = {fPosX + x, fPosY + y}} then
					local playerEnt = game.get_surface(1).find_entities_filtered{area = {{fPosX + x - 1, fPosY + y - 1},{fPosX + x + 1, fPosY + y + 1}}, name="player"}
					if #playerEnt > 0 then
						-- do nothing
					else
						return
					end
				end
			end
		end
	end
	local blockingField = {}
	blockingField = game.get_surface(1).find_entities_filtered{area = {{x = fPosX - 8, y = fPosY - 8}, {fPosX + 8, fPosY + 8}}, name="field-2"}
	if #blockingField > 1 then
		return
	end
	return true
end


function getSeedInInventory(fieldEnt)
	for _,seedType in pairs(global.treefarm.seedTypes) do
		local newAmount = fieldEnt.get_item_count(seedType.states[1])
		if newAmount > 0 then
			local seed =
			{
				name = seedType.states[1],
				amount = newAmount
			}
			return seed
		end
	end
	return nil
end


function showFieldmk2GUI(index, playerIndex)
	local player = game.players[playerIndex]
	if player.gui.center.fieldmk2Root == nil then
		local rootFrame = player.gui.center.add{type = "frame", name = "fieldmk2Root", caption = game.get_localised_entity_name("fieldmk2"), direction = "vertical"}
			local rootTable = rootFrame.add{type ="table", name = "fieldmk2Table", colspan = 4}
				rootTable.add{type = "label", name = "colLabel1", caption = {"thisFieldIs"}}
				local status = "active / not active"
				if global.treefarm.fieldmk2[index].active == true then
					status = {"active"}
				else
					status = {"notActive"}
				end
				rootTable.add{type = "label", name = "colLabel2", caption = status}
				rootTable.add{type = "button", name = "toggleActiveBut", caption = {"toggleButtonCaption"}, style = "tf_smallerButtonFont"}
				rootTable.add{type = "label", name = "colLabel4", caption = ""}

				rootTable.add{type = "label", name = "areaLabel1", caption = {"usedArea"}}
				rootTable.add{type = "label", name = "areaLabel2", caption = global.treefarm.fieldmk2[index].areaRadius}
				rootTable.add{type = "button", name = "incAreaBut", caption = "+", style = "tf_smallerButtonFont"}
				rootTable.add{type = "button", name = "decAreaBut", caption = "-", style = "tf_smallerButtonFont"}
			rootFrame.add{type = "button", name = "okButton", caption = {"okButtonCaption"}, style = "tf_smallerButtonFont"}


		createOverlay(global.treefarm.fieldmk2[index])
	end
end


function createOverlay(fieldTable)
	local radius = fieldTable.areaRadius
	local startPos = {x = fieldTable.entity.position.x - radius,
					  y = fieldTable.entity.position.y - radius}

	if global.treefarm.overlayStack == nil then
		global.treefarm.overlayStack = {}
	end

	if fieldTable.active == true then
		for i = 0, 2 * radius + 1 do
			for j = 0, 2 * radius + 1 do
				local overlay = game.get_surface(1).create_entity{name = "tf-overlay-green", position ={x = startPos.x + i, y = startPos.y + j}, force = game.forces.player}
				table.insert(global.treefarm.overlayStack, overlay)
			end
		end
	else
		for i = 0, 2 * radius + 1 do
			for j = 0, 2 * radius + 1 do
				local overlay = game.get_surface(1).create_entity{name = "tf-overlay-red", position ={x = startPos.x + i, y = startPos.y + j}, force = game.forces.player}
				table.insert(global.treefarm.overlayStack, overlay)
			end
		end
	end
end

function destroyOverlay()
	for _, overlay in ipairs(global.treefarm.overlayStack) do
		if overlay.valid then
			overlay.destroy()
		end
	end
	global.treefarm.overlayStack = {}
end
