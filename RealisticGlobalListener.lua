
RealisticGlobalListener = {};

function RealisticGlobalListener:loadMap(name)

	--RealisticUtilsGP.testClass("g_currentMission.missionInfo", g_currentMission.missionInfo)	
	
	--Goldcrest Valley
	if g_currentMission.missionInfo.mapId=="Map01" then
		RealisticGlobalListener.replaceDefaultVehiclesXml("careerVehicles_map01.xml");	
		RealisticGlobalListener.updateFieldPrice(40000);
	--Sosnovka
	elseif g_currentMission.missionInfo.mapId=="Map02" then
		RealisticGlobalListener.replaceDefaultVehiclesXml("careerVehicles_map02.xml");
		RealisticGlobalListener.updateFieldPrice(35000);
	--Estancia Lapacho
	elseif g_currentMission.missionInfo.mapId=="pdlc_platinumEdition.SouthAmericanMap" then
		RealisticGlobalListener.replaceDefaultVehiclesXml("careerVehicles_map03.xml");
		RealisticGlobalListener.updateFieldPrice(30000);
	end;
		
end;


function RealisticGlobalListener.replaceDefaultVehiclesXml(xmlFileName)
	if g_currentMission.missionInfo.playTime==0 then --this is a new game
		g_currentMission.missionInfo.vehiclesXMLLoad = RealisticUtilsGP.mrGameplayDirectory .. "data/defaultVehicles/" .. xmlFileName;
	end;
end;

function RealisticGlobalListener.updateFieldPrice(refPrice)
	--modify the price of the fields of the 2 base maps (201801 = and platinum map)
	-- could use "FieldDefinition.PRICE_HA_SCALE" or "FieldDefinition.PRICE_PER_HA" too
	-- vanilla game price = 81000 * fieldArea (hectare)
	-- MR price = depend on difficulty level and field size
	--    from "refPrice" per hectare for a small field in easy
	--    to 2x"refPrice" for a big field in hard difficulty
	if g_currentMission.fieldDefinitionBase.numberOfFields and g_currentMission.fieldDefinitionBase.numberOfFields>0 then
		for i=1, g_currentMission.fieldDefinitionBase.numberOfFields do
			local field = g_currentMission.fieldDefinitionBase.fieldDefs[i];
			if field~=nil then
				--take into account the difficulty level (g_currentMission.missionInfo.difficulty==1 => easy, 2 => normal, 3 => hard)
				local diffFactor = 1 + 0.25*(g_currentMission.missionInfo.difficulty-1); -- 1 / 1.25 / 1.5
				local sizeFactor = 1 + 0.02*field.fieldArea  -- big field = more $$ per Ha since this is better/faster to take care compared to several small fields
				field.fieldPriceInitial = field.fieldArea * refPrice * diffFactor * sizeFactor;
				--RealisticUtilsGP.testClass("field "..tostring(i), field);
			end;
		end;
	end;
end;





function RealisticGlobalListener:deleteMap()    
end

function RealisticGlobalListener:mouseEvent(posX, posY, isDown, isUp, button)
end

function RealisticGlobalListener:keyEvent(unicode, sym, modifier, isDown)
end

function RealisticGlobalListener:update(dt)
end

function RealisticGlobalListener:draw()
end

addModEventListener(RealisticGlobalListener)