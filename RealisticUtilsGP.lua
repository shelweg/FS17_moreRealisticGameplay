RealisticUtilsGP = {}


--**********************************************************************************************************************************************************
RealisticUtilsGP.loadConfigFile = function(filePath)

	local xmlFile = loadXMLFile("realConfigXML", filePath)
	
	--20170615 - use "global" variables so that other mods can override our settings
	--only load our values if there is no existing value
	
	if g_currentMission.mrGameplayDoChangeFillTypes==nil then
		g_currentMission.mrGameplayDoChangeFillTypes = Utils.getNoNil(getXMLBool(xmlFile, "settings.doChangeFillTypes#value"),true)
	end
	if g_currentMission.mrGameplayDoChangeFruitTypes==nil then
		g_currentMission.mrGameplayDoChangeFruitTypes = Utils.getNoNil(getXMLBool(xmlFile, "settings.doChangeFruitTypes#value"),true)
	end
	if g_currentMission.mrGameplayDoChangeSprayTypes==nil then
		g_currentMission.mrGameplayDoChangeSprayTypes = Utils.getNoNil(getXMLBool(xmlFile, "settings.doChangeSprayTypes#value"),true)
	end
	if g_currentMission.mrGameplayDoChangeFruitConvertersTypes==nil then
		g_currentMission.mrGameplayDoChangeFruitConvertersTypes = Utils.getNoNil(getXMLBool(xmlFile, "settings.doChangeFruitConvertersTypes#value"),true)
	end
	if g_currentMission.mrGameplayBalerFillLevelScaling==nil then
		g_currentMission.mrGameplayBalerFillLevelScaling = Utils.getNoNil(getXMLFloat(xmlFile, "settings.balerFillLevelScale#value"),1)		
	end
	if g_currentMission.mrGameplayDoChangeTipUtilHeightTypes==nil then
		g_currentMission.mrGameplayDoChangeTipUtilHeightTypes = Utils.getNoNil(getXMLFloat(xmlFile, "settings.doChangeTipUtilHeightTypes#value"),1)
	end
	if g_currentMission.mrGameplayDirtSpeedMultiplier==nil then
		g_currentMission.mrGameplayDirtSpeedMultiplier = Utils.getNoNil(getXMLFloat(xmlFile, "settings.dirtSpeedMultiplier#value"),1)
	end
	if g_currentMission.mrGameplayPriceDropDelay==nil then
		local priceDropDelay = getXMLFloat(xmlFile, "settings.priceDropDelay#value")
		if priceDropDelay~=nil then
			TipTrigger.PRICE_DROP_DELAY = priceDropDelay
		end
	end
	--20180117 - add draftForce fx
	if g_currentMission.mrGameplaySoilDraftForceFactor==nil then
		g_currentMission.mrGameplaySoilDraftForceFactor = Utils.getNoNil(getXMLFloat(xmlFile, "settings.soilDraftForceFactor#value"),1)
	end
	
	
	--20170913 - specific "global" variables
	if g_currentMission.mrGameplaySilageBaleDensity==nil then
		local silageBaleDensity = getXMLFloat(xmlFile, "settings.silageBaleDensity#value")
		if silageBaleDensity~=nil then
			Bale.MR_SILAGEBALE_DENSITY = silageBaleDensity
			g_currentMission.mrGameplaySilageBaleDensity = true
		end
	end	
	
	--20171008 - factor to modify animals food consumption
	if g_currentMission.mrGameplayAnimalsCowFoodFactor==nil then
		local factor = getXMLFloat(xmlFile, "settings.animals.cow#foodRatio")
		if factor~=nil then
			g_currentMission.mrGameplayAnimalsCowFoodFactor = factor			
			if AnimalUtil~=nil and AnimalUtil.animals~=nil and AnimalUtil.animals["cow"]~=nil then
				AnimalUtil.animals["cow"].foodPerDay = factor * AnimalUtil.animals["cow"].foodPerDay
			end
		end
	end
	
	if g_currentMission.mrGameplayAnimalsPigFoodFactor==nil then
		local factor = getXMLFloat(xmlFile, "settings.animals.pig#foodRatio")
		if factor~=nil then
			g_currentMission.mrGameplayAnimalsPigFoodFactor = factor			
			if AnimalUtil~=nil and AnimalUtil.animals~=nil and AnimalUtil.animals["pig"]~=nil then
				AnimalUtil.animals["pig"].foodPerDay = factor * AnimalUtil.animals["pig"].foodPerDay
			end
		end
	end
	
	if g_currentMission.mrGameplayAnimalsSheepFoodFactor==nil then
		local factor = getXMLFloat(xmlFile, "settings.animals.sheep#foodRatio")
		if factor~=nil then
			g_currentMission.mrGameplayAnimalsSheepFoodFactor = factor			
			if AnimalUtil~=nil and AnimalUtil.animals~=nil and AnimalUtil.animals["sheep"]~=nil then
				AnimalUtil.animals["sheep"].foodPerDay = factor * AnimalUtil.animals["sheep"].foodPerDay
			end
		end
	end
	
	delete(xmlFile)

