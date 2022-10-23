------------------------------------------------------------------------------
include("MapGenerator");
include("FractalWorld");
include("FeatureGenerator");
include("TerrainGenerator");

local versionName = "V" -- version 5
local L = Locale.ConvertTextKey;
------------------------------------------------------------------------------

function GetMapScriptInfo()
	local world_age, temperature, rainfall, sea_level, resources, islands, plate_motion, continents, land, plates, size_mod, coastalStarts = GetCoreMapOptions()
	return {
		Name = L("TXT_KEY_TECTONIC") .. " - " .. versionName,
		Description = "TXT_KEY_TECTONIC_HELP",
		IsAdvancedMap = 0,
		IconIndex = 5,
		SortIndex = 1,
		CustomOptions = {world_age, temperature, rainfall, sea_level, resources, islands, plate_motion, continents, land, plates, size_mod, coastalStarts},
	};
end

function GetCoreMapOptions()
	--[[ All options have a default SortPriority of 0. Lower values will be shown above
	higher values. Negative integers are valid. So the Core Map Options, which should 
	always be at the top of the list, are getting negative values from -99 to -95. Note
	that any set of options with identical SortPriority will be sorted alphabetically. ]]--
	local size_mod = {
		Name = "TXT_KEY_MAP_OPTION_SIZE_MODIFIER",
		Values = {
			"TXT_KEY_MAP_OPTION_SIZE_80",
			"TXT_KEY_MAP_OPTION_SIZE_85",
			"TXT_KEY_MAP_OPTION_SIZE_90",
			"TXT_KEY_MAP_OPTION_SIZE_95",
			"TXT_KEY_MAP_OPTION_SIZE_100",
			"TXT_KEY_MAP_OPTION_SIZE_105",
			"TXT_KEY_MAP_OPTION_SIZE_110",
			"TXT_KEY_MAP_OPTION_SIZE_115",
			"TXT_KEY_MAP_OPTION_SIZE_120",
		},
		DefaultValue = 5,
		SortPriority = -99,
	};
	local temperature = {
		Name = "TXT_KEY_MAP_OPTION_TEMPERATURE",
		Values = {
			"TXT_KEY_MAP_OPTION_COOL",
			"TXT_KEY_MAP_OPTION_TEMPERATE",
			"TXT_KEY_MAP_OPTION_HOT",
			"TXT_KEY_MAP_OPTION_RANDOM",
		},
		DefaultValue = 2,
		SortPriority = -98,
	};
	local rainfall = {
		Name = "TXT_KEY_MAP_OPTION_RAINFALL",
		Values = {
			"TXT_KEY_MAP_OPTION_ARID",
			"TXT_KEY_MAP_OPTION_NORMAL",
			"TXT_KEY_MAP_OPTION_WET",
			"TXT_KEY_MAP_OPTION_RANDOM",
		},
		DefaultValue = 2,
		SortPriority = -97,
	};
	local sea_level = {
		Name = "TXT_KEY_MAP_OPTION_SEA_LEVEL",
		Values = {
			"TXT_KEY_MAP_OPTION_LOW",
			"TXT_KEY_MAP_OPTION_MEDIUM",
			"TXT_KEY_MAP_OPTION_HIGH",
			"TXT_KEY_MAP_OPTION_RANDOM",
		},
		DefaultValue = 2,
		SortPriority = -96,
	};
	local resources = {
		Name = "TXT_KEY_MAP_OPTION_RESOURCES",
		Values = {
			"TXT_KEY_MAP_OPTION_SPARSE",
			"TXT_KEY_MAP_OPTION_STANDARD",
			"TXT_KEY_MAP_OPTION_ABUNDANT",
			"TXT_KEY_MAP_OPTION_LEGENDARY_START",
			"TXT_KEY_MAP_OPTION_STRATEGIC_BALANCE",
			"TXT_KEY_MAP_OPTION_RANDOM",
		},
		DefaultValue = 2,
		SortPriority = -95,
	};
	local islands = {
		Name = "TXT_KEY_MAP_OPTION_ISLANDS",
		Values = {
			"TXT_KEY_MAP_OPTION_NONE",
			"TXT_KEY_MAP_OPTION_FEW",
			"TXT_KEY_MAP_OPTION_SCATTERED",
			"TXT_KEY_MAP_OPTION_ABUNDANT",
			"TXT_KEY_MAP_OPTION_RANDOM",
		},
		DefaultValue = 3,
		SortPriority = -94,
	};
	local plate_motion = {
		Name = "TXT_KEY_MAP_OPTION_PLATE_MOTION",
		Values = {
			"TXT_KEY_MAP_OPTION_SLOW",
			"TXT_KEY_MAP_OPTION_AVERAGE",
			"TXT_KEY_MAP_OPTION_FAST",
			"TXT_KEY_MAP_OPTION_RAMMING_SPEED",
			"TXT_KEY_MAP_OPTION_RANDOM",
		},
		DefaultValue = 2,
		SortPriority = -93,
	};
	local continents = {
		Name = "TXT_KEY_MAP_OPTION_CONTINENTS",
		Values = {
			"TXT_KEY_MAP_OPTION_SNAKY",
			"TXT_KEY_MAP_OPTION_STANDARD",
			"TXT_KEY_MAP_OPTION_BLOCKY",
			"TXT_KEY_MAP_OPTION_RANDOM",
		},
		DefaultValue = 2,
		SortPriority = -92,
	};
	local land = {
		Name = "TXT_KEY_MAP_OPTION_LAND",
		Values = {
			"TXT_KEY_MAP_OPTION_LESS",
			"TXT_KEY_MAP_OPTION_STANDARD",
			"TXT_KEY_MAP_OPTION_MORE",
			"TXT_KEY_MAP_OPTION_RANDOM",
		},
		DefaultValue = 2,
		SortPriority = -91,
	};
	local plates = {
		Name = "TXT_KEY_MAP_OPTION_PLATES",
		Values = {
			"TXT_KEY_MAP_OPTION_LESS",
			"TXT_KEY_MAP_OPTION_STANDARD",
			"TXT_KEY_MAP_OPTION_MORE",
			"TXT_KEY_MAP_OPTION_RANDOM",
		},
		DefaultValue = 2,
		SortPriority = -90,
	};
	local coastalStarts = {
		Name = "TXT_KEY_MAP_OPTION_COASTAL_START",
		Values = {
			"TXT_KEY_MAP_OPTION_NO",
			"TXT_KEY_MAP_OPTION_YES",
			"TXT_KEY_MAP_OPTION_RANDOM",
		},
		DefaultValue = 2,
		SortPriority = -89,
	};
	return world_age, temperature, rainfall, sea_level, resources, islands, plate_motion, continents, land, plates, size_mod, coastalStarts
