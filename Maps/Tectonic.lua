--[[--------------------------------------------------------------------------

-- Tectonic map script --

  Credits:
- Haftetavenscrap		- Original creator of the map script
  (Jibbles on Steam)
- James Barrows			- A (very) small part of the code is based on Small Continents Deluxe (v 100)
- N.Core				- Added map ratio selector, size modifier, rift width option, arctic ocean width option,
						  start placement method, more options for existing custom options for gradual adjustment,
						  balancing the map to be kinder to smaller sizes by generate more land and fewer islands,
						  and the opposite for larger sizes.


Generates a map based on global tectonics.
Maps are similar to a combination of Fractal, Small Continents, Archipelago, with added tectonic elements like mountain belts and rift zones.
Works best on relatively large maps (Map size options are equivalent to Terra maps).

--]]
------------------------------------------------------------------------------
include("MapGenerator");
include("FractalWorld");
include("FeatureGenerator");
include("TerrainGenerator");

local versionName = "VI" -- version 6
local L = Locale.ConvertTextKey;
------------------------------------------------------------------------------

function GetMapScriptInfo()
	local	world_age,
			temperature,
			rainfall,
			sea_level,
			resources,
			islands,
			plate_motion,
			continents,
			land,
			plates_set,
			map_ratio,
			size_mod,
			ocean_width,
			arctic_width,
			coastalStarts,
			startPlacement = GetCoreMapOptions()
	return {
		Name = L("TXT_KEY_TECTONIC") .. " - " .. versionName,
		Description = "TXT_KEY_TECTONIC_HELP",
		IsAdvancedMap = 0,
		IconIndex = 5,
		SortIndex = 1,
		CustomOptions = {
			world_age,
			temperature,
			rainfall,
			sea_level,
			resources,
			islands,
			plate_motion,
			continents,
			land,
			plates_set,
			map_ratio,
			size_mod,
			ocean_width,
			arctic_width,
			coastalStarts,
			startPlacement
		},
	};
end

