require "utils"
require "defines"
require "interfaces"

remote.addinterface("narmod",
{
  Regenerate = function()
	game.regenerateentity("tin-ore")
	game.regenerateentity("zinc-ore")
	game.regenerateentity("tungsten-ore")
	game.regenerateentity("gold-ore")
	game.regenerateentity("bauxite-ore")
	game.regenerateentity("lead-ore")
	game.regenerateentity("rutile-ore")
	game.regenerateentity("quartz")
	game.regenerateentity("uraninite-ore")
	game.regenerateentity("fluorite-ore")
  end
}
)

local seedTypeLookUpTable = {}
function createSeedTypeLookUpTable()
	for seedTypeName, seedType in pairs(glob.treefarm.seedTypes) do
		for _, stateName in pairs(seedType.states) do
			seedTypeLookUpTable[stateName] = seedTypeName
		end
	end	
end


game.oninit(function()
	utils.initTables()

	for _, treeTypes in pairs(glob.treefarm.seedTypes) do
		if treeTypes.efficiency.other == 0 then
			treeTypes.efficiency.other = 0.01
		end
	end

	for seedTypeName, seedTypeInfo in pairs (glob.treefarm.seedTypes) do
		if game.itemprototypes[seedTypeInfo.states[1]] == nil then
			glob.treefarm.isGrowing[seedTypeName] = nil
			glob.treefarm.seedTypes[seedTypeName] = nil
		end
	end

	createSeedTypeLookUpTable()
end)


game.onload(function()

	for _, treeTypes in pairs(glob.treefarm.seedTypes) do
		if treeTypes.efficiency.other == 0 then
			treeTypes.efficiency.other = 0.01
		end
	end

	for seedTypeName, seedTypeInfo in pairs (glob.treefarm.seedTypes) do
		if game.itemprototypes[seedTypeInfo.states[1]] == nil then
			glob.treefarm.isGrowing[seedTypeName] = nil
			glob.treefarm.seedTypes[seedTypeName] = nil
		end
	end

	createSeedTypeLookUpTable()

end)


game.onevent(defines.events.onplayermineditem, function(event)
	if event.itemstack.name == "field" then
		for index, field in ipairs(glob.treefarm.field) do
			if not field.entity.valid then
				table.remove(glob.treefarm.field, index)
				return
			end
		end
	elseif event.itemstack.name == "fieldmk2" then
		for index, field in ipairs(glob.treefarm.fieldmk2) do
			if not field.entity.valid then
				table.remove(glob.treefarm.fieldmk2, index)
				return
			end
		end
	end
end)


game.onevent(defines.events.onrobotmined, function(event)
	if event.itemstack.name == "field" then
		for index, field in ipairs(glob.treefarm.field) do
			if not field.entity.valid then
				table.remove(glob.treefarm.field, index)
				return
			end
		end
	elseif event.itemstack.name == "fieldmk2" then
		for index, field in ipairs(glob.treefarm.fieldmk2) do
			if not field.entity.valid then
				table.remove(glob.treefarm.fieldmk2, index)
				return
			end
		end
	end
end)


game.onevent(defines.events.onentitydied, function(event)
	if event.entity.name == "field-2" then
		for index,entInfo in ipairs(glob.treefarm.field) do
			if  entInfo.entity.equals(event.entity) then
				table.remove(glob.treefarm.field, index)
				return
			end
		end
	elseif event.entity.name == "fieldmk2" then
		for index,entInfo in ipairs(glob.treefarm.fieldmk2) do
			if  entInfo.entity.equals(event.entity) then
				table.remove(glob.treefarm.fieldmk2, index)
				return
			end
		end
	end
end)


game.onevent(defines.events.onputitem, function(event)

	for playerIndex,player in pairs(game.players) do
		if (player ~= nil) and (player.selected ~= nil) then
			if player.selected.name == "fieldmk2" then
				for index, entInfo in ipairs(glob.treefarm.fieldmk2) do
					if entInfo.entity.equals(player.selected) then
						glob.treefarm.tmpData.fieldmk2Index = index
						showFieldmk2GUI(index, playerIndex)
					end
				end
			end
		end
	end
end)