end

function FractalWorld:ShiftPlotTypes()
	local stripRadius = self.stripRadius;
	local shift_x = 0;

	shift_x = self:DetermineXShift();
	print("Shift",shift_x);

	self:ShiftPlotTypesBy(shift_x, 0);
end

local mapWidth;
local mapHeight;
local numPlates;
local maps;
local numMaps;
local skewFactor;
local skewFactor2;

function GetMapInitData(worldSize)
	-- This function can reset map grid sizes or world wrap settings.
	--[[	X width						Y height	
	local duelX 	= 52;		local duelY		= 32;
	local tinyX 	= 64;		local tinyY		= 40;
	local smallX 	= 84;		local smallY	= 52;
	local standardX	= 104;		local standardY	= 64;
	local largeX 	= 128;		local largeY	= 80;
	local hugeX 	= 152;		local hugeY		= 96;]]

	local size_mod = Map.GetCustomOption(11);
	local size_modMultiplier = 1;	-- Normal size - 100%
	if (size_mod == 1) then
		size_modMultiplier = 0.80;	-- Compressed size - 80%
	elseif (size_mod == 2) then
		size_modMultiplier = 0.85;	-- Squeezed size - 85%
	elseif (size_mod == 3) then
		size_modMultiplier = 0.90;	-- Reduced size - 90%
	elseif (size_mod == 4) then
		size_modMultiplier = 0.95;	-- Smaller size - 95%
	elseif (size_mod == 6) then
		size_modMultiplier = 1.05;	-- Plus size - 105%
	elseif (size_mod == 7) then
		size_modMultiplier = 1.10;	-- Extra size - 110%
	elseif (size_mod == 8) then
		size_modMultiplier = 1.15;	-- Super size - 115%
	elseif (size_mod == 9) then
		size_modMultiplier = 1.20;	-- Gigantic size - 120%
	end
	print("Map Size modifier: " .. size_modMultiplier * 100 .. "%");

	local worldsizes = {
			[GameInfo.Worlds.WORLDSIZE_DUEL.ID] = {52, 32},
			[GameInfo.Worlds.WORLDSIZE_TINY.ID] = {64, 40},
			[GameInfo.Worlds.WORLDSIZE_SMALL.ID] = {84, 52},
			[GameInfo.Worlds.WORLDSIZE_STANDARD.ID] = {104, 64},
			[GameInfo.Worlds.WORLDSIZE_LARGE.ID] = {128, 80},
			[GameInfo.Worlds.WORLDSIZE_HUGE.ID] = {152, 96}
	}
	local grid_size = worldsizes[worldSize];
	--
	local world = GameInfo.Worlds[worldSize];
	if(world ~= nil) then
		print("Map Size before modifier = Width: " .. grid_size[1] .. ", Height: " .. grid_size[2]);
		print("Map Size after modifier = Width: " .. grid_size[1] * size_modMultiplier.. ", Height: " .. grid_size[2] * size_modMultiplier);
	return {
		Width = grid_size[1] * size_modMultiplier,
		Height = grid_size[2] * size_modMultiplier,
		WrapX = true,
	};
    end
end

function InitHeightmaps()
	maps = {}
	numMaps = 0;
	local i = 0;

	while math.pow(2,i) <= mapWidth/8 do
		maps[i] = {}
		numMaps = numMaps + 1;

		factor = math.pow(2,i);

		for x = 0, math.ceil(mapWidth/factor), 1 do
			for y = 0, math.ceil(mapWidth/factor), 1 do
				q = (y * (math.ceil(mapWidth/factor)+1)) + x;
				maps[i][q] = RandomFloat() * 2 - 1;
			end
		end
		i = i+1;
	end
end

function Interpolate(a, b, x)
	ft = x * 3.1415927;
	f = (1 - math.cos(ft)) * 0.5;

	return  a*(1.0-f) + b*f;
end

function RandomFloat()
	local max = Map.Rand(16384,"Random float");
	return max/16384.0;
end

function GetHeightFromMap(i,x,y)
	factor = math.pow(2,i);

	indexX = x/factor;
	indexY = y/factor;
	intX = math.floor(indexX);
	intY = math.floor(indexY);
	fracX = indexX - intX;
	fracY = indexY - intY;

	q = (intY * (math.ceil(mapWidth/factor)+1)) + intX;
	q2 = ((intY+1) * (math.ceil(mapWidth/factor)+1)) + intX;
	r1 = Interpolate(maps[i][q], maps[i][q+1], fracX);
	r2 = Interpolate(maps[i][q2], maps[i][q2+1], fracX);

	return Interpolate(r1, r2, fracY);
end