end

--**********************************************************************************************************************************************************
RealisticUtilsGP.loadRealFillTypesData = function(filePath)	
	
	local xmlFile = loadXMLFile("realFillTypesXML", filePath)
	
	local i = 0
	while true do
		local fillTypeName = string.format("fillTypes.fillType(%d)", i)
		if not hasXMLProperty(xmlFile, fillTypeName) then break end
		
		local realFillType = {}
		realFillType.name = getXMLString(xmlFile, fillTypeName .. "#name")
		if realFillType.name == nil then
			RealisticUtilsGP.printWarning("RealisticUtilsGP.loadRealFillTypesData", "realFillType.name is nil, i="..tostring(i), true)
			break
		end		
		realFillType.startPricePerM3 = getXMLFloat(xmlFile, fillTypeName .. "#startPricePerM3")		
		realFillType.density = getXMLFloat(xmlFile, fillTypeName .. "#density")
		realFillType.mrBalerMaterialFx = getXMLFloat(xmlFile, fillTypeName .. "#balerMaterialFx")
		
		local fillType = FillUtil.fillTypeNameToDesc[realFillType.name]
		if fillType==nil then
			if Utils.mrGpDebug then
				RealisticUtilsGP.printWarning("RealisticUtilsGP.loadRealFillTypesData", "fillType is unknown on this map, name="..realFillType.name, false)
			end
		else			
			if realFillType.startPricePerM3~= nil then
				--print("fillType "..tostring(fillType.name).." - old startPrice="..tostring(fillType.startPricePerLiter*1000).." - old price="..tostring(fillType.pricePerLiter*1000) .. " - new start price="..tostring(realFillType.startPricePerM3));
				fillType.startPricePerLiter = 0.001 * realFillType.startPricePerM3
				fillType.pricePerLiter = fillType.startPricePerLiter		
				
				--20180101 - fix straw addon pellets bulk selling prices
				if realFillType.name=="strawPellets" then
					if g_modIsLoaded["pdlc_strawHarvestAddon"] then		
						local mod1 = getfenv(0)["pdlc_strawHarvestAddon"]		
						if mod1 ~= nil and mod1.MaterialLoader ~= nil then
							--print("test mod1.MaterialLoader.strawPelletsPrice="..tostring(mod1.MaterialLoader.strawPelletsPrice))
							mod1.MaterialLoader.strawPelletsPrice = fillType.pricePerLiter
						end
					end
				elseif realFillType.name=="hayPellets" then
					if g_modIsLoaded["pdlc_strawHarvestAddon"] then		
						local mod1 = getfenv(0)["pdlc_strawHarvestAddon"]		
						if mod1 ~= nil and mod1.MaterialLoader ~= nil then
							--print("test mod1.MaterialLoader.hayPelletsPrice="..tostring(mod1.MaterialLoader.hayPelletsPrice))
							mod1.MaterialLoader.hayPelletsPrice = fillType.pricePerLiter
						end
					end
				end
			end	
			if realFillType.density~= nil then
				--print("fillType "..tostring(fillType.name).." - old density="..tostring(fillType.massPerLiter*1000).." - new density="..tostring(realFillType.density));
				fillType.massPerLiter = 0.001 * realFillType.density			
			end	
			if realFillType.mrBalerMaterialFx~= nil then
				--print("fillType "..tostring(fillType.name).." - old mrBalerMaterialFx="..tostring(fillType.mrBalerMaterialFx).." - new mrBalerMaterialFx="..tostring(realFillType.mrBalerMaterialFx));
				fillType.mrBalerMaterialFx = realFillType.mrBalerMaterialFx			
			end	
		end
		
		i = i + 1
	end
	
	delete(xmlFile)

