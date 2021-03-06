relic_unique_memory_alloy = class({})

function relic_unique_memory_alloy:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE }
end

function relic_unique_memory_alloy:OnTakeDamage(params)
	if params.unit == self:GetParent() and not ( HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) or HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) )  then
		local healticks = math.ceil(40 / 0.33)
		local healpTick = params.damage / healticks

		local parent = self:GetParent()
		Timers:CreateTimer(0.33, function()
			healticks = healticks - 1
			parent:HealEvent(healpTick, nil, parent, true)
			if healticks > 0 then
				return 0.33
			end
		end)
	end
end

function relic_unique_memory_alloy:IsHidden()
	return self:GetStackCount() == 0
end

function relic_unique_memory_alloy:IsPurgable()
	return false
end

function relic_unique_memory_alloy:RemoveOnDeath()
	return false
end

function relic_unique_memory_alloy:IsPermanent()
	return true
end

function relic_unique_memory_alloy:AllowIllusionDuplicate()
	return true
end

function relic_unique_memory_alloy:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end