function GetHeight(x,y,n,f)
	height = 0;

	for mapIndex, thisMap in ipairs(maps) do
		if mapIndex < numMaps-f then
			height = height + GetHeightFromMap(mapIndex,x,y)/(math.pow(n, numMaps-(mapIndex-1)));
		else 
			if (x == 100 and y == 100) then print("PARP") end
		end
	end

	return height;
end

function FractalWorld:GeneratePlotTypes(args)

	skewFactor = { RandomFloat()*2+1, RandomFloat()+1, RandomFloat()+1,  RandomFloat()*6+5, RandomFloat()*3+3, RandomFloat()*2+2,  RandomFloat()*7, RandomFloat()*7, RandomFloat()*7};
	skewFactor2 = { RandomFloat()*10+5, RandomFloat()*5+5, RandomFloat()*5+3, RandomFloat()*5+3, RandomFloat()*7, RandomFloat()*7, RandomFloat()*7, RandomFloat()*7};

	local WorldSizeTypes = {};
	for row in GameInfo.Worlds() do
		WorldSizeTypes[row.Type] = row.ID;
	end
	local size_mod = Map.GetCustomOption(11);
	local size_modMultiplier = 1;	-- Normal size - 100%
	if (size_mod == 1) then
		size_modMultiplier = 0.80;	-- Compressed size - 80%
	elseif (size_mod == 2) then
		size_modMultiplier = 0.85;	-- Squeezed size - 85%
	elseif (size_mod == 3) then
		size_modMultiplier = 0.90;	-- Reduced size - 90%
	elseif (size_mod == 4) then
		size_modMultiplier = 0.95;	-- Smaller size - 95%
	elseif (size_mod == 6) then
		size_modMultiplier = 1.05;	-- Plus size - 105%
	elseif (size_mod == 7) then
		size_modMultiplier = 1.10;	-- Extra size - 110%
	elseif (size_mod == 8) then
		size_modMultiplier = 1.15;	-- Super size - 115%
	elseif (size_mod == 9) then
		size_modMultiplier = 1.20;	-- Gigantic size - 120%
	end

	local sizekey = Map.GetWorldSize();
	local sizevalues = {
		[WorldSizeTypes.WORLDSIZE_DUEL]     = 12, -- 4
		[WorldSizeTypes.WORLDSIZE_TINY]     = 20, -- 8
		[WorldSizeTypes.WORLDSIZE_SMALL]    = 28, -- 16
		[WorldSizeTypes.WORLDSIZE_STANDARD] = 36, -- 20
		[WorldSizeTypes.WORLDSIZE_LARGE]    = 44, -- 24
		[WorldSizeTypes.WORLDSIZE_HUGE]		= 52 -- 32
	}
	print("Generating Plates");

	numPlates = (sizevalues[sizekey] or 8) * size_modMultiplier;
	print("Number of plates: " .. numPlates);

	local plates = Map.GetCustomOption(10);
	if (plates == 4) then
		plates = 1 + Map.Rand(3, "Random Plates Setting");
	end
	if (plates == 1) then
		numPlates = (numPlates * 2)/3;
	elseif (plates == 2) then
		numPlates = numPlates;
	else
		numPlates = (numPlates * 6)/3;
	end
	print ("Plates Option", plates, numPlates);

	mapWidth = self.iNumPlotsX;
	mapHeight = self.iNumPlotsY;

	local plates = {};
	for i = 1, numPlates, 1 do
		plates[i] = {};
		plates[i].x = Map.Rand(mapWidth, "centerX of Plate");
		plates[i].y = Map.Rand(mapHeight, "centerY of Plate");
		plates[i].mass = Map.Rand(7, "mass of Plate") + 6;
		plates[i].size = 0;
		plates[i].terrainType = "?";
		plates[i].neighbours = {};
		plates[i].neighbours.borders = {};
		plates[i].neighbours.relativeMotions = {};
		plates[i].velocity = {};
		plates[i].velocity.x = Map.Rand(21, "velocity in x direction")-10;
		plates[i].velocity.y = Map.Rand(21, "velocity in y direction")-10;
	end

	print("Calculating Plate Neighbours");


	neighbours = {};
	for i = 1, numPlates, 1 do
		neighbours[i] = {};
		for j = 1, numPlates, 1 do
			neighbours[i][j] = 0;
		end
		neighbours[i]["West"] = 0;
		neighbours[i]["South"] = 0;
		neighbours[i]["East"] = 0;
		neighbours[i]["North"] = 0;
	end

	for x = 0, mapWidth-1, 1 do
		for y = 0, mapHeight-1, 1 do
			currentPlate = partOfPlate(x,y,plates);
			info = getPlateBoundaryInfo(x, y, plates);
			for infoIndex, thisPlateInfo in ipairs(info) do
				if (infoIndex ~= currentPlate) then
					neighbours[currentPlate][infoIndex] = neighbours[currentPlate][infoIndex]+thisPlateInfo;
				end
			end
			neighbours[currentPlate]["North"] = neighbours[currentPlate]["North"]+info["North"];
			neighbours[currentPlate]["East"] = neighbours[currentPlate]["East"]+info["East"];
			neighbours[currentPlate]["South"] = neighbours[currentPlate]["South"]+info["South"];
			neighbours[currentPlate]["West"] = neighbours[currentPlate]["West"]+info["West"];
		end
	end

	for plateIndex, thisPlate in ipairs(plates) do
		thisPlate.neighbours.borders = neighbours[plateIndex];
	end

	print("Creating Base Heightmap");
	InitHeightmaps()

	print("Calculating Relative Plate Motions");
	for plateIndex, thisPlate in ipairs(plates) do
		motions = {};
		for plateIndex2, thatPlate in ipairs(plates) do
			motions[plateIndex2] = {};
			if (thisPlate.neighbours.borders[plateIndex2] > 0) then
				x = thatPlate.velocity.x - thisPlate.velocity.x;
				y = thatPlate.velocity.y - thisPlate.velocity.y;

				motions[plateIndex2].x = x;
				motions[plateIndex2].y = y;

				mag = math.sqrt(x*x+y*y);
				if (mag < 5) then
					motions[plateIndex2].boundaryType = "Passive";
				else
					xNorm = x/mag;
					yNorm = y/mag;

					dirX = thatPlate.x - thisPlate.x;
					dirY = thatPlate.y - thisPlate.y;

					dirMag = math.sqrt(dirX*dirX+dirY*dirY);
					dirXNorm = dirX/dirMag;
					dirYNorm = dirY/dirMag;

					dotProduct = xNorm*dirXNorm + yNorm*dirYNorm;

					if (dotProduct < -0.5) then
						motions[plateIndex2].boundaryType = "Collision";
					elseif (dotProduct > 0.5) then
						motions[plateIndex2].boundaryType = "Rift";
					else
						motions[plateIndex2].boundaryType = "Transform";
					end
				end
			end
		end
		thisPlate.neighbours.relativeMotions = motions;
	end

	print("Calculating Plate Size");
	for x = 0, mapWidth-1, 1 do
		for y = 0, mapHeight-1, 1 do
			local currentPlate = partOfPlate(x, y, plates);
			plates[currentPlate].size = plates[currentPlate].size + 1;
		end
	end

	print("Calculating Plate Types");
	---[[
	oceanAmount = 0;
	oceanAmountD = 0;
	oceanAmountNS = 0;
	oceanAmountREG = 0;
	landAmount = 0;
	arcAmount = 0;
	fractalAmount = 0;
	spiffiness = 0;--]]--

	local islands = Map.GetCustomOption(6);
	if (islands == 5) then
		islands = 1 + Map.Rand(4, "Random Islands Setting");
	end
	local islandsModifier = 0;
	if (islands == 1) then
		islandsModifier = -5;
	elseif (islands == 2) then
		islandsModifier = -0.10;
	elseif (islands == 3) then
		islandsModifier = 0.1;
	else
		islandsModifier = 0.3;
	end
	print ("Islands Option", islands);

	local land = Map.GetCustomOption(9);
	if (land == 4) then
		land = 1 + Map.Rand(3, "Random Land Setting");
	end
	local landModifier = 0;
	if (land == 1) then
		landModifier = -0.18;
	elseif (land == 2) then
		landModifier = 0.125;
	else
		landModifier = 0.2;
	end
	print ("Land Option", land);

	local continents = Map.GetCustomOption(8);
	if (continents == 4) then
		continents = 1 + Map.Rand(3, "Random Continents Setting");
	end
	local continents_modifier = 0;
	if (continents == 1) then
		continents_modifier = -0.45;
	elseif (continents == 2) then
		continents_modifier = -0.05;
	else
		continents_modifier = 1.5;
	end

	for plateIndex, thisPlate in ipairs(plates) do
		if (thisPlate.neighbours.borders["West"] > 5 or thisPlate.neighbours.borders["East"] > 5) then
			thisPlate.terrainType = "Deep Ocean";
			oceanAmount = oceanAmount + thisPlate.size;
			oceanAmountD = oceanAmountD + thisPlate.size;
		elseif ((thisPlate.neighbours.borders["South"] > 20 or thisPlate.neighbours.borders["North"] > 20) and RandomFloat() > 0.375 + (landModifier/2)) then
			thisPlate.terrainType = "Ocean";
			oceanAmount = oceanAmount + thisPlate.size;
			oceanAmountNS = oceanAmountNS + thisPlate.size;
		elseif (thisPlate.size/(mapHeight*mapWidth) * RandomFloat() * numPlates > 0.5 + landModifier) then
			thisPlate.terrainType = "Ocean";
			oceanAmount = oceanAmount + thisPlate.size;
			oceanAmountREG = oceanAmountREG + thisPlate.size;
		elseif (thisPlate.size/(mapHeight*mapWidth) * RandomFloat() * numPlates < 0.2 + islandsModifier) then
			thisPlate.terrainType = "Island Arcs";
			arcAmount = arcAmount + thisPlate.size;
		--elseif (math.random() < 0.325) then
		--	thisPlate.terrainType = "Fractal";
		--	fractalAmount = fractalAmount + thisPlate.size;
		else
			thisPlate.terrainType = "Continental"
		end

		neighbouringContinentAmount = 0;
		for neighbourIndex, thisNeighbour in ipairs(thisPlate.neighbours.borders) do
			if (plates[neighbourIndex].terrainType == "Continental") then
				neighbouringContinentAmount = neighbouringContinentAmount + thisNeighbour;
			end
		end
		neighbouringContinentAmount = neighbouringContinentAmount / (mapWidth*mapHeight) * 100
		--print("Plate", plateIndex, "Neighbouring continent amount", neighbouringContinentAmount)

		if thisPlate.terrainType == "Continental" and RandomFloat() - neighbouringContinentAmount < 0.1 then
			thisPlate.terrainType = "Fractal"
			fractalAmount = fractalAmount + thisPlate.size;
		else 
			landAmount = landAmount + thisPlate.size;
		end

		if thisPlate.terrainType == "Ocean" and RandomFloat() - (neighbouringContinentAmount * continents_modifier) < 0.0 then
			thisPlate.terrainType = "Continental"
			spiffiness = spiffiness + thisPlate.size;
		end
		--thisPlate.terrainType = "Fractal"
	end
	---[[
	print("Amount of ocean:       ", (oceanAmount*100)/(oceanAmount+landAmount+arcAmount+fractalAmount),"%");
	print("Amount of deep ocean:  ", (oceanAmountD*100)/(oceanAmount+landAmount+arcAmount+fractalAmount),"%");
	print("Amount of N/S ocean:   ", (oceanAmountNS*100)/(oceanAmount+landAmount+arcAmount+fractalAmount),"%");
	print("Amount of random ocean:", (oceanAmountREG*100)/(oceanAmount+landAmount+arcAmount+fractalAmount),"%");
	print("Amount of land:        ", (landAmount*100)/(oceanAmount+landAmount+arcAmount+fractalAmount),"%");
	print("Amount of island arc:  ", (arcAmount*100)/(oceanAmount+landAmount+arcAmount+fractalAmount),"%");
	print("Amount of fractal:     ", (fractalAmount*100)/(oceanAmount+landAmount+arcAmount+fractalAmount),"%");
	print("Ocean converted to land:", (spiffiness*100)/(oceanAmount+landAmount+arcAmount+fractalAmount),"%");--]]--

	--[[for plateIndex, thisPlate in ipairs(plates) do
		print("Plate", plateIndex, "Position", thisPlate.x, thisPlate.y, "Mass", thisPlate.mass, "Size", thisPlate.size);
		for neighbourIndex, thisNeighbour in ipairs(thisPlate.neighbours.borders) do
			print("Tiles bordered with plate",neighbourIndex,"-",thisNeighbour);
		end
		print("Tiles bordered with","West","-",thisPlate.neighbours.borders["West"]);
		print("Tiles bordered with","East","-",thisPlate.neighbours.borders["East"]);
		print("Tiles bordered with","North","-",thisPlate.neighbours.borders["North"]);
		print("Tiles bordered with","South","-",thisPlate.neighbours.borders["South"]);
	end--]]--

	print("Generating Terrain");

	local plate_motion = Map.GetCustomOption(7);
	if (plate_motion == 5) then
		plate_motion = 1 + Map.Rand(4, "Random Plate Motion Setting");
	end
	local plate_motionModifier = 0;
	local plate_motionMultiplier = 0;
	if (plate_motion == 1) then
		plate_motionModifier = -0.05;
		plate_motionMultiplier = 0.66;
	elseif (plate_motion == 2) then
		plate_motionModifier = 0.1;
		plate_motionMultiplier = 1;
	elseif (plate_motion == 3) then
		plate_motionModifier = 0.25;
		plate_motionMultiplier = 2;
	else
		plate_motionModifier = 0.35;
		plate_motionMultiplier = 3;
	end
	print ("Plate Motion Option", plate_motion);

	local continents = Map.GetCustomOption(8);
	if (continents == 4) then
		continents = 1 + Map.Rand(3, "Random Continents Setting");
	end
	local continents_modifier1 = 0;
	local continents_modifier2 = 0;
	if (continents == 1) then
		continents_modifier1 = -0.15;
		continents_modifier2 = -0.05;
	elseif (continents == 2) then
		continents_modifier1 = 0.0;
		continents_modifier2 = 0.075;
	else
		continents_modifier1 = 0.3;
		continents_modifier2 = 0.1;
	end
	print ("Continents Option", continents);

	local sea_level = Map.GetCustomOption(4);
	if (sea_level == 4) then
		sea_level = 1 + Map.Rand(3, "Random Sea Level");
	end
	local sea_levelModifier = 0;
	if (sea_level == 1) then
		sea_levelModifier = -0.5;
	elseif (sea_level == 2) then
		sea_levelModifier = -0.025;
	else
		sea_levelModifier = 0.1;
	end
	print ("Sea Level Option", sea_level);
	---[[
	for x = 0, mapWidth-1, 1 do
		for y = 0, mapHeight-1, 1 do
			local i = y * self.iNumPlotsX + x;
			local currentPlate = partOfPlate(x, y, plates);

			neighbour = adjacentToPlate(x,y,plates);
			--neighbour2 = -1;
			--if (neighbour <= 0) then neighbour2 = oneOff(x,y,plates) end
			--[[if (neighbour > 0) then
				boundaryType = plates[currentPlate].neighbours.relativeMotions[neighbour].boundaryType;
				if (boundaryType == "Collision") then
					self.plotTypes[i] = PlotTypes.PLOT_MOUNTAIN;
				elseif (boundaryType == "Transform") then
					self.plotTypes[i] = PlotTypes.PLOT_HILLS;
				elseif (boundaryType == "Rift") then
					self.plotTypes[i] = PlotTypes.PLOT_OCEAN;
				else
					self.plotTypes[i] = PlotTypes.PLOT_LAND;
				end
			else
				self.plotTypes[i] = PlotTypes.PLOT_LAND;
			end]]--

			local value;
			if (plates[currentPlate].terrainType == "Ocean") then value = GetHeight(x,y,1.5,0)-0.5+islandsModifier;
			elseif (plates[currentPlate].terrainType == "Deep Ocean") then value = -1;
			elseif (plates[currentPlate].terrainType == "Continental") then
				value = GetHeight(x,y,1.9+continents_modifier1,0)+0.1+continents_modifier2;
				if (value < 0 + sea_levelModifier and numAdjacentLandTiles(x,y,1.9+continents_modifier1,0,sea_levelModifier,0.1+continents_modifier2) >= 4) then value = 0.11 end 
				--value = 0.01
			elseif (plates[currentPlate].terrainType == "Island Arcs") then
				value = GetHeight(x,y,1.4,2)-0.2;
				if (value > 0 + sea_levelModifier and numAdjacentLandTiles(x,y,1.4,2,sea_levelModifier,-0.2) <= 1) then value = -0.5 end 
			elseif (plates[currentPlate].terrainType == "Fractal") then 
				value = GetHeight(x,y,2.0,2)-0.05-sea_levelModifier/2;
				if (value < 0 + sea_levelModifier and numAdjacentLandTiles(x,y,1.5,1,sea_levelModifier,0.05) >= 3) then value = 0.1 end 
			else value = 1;
			end

			if (neighbour > 0) then
				boundaryType = plates[currentPlate].neighbours.relativeMotions[neighbour].boundaryType;
				if (boundaryType == "Collision") then
					terrainType = plates[currentPlate].terrainType;
					terrainTypeN = plates[neighbour].terrainType;

					if (terrainType == "Continental") then
						value = value + 0.05 + RandomFloat()/5.0 + plate_motionModifier;
					elseif (terrainType == "Fractal") then
						if (terrainTypeN == "Ocean" or terrainTypeN == "Island Arcs") then
							value = value + RandomFloat()/5.0 + plate_motionModifier;
						else
							value = value + 0.05 + RandomFloat()/5.0 + plate_motionModifier;
						end
					elseif (terrainType == "Island Arcs") then
						value = value + 0.15 + RandomFloat()/2.5 + plate_motionModifier;
					else
						if (terrainTypeN == "Continental") then
							value =  RandomFloat()/2.5 - 0.05;
						else
							value = value + 0.1 + RandomFloat()/2.5;
						end
					end

					if (value < 0.1 + RandomFloat()/5.0 and RandomFloat() < 0.5) then
						value = value - 0.5;
					end
				elseif (boundaryType == "Transform") then
					value = value - (0.05 - RandomFloat()/10.0) * plate_motionMultiplier;
				elseif (boundaryType == "Rift") then
					value = value - 0.05 - RandomFloat()/20.0 - plate_motionModifier/2;
					if (RandomFloat() > 0.97) then value = 0.5 end
				end
			end

			--[[
			if (neighbour2 > 0) then
				boundaryType = plates[currentPlate].neighbours.relativeMotions[neighbour2].boundaryType;
				if (boundaryType == "Collision") then
					terrainType = plates[currentPlate].terrainType;
					terrainTypeN = plates[neighbour2].terrainType;
					if (terrainType == "Continental") then
						value = value + math.random()/5.0 + plate_motionModifier/2;
					end
					if (value < 0.1 + math.random()/5.0 and math.random() < 0.5) then
						value = value - 0.5;
					end
				elseif (boundaryType == "Rift") then
					--value = value - math.random()/20.0 - plate_motionModifier/3;
				end
			end--]]--

			if (value < 0 + sea_levelModifier) then
				self.plotTypes[i] = PlotTypes.PLOT_OCEAN;
			elseif (value < RandomFloat()/2.0) then
				self.plotTypes[i] = PlotTypes.PLOT_LAND;
			elseif (value < 0.4 + RandomFloat()/2.0) then
				self.plotTypes[i] = PlotTypes.PLOT_HILLS;
			else
				self.plotTypes[i] = PlotTypes.PLOT_MOUNTAIN;
			end

			--[[ TEST
			terrainType = plates[currentPlate].terrainType;
			if (value < 0 + sea_levelModifier) then
				self.plotTypes[i] = PlotTypes.PLOT_OCEAN;
			elseif (terrainType == "Island Arcs") then
				self.plotTypes[i] = PlotTypes.PLOT_LAND;
			elseif (terrainType == "Fractal") then
				self.plotTypes[i] = PlotTypes.PLOT_HILLS;
			else
				self.plotTypes[i] = PlotTypes.PLOT_MOUNTAIN;
			end
			--]]--
		end
	end--]]--
	--[[
	for x = 0, mapWidth-1, 1 do
		for y = 0, mapHeight-1, 1 do
			local i = y * self.iNumPlotsX + x;
			if adjacentToPlate(x,y,plates) > 0 then
				self.plotTypes[i] = PlotTypes.PLOT_MOUNTAIN;
			--elseif oneOff(x,y,plates) > 0 then
			--	self.plotTypes[i] = PlotTypes.PLOT_HILLS;
			else
				self.plotTypes[i] = PlotTypes.PLOT_OCEAN;
			end
		end
	end--]]--
	--self:ShiftPlotTypes();
	return self.plotTypes;