end


--**********************************************************************************************************************************************************
RealisticUtilsGP.loadRealFruitTypesData = function(filePath)	
	
	local xmlFile = loadXMLFile("realFruitTypesXML", filePath);
	
	local i = 0;
	while true do
		local fruitTypeName = string.format("fruitTypes.fruitType(%d)", i);
		if not hasXMLProperty(xmlFile, fruitTypeName) then break; end;
		
		local realFruitType = {};
		realFruitType.name = getXMLString(xmlFile, fruitTypeName .. "#name");
		if realFruitType.name == nil then
			RealisticUtilsGP.printWarning("RealisticUtilsGP.loadRealFruitTypesData", "realFruitType.name is nil, i="..tostring(i), true);
			break;
		end;
		realFruitType.literPerSqm = getXMLFloat(xmlFile, fruitTypeName .. "#literPerSqm");
		--if realFruitType.literPerSqm == nil then
		--	RealisticUtilsGP.printWarning("RealisticUtilsGP.loadRealFruitTypesData", "realFruitType.literPerSqm is nil, i="..tostring(i), true);
		--	break;
		--end;
		realFruitType.seedUsagePerSqm = getXMLFloat(xmlFile, fruitTypeName .. "#seedUsagePerSqm");
		--if realFruitType.seedUsagePerSqm == nil then
		--	RealisticUtilsGP.printWarning("RealisticUtilsGP.loadRealFruitTypesData", "realFruitType.seedUsagePerSqm is nil, i="..tostring(i), true);
		--	break;
		--end;
		realFruitType.windrowLiterPerSqm = getXMLFloat(xmlFile, fruitTypeName .. "#windrowLiterPerSqm");
		
		realFruitType.mrMaterialQtyFx = Utils.getNoNil(getXMLFloat(xmlFile, fruitTypeName .. "#mrMaterialQtyFx"), 1);
				
		local fruitType = FruitUtil.fruitTypes[realFruitType.name];
		if fruitType==nil then
			if Utils.mrGpDebug then
				RealisticUtilsGP.printWarning("RealisticUtilsGP.loadRealFruitTypesData", "fruitType is unknown, name="..realFruitType.name, false);
			end
		else
			if realFruitType.literPerSqm~= nil then
				fruitType.literPerSqm = realFruitType.literPerSqm
			end
			if realFruitType.seedUsagePerSqm~= nil then
				fruitType.seedUsagePerSqm = realFruitType.seedUsagePerSqm
			end
			if realFruitType.windrowLiterPerSqm~= nil then
				fruitType.windrowLiterPerSqm = realFruitType.windrowLiterPerSqm
			end
			if realFruitType.mrMaterialQtyFx~=nil then
				fruitType.mrMaterialQtyFx = realFruitType.mrMaterialQtyFx
			end
		end;
		
		i = i + 1;
	end
	
	delete(xmlFile);

end;

--**********************************************************************************************************************************************************
RealisticUtilsGP.loadRealSprayTypesData = function(filePath)	
	
	local xmlFile = loadXMLFile("realSprayTypesXML", filePath);
	
	local i = 0;
	while true do
		local sprayTypeName = string.format("sprayTypes.sprayType(%d)", i);		
		if not hasXMLProperty(xmlFile, sprayTypeName) then break; end;
		
		local realSprayType = {};
		realSprayType.name = getXMLString(xmlFile, sprayTypeName .. "#name");
		if realSprayType.name == nil then
			RealisticUtilsGP.printWarning("RealisticUtilsGP.loadRealSprayTypesData", "realSprayType.name is nil, i="..tostring(i), true);
			break;
		end;		
		realSprayType.litersPerHectare = getXMLFloat(xmlFile, sprayTypeName .. "#litersPerHectare");
		
		local sprayType = Sprayer.sprayTypes[realSprayType.name]
		if sprayType==nil then
			if Utils.mrGpDebug then
				RealisticUtilsGP.printWarning("RealisticUtilsGP.loadRealSprayTypesData", "sprayType is unknown on this map, name="..realSprayType.name, false);
			end
		else			
			if realSprayType.litersPerHectare~= nil then				
				sprayType.litersPerSecond = realSprayType.litersPerHectare / 36000							
			end;			
		end;
		
		i = i + 1;
	end
	
	delete(xmlFile);