function GetCoreMapOptions()
	--[[ All options have a default SortPriority of 0. Lower values will be shown above
	higher values. Negative integers are valid. So the Core Map Options, which should 
	always be at the top of the list, are getting negative values from -99 to -95. Note
	that any set of options with identical SortPriority will be sorted alphabetically. ]]--
	local map_ratio = {
		Name = "TXT_KEY_MAP_OPTION_MAP_RATIO",
		Description = "TXT_KEY_MAP_OPTION_MAP_RATIO_HELP",
		Values = {
			"TXT_KEY_MAP_OPTION_SQUARED",
			"TXT_KEY_MAP_OPTION_SQUARISH",
			"TXT_KEY_MAP_OPTION_RECTANGULAR",
			"TXT_KEY_MAP_OPTION_WIDE_RECTANGULAR",
			"TXT_KEY_MAP_OPTION_RECTILINEAR",
			"TXT_KEY_MAP_OPTION_RANDOM",
		},
		DefaultValue = 3,
		SortPriority = -99,
	};
	local size_mod = {
		Name = "TXT_KEY_MAP_OPTION_SIZE_MODIFIER",
		Description = "TXT_KEY_MAP_OPTION_SIZE_MODIFIER_HELP",
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
		SortPriority = -98,
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
		SortPriority = -97,
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
		SortPriority = -96,
	};
	local sea_level = {
		Name = "TXT_KEY_MAP_OPTION_SEA_LEVEL",
		Description = "TXT_KEY_MAP_OPTION_SEA_LEVEL_HELP_TECTONIC",
		Values = {
			"TXT_KEY_MAP_OPTION_SHALLOW",
			"TXT_KEY_MAP_OPTION_LOW",
			"TXT_KEY_MAP_OPTION_MEDIUM",
			"TXT_KEY_MAP_OPTION_HIGH",
			"TXT_KEY_MAP_OPTION_EXTREME",
			"TXT_KEY_MAP_OPTION_RANDOM",
		},
		DefaultValue = 3,
		SortPriority = -95,
	};
	local ocean_width = {
		Name = "TXT_KEY_MAP_OPTION_OCEAN_RIFT_WIDTH",
		Description = "TXT_KEY_MAP_OPTION_OCEAN_RIFT_WIDTH_HELP",
		Values = {
			"TXT_KEY_MAP_OPTION_TIGHT",
			"TXT_KEY_MAP_OPTION_NARROW",
			"TXT_KEY_MAP_OPTION_NORMAL",
			"TXT_KEY_MAP_OPTION_WIDE",
			"TXT_KEY_MAP_OPTION_LOOSE",
			"TXT_KEY_MAP_OPTION_RANDOM",
		},
		DefaultValue = 3,
		SortPriority = -94,
	};
	local arctic_width = {
		Name = "TXT_KEY_MAP_OPTION_ARCTIC_OCEAN_WIDTH",
		Description = "TXT_KEY_MAP_OPTION_ARCTIC_OCEAN_WIDTH_HELP",
		Values = {
			"TXT_KEY_MAP_OPTION_TIGHT",
			"TXT_KEY_MAP_OPTION_NARROW",
			"TXT_KEY_MAP_OPTION_NORMAL",
			"TXT_KEY_MAP_OPTION_WIDE",
			"TXT_KEY_MAP_OPTION_LOOSE",
			"TXT_KEY_MAP_OPTION_RANDOM",
		},
		DefaultValue = 3,
		SortPriority = -93,
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
		SortPriority = -92,
	};
	local islands = {
		Name = "TXT_KEY_MAP_OPTION_ISLANDS",
		Description = "TXT_KEY_MAP_OPTION_ISLANDS_HELP",
		Values = {
			"TXT_KEY_MAP_OPTION_NONE",
			"TXT_KEY_MAP_OPTION_FEW",
			"TXT_KEY_MAP_OPTION_SCATTERED",
			"TXT_KEY_MAP_OPTION_STANDARD",
			"TXT_KEY_MAP_OPTION_MORE",
			"TXT_KEY_MAP_OPTION_ABUNDANT",
			"TXT_KEY_MAP_OPTION_RANDOM",
		},
		DefaultValue = 4,
		SortPriority = -91,
	};
	local plate_motion = {
		Name = "TXT_KEY_MAP_OPTION_PLATE_MOTION",
		Description = "TXT_KEY_MAP_OPTION_PLATE_MOTION_HELP",
		Values = {
			"TXT_KEY_MAP_OPTION_SLOW",
			"TXT_KEY_MAP_OPTION_AVERAGE",
			"TXT_KEY_MAP_OPTION_FAST",
			"TXT_KEY_MAP_OPTION_RAMMING_SPEED",
			"TXT_KEY_MAP_OPTION_RANDOM",
		},
		DefaultValue = 2,
		SortPriority = -90,
	};
	local continents = {
		Name = "TXT_KEY_MAP_OPTION_CONTINENTS",
		Description = "TXT_KEY_MAP_OPTION_CONTINENTS_HELP",
		Values = {
			"TXT_KEY_MAP_OPTION_STRINGY",
			"TXT_KEY_MAP_OPTION_SNAKY",
			"TXT_KEY_MAP_OPTION_STANDARD",
			"TXT_KEY_MAP_OPTION_CHUNKY",
			"TXT_KEY_MAP_OPTION_BLOCKY",
			"TXT_KEY_MAP_OPTION_RANDOM",
		},
		DefaultValue = 3,
		SortPriority = -89,
	};
	local land = {
		Name = "TXT_KEY_MAP_OPTION_LAND",
		Description = "TXT_KEY_MAP_OPTION_LAND_HELP",
		Values = {
			"TXT_KEY_MAP_OPTION_FEW",
			"TXT_KEY_MAP_OPTION_LESS",
			"TXT_KEY_MAP_OPTION_STANDARD",
			"TXT_KEY_MAP_OPTION_MODERATE",
			"TXT_KEY_MAP_OPTION_MORE",
			"TXT_KEY_MAP_OPTION_RANDOM",
		},
		DefaultValue = 3,
		SortPriority = -88,
	};
	local plates_set = {
		Name = "TXT_KEY_MAP_OPTION_PLATES",
		Description = "TXT_KEY_MAP_OPTION_PLATES_HELP",
		Values = {
			"TXT_KEY_MAP_OPTION_FEW",
			"TXT_KEY_MAP_OPTION_LESS",
			"TXT_KEY_MAP_OPTION_STANDARD",
			"TXT_KEY_MAP_OPTION_MODERATE",
			"TXT_KEY_MAP_OPTION_MORE",
			"TXT_KEY_MAP_OPTION_RANDOM",
		},
		DefaultValue = 3,
		SortPriority = -87,
	};
	local coastalStarts = {
		Name = "TXT_KEY_MAP_OPTION_COASTAL_START",
		Description = "TXT_KEY_MAP_OPTION_COASTAL_START_HELP",
		Values = {
			"TXT_KEY_MAP_OPTION_NO",
			"TXT_KEY_MAP_OPTION_YES",
			"TXT_KEY_MAP_OPTION_RANDOM",
		},
		DefaultValue = 2,
		SortPriority = -86,
	};
	local startPlacement = {
		Name = "TXT_KEY_MAP_OPTION_START_PLACEMENT",
		Description = "TXT_KEY_MAP_OPTION_START_PLACEMENT_HELP",
		Values = {
			"TXT_KEY_MAP_OPTION_LARGEST_LANDMASS",
			"TXT_KEY_MAP_OPTION_ANY_CONTINENTS",
			"TXT_KEY_MAP_OPTION_START_ANYWHERE",
			"TXT_KEY_MAP_OPTION_RANDOM",
		},
		DefaultValue = 2,
		SortPriority = -85,
	};
	return world_age, temperature, rainfall, sea_level, resources, islands, plate_motion, continents, land, plates_set, map_ratio, size_mod, ocean_width, arctic_width, coastalStarts, startPlacement
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
local numIslands;
local numLands;
local numOceans;
local maps;
local numMaps;
local skewFactor;
local skewFactor2;