end

function partOfPlate(x, y, plates)
	if x < 0 then
		return "West";
	elseif y < 0 then
		return "South";
	elseif x >= mapWidth then
		return "East";
	elseif y >= mapHeight then
		return "North";
	end

	yShift = skewFactor[1]*math.sin(x/skewFactor[4]+skewFactor[7]) + skewFactor[2]*math.sin(x/skewFactor[5]+skewFactor[8]) + skewFactor[3]*math.sin(x/skewFactor[6]+skewFactor[9]);
	xShift = skewFactor[1]*math.sin(y/skewFactor[5]+skewFactor[9]) + skewFactor[2]*math.sin(y/skewFactor[6]+skewFactor[7]) + skewFactor[3]*math.sin(y/skewFactor[4]+skewFactor[8]);

	yFuddle = math.pow((0.5*math.sin(x/skewFactor2[1]+skewFactor2[5])+0.5*math.sin(x/skewFactor2[2]+skewFactor2[6])),2)*(math.sin(x*skewFactor2[3]+skewFactor2[7])+math.sin(x*skewFactor2[4]+skewFactor2[8]));
	xFuddle = math.pow((0.5*math.sin(y/skewFactor2[1]+skewFactor2[6])+0.5*math.sin(y/skewFactor2[2]+skewFactor2[7])),2)*(math.sin(y*skewFactor2[3]+skewFactor2[8])+math.sin(y*skewFactor2[4]+skewFactor2[5]));

	xAdj = x + xShift+xFuddle;
	yAdj = y + yShift+yFuddle;

	local distanceToPlate = {};
	for plateIndex, thisPlate in ipairs(plates) do
		local yMod = 1 + (((mapHeight/2.0) - yAdj) * ((mapHeight/2.0) - yAdj)) / (mapHeight*2.0);
		local xMod = 1 + (((mapWidth/2.0) - xAdj) * ((mapWidth/2.0) - xAdj)) / (mapWidth*2.0);
		distanceToPlate[plateIndex] = ((xAdj-thisPlate.x)*(xAdj-thisPlate.x)*xMod+(yAdj-thisPlate.y)*(yAdj-thisPlate.y)*yMod)/thisPlate.mass;
	end

	local nearestPlate = 10;
	local nearestPlateDist = 10000;
	local nearestPlateDist2 = 10000;
	for distIndex, thisDiscance in ipairs(distanceToPlate) do
		if (thisDiscance < nearestPlateDist) then
			nearestPlate = distIndex;
			nearestPlateDist2 = nearestPlateDist;
			nearestPlateDist = thisDiscance;
		end
	end
	return nearestPlate;
