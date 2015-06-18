module(..., package.seeall)

remote.addinterface("treefarm",
{
	addSeed = function(seedInfo)
		if glob.treefarm == nil then
			return "treefarm isn't initialized yet. Save the game and reload it."
		end

		if glob.treefarm.seedTypes[seedInfo.name] == nil then
			glob.treefarm.seedTypes[seedInfo.name] = {}
			if seedInfo.states ~= nil then
				glob.treefarm.seedTypes[seedInfo.name].states = seedInfo.states
			else
				return "growing states not defined"
			end
			if seedInfo.output ~= nil then
				glob.treefarm.seedTypes[seedInfo.name].output = seedInfo.output
			else
				return "result not defined"
			end
			if seedInfo.efficiency then
				glob.treefarm.seedTypes[seedInfo.name].efficiency = seedInfo.efficiency
			else
				return "efficiency not defined"
			end
			if seedInfo.basicGrowingTime ~= nil then
				glob.treefarm.seedTypes[seedInfo.name].basicGrowingTime = seedInfo.basicGrowingTime
			else
				return "basicGrowingTime not defined"
			end
			if seedInfo.randomGrowingTime ~= nil then			
				glob.treefarm.seedTypes[seedInfo.name].randomGrowingTime = seedInfo.randomGrowingTime
			else
				return "randomGrowingTime not defined"
			end
			if seedInfo.fertilizerBoost ~= nil then
				glob.treefarm.seedTypes[seedInfo.name].fertilizerBoost = seedInfo.fertilizerBoost
			else
				return "fertilizerBoost not defined"
			end
			glob.treefarm.isGrowing[seedInfo.name] = {}
			glob.treefarm.requestLookUpTableUpdate = true
		else
			return "seed type already present"
		end
	end,

	readSeed = function(seedName)
		return glob.treefarm.seedTypes[seedName]
	end,

	getSeedTypesData = function()
		return glob.treefarm.seedTypes
	end,


	getNumTrees = function()
		return #glob.treefarm.isGrowing.basicTrees
	end,

	getFirstTreeTick = function()
		return glob.treefarm.isGrowing.basicTrees[1].nextUpdate
	end,

	getFirstTreeEff = function()
		return glob.treefarm.isGrowing.basicTrees[1].efficiency
	end,

	fixTreeTicks = function()
		glob.treefarm.seedTypes.basicTrees.efficiency.other = 0.01
		for _, tree in ipairs(glob.treefarm.isGrowing.basicTrees) do
			if tree.efficiency == 0 then
				tree.efficiency = 1
				tree.nextUpdate = game.tick + 60
			end
		end
	end,

	removeAllTrees = function()
		for _, tree in ipairs(glob.treefarm.isGrowing.basicTrees) do
			if tree.entity.valid then
				tree.entity.destroy()
			end
		end

		while (#glob.treefarm.isGrowing.basicTrees > 0) do
			table.remove(glob.treefarm.isGrowing.basicTrees)
		end
	end
 })