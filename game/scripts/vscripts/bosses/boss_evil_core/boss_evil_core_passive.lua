boss_evil_core_passive = class({})

function boss_evil_core_passive:GetIntrinsicModifierName()
	return "modifier_boss_evil_core_passive"
end

modifier_boss_evil_core_passive = class({})
LinkLuaModifier("modifier_boss_evil_core_passive", "bosses/boss_evil_core/boss_evil_core_passive", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	POSSIBLE_BOSSES = {	["npc_dota_boss31"] = 100, 
						["npc_dota_boss32_trueform"] = 100,
						["npc_dota_boss33_a"] = 80, 
						["npc_dota_boss33_b"] = 80, 
						["npc_dota_boss34"] = 25, 
						["npc_dota_boss35"] = 60,}

	function modifier_boss_evil_core_passive:OnCreated()
		self.manaCharge = self:GetParent():GetMaxMana()
		self.manaChargeRegen = ( self.manaCharge / self:GetTalentSpecialValueFor("recharge_time") ) * 0.3
		self.damageTaken = self:GetTalentSpecialValueFor("damage_per_hit")
		self.limit = 6
		
		
		self:StartIntervalThink(0.3)
	end
	
	function modifier_boss_evil_core_passive:OnRemoved()
		self:DestroyShield()
	end
	
	function modifier_boss_evil_core_passive:OnIntervalThink()
		local parent = self:GetParent()
		FindClearSpaceForUnit(parent, Vector(969, 132), true)
		if not self.asuraSpawn then
			parent:SetMana(self.manaCharge)
			if not self.shield then
				local demons = parent:FindFriendlyUnitsInRadius( parent:GetAbsOrigin(), -1 ) or {}
				if self.manaCharge < parent:GetMaxMana() then
					self.manaCharge = math.min(parent:GetMaxMana(), self.manaCharge + self.manaChargeRegen)
				elseif self:GetAbility():IsCooldownReady() and self.limit - 2 >= (#demons-1) then -- guarantee a minimum of time between casts
					self:ActivateShield()
				end
			else
				if self.manaCharge >= parent:GetMaxMana() then
					self:DestroyShield()
				else
					self.manaCharge = math.min(parent:GetMaxMana(), self.manaCharge + self.manaChargeRegen)
				end
			end
		end
	end
	
	function modifier_boss_evil_core_passive:ActivateShield(bInit)
		local parent = self:GetParent()
		self.shield = ParticleManager:CreateParticle("particles/units/heroes/hero_faceless_void/faceless_void_chronosphere.vpcf", PATTACH_POINT_FOLLOW, parent)
		ParticleManager:SetParticleControl(self.shield, 1, Vector(200,200,0))
		local count = (2 + math.floor((100 - parent:GetHealthPercent()) / 25))
		
		local demons = parent:FindFriendlyUnitsInRadius( parent:GetAbsOrigin(), -1 )	
		local spawnCount = math.min((self.limit - #demons + 1), count)
		
		self:GetAbility():SetCooldown()
		self.manaCharge = 0
		parent:SetMana(self.manaCharge)
		for i = 1, spawnCount do
			self:SpawnRandomUnit( parent:GetAbsOrigin() + ActualRandomVector(800, 450) )
		end
	end
	
	function modifier_boss_evil_core_passive:DestroyShield()
		ParticleManager:ClearParticle(self.shield)
		self.shield = nil
	end
	
	function modifier_boss_evil_core_passive:SpawnAsura(position)
		local caster = self:GetCaster()
		for _,unit in pairs ( Entities:FindAllByName( "npc_dota_creature")) do
			if unit:GetTeamNumber() == DOTA_TEAM_BADGUYS and unit:GetUnitName() ~= "npc_dota_boss36" and unit:GetUnitName() ~= "npc_dota_boss36_guardian" then
				unit:ForceKill(true)
			end
		end
		local asura = CreateUnitByName( "npc_dota_boss36_guardian" , position, true, nil, nil, caster:GetTeam() )
		asura.Holdout_IsCore = true
		asura:AddNewModifier(caster, self:GetAbility(), "modifier_spawn_immunity", {duration = 3})
		self:Destroy()
		Timers:CreateTimer(0.1, function() caster:ForceKill(false) end)
		GameRules.holdOut:_RefreshPlayers()
		return true
	end
	
	function modifier_boss_evil_core_passive:SpawnRandomUnit(position)
		local spawnName = "npc_dota_boss31"
		local range = 0
		for name, weight in pairs( POSSIBLE_BOSSES ) do -- very rough weighted randoming, no idea how close to accurate it is
			range = range + weight
		end
		local picker = RandomInt(1, range)
		for name, weight in pairs ( POSSIBLE_BOSSES ) do
			if picker <= weight then -- falls into the weighted slot
				spawnName = name
				break
			else
				picker = picker - weight
			end
		end
		
		local spawnedUnit = CreateUnitByName( spawnName, position, true, nil, nil, self:GetCaster():GetTeam() )
		spawnedUnit:SetBaseMaxHealth(2000*GameRules.gameDifficulty)
		spawnedUnit:SetMaxHealth(2000*GameRules.gameDifficulty)
		spawnedUnit:SetHealth(spawnedUnit:GetMaxHealth())
		spawnedUnit:SetAverageBaseDamage(spawnedUnit:GetAverageBaseDamage() / 1.5, 20)
		
		if spawnName == "npc_dota_boss32_trueform" then
			spawnedUnit:FindAbilityByName("boss_meteor"):SetActivated(false)
		elseif spawnName == "npc_dota_boss34" then
			spawnedUnit:FindAbilityByName("boss_death_time"):SetActivated(false)
		elseif spawnName == "npc_dota_boss35" then
			spawnedUnit:FindAbilityByName("boss_doom_hell_tempest"):SetActivated(false)
			spawnedUnit:FindAbilityByName("boss_doom_demonic_servants"):SetActivated(false)
		end
		
		spawnedUnit:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_spawn_immunity", {duration = 2})
		spawnedUnit:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_silence_generic", {duration = 2 + RandomInt(4,6)})
	end
end

function modifier_boss_evil_core_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function modifier_boss_evil_core_passive:GetModifierIncomingDamage_Percentage( params )
	local parent = self:GetParent()
	if params.damage <= 0 then return end
	local damage = self.damageTaken * ((GameRules.BasePlayers - PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS)) + 1)
	if self.shield then damage = 1 end
	if parent:GetHealth() > damage then
		parent:SetHealth( math.max(1, parent:GetHealth() - damage) )
	elseif not self.asuraSpawn then
		self.asuraSpawn = self:SpawnAsura(self:GetParent():GetAbsOrigin())
	end
	return -999
end