end

function adjacentToPlate(x,y,plates)
	currentPlate = partOfPlate(x,y,plates);
	if (isAtPlateBoundary(x, y, plates,currentPlate)) then
		info = getPlateBoundaryInfo(x, y, plates);
		biggest = 0;
		biggestIndex = -1;
		for infoIndex, thisInfo in ipairs(info) do
			if (infoIndex ~= currentPlate and thisInfo > biggest) then
				biggest = thisInfo;
				biggestIndex = infoIndex
			end
		end
		return biggestIndex;
	else
		return -1;
	end
end

function oneOff(x,y,plates)
	if (adjacentToPlate(x,y,plates) ~= -1) then return -1 end

	currentPlate = partOfPlate(x,y,plates);

	indices = {};
	indices[1] = adjacentToPlate(x-1+(y%2), y+1,plates);
	indices[2] = adjacentToPlate(x+(y%2), y+1,plates);
	indices[3] = adjacentToPlate(x-1, y,plates);
	indices[4] = adjacentToPlate(x+1, y,plates);
	indices[5] = adjacentToPlate(x-1+(y%2), y-1,plates);
	indices[6] = adjacentToPlate(x+(y%2), y-1,plates);

	biggest = -1;
	for i = 1, 6, 1 do -- Huge hack
		if (indices[i] ~= -1) then return indices[i] end 
	end

	return -1;
