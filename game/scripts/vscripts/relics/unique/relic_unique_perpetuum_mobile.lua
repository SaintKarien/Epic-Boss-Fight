relic_unique_perpetuum_mobile = class({})

function relic_unique_perpetuum_mobile:DeclareFunctions()
	return {MODIFIER_EVENT_ON_SPENT_MANA}
end

function relic_unique_perpetuum_mobile:OnSpentMana(params)
	if params.unit == self:GetParent() then
		SendOverheadEventMessage(self:GetParent(), OVERHEAD_ALERT_MANA_ADD , self:GetParent(), 10, self:GetParent())
		self:GetParent():GiveMana(10)
	end
end

function relic_unique_perpetuum_mobile:IsHidden()
	return true
end

function relic_unique_perpetuum_mobile:IsPurgable()
	return false
end

function relic_unique_perpetuum_mobile:RemoveOnDeath()
	return false
end

function relic_unique_perpetuum_mobile:IsPermanent()
	return true
end

function relic_unique_perpetuum_mobile:AllowIllusionDuplicate()
	return true
end

function relic_unique_perpetuum_mobile:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