function GetMapInitData(worldSize)
	-- This function can reset map grid sizes or world wrap settings.

	local map_ratio		=	Map.GetCustomOption(11);
	local size_mod 		=	Map.GetCustomOption(12);

	if (map_ratio == 6) then			-- Random
		map_ratio = 1 + Map.Rand(5, "Random Map Size Ratio Setting");
	end
	local map_ratioMultiplierW = 1;
	local map_ratioMultiplierH = 1;
	if (map_ratio == 1) then			-- Squared
		map_ratioMultiplierW = 0.9;
		map_ratioMultiplierH = 1.1;
	elseif (map_ratio == 2) then		-- Squarish
		map_ratioMultiplierW = 0.95;
		map_ratioMultiplierH = 1.05;
	elseif (map_ratio == 3) then		-- Rectangular
		map_ratioMultiplierW = 1;
		map_ratioMultiplierH = 1;
	elseif (map_ratio == 4) then		-- Wide Rectangular
		map_ratioMultiplierW = 1.05;
		map_ratioMultiplierH = 0.95;
	elseif (map_ratio == 5) then		-- Rectilinear
		map_ratioMultiplierW = 1.1;
		map_ratioMultiplierH = 0.9;
	else								-- Fallback
		map_ratioMultiplierW = 1;
		map_ratioMultiplierH = 1;
	end
	print("--");
	print("--");
	print("Map Size Ratio modifier: 				", map_ratio, "Width: " .. map_ratioMultiplierW * 100 .. "%, Height: " .. map_ratioMultiplierH * 100 .. "%");

	local size_modMultiplier = 1;	-- Normal size - 100%
	if (size_mod == 1) then
		size_modMultiplier = 0.80;	-- Compressed size - 80%
	elseif (size_mod == 2) then
		size_modMultiplier = 0.85;	-- Squeezed size - 85%
	elseif (size_mod == 3) then
		size_modMultiplier = 0.90;	-- Reduced size - 90%
	elseif (size_mod == 4) then
		size_modMultiplier = 0.95;	-- Smaller size - 95%
	elseif (size_mod == 5) then
		size_modMultiplier = 1.00;	-- Normal size - 100%
	elseif (size_mod == 6) then
		size_modMultiplier = 1.05;	-- Plus size - 105%
	elseif (size_mod == 7) then
		size_modMultiplier = 1.10;	-- Extra size - 110%
	elseif (size_mod == 8) then
		size_modMultiplier = 1.15;	-- Super size - 115%
	elseif (size_mod == 9) then
		size_modMultiplier = 1.20;	-- Gigantic size - 120%
	end
	print("Map Size modifier:								", size_modMultiplier * 100 .. "%");

	local worldsizes = {
			[GameInfo.Worlds.WORLDSIZE_DUEL.ID] = {52, 32},
			[GameInfo.Worlds.WORLDSIZE_TINY.ID] = {64, 40},
			[GameInfo.Worlds.WORLDSIZE_SMALL.ID] = {84, 52},
			[GameInfo.Worlds.WORLDSIZE_STANDARD.ID] = {104, 64},
			[GameInfo.Worlds.WORLDSIZE_LARGE.ID] = {128, 80},
			[GameInfo.Worlds.WORLDSIZE_HUGE.ID] = {150, 94}
	}
	local grid_size = worldsizes[worldSize];
	--
	local world = GameInfo.Worlds[worldSize];
	if(world ~= nil) then
		print("Map Size before modifier:				", "Width: " .. grid_size[1] * map_ratioMultiplierW .. ", Height: " .. grid_size[2] * map_ratioMultiplierH);
		print("Map Size after modifier:					", "Width: " .. (grid_size[1] * map_ratioMultiplierW) * size_modMultiplier.. ", Height: " .. (grid_size[2] * map_ratioMultiplierH) * size_modMultiplier);
		print("--");
		print("--");
	return {
		Width = (grid_size[1] * map_ratioMultiplierW) * size_modMultiplier,
		Height = (grid_size[2] * map_ratioMultiplierH) * size_modMultiplier,
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

	-- Set variables for custom options, 1-5 are reserved for default civ 5 options
	local islands 		=	Map.GetCustomOption(6);
	local plate_motion	=	Map.GetCustomOption(7);
	local continents	=	Map.GetCustomOption(8);
	local land 			=	Map.GetCustomOption(9);
	local plates_set 	=	Map.GetCustomOption(10);
	--local map_ratio		=	Map.GetCustomOption(11);	-- not used in this function
	local size_mod 		=	Map.GetCustomOption(12);
	local ocean_width	=	Map.GetCustomOption(13);
	local arctic_width	=	Map.GetCustomOption(14);

	local getWorldSize	=	Map.GetWorldSize();

	skewFactor = { RandomFloat()*2+1, RandomFloat()+1, RandomFloat()+1,  RandomFloat()*6+5, RandomFloat()*3+3, RandomFloat()*2+2,  RandomFloat()*7, RandomFloat()*7, RandomFloat()*7};
	skewFactor2 = { RandomFloat()*10+5, RandomFloat()*5+5, RandomFloat()*5+3, RandomFloat()*5+3, RandomFloat()*7, RandomFloat()*7, RandomFloat()*7, RandomFloat()*7};

	local WorldSizeTypes = {};
	for row in GameInfo.Worlds() do
		WorldSizeTypes[row.Type] = row.ID;
	end

	local size_modMultiplier = 1;		-- Normal size - 100%
	if (size_mod == 1) then
		size_modMultiplier = 0.80;		-- Compressed size - 80%
	elseif (size_mod == 2) then
		size_modMultiplier = 0.85;		-- Squeezed size - 85%
	elseif (size_mod == 3) then
		size_modMultiplier = 0.90;		-- Reduced size - 90%
	elseif (size_mod == 4) then
		size_modMultiplier = 0.95;		-- Smaller size - 95%
	elseif (size_mod == 5) then
		size_modMultiplier = 1.00;		-- Normal size - 100%
	elseif (size_mod == 6) then
		size_modMultiplier = 1.05;		-- Plus size - 105%
	elseif (size_mod == 7) then
		size_modMultiplier = 1.10;		-- Extra size - 110%
	elseif (size_mod == 8) then
		size_modMultiplier = 1.15;		-- Super size - 115%
	elseif (size_mod == 9) then
		size_modMultiplier = 1.20;		-- Gigantic size - 120%
	end

	local platesSizes = {
		[WorldSizeTypes.WORLDSIZE_DUEL]     = 16, -- 4
		[WorldSizeTypes.WORLDSIZE_TINY]     = 24, -- 8
		[WorldSizeTypes.WORLDSIZE_SMALL]    = 32, -- 16
		[WorldSizeTypes.WORLDSIZE_STANDARD] = 40, -- 20
		[WorldSizeTypes.WORLDSIZE_LARGE]    = 48, -- 24
		[WorldSizeTypes.WORLDSIZE_HUGE]		= 56 -- 32
	}
	print("Generating Plates");

	numPlates = platesSizes[getWorldSize] or 24;
	print("Number of plates:								", numPlates);

	if (plates_set == 6) then				-- Random
		plates_set = 1 + Map.Rand(8, "Random Plates Setting");
	end
	if (plates_set == 1) then				-- Few
		numPlates = (numPlates)/2;
	elseif (plates_set == 2) then			-- Less
		numPlates = (numPlates * 2)/3;
	elseif (plates_set == 3) then			-- Standard
		numPlates = numPlates;
	elseif (plates_set == 4) then			-- Moderate
		numPlates = (numPlates * 3)/2;
	elseif (plates_set == 5) then			-- More
		numPlates = (numPlates * 2);
	else									-- Fallback for Random
		numPlates = (numPlates * 4)/3;
	end
	numPlates = numPlates * size_modMultiplier;
	print ("Plates option:										", plates_set, "numPlates: ".. numPlates);

	mapWidth = self.iNumPlotsX;
	mapHeight = self.iNumPlotsY;

	local plates = {};
	for i = 1, numPlates, 1 do
		plates[i] = {};
		plates[i].x = Map.Rand(mapWidth, "centerX of Plate");
		plates[i].y = Map.Rand(mapHeight, "centerY of Plate");
		plates[i].mass = Map.Rand(3, "mass of Plate") + 10;
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
			currentPlate = PartOfPlate(x,y,plates);
			info = GetPlateBoundaryInfo(x, y, plates);
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
			local currentPlate = PartOfPlate(x, y, plates);
			plates[currentPlate].size = plates[currentPlate].size + 1;
		end
	end

	print("Calculating Plate Types");
	print("--");
	print("--");
	--
	oceanAmount = 0;
	oceanAmountD = 0;
	oceanAmountNS = 0;
	oceanAmountREG = 0;
	landAmount = 0;
	arcAmount = 0;
	fractalAmount = 0;
	spiffiness = 0;--]]--

	local islandsSizes = {
		[WorldSizeTypes.WORLDSIZE_DUEL]     = 0.025,
		[WorldSizeTypes.WORLDSIZE_TINY]     = 0.050,
		[WorldSizeTypes.WORLDSIZE_SMALL]    = 0.075,
		[WorldSizeTypes.WORLDSIZE_STANDARD] = 0.100,
		[WorldSizeTypes.WORLDSIZE_LARGE]    = 0.125,
		[WorldSizeTypes.WORLDSIZE_HUGE]		= 0.150
	}
	numIslands = (islandsSizes[getWorldSize] or 0.115) * size_modMultiplier;
	print ("Islands modifier from world size:", "+" .. numIslands * 100 .. "%");

	if (islands == 7) then				-- Random
		islands = 2 + Map.Rand(9, "Random Islands Setting");
	end
	local islandsModifier = 0;
	if (islands == 1) then				-- None
		islandsModifier = -5;
	elseif (islands == 2) then			-- Few
		islandsModifier = -0.3;
	elseif (islands == 3) then			-- Scattered
		islandsModifier = -0.15;
	elseif (islands == 4) then			-- Standard
		islandsModifier = 0.05;
	elseif (islands == 5) then			-- More
		islandsModifier = 0.2;
	elseif (islands == 6) then			-- Abundant
		islandsModifier = 0.3;
	else								-- Fallback for Random
		islandsModifier = 0.125;
	end
	print("Islands option:									", islands);
	print("Islands modifier from options:		", islandsModifier);
	print("--");

	local landSizes = {
		[WorldSizeTypes.WORLDSIZE_DUEL]     = 0.225,
		[WorldSizeTypes.WORLDSIZE_TINY]     = 0.200,
		[WorldSizeTypes.WORLDSIZE_SMALL]    = 0.175,
		[WorldSizeTypes.WORLDSIZE_STANDARD] = 0.125,
		[WorldSizeTypes.WORLDSIZE_LARGE]    = 0.100,
		[WorldSizeTypes.WORLDSIZE_HUGE]		= 0.075
	}
	numLands = (landSizes[getWorldSize] or 0.15) * size_modMultiplier;
	print("Land modifier from world size:		", "+" .. numLands * 100 .. "%");

	if (land == 6) then					-- Random
		land = 1 + Map.Rand(8, "Random Land Setting");
	end
	local landModifier = 0;
	if (land == 1) then					-- Few
		landModifier = -0.2;
	elseif (land == 2) then				-- Less
		landModifier = -0.1;
	elseif (land == 3) then				-- Standard
		landModifier = 0.125;
	elseif (land == 4) then				-- Moderate
		landModifier = 0.2;
	elseif (land == 5) then				-- More
		landModifier = 0.25;
	else								-- Fallback for Random
		landModifier = 0.15;
	end
	landModifier = landModifier + numLands;
	print("Land option:											", land);
	print("--");

	if (continents == 6) then			-- Random
		continents = 1 + Map.Rand(8, "Random Continents Setting");
	end
	local continents_modifier = 0;
	if (continents == 1) then			-- Stringy
		continents_modifier = -0.45;
	elseif (continents == 2) then		-- Snaky
		continents_modifier = -0.25;
	elseif (continents == 3) then		-- Standard
		continents_modifier = -0.05;
	elseif (continents == 4) then		-- Chunky
		continents_modifier = 0.2;
	elseif (continents == 5) then		-- Blocky
		continents_modifier = 0.5;
	else								-- Fallback for Random
		continents_modifier = -0.15;
	end

	local oceanSizes = {
		[WorldSizeTypes.WORLDSIZE_DUEL]     = 1.50,
		[WorldSizeTypes.WORLDSIZE_TINY]     = 1.40,
		[WorldSizeTypes.WORLDSIZE_SMALL]    = 1.25,
		[WorldSizeTypes.WORLDSIZE_STANDARD] = 1.10,
		[WorldSizeTypes.WORLDSIZE_LARGE]    = 0.95,
		[WorldSizeTypes.WORLDSIZE_HUGE]		= 0.85
	}
	numOceans = (oceanSizes[getWorldSize] or 1.15) * size_modMultiplier;
	print("Ocean modifier from world size:	", numOceans .. " x");

	if (ocean_width == 6) then			-- Random
		ocean_width = 1 + Map.Rand(8, "Random Ocean Rift Width Setting");
	end
	if (arctic_width == 6) then			-- Random
		arctic_width = 1 + Map.Rand(8, "Random Arctic Ocean Width Setting");
	end
	local ocean_widthModifierEW = 1;
	local ocean_widthModifierNS = 1;
	local ocean_widthModifierREG = 1;
	if (ocean_width == 1) then			-- Tight
		ocean_widthModifierEW = 2;
		ocean_widthModifierREG = 1.5;
	elseif (ocean_width == 2) then		-- Narrow
		ocean_widthModifierEW = 1.5;
		ocean_widthModifierREG = 1.25;
	elseif (ocean_width == 3) then		-- Normal
		ocean_widthModifierEW = 1;
		ocean_widthModifierREG = 1;
	elseif (ocean_width == 4) then		-- Wide
		ocean_widthModifierEW = 0.5;
		ocean_widthModifierREG = 0.75;
	elseif (ocean_width == 5) then		-- Loose
		ocean_widthModifierEW = 0.25;
		ocean_widthModifierREG = 0.5;
	else								-- Fallback for Random
		ocean_widthModifierEW = 1.25;
		ocean_widthModifierREG = 1.15;
	end
	if (arctic_width == 1) then			-- Tight
		ocean_widthModifierNS = 1.5;
	elseif (arctic_width == 2) then		-- Narrow
		ocean_widthModifierNS = 1.25;
	elseif (arctic_width == 3) then		-- Normal
		ocean_widthModifierNS = 1;
	elseif (arctic_width == 4) then		-- Wide
		ocean_widthModifierNS = 0.75;
	elseif (arctic_width == 5) then		-- Loose
		ocean_widthModifierNS = 0.5;
	else								-- Fallback for Random
		ocean_widthModifierNS = 1.1;
	end
	print("Ocean Rift Width option:					", ocean_width, "EW:", (ocean_widthModifierEW * numOceans) * 100 .. "%", "REG:", (ocean_widthModifierREG * numOceans) * 100 .. "%");
	print("Arctic Ocean Width option:				", arctic_width, "NS:", (ocean_widthModifierNS * numOceans) * 100 .. "%");

	local oceanEW = (30 * (ocean_widthModifierEW * numOceans));
	local oceanNS = (10 * (ocean_widthModifierNS * numOceans));
	local oceanREG = (0.5 * (ocean_widthModifierREG * numOceans));
	print("Ocean Rift Width - East-West:		", oceanEW);
	print("Ocean Rift Width - North-South:	", oceanNS);
	print("Ocean Rift Width - Random:				", oceanREG);

	for plateIndex, thisPlate in ipairs(plates) do
		if (thisPlate.neighbours.borders["West"] > oceanEW or thisPlate.neighbours.borders["East"] > oceanEW) then
			thisPlate.terrainType = "Deep Ocean";
			oceanAmount = oceanAmount + thisPlate.size;
			oceanAmountD = oceanAmountD + thisPlate.size;
		elseif ((thisPlate.neighbours.borders["South"] > oceanNS or thisPlate.neighbours.borders["North"] > oceanNS) and RandomFloat() > 0.375 + (landModifier/2)) then
			thisPlate.terrainType = "Ocean";
			oceanAmount = oceanAmount + thisPlate.size;
			oceanAmountNS = oceanAmountNS + thisPlate.size;
		elseif (thisPlate.size/(mapHeight*mapWidth) * RandomFloat() * numPlates > oceanREG + landModifier) then
			thisPlate.terrainType = "Ocean";
			oceanAmount = oceanAmount + thisPlate.size;
			oceanAmountREG = oceanAmountREG + thisPlate.size;
		elseif (thisPlate.size/(mapHeight*mapWidth) * RandomFloat() * numPlates < ((0.225 + numIslands) * size_modMultiplier) + islandsModifier) then
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

		if thisPlate.terrainType == "Continental" and RandomFloat() - neighbouringContinentAmount < ((0.2 + numLands) * size_modMultiplier) then
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
	--
	print("--");
	print("--");
	print("Total amount of ocean:						", (oceanAmount*100)/(oceanAmount+landAmount+arcAmount+fractalAmount),"%");
	print("Amount of deep ocean:						", (oceanAmountD*100)/(oceanAmount+landAmount+arcAmount+fractalAmount),"%");
	print("Amount of N/S ocean:							", (oceanAmountNS*100)/(oceanAmount+landAmount+arcAmount+fractalAmount),"%");
	print("Amount of random ocean:					", (oceanAmountREG*100)/(oceanAmount+landAmount+arcAmount+fractalAmount),"%");
	print("Amount of land:									", (landAmount*100)/(oceanAmount+landAmount+arcAmount+fractalAmount),"%");
	print("Amount of island arc:						", (arcAmount*100)/(oceanAmount+landAmount+arcAmount+fractalAmount),"%");
	print("Amount of fractal:								", (fractalAmount*100)/(oceanAmount+landAmount+arcAmount+fractalAmount),"%");
	print("Ocean converted to land:					", (spiffiness*100)/(oceanAmount+landAmount+arcAmount+fractalAmount),"%");--]]--
	print("--");
	print("--");

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

	if (plate_motion == 5) then			-- Random
		plate_motion = 1 + Map.Rand(7, "Random Plate Motion Setting");
	end
	local plate_motionModifier = 0;
	local plate_motionMultiplier = 0;
	if (plate_motion == 1) then			-- Slow
		plate_motionModifier = -0.05;
		plate_motionMultiplier = 0.66;
	elseif (plate_motion == 2) then		-- Average
		plate_motionModifier = 0.1;
		plate_motionMultiplier = 1;
	elseif (plate_motion == 3) then		-- Fast
		plate_motionModifier = 0.25;
		plate_motionMultiplier = 2;
	elseif (plate_motion == 4) then		-- Ramming Speed!
		plate_motionModifier = 0.35;
		plate_motionMultiplier = 3;
	else								-- Fallback for Random
		plate_motionModifier = 0.15;
		plate_motionMultiplier = 1.5;
	end
	print("Plate Motion option:							", plate_motion);

	if (continents == 6) then			-- Random
		continents = 1 + Map.Rand(8, "Random Continents Setting");
	end
	local continents_modifier1 = 0;
	local continents_modifier2 = 0;
	if (continents == 1) then			-- Stringy
		continents_modifier1 = -0.15;
		continents_modifier2 = -0.05;
	elseif (continents == 2) then		-- Snaky
		continents_modifier1 = -0.075;
		continents_modifier2 = -0.025;
	elseif (continents == 3) then		-- Standard
		continents_modifier1 = 0.0;
		continents_modifier2 = 0.05;
	elseif (continents == 4) then		-- Chunky
		continents_modifier1 = 0.125;
		continents_modifier2 = 0.075;
	elseif (continents == 5) then		-- Blocky
		continents_modifier1 = 0.3;
		continents_modifier2 = 0.1;
	else								-- Fallback for Random
		continents_modifier1 = 0.05;
		continents_modifier2 = 0.075;
	end
	print("Continents option:								", continents);

	local sea_level = Map.GetCustomOption(4);
	if (sea_level == 6) then			-- Random
		sea_level = 1 + Map.Rand(8, "Random Sea Level");
	end
	local sea_levelModifier = 0;
	if (sea_level == 1) then			-- Shallow
		sea_levelModifier = -0.10;
	elseif (sea_level == 2) then		-- Low
		sea_levelModifier = -0.05;
	elseif (sea_level == 3) then		-- Medium
		sea_levelModifier = -0.025;
	elseif (sea_level == 4) then		-- High
		sea_levelModifier = 0.025;
	elseif (sea_level == 5) then		-- Extreme
		sea_levelModifier = 0.05;
	else								-- Fallback for Random
		sea_levelModifier = 0.005;
	end
	print("Sea Level option:								", sea_level);
	print("--");
	print("--");
	--
	for x = 0, mapWidth-1, 1 do
		for y = 0, mapHeight-1, 1 do
			local i = y * self.iNumPlotsX + x;
			local currentPlate = PartOfPlate(x, y, plates);

			neighbour = AdjacentToPlate(x,y,plates);
			--neighbour2 = -1;
			--if (neighbour <= 0) then neighbour2 = OneOff(x,y,plates) end
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
				if (value < 0 + sea_levelModifier and NumAdjacentLandTiles(x,y,1.9+continents_modifier1,0,sea_levelModifier,0.1+continents_modifier2) >= 4) then value = 0.11 end
				--value = 0.01
			elseif (plates[currentPlate].terrainType == "Island Arcs") then
				value = GetHeight(x,y,1.4,2)-0.2;
				if (value > 0 + sea_levelModifier and NumAdjacentLandTiles(x,y,1.4,2,sea_levelModifier,-0.2) <= 1) then value = -0.5 end
			elseif (plates[currentPlate].terrainType == "Fractal") then
				value = GetHeight(x,y,2.0,2)-0.05-sea_levelModifier/2;
				if (value < 0 + sea_levelModifier and NumAdjacentLandTiles(x,y,1.5,1,sea_levelModifier,0.05) >= 3) then value = 0.1 end
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
			if AdjacentToPlate(x,y,plates) > 0 then
				self.plotTypes[i] = PlotTypes.PLOT_MOUNTAIN;
			--elseif OneOff(x,y,plates) > 0 then
			--	self.plotTypes[i] = PlotTypes.PLOT_HILLS;
			else
				self.plotTypes[i] = PlotTypes.PLOT_OCEAN;
			end
		end
	end--]]--
	--self:ShiftPlotTypes();
	return self.plotTypes;