end

function getPlateBoundaryInfo(x, y, plates)
	local info = {};
	for plateIndex, thisPlate in ipairs(plates) do
		info[plateIndex] = 0;
	end
	info["West"] = 0;
	info["South"] = 0;
	info["East"] = 0;
	info["North"] = 0;

	local index1 = partOfPlate(x-1+(y%2), y+1,plates);
	if (info[index1] ~= nil) then
		info[index1] = info[index1]+1;
	end
	local index2 = partOfPlate(x+(y%2), y+1,plates);
	if (info[index2] ~= nil) then
		info[index2] = info[index2]+1;
	end
	local index3 = partOfPlate(x-1, y,plates);
	if (info[index3] ~= nil) then
		info[index3] = info[index3]+1;
	end
	local index4 = partOfPlate(x+1, y,plates);
	if (info[index4] ~= nil) then
		info[index4] = info[index4]+1;
	end
	local index5 = partOfPlate(x-1+(y%2), y-1,plates);
	if (info[index5] ~= nil) then
		info[index5] = info[index5]+1;
	end
	local index6 = partOfPlate(x+(y%2), y-1,plates);
	if (info[index6] ~= nil) then
		info[index6] = info[index6]+1;
	end
	return info;
end

function numAdjacentLandTiles(x, y, n, f, s, d)
	if (x <= 0 or y <= 0 or x >= mapWidth-1 or y >= mapHeight-1) then return 0 end

	adjacentLandTiles = 0;
	height = GetHeight(x-1+(y%2), y+1, n, f) + d;
	if (height > 0 + s) then
		adjacentLandTiles = adjacentLandTiles+1;
	end
	height = GetHeight(x+(y%2), y+1, n, f) + d;
	if (height > 0 + s) then
		adjacentLandTiles = adjacentLandTiles+1;
	end
	height = GetHeight(x-1, y, n, f) + d;
	if (height > 0 + s) then
		adjacentLandTiles = adjacentLandTiles+1;
	end
	height = GetHeight(x+1, y, n, f) + d;
	if (height > 0 + s) then
		adjacentLandTiles = adjacentLandTiles+1;
	end
	height = GetHeight(x-1+(y%2), y-1, n, f) + d;
	if (height > 0 + s) then
		adjacentLandTiles = adjacentLandTiles+1;
	end
	height = GetHeight(x+(y%2), y-1, n, f) + d;
	if (height > 0 + s) then
		adjacentLandTiles = adjacentLandTiles+1;
	end

	return adjacentLandTiles;