game.onevent(defines.events.onbuiltentity, function(event)

	local player = game.players[event.playerindex]

	if event.createdentity.name == "field-2" then
		if canPlaceField(event.createdentity) ~= true then
			player.insert{name = "field", count = 1}
			event.createdentity.destroy()
			player.print({"msg_buildingFail"})
			return
		else
			local entInfo =
			{
				entity = event.createdentity,
				fertAmount = 0,
				lastSeedPos = {x = 2, y = 1},
				nextUpdate = event.tick + 60
			}
			table.insert(glob.treefarm.field, entInfo)
			return
		end
	elseif event.createdentity.type == "tree" then
		local currentSeedTypeName = seedTypeLookUpTable[event.createdentity.name]
		if currentSeedTypeName ~= nil then
			local newEfficiency = calcEfficiency(event.createdentity, false)
			local deltaTime = math.ceil((math.random() * glob.treefarm.seedTypes[currentSeedTypeName].randomGrowingTime + glob.treefarm.seedTypes[currentSeedTypeName].basicGrowingTime) / newEfficiency)
			local nextUpdateIn = event.tick + deltaTime
			local entInfo =
			{
				entity = event.createdentity,
				state = 1,
				efficiency = newEfficiency,
				nextUpdate = nextUpdateIn
			}
			placeSeedIntoList(entInfo, currentSeedTypeName)
			return
		end
	elseif event.createdentity.name == "fieldmk2Overlay" then
		local ent = game.createentity{name = "fieldmk2",
									  position = event.createdentity.position,
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
		table.insert(glob.treefarm.fieldmk2, entInfo)

		glob.treefarm.tmpData.fieldmk2Index = #glob.treefarm.fieldmk2
		showFieldmk2GUI(#glob.treefarm.fieldmk2, event.playerindex)
		event.createdentity.destroy()
		return
	end
end)


game.onevent(defines.events.onguiclick, function(event)
	local index = glob.treefarm.tmpData.fieldmk2Index
	local player = game.players[event.element.playerindex]
	if event.element.name == "okButton" then
		if player.gui.center.fieldmk2Root ~= nil then
			player.gui.center.fieldmk2Root.destroy()
			destroyOverlay()
		end
	elseif event.element.name == "toggleActiveBut" then
		if glob.treefarm.fieldmk2[index].active == true then
			glob.treefarm.fieldmk2[index].active = false
			mk2CancelDecontruction(glob.treefarm.fieldmk2[index])
			player.gui.center.fieldmk2Root.fieldmk2Table.colLabel2.caption = "not active"
		else
			glob.treefarm.fieldmk2[index].active = true
			mk2MarkDeconstruction(glob.treefarm.fieldmk2[index])
			player.gui.center.fieldmk2Root.fieldmk2Table.colLabel2.caption = "active"
		end
		destroyOverlay()
		createOverlay(glob.treefarm.fieldmk2[index])
	elseif event.element.name == "incAreaBut" then
		if glob.treefarm.fieldmk2[index].areaRadius < 9 then
			glob.treefarm.fieldmk2[index].areaRadius = glob.treefarm.fieldmk2[index].areaRadius + 1
			destroyOverlay()
			createOverlay(glob.treefarm.fieldmk2[index])
		end
		player.gui.center.fieldmk2Root.fieldmk2Table.areaLabel2.caption = glob.treefarm.fieldmk2[index].areaRadius
	elseif event.element.name == "decAreaBut" then
		if glob.treefarm.fieldmk2[index].areaRadius > 1 then
			glob.treefarm.fieldmk2[index].areaRadius = glob.treefarm.fieldmk2[index].areaRadius - 1
			destroyOverlay()
			createOverlay(glob.treefarm.fieldmk2[index])
		end
		player.gui.center.fieldmk2Root.fieldmk2Table.areaLabel2.caption = glob.treefarm.fieldmk2[index].areaRadius
	end
end)


game.onevent(defines.events.ontick, function(event)
	if (glob.treefarm.requestLookUpTableUpdate == true) then
		createSeedTypeLookUpTable()
		glob.treefarm.requestLookUpTableUpdate = false
	end

	for _, seedType in pairs(glob.treefarm.isGrowing) do
		if (seedType[1] ~= nil) and (event.tick >= seedType[1].nextUpdate)then
			local removedEntity = table.remove(seedType, 1)
			
			local seedTypeName
			local newState
			if removedEntity.entity.valid then
				seedTypeName = seedTypeLookUpTable[removedEntity.entity.name]
				newState = removedEntity.state + 1

				if newState <= #glob.treefarm.seedTypes[seedTypeName].states then
					local tmpPos = removedEntity.entity.position
					local newEnt = game.createentity{name = glob.treefarm.seedTypes[seedTypeLookUpTable[removedEntity.entity.name]].states[newState], position = tmpPos}
					removedEntity.entity.destroy()
					local deltaTime = math.ceil((math.random() * glob.treefarm.seedTypes[seedTypeName].randomGrowingTime + glob.treefarm.seedTypes[seedTypeName].basicGrowingTime) / removedEntity.efficiency)
					local updatedEntry =
					{
						entity = newEnt,
						state = newState,
						efficiency = removedEntity.efficiency,
						nextUpdate = event.tick + deltaTime
					}
					placeSeedIntoList(updatedEntry, seedTypeName)
				elseif (isInMk2Range(removedEntity.entity.position)) then
					removedEntity.entity.orderdeconstruction(game.forces.player)
				end
			end
		end
	end


	if (glob.treefarm.field[1] ~= nil) and (event.tick >= glob.treefarm.field[1].nextUpdate) then
		if glob.treefarm.field[1].entity.valid then
			fieldMaintainer(event.tick)
		else
			table.remove(glob.treefarm.field, 1)
		end
	end

	if (glob.treefarm.fieldmk2[1] ~= nil) and (event.tick >= glob.treefarm.fieldmk2[1].nextUpdate) then
		if glob.treefarm.fieldmk2[1].entity.valid then
			if not anyPlayerHasOpenUI() then
				if glob.treefarm.fieldmk2[1].active == true then
					fieldmk2Maintainer(event.tick)
				else
					glob.treefarm.fieldmk2[1].nextUpdate = event.tick + 60
					local field = table.remove(glob.treefarm.fieldmk2, 1)
					table.insert(glob.treefarm.fieldmk2, field)
				end
			end
		else
			table.remove(glob.treefarm.fieldmk2, 1)
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
	local tmpEntities = game.findentitiesfiltered{area = {areaPosMin, areaPosMax}, type = "tree"}

	if #tmpEntities > 0 then
		for i = 1, #tmpEntities do
			for _, seedType in pairs(glob.treefarm.seedTypes) do
				if (tmpEntities[i].name == seedType.states[#seedType.states]) and (tmpEntities[i].tobedeconstructed(game.forces.player) == false) then
					tmpEntities[i].orderdeconstruction(game.forces.player)
				end
			end
		end
	end
end

function mk2CancelDecontruction(field)
	local fieldPos = {x = field.entity.position.x, y = field.entity.position.y}
	local areaPosMin = {x = fieldPos.x - field.areaRadius - 1, y = fieldPos.y - field.areaRadius - 1}
	local areaPosMax = {x = fieldPos.x + field.areaRadius + 1, y = fieldPos.y + field.areaRadius + 1}
	local tmpEntities = game.findentitiesfiltered{area = {areaPosMin, areaPosMax}, type = "tree"}

	if #tmpEntities > 0 then
		for i = 1, #tmpEntities do
			for _, seedType in pairs(glob.treefarm.seedTypes) do
				if (tmpEntities[i].name == seedType.states[#seedType.states]) and (tmpEntities[i].tobedeconstructed(game.forces.player) == true) then
					tmpEntities[i].canceldeconstruction(game.forces.player)
				end
			end
		end
	end
end


function isInMk2Range(plantPos)
	for _, field in ipairs(glob.treefarm.fieldmk2) do
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
	local currentTilename = game.gettile(entity.position.x, entity.position.y).name

	local efficiency
	if glob.treefarm.seedTypes[seedType].efficiency[currentTilename] == nil then
		return glob.treefarm.seedTypes[seedType].efficiency.other
	else
		efficiency = glob.treefarm.seedTypes[seedType].efficiency[currentTilename]
		if fertilizerApplied then
			return efficiency + glob.treefarm.seedTypes[seedType].fertilizerBoost
		else
			return efficiency
		end
	end
end


function placeSeedIntoList(entInfo, seedTypeName)
	if #glob.treefarm.isGrowing[seedTypeName] > 1 then
		for i = #glob.treefarm.isGrowing[seedTypeName], 1, -1 do
			if glob.treefarm.isGrowing[seedTypeName][i].nextUpdate <= entInfo.nextUpdate then
				table.insert(glob.treefarm.isGrowing[seedTypeName], i + 1, entInfo)
				return
			end
		end
		table.insert(glob.treefarm.isGrowing[seedTypeName], 1,  entInfo)
		return
	elseif #glob.treefarm.isGrowing[seedTypeName] == 1 then
		if glob.treefarm.isGrowing[seedTypeName][1].nextUpdate > entInfo.nextUpdate then
			table.insert(glob.treefarm.isGrowing[seedTypeName], 1,  entInfo)
			return
		else
			table.insert(glob.treefarm.isGrowing[seedTypeName], entInfo)
			return
		end
	else
		table.insert(glob.treefarm.isGrowing[seedTypeName], entInfo)
		return
	end
	table.insert(glob.treefarm.isGrowing[seedTypeName], entInfo)
end


function fieldMaintainer(tick)
	-- SEEDPLANTING --
	local seedInInv = {name ="DUMMY", amount = "DUMMY"}
	for _,seedType in pairs(glob.treefarm.seedTypes) do
		local newAmount = glob.treefarm.field[1].entity.getinventory(1).getitemcount(seedType.states[1])
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
		local fieldPos = {x = glob.treefarm.field[1].entity.position.x, y = glob.treefarm.field[1].entity.position.y}
		
		local placed = false
		if glob.treefarm.field[1].lastSeedPos == nil then
			glob.treefarm.field[1].lastSeedPos = {x = 2, y = 1}
		end
		local lastPos = {x = glob.treefarm.field[1].lastSeedPos.x, y = glob.treefarm.field[1].lastSeedPos.y}
		for dx = lastPos.x, 7 do
			for dy = 1, 7 do
				if (game.canplaceentity{name = "germling", position = {fieldPos.x + dx - 0.5, fieldPos.y + dy - 0.5}}) then
					seedPos = {x = fieldPos.x + dx - 0.5, y = fieldPos.y + dy - 0.5}
					placed = true
					glob.treefarm.field[1].lastSeedPos = {x = dx, y = dy}
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
					if (game.canplaceentity{name = "germling", position = {fieldPos.x + dx - 0.5, fieldPos.y + dy - 0.5}}) then
						seedPos = {x = fieldPos.x + dx - 0.5, y = fieldPos.y + dy - 0.5}
						placed = true
						glob.treefarm.field[1].lastSeedPos = {x = dx, y = dy}
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
			local newEntity = game.createentity{name = seedInInv.name, position = seedPos}
			local newFertilized = false

			if (glob.treefarm.field[1].fertAmount <= 0) and (glob.treefarm.field[1].entity.getinventory(2).getitemcount("fertilizer") > 0) then
				glob.treefarm.field[1].fertAmount = 1
				glob.treefarm.field[1].entity.getinventory(2).remove{name = "fertilizer", count = 1}
			end

			if glob.treefarm.field[1].fertAmount >= 0.1 then
				glob.treefarm.field[1].fertAmount = glob.treefarm.field[1].fertAmount - 0.1
				newFertilized = true
				if glob.treefarm.field[1].fertAmount < 0.1 then
					glob.treefarm.field[1].fertAmount = 0
				end
			end
 
			local newEfficiency = calcEfficiency(newEntity, newFertilized)
			local entInfo =
			{
				entity = newEntity,
				state = 1,
				efficiency = newEfficiency,
				nextUpdate = tick + math.ceil((math.random() * glob.treefarm.seedTypes[seedTypeName].randomGrowingTime + glob.treefarm.seedTypes[seedTypeName].basicGrowingTime) / newEfficiency)
			}
			glob.treefarm.field[1].entity.getinventory(1).remove{name = seedInInv.name, count = 1}
			placeSeedIntoList(entInfo, seedTypeName)
		end
	end

	-- HARVESTING --
	local fieldPos = {x = glob.treefarm.field[1].entity.position.x, y = glob.treefarm.field[1].entity.position.y}
	local grownEntities = game.findentitiesfiltered{area = {fieldPos, {fieldPos.x + 8, fieldPos.y + 8}}, type = "tree"}
	for _,entity in ipairs(grownEntities) do
		for _,seedType in pairs(glob.treefarm.seedTypes) do
			if entity.name == seedType.states[#seedType.states] then
				local output = {name = seedType.output[1], amount = seedType.output[2]}
				if (glob.treefarm.field[1].entity.getinventory(3).caninsert{name = output.name, count = output.amount}) and (50 - glob.treefarm.field[1].entity.getinventory(3).getitemcount(output.name) >= output.amount) then
					glob.treefarm.field[1].entity.getinventory(3).insert{name = output.name, count = output.amount}
					entity.destroy()
				end
				glob.treefarm.field[1].nextUpdate = tick + 60
				local field = table.remove(glob.treefarm.field, 1)
				table.insert(glob.treefarm.field, field)
				return
			end
		end
	end
	glob.treefarm.field[1].nextUpdate = tick + 60
	local field = table.remove(glob.treefarm.field, 1)
	table.insert(glob.treefarm.field, field)
end


function fieldmk2Maintainer(tick)
	-- SEEDPLANTING --
	local seedInInv = {name ="DUMMY", amount = "DUMMY"}
	for _,seedType in pairs(glob.treefarm.seedTypes) do
		local newAmount = glob.treefarm.fieldmk2[1].entity.getitemcount(seedType.states[1])
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
		if glob.treefarm.fieldmk2[1].lastSeedPos == nil then
			glob.treefarm.fieldmk2[1].lastSeedPos = {x = -glob.treefarm.fieldmk2[1].areaRadius, y = -glob.treefarm.fieldmk2[1].areaRadius}
		end
		local fieldPos = {x = glob.treefarm.fieldmk2[1].entity.position.x, y = glob.treefarm.fieldmk2[1].entity.position.y}
		
		local placed = false
		local lastPos = {x = glob.treefarm.fieldmk2[1].lastSeedPos.x, y = glob.treefarm.fieldmk2[1].lastSeedPos.y}
		
		if lastPos.x < -glob.treefarm.fieldmk2[1].areaRadius then
			lastPos.x = -glob.treefarm.fieldmk2[1].areaRadius
		elseif lastPos.x > glob.treefarm.fieldmk2[1].areaRadius then
			lastPos.x = glob.treefarm.fieldmk2[1].areaRadius
		end

		if lastPos.y < -glob.treefarm.fieldmk2[1].areaRadius then
			lastPos.y = -glob.treefarm.fieldmk2[1].areaRadius
		elseif lastPos.y > glob.treefarm.fieldmk2[1].areaRadius then
			lastPos.y = glob.treefarm.fieldmk2[1].areaRadius
		end


		for dx = lastPos.x, glob.treefarm.fieldmk2[1].areaRadius do
			for dy = -glob.treefarm.fieldmk2[1].areaRadius, glob.treefarm.fieldmk2[1].areaRadius do
				if (game.canplaceentity{name = "germling", position = {fieldPos.x + dx - 0.5, fieldPos.y + dy - 0.5}}) then
					seedPos = {x = fieldPos.x + dx - 0.5, y = fieldPos.y + dy - 0.5}
					placed = true
					glob.treefarm.fieldmk2[1].lastSeedPos = {x = dx, y = dy}
					break
				end
			end
			if placed == true then
				break
			end
		end

		if (placed == false) and (lastPos.x ~= -glob.treefarm.fieldmk2[1].areaRadius) then
			for dx = -glob.treefarm.fieldmk2[1].areaRadius, lastPos.x - 1 do
				for dy = -glob.treefarm.fieldmk2[1].areaRadius, glob.treefarm.fieldmk2[1].areaRadius do
					if (game.canplaceentity{name = "germling", position = {fieldPos.x + dx - 0.5, fieldPos.y + dy - 0.5}}) then
						seedPos = {x = fieldPos.x + dx - 0.5, y = fieldPos.y + dy - 0.5}
						placed = true
						glob.treefarm.fieldmk2[1].lastSeedPos = {x = dx, y = dy}
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
			local newEntity = game.createentity{name = seedInInv.name, position = seedPos}
			local newFertilized = false

			if (glob.treefarm.fieldmk2[1].fertAmount <= 0) and (glob.treefarm.fieldmk2[1].entity.getinventory(1).getitemcount("fertilizer") > 0) then
				glob.treefarm.fieldmk2[1].fertAmount = 1
				glob.treefarm.fieldmk2[1].entity.getinventory(1).remove{name = "fertilizer", count = 1}
			end

			if glob.treefarm.fieldmk2[1].fertAmount >= 0.1 then
				glob.treefarm.fieldmk2[1].fertAmount = glob.treefarm.fieldmk2[1].fertAmount - 0.1
				newFertilized = true
				if glob.treefarm.fieldmk2[1].fertAmount < 0.1 then
					glob.treefarm.fieldmk2[1].fertAmount = 0
				end
			end
 
			local newEfficiency = calcEfficiency(newEntity, newFertilized)
			local entInfo =
			{
				entity = newEntity,
				state = 1,
				efficiency = newEfficiency,
				nextUpdate = tick + math.ceil((math.random() * glob.treefarm.seedTypes[seedTypeName].randomGrowingTime + glob.treefarm.seedTypes[seedTypeName].basicGrowingTime) / newEfficiency)
			}
			glob.treefarm.fieldmk2[1].entity.getinventory(1).remove{name = seedInInv.name, count = 1}
			placeSeedIntoList(entInfo, seedTypeName)
		end
	end


	-- HARVESTING --
	-- is done in tree-growing function --

	glob.treefarm.fieldmk2[1].nextUpdate = tick + 60
	local field = table.remove(glob.treefarm.fieldmk2, 1)
	table.insert(glob.treefarm.fieldmk2, field)
end


function canPlaceSeed(entInfo)
	local fieldPos = {x = entInfo.entity.position.x, y = entInfo.entity.position.y}
	if entInfo.entity.name == "fieldmk2" then
		local pos = {x = entInfo.entity.position.x, y = entInfo.entity.position.y}
		for dx = -entInfo.areaRadius, entInfo.areaRadius + 1 do
			for dy = -entInfo.areaRadius, entInfo.areaRadius + 1 do
				if (game.canplaceentity{name = "germling", position = {pos.x + dx - 0.5, pos.y + dy - 0.5}}) then
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
				if not game.canplaceentity{name="wooden-chest", position = {fPosX + x, fPosY + y}} then
					local playerEnt = game.findentitiesfiltered{area = {{fPosX + x - 1, fPosY + y - 1},{fPosX + x + 1, fPosY + y + 1}}, name="player"}
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
	blockingField = game.findentitiesfiltered{area = {{x = fPosX - 8, y = fPosY - 8}, {fPosX + 8, fPosY + 8}}, name="field-2"}
	if #blockingField > 1 then
		return
	end
	return true
end


function getSeedInInventory(fieldEnt)
	for _,seedType in pairs(glob.treefarm.seedTypes) do
		local newAmount = fieldEnt.getitemcount(seedType.states[1])
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
		local rootFrame = player.gui.center.add{type = "frame", name = "fieldmk2Root", caption = game.getlocalisedentityname("fieldmk2"), direction = "vertical"}
			local rootTable = rootFrame.add{type ="table", name = "fieldmk2Table", colspan = 4}
				rootTable.add{type = "label", name = "colLabel1", caption = {"thisFieldIs"}}
				local status = "active / not active"
				if glob.treefarm.fieldmk2[index].active == true then
					status = {"active"}
				else
					status = {"notActive"}
				end
				rootTable.add{type = "label", name = "colLabel2", caption = status}
				rootTable.add{type = "button", name = "toggleActiveBut", caption = {"toggleButtonCaption"}, style = "tf_smallerButtonFont"}
				rootTable.add{type = "label", name = "colLabel4", caption = ""}

				rootTable.add{type = "label", name = "areaLabel1", caption = {"usedArea"}}
				rootTable.add{type = "label", name = "areaLabel2", caption = glob.treefarm.fieldmk2[index].areaRadius}
				rootTable.add{type = "button", name = "incAreaBut", caption = "+", style = "tf_smallerButtonFont"}
				rootTable.add{type = "button", name = "decAreaBut", caption = "-", style = "tf_smallerButtonFont"}
			rootFrame.add{type = "button", name = "okButton", caption = {"okButtonCaption"}, style = "tf_smallerButtonFont"}


		createOverlay(glob.treefarm.fieldmk2[index])
	end
end


function createOverlay(fieldTable)
	local radius = fieldTable.areaRadius
	local startPos = {x = fieldTable.entity.position.x - radius,
					  y = fieldTable.entity.position.y - radius}

	if glob.treefarm.overlayStack == nil then
		glob.treefarm.overlayStack = {}
	end

	if fieldTable.active == true then
		for i = 0, 2 * radius + 1 do
			for j = 0, 2 * radius + 1 do
				local overlay = game.createentity{name = "tf-overlay-green", position ={x = startPos.x + i, y = startPos.y + j}, force = game.forces.player}
				table.insert(glob.treefarm.overlayStack, overlay)
			end
		end
	else
		for i = 0, 2 * radius + 1 do
			for j = 0, 2 * radius + 1 do
				local overlay = game.createentity{name = "tf-overlay-red", position ={x = startPos.x + i, y = startPos.y + j}, force = game.forces.player}
				table.insert(glob.treefarm.overlayStack, overlay)
			end
		end
	end
end

function destroyOverlay()
	for _, overlay in ipairs(glob.treefarm.overlayStack) do
		if overlay.valid then
			overlay.destroy()
		end
	end
	glob.treefarm.overlayStack = {}
end