end;

--**********************************************************************************************************************************************************
RealisticUtilsGP.loadRealFruitConvertersData = function(filePath)	
	
	local xmlFile = loadXMLFile("realFruitConvertersXML", filePath)
	
	local i = 0
	while true do
		local converterPath = string.format("fruitConverters.fruitConverter(%d)", i)
		if not hasXMLProperty(xmlFile, converterPath) then break end		
		
		local categoryName = getXMLString(xmlFile, converterPath .. "#categoryName")
		if categoryName == nil then
			RealisticUtilsGP.printWarning("RealisticUtilsGP.loadRealFruitConvertersData", "categoryName is nil, i="..tostring(i), true)
			break
		end

		--check the converter exists in the current game
		local converterId = FruitUtil.converterNameToInt[categoryName]		
		if converterId==nil then
			if Utils.mrGpDebug then
				RealisticUtilsGP.printWarning("RealisticUtilsGP.loadRealFruitConvertersData", "FruitUtil.converter does not exist for "..tostring(categoryName), true)
			end
		else
			--check there is a table for this converter id
			local converterFillTypes = FruitUtil.converterToFillTypes[converterId]
			if converterFillTypes==nil then
				if Utils.mrGpDebug then
					RealisticUtilsGP.printWarning("RealisticUtilsGP.loadRealFruitConvertersData", "FruitUtil.converterToFillTypes does not exist for "..tostring(converterId), true)
				end
			else			
				--parse the different fillTypes with conversion factor in the xml
				local j = 0
				while true do
					local fillTypePath = converterPath .. string.format(".fillType(%d)", j)
					
					if not hasXMLProperty(xmlFile, fillTypePath) then break end	
					
					local inputFillTypeName = getXMLString(xmlFile, fillTypePath .. "#inputName")					
					if inputFillTypeName == nil then
						RealisticUtilsGP.printWarning("RealisticUtilsGP.loadRealFruitConvertersData", "inputName is nil, j="..tostring(j) .. " for category : " .. tostring(categoryName), true)
						break			
					end
					
					--check if inputFillType exists in current game					
					local inputFillType = FillUtil.fillTypeNameToInt[inputFillTypeName]
					if inputFillType == nil then
						if Utils.mrGpDebug then
							RealisticUtilsGP.printWarning("RealisticUtilsGP.loadRealFruitConvertersData", "inputFillType does not exist in the current game, j="..tostring(j) .. " - inputFillType="..tostring(inputFillTypeName) .. " for category : " .. tostring(categoryName), true)
						end
					else
						--modify the converter with the value of the xml
						local targetName = getXMLString(xmlFile, fillTypePath .. "#targetName")
						local conversionFactor = getXMLFloat(xmlFile, fillTypePath .. "#conversionFactor")						
						local windrowConversionFactor = getXMLFloat(xmlFile, fillTypePath .. "#windrowConversionFactor")
						
						if targetName~=nil then
							--check if the target fillType exists
							local targetFillType = FillUtil.fillTypeNameToInt[targetName]
							if targetFillType==nil then
								if Utils.mrGpDebug then
									RealisticUtilsGP.printWarning("RealisticUtilsGP.loadRealFruitConvertersData", "targetFillType does not exist in the current game, j="..tostring(j) .. " - targetFillType="..tostring(targetName) .. " for category : " .. tostring(categoryName), true)
								end
								--reset factors to avoid putting values that have nothing to do with the actual targetFillType
								conversionFactor = nil
								windrowConversionFactor = nil
							else
								if converterFillTypes[inputFillType]==nil then
									converterFillTypes[inputFillType] = {} --allow creation of new conversion if the input and target are valid
									converterFillTypes[inputFillType].conversionFactor = 1
								end
								converterFillTypes[inputFillType].fillTypeTarget = targetFillType
							end
						end
						
						if conversionFactor~=nil and converterFillTypes[inputFillType]~=nil then
							converterFillTypes[inputFillType].conversionFactor = conversionFactor
						end
						if windrowConversionFactor~=nil and converterFillTypes[inputFillType]~=nil then
							converterFillTypes[inputFillType].windrowConversionFactor = windrowConversionFactor
						end
						
					end--	inputFillType nil				
					
					j = j +1
				end		
			
			
			end --converterFillTypes nil
		
		end--converterId is nil		
		
		i = i + 1
	end
	
	delete(xmlFile);