end

function isAtPlateBoundary(x, y, plates,currentPlate)

	if (partOfPlate(x-1+(y%2), y+1,plates) ~= currentPlate) then
		return true;
	end
	if (partOfPlate(x+(y%2), y+1,plates) ~= currentPlate) then
		return true;
	end
	if (partOfPlate(x-1, y,plates) ~= currentPlate) then
		return true;
	end
	if (partOfPlate(x+1, y,plates) ~= currentPlate) then
		return true;
	end
	if (partOfPlate(x-1+(y%2), y-1,plates) ~= currentPlate) then
		return true;
	end
	if (partOfPlate(x+(y%2), y-1,plates) ~= currentPlate) then
		return true;
	end

	return false;
end

function GenerateCoasts(args) 
	print("Setting coasts and oceans (MapGenerator.Lua)");
	local args = args or {};
	local bExpandCoasts = args.bExpandCoasts or true;
	local expansion_diceroll_table = args.expansion_diceroll_table or {4, 4};

	local shallowWater = GameDefines.SHALLOW_WATER_TERRAIN;
	local deepWater = GameDefines.DEEP_WATER_TERRAIN;

	for i, plot in Plots() do
		if(plot:IsWater()) then
			if(plot:IsAdjacentToLand()) then
				plot:SetTerrainType(shallowWater, false, false);
			else
				plot:SetTerrainType(deepWater, false, false);
			end
		end
	end

	if bExpandCoasts == false then
		return
	end
	---[[
	print("Expanding coasts (MapGenerator.Lua)");
	for loop, iExpansionDiceroll in ipairs(expansion_diceroll_table) do
		local shallowWaterPlots = {};
		for i, plot in Plots() do
			if(plot:GetTerrainType() == deepWater) then
				-- Chance for each eligible plot to become an expansion is 1 / iExpansionDiceroll.
				-- Default is two passes at 1/4 chance per eligible plot on each pass.
				if(plot:IsAdjacentToShallowWater() and Map.Rand(iExpansionDiceroll, "add shallows") == 0) then
					table.insert(shallowWaterPlots, plot);
				end
			end
		end
		for i, plot in ipairs(shallowWaterPlots) do
			plot:SetTerrainType(shallowWater, false, false);
		end
	end--]]--
