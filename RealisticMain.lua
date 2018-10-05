Utils.mrGpDebug = false

local mrGameplayModName = "FS17_moreRealisticGameplay"
local mrGameplayDirectory = g_modNameToDirectory[mrGameplayModName]

--2017/04/30 - check the "moreRealisticGameplay" folder is present
if mrGameplayDirectory==nil then
	print("[MoreRealisticGamePlay] : ERROR, the moreRealisticGameplay mod folder must remain with the exact name = 'FS17_moreRealisticGameplay'.")
end

-- Global Classes
SpecializationUtil.registerSpecialization("realisticUtilsGP", "RealisticUtilsGP", mrGameplayDirectory .. "RealisticUtilsGP.lua")

RealisticUtilsGP.mrGameplayDirectory = mrGameplayDirectory
RealisticUtilsGP.modName = g_currentModName
local modItem = ModsUtil.findModItemByModName(RealisticUtilsGP.modName)

RealisticUtilsGP.version = '0.0.0.0'
if modItem and modItem.version then
	RealisticUtilsGP.version = modItem.version
end


--this script run after the "moreRealistic" is already loaded
Mission00.setMissionInfo2 = function(currentMission, missionInfo, args)
	
	local mapMrGameplayFolderPath = currentMission.baseDirectory -- missionInfo.baseDirectory
	--RealisticUtilsGP.testClass("missionInfo", missionInfo)
	--RealisticUtilsGP.testClass("currentMission", currentMission)
	

	-- load settings for the mod
	-- load the map config xml file first if present
	if mapMrGameplayFolderPath~="" then
		local mapConfigXmlPath = mapMrGameplayFolderPath .. "mrgameplay/config.xml"		
		if fileExists(mapConfigXmlPath) then
			print("**** MoreRealistic Gameplay **** loading specific map config file : " .. tostring(mapConfigXmlPath))
			RealisticUtilsGP.loadConfigFile(mapConfigXmlPath)			
		end
	end
	RealisticUtilsGP.loadConfigFile(RealisticUtilsGP.mrGameplayDirectory .. "data/config.xml")

	-- set more realistic figures for fillTypes = balance startPricePerLiter accordingly to the new moreRealistic yields
	if g_currentMission.mrGameplayDoChangeFillTypes then
		RealisticUtilsGP.loadRealFillTypesData(RealisticUtilsGP.mrGameplayDirectory .. "data/fillTypes.xml")
		-- load the map fillTypes xml file if present (overriding default mr gameplay values)
		if mapMrGameplayFolderPath~="" then
			local mapFillTypeXmlPath = mapMrGameplayFolderPath .. "mrgameplay/fillTypes.xml"		
			if fileExists(mapFillTypeXmlPath) then
				print("**** MoreRealistic Gameplay **** loading specific map fileTypes file : " .. tostring(mapFillTypeXmlPath))
				RealisticUtilsGP.loadRealFillTypesData(mapFillTypeXmlPath)			
			end
		end
		
	end

	-- set more realistic figures for fruitTypes literPerSqm, seedUsagePerSqm and windrowLiterPerSqm
	if g_currentMission.mrGameplayDoChangeFruitTypes then
		RealisticUtilsGP.loadRealFruitTypesData(RealisticUtilsGP.mrGameplayDirectory .. "data/fruitTypes.xml")
		-- load the map fruitTypes xml file if present (overriding default mr gameplay values)
		if mapMrGameplayFolderPath~="" then
			local mapFruitTypeXmlPath = mapMrGameplayFolderPath .. "mrgameplay/fruitTypes.xml"		
			if fileExists(mapFruitTypeXmlPath) then
				print("**** MoreRealistic Gameplay **** loading specific map fruitTypes file : " .. tostring(mapFruitTypeXmlPath))
				RealisticUtilsGP.loadRealFruitTypesData(mapFruitTypeXmlPath)			
			end
		end
		
	end

	-- set more realistic figures for sprayTypes
	if g_currentMission.mrGameplayDoChangeSprayTypes then
		RealisticUtilsGP.loadRealSprayTypesData(RealisticUtilsGP.mrGameplayDirectory .. "data/sprayTypes.xml")
		-- load the map sprayTypes xml file if present (overriding default mr gameplay values)
		if mapMrGameplayFolderPath~="" then
			local mapSprayTypeXmlPath = mapMrGameplayFolderPath .. "mrgameplay/sprayTypes.xml"		
			if fileExists(mapSprayTypeXmlPath) then
				print("**** MoreRealistic Gameplay **** loading specific map sprayTypes file : " .. tostring(mapSprayTypeXmlPath))
				RealisticUtilsGP.loadRealSprayTypesData(mapSprayTypeXmlPath)			
			end
		end
		
	end
	
	-- set more realistic figures for FruitUtil.converters
	if g_currentMission.mrGameplayDoChangeFruitConvertersTypes then
		RealisticUtilsGP.loadRealFruitConvertersData(RealisticUtilsGP.mrGameplayDirectory .. "data/fruitConverters.xml")
		-- load the map fruitConverters xml file if present (overriding default mr gameplay values)
		if mapMrGameplayFolderPath~="" then
			local mapFruitConvertersXmlPath = mapMrGameplayFolderPath .. "mrgameplay/fruitConverters.xml"		
			if fileExists(mapFruitConvertersXmlPath) then
				print("**** MoreRealistic Gameplay **** loading specific map fruitConverters file : " .. tostring(mapFruitConvertersXmlPath))
				RealisticUtilsGP.loadRealFruitConvertersData(mapFruitConvertersXmlPath)					
			end
		end
		
	end
	
	-- set more realistic figures for TipUtil.heightTypes
	if g_currentMission.mrGameplayDoChangeTipUtilHeightTypes then
		RealisticUtilsGP.loadRealTipUtilHeightTypesData(RealisticUtilsGP.mrGameplayDirectory .. "data/heightTypes.xml")
		-- load the map heightTypes xml file if present (overriding default mr gameplay values)
		if mapMrGameplayFolderPath~="" then
			local mapHeightTypesXmlPath = mapMrGameplayFolderPath .. "mrgameplay/heightTypes.xml"		
			if fileExists(mapHeightTypesXmlPath) then
				print("**** MoreRealistic Gameplay **** loading specific map heightTypes file : " .. tostring(mapHeightTypesXmlPath))
				RealisticUtilsGP.loadRealTipUtilHeightTypesData(mapHeightTypesXmlPath)			
			end
		end
		
	end

	print(string.format("**** MoreRealistic Gameplay V%s loaded ****", RealisticUtilsGP.version))

end
Mission00.setMissionInfo = Utils.appendedFunction(Mission00.setMissionInfo, Mission00.setMissionInfo2)