end;



--**********************************************************************************************************************************************************
RealisticUtilsGP.loadRealTipUtilHeightTypesData = function(filePath)	
	
	local xmlFile = loadXMLFile("realHeightTypesXML", filePath)
	
	local i = 0
	while true do
		local heightTypePath = string.format("heightTypes.heightType(%d)", i)	
		if not hasXMLProperty(xmlFile, heightTypePath) then break end
		
		local realHeightType = {};
		realHeightType.fillTypeName = getXMLString(xmlFile, heightTypePath .. "#fillTypeName")
		if realHeightType.fillTypeName == nil then
			RealisticUtilsGP.printWarning("RealisticUtilsGP.loadRealTipUtilHeightTypesData", "realHeightType.fillTypeName is nil, i="..tostring(i), true)
			break
		end;		
		realHeightType.fillToGroundScale = getXMLFloat(xmlFile, heightTypePath .. "#fillToGroundScale")
		realHeightType.maxSurfaceAngle = getXMLFloat(xmlFile, heightTypePath .. "#maxSurfaceAngle")
		realHeightType.collisionScale = getXMLFloat(xmlFile, heightTypePath .. "#collisionScale")
		realHeightType.collisionBaseOffset = getXMLFloat(xmlFile, heightTypePath .. "#collisionBaseOffset")
		realHeightType.minCollisionOffset = getXMLFloat(xmlFile, heightTypePath .. "#minCollisionOffset")
		realHeightType.maxCollisionOffset = getXMLFloat(xmlFile, heightTypePath .. "#maxCollisionOffset")
		
		
		--check if fillType exists
		local fillType = FillUtil.fillTypeNameToInt[realHeightType.fillTypeName]		
		if fillType==nil then
			if Utils.mrGpDebug then
				RealisticUtilsGP.printWarning("RealisticUtilsGP.loadRealTipUtilHeightTypesData", "fillType is unknown on this map, name="..realHeightType.fillTypeName, false)
			end
		else
			--check if heightType exists
			local heightType = TipUtil.fillTypeToHeightType[fillType]
			if heightType==nil then
				if Utils.mrGpDebug then
					RealisticUtilsGP.printWarning("RealisticUtilsGP.loadRealTipUtilHeightTypesData", "heightType is unknown on this map, fillType name="..realHeightType.fillTypeName, false)
				end
			else
				if realHeightType.fillToGroundScale~= nil then				
					heightType.fillToGroundScale = realHeightType.fillToGroundScale							
				end
				if realHeightType.maxSurfaceAngle~= nil then				
					heightType.maxSurfaceAngle = math.rad(realHeightType.maxSurfaceAngle)							
				end
				if realHeightType.collisionScale~= nil then				
					heightType.collisionScale = realHeightType.collisionScale
				end
				if realHeightType.collisionBaseOffset~= nil then				
					heightType.collisionBaseOffset = realHeightType.collisionBaseOffset
				end
				if realHeightType.minCollisionOffset~= nil then				
					heightType.minCollisionOffset = realHeightType.minCollisionOffset
				end
				if realHeightType.maxCollisionOffset~= nil then				
					heightType.maxCollisionOffset = realHeightType.maxCollisionOffset
				end
			end
		end
		
		i = i + 1
	end
	
	delete(xmlFile)

end;


--**********************************************************************************************************************************************************
--***** TEST / DEBUG
--**********************************************************************************************************************************************************
RealisticUtilsGP.printWarning = function(stackTrace, message, isError)
	
	local gameTime = 0;
	if g_currentMission then gameTime = g_currentMission.time; end
	local msg = "*** " .. tostring(gameTime) .. " MoreRealistic - ";
	--local msg = "*** MoreRealistic - ";
	
	if isError then
		msg = msg .. "ERROR - ";
	else
		msg = msg .. "WARNING - ";
	end;
	
	msg = msg .. stackTrace .. " - " .. message;
	
	print(msg);	

end;

function RealisticUtilsGP.testClass(className, classToTest)

	print("testing " .. tostring(className));		
	for _,k in pairs(classToTest) do
		print("function name : " .. tostring(_) .. " value : " .. tostring(k));			
	end;
	
	--table.foreach(classToTest,print);
	
	print("end testing " .. tostring(className));
	
end;