end

function GeneratePlotTypes()
	print("Generating Plot Types (Lua Tectonic) ...");

	local fractal_world = FractalWorld.Create();
	fractal_world:InitFractal{
		continent_grain = 4};

	local plotTypes = fractal_world:GeneratePlotTypes(args);

	SetPlotTypes(plotTypes);

	GenerateCoasts(args);
end
---[[
------------------------------------------------------------------------------
-- MOD -- Slightly lowered amounts of desert, tundra, snow.
--
function GenerateTerrain()
	print("Generating Terrain (Lua Small Continents) ...");

	-- Get Temperature setting input by user.
	local temp = Map.GetCustomOption(2)
	if temp == 4 then
		temp = 1 + Map.Rand(3, "Random Temperature - Lua");
	end

	local args = {
		temperature = temp,
		grain_amount = 3,
		iDesertPercent = 35,
		fSnowLatitude = 0.8,
		fTundraLatitude = 0.6,
		fDesertBottomLatitude =	0.33,
		fDesertTopLatitude = 0.45
		};
	local terraingen = TerrainGenerator.Create(args);

	terrainTypes = terraingen:GenerateTerrain();

	SetTerrainTypes(terrainTypes);
end
------------------------------------------------------------------------------
-- Modified to reduce the amount of ice generated.
--
function FeatureGenerator:AddIceAtPlot(plot, iX, iY, lat)
	if(plot:CanHaveFeature(self.featureIce)) then
		if Map.IsWrapX() and (iY == 0 or iY == self.iGridH - 1) then
			plot:SetFeatureType(self.featureIce, -1)
		elseif Map.IsWrapX() and (iY == 1 or iY == self.iGridH - 2) then
			local rand = Map.Rand(100, "Add Ice Lua");
			if (rand <= 70) then
				plot:SetFeatureType(self.featureIce, -1);
			end
		elseif Map.IsWrapX() and (iY == 2 or iY == self.iGridH - 3) then
			local rand = Map.Rand(100, "Add Ice Lua");
			if (rand <= 40) then
				plot:SetFeatureType(self.featureIce, -1);
			end
		elseif Map.IsWrapX() and (iY == 3 or iY == self.iGridH - 4) then
			if plot:IsAdjacentToLand() == false then
				local rand = Map.Rand(100, "Add Ice Lua");
				if (rand <= 20) then
					plot:SetFeatureType(self.featureIce, -1);
				end
			end
		end
	end
end
------------------------------------------------------------------------------
-- Modified to make jungles and forests slightly less clumpy.
--
function AddFeatures()
	print("Adding Features (Lua Tectonic) ...");

	-- Get Rainfall setting input by user.
	local rain = Map.GetCustomOption(3)
	if rain == 4 then
		rain = 1 + Map.Rand(3, "Random Rainfall - Lua");
	end

	local args = {
		rainfall = rain,
		jungle_grain = 8,
		forest_grain = 8,
		clump_grain = 4,
		iJungleFactor = 6,
		iJunglePercent = 67,
		iForestPercent = 45,
		fMarshPercent = 20,
		iOasisPercent = 15
		};
	local featuregen = FeatureGenerator.Create(args);

	-- False parameter removes mountains from coastlines.
	featuregen:AddFeatures(true);
end

------------------------------------------------------------------------------
function StartPlotSystem()
	-- Get Resources setting input by user.
	local res = Map.GetCustomOption(5)
	if res == 6 then
		res = 1 + Map.Rand(3, "Random Resources Option - Lua");
	end

	print("Creating start plot database.");
	local start_plot_database = AssignStartingPlots.Create()

	print("Dividing the map in to Regions.");
	-- Regional Division Method 2: Continental
	local args = {
		method = 2,
		resources = res,
		};
	start_plot_database:GenerateRegions(args)

	print("Choosing start locations for civilizations.");
	-- Forcing starts along the ocean.
	local coastalStarts = Map.GetCustomOption(12);
	if coastalStarts == 3 then
		coastalStarts = 1 + Map.Rand(2, "Random Coastal Starts");
	end
	print("Coastal Starts Option", coastalStarts);
	local args = {mustBeCoast = (coastalStarts == 2) };
	start_plot_database:ChooseLocations(args)

	print("Normalizing start locations and assigning them to Players.");
	start_plot_database:BalanceAndAssign()

	print("Placing Natural Wonders.");
	start_plot_database:PlaceNaturalWonders()

	print("Placing Resources and City States.");
	start_plot_database:PlaceResourcesAndCityStates()

end
--]]--