end

function PartOfPlate(x, y, plates)
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

function AdjacentToPlate(x,y,plates)
	currentPlate = PartOfPlate(x,y,plates);
	if (IsAtPlateBoundary(x, y, plates,currentPlate)) then
		info = GetPlateBoundaryInfo(x, y, plates);
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

function OneOff(x,y,plates)
	if (AdjacentToPlate(x,y,plates) ~= -1) then return -1 end

	currentPlate = PartOfPlate(x,y,plates);

	indices = {};
	indices[1] = AdjacentToPlate(x-1+(y%2), y+1,plates);
	indices[2] = AdjacentToPlate(x+(y%2), y+1,plates);
	indices[3] = AdjacentToPlate(x-1, y,plates);
	indices[4] = AdjacentToPlate(x+1, y,plates);
	indices[5] = AdjacentToPlate(x-1+(y%2), y-1,plates);
	indices[6] = AdjacentToPlate(x+(y%2), y-1,plates);

	biggest = -1;
	for i = 1, 6, 1 do -- Huge hack
		if (indices[i] ~= -1) then return indices[i] end 
	end

	return -1;
end

function GetPlateBoundaryInfo(x, y, plates)
	local info = {};
	for plateIndex, thisPlate in ipairs(plates) do
		info[plateIndex] = 0;
	end
	info["West"] = 0;
	info["South"] = 0;
	info["East"] = 0;
	info["North"] = 0;

	local index1 = PartOfPlate(x-1+(y%2), y+1,plates);
	if (info[index1] ~= nil) then
		info[index1] = info[index1]+1;
	end
	local index2 = PartOfPlate(x+(y%2), y+1,plates);
	if (info[index2] ~= nil) then
		info[index2] = info[index2]+1;
	end
	local index3 = PartOfPlate(x-1, y,plates);
	if (info[index3] ~= nil) then
		info[index3] = info[index3]+1;
	end
	local index4 = PartOfPlate(x+1, y,plates);
	if (info[index4] ~= nil) then
		info[index4] = info[index4]+1;
	end
	local index5 = PartOfPlate(x-1+(y%2), y-1,plates);
	if (info[index5] ~= nil) then
		info[index5] = info[index5]+1;
	end
	local index6 = PartOfPlate(x+(y%2), y-1,plates);
	if (info[index6] ~= nil) then
		info[index6] = info[index6]+1;
	end
	return info;
