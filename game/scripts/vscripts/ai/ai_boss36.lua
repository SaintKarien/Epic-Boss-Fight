require( "ai/ai_core" )
if IsServer() then
	function Spawn( entityKeyValues )
		Timers:CreateTimer(0.06,function()
			local origin = Vector(969, 132)
			thisEntity:SetAbsOrigin( origin )
			FindClearSpaceForUnit(thisEntity, origin, true)
			
			if GameRules.gameDifficulty > 2 then 
				thisEntity:SetBaseMaxHealth(2500)
				thisEntity:SetMaxHealth(2500)
				thisEntity:SetHealth(2500)
			elseif GameRules.gameDifficulty <= 2 then 
				thisEntity:SetBaseMaxHealth(2000)
				thisEntity:SetMaxHealth(2000)
				thisEntity:SetHealth(2000)
			end
		end)
	end
end