end

function NumAdjacentLandTiles(x, y, n, f, s, d)
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

function IsAtPlateBoundary(x, y, plates,currentPlate)

	if (PartOfPlate(x-1+(y%2), y+1,plates) ~= currentPlate) then
		return true;
	end
	if (PartOfPlate(x+(y%2), y+1,plates) ~= currentPlate) then
		return true;
	end
	if (PartOfPlate(x-1, y,plates) ~= currentPlate) then
		return true;
	end
	if (PartOfPlate(x+1, y,plates) ~= currentPlate) then
		return true;
	end
	if (PartOfPlate(x-1+(y%2), y-1,plates) ~= currentPlate) then
		return true;
	end
	if (PartOfPlate(x+(y%2), y-1,plates) ~= currentPlate) then
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
	--
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
--
------------------------------------------------------------------------------
-- MOD -- Slightly lowered amounts of desert, tundra, snow.
--
function GenerateTerrain()
	print("Generating Terrain (Lua Tectonic) ...");

	-- Get Temperature setting input by user.
	local temp = Map.GetCustomOption(2)
	if temp == 4 then
		temp = 1 + Map.Rand(3, "Random Temperature - Lua");
	end

	local map_ratio		=	Map.GetCustomOption(11);
	if (map_ratio == 6) then			-- Random
		map_ratio = 1 + Map.Rand(5, "Random Map Size Ratio Setting");
	end

	local fLatitudeChange = 0;
	if (map_ratio == 1) then			-- Squared
		fLatitudeChange = 0.05;
	elseif (map_ratio == 2) then		-- Squarish
		fLatitudeChange = 0.03;
	elseif (map_ratio == 3) then		-- Rectangular
		fLatitudeChange = 0;
	elseif (map_ratio == 4) then		-- Wide Rectangular
		fLatitudeChange = -0.03;
	elseif (map_ratio == 5) then		-- Rectilinear
		fLatitudeChange = -0.05;
	else								-- Fallback
		fLatitudeChange = 0;
	end

	print("--");
	print("Map Size Ratio option: 					", map_ratio);
	print("Latitude change because of ratio:", fLatitudeChange);
	print("--");

	local args = {
		temperature = temp,
		grain_amount = 3,
		iDesertPercent = 40,
		fSnowLatitude = 0.82 + fLatitudeChange,
		fTundraLatitude = 0.6 + fLatitudeChange,
		fDesertBottomLatitude =	0.28 + fLatitudeChange,
		fDesertTopLatitude = 0.42 + fLatitudeChange
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
		fMarshPercent = 18,
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
		res = 1 + Map.Rand(5, "Random Resources Option - Lua");
	end

	print("Creating start plot database.");
	local start_plot_database = AssignStartingPlots.Create()

	local startPlacement = Map.GetCustomOption(16)
	local divMethod = nil
	if startPlacement == 4 then
		divMethod = 1 + Map.Rand(3, "Random Start Placement");
	end
	if startPlacement == 1 then			-- Biggest Landmass
		divMethod = 1
	elseif startPlacement == 2 then		-- Any Continents
		divMethod = 2
	elseif startPlacement == 3 then		-- Start Anywhere
		divMethod = 3
	else								-- Fallback
		divMethod = 2
	end
	print("Start placement method:						", startPlacement);

	local largestLand = Map.FindBiggestArea(false)
	if startPlacement == 1 then
		-- Biggest Landmass placement
		if largestLand:GetNumTiles() < 0.25 * Map.GetLandPlots() then
			print("AI Map Strategy - Offshore expansion with navy bias")
			-- Tell the AI that we should treat this as a offshore expansion map with naval bias
			Map.ChangeAIMapHint(4+1)
		else
			print("AI Map Strategy - Offshore expansion")
			-- Tell the AI that we should treat this as a offshore expansion map
			Map.ChangeAIMapHint(4)
		end
	elseif startPlacement == 2 then
		-- Any Continents placement
		if largestLand:GetNumTiles() < 0.25 * Map.GetLandPlots() then
			print("AI Map Strategy - Offshore expansion with navy bias")
			-- Tell the AI that we should treat this as a offshore expansion map with naval bias
			Map.ChangeAIMapHint(4+1)
		else
			print("AI Map Strategy - Normal")
		end
	elseif startPlacement == 3 then
		-- Start Anywhere placement
		if largestLand:GetNumTiles() < 0.25 * Map.GetLandPlots() then
			print("AI Map Strategy - Navy bias")
			-- Tell the AI that we should treat this as a map with naval bias
			Map.ChangeAIMapHint(1)
		else
			print("AI Map Strategy - Normal")
		end
	else
		print("AI Map Strategy - Normal")
	end

	print("Dividing the map in to Regions.");
	-- Regional Division Method 2: Continental
	local args = {
		method = divMethod,
		resources = res,
		};
	start_plot_database:GenerateRegions(args)

	print("Choosing start locations for civilizations.");
	-- Forcing starts along the ocean.
	local coastalStarts = Map.GetCustomOption(15);
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