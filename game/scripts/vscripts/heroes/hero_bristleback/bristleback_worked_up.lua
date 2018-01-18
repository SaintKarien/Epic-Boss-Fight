bristleback_worked_up = class({})
LinkLuaModifier( "modifier_worked_up", "heroes/hero_bristleback/bristleback_worked_up.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_worked_up_stack", "heroes/hero_bristleback/bristleback_worked_up.lua",LUA_MODIFIER_MOTION_NONE )

function bristleback_worked_up:GetIntrinsicModifierName()
	return "modifier_worked_up"
end

function bristleback_worked_up:OnUpgrade()
	if self:GetCaster():HasModifier("modifier_worked_up_stack") then
		local stacks = self:GetCaster():FindModifierByName("modifier_worked_up_stack"):GetStackCount()
		self:GetCaster():RemoveModifierByName("modifier_worked_up_stack")
		local new = self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_worked_up_stack", {Duration = self:GetTalentSpecialValueFor("duration")})
		new:SetStackCount(stacks)
	end
end

modifier_worked_up = class({})
function modifier_worked_up:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_SPENT_MANA
	}
	return funcs
end

function modifier_worked_up:OnSpentMana(params)
	if IsServer() then
		if params.unit == self:GetCaster() then
			if params.unit:HasModifier("modifier_worked_up_stack") then
				if params.unit:FindModifierByName("modifier_worked_up_stack"):GetStackCount() < self:GetTalentSpecialValueFor("max_stacks") then
					params.unit:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_worked_up_stack", {Duration = self:GetTalentSpecialValueFor("duration")}):IncrementStackCount()
				else
					params.unit:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_worked_up_stack", {Duration = self:GetTalentSpecialValueFor("duration")})
				end
			else
				params.unit:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_worked_up_stack", {Duration = self:GetTalentSpecialValueFor("duration")}):IncrementStackCount()
			end
		end
	end
end

function modifier_worked_up:IsHidden()
	return true
end

modifier_worked_up_stack = class({})
function modifier_worked_up_stack:OnCreated(table)
	if IsServer() then
		self.nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_bristleback/bristleback_warpath.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControlEnt(self.nfx, 3, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetCaster():GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(self.nfx, 4, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack2", self:GetCaster():GetAbsOrigin(), true)
	end
end

function modifier_worked_up_stack:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MODEL_SCALE
	}
	return funcs
end

function modifier_worked_up_stack:GetModifierBonusStats_Strength()
	return self:GetTalentSpecialValueFor("bonus_strength") * self:GetStackCount()
end

function modifier_worked_up_stack:GetModifierMoveSpeedBonus_Percentage()
	return self:GetTalentSpecialValueFor("bonus_ms") * self:GetStackCount()
end

function modifier_worked_up_stack:GetModifierAttackSpeedBonus_Constant()
	return self:GetTalentSpecialValueFor("bonus_as") * self:GetStackCount()
end

function modifier_worked_up_stack:GetModifierModelScale()
	return self:GetStackCount()*5
end

function modifier_worked_up_stack:OnRemoved()
	if IsServer() then
		ParticleManager:DestroyParticle(self.nfx, false)

		local count = self:GetStackCount()
		if self:GetStackCount() > 0 and self:GetParent():IsAlive() then
			self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_worked_up_stack", {Duration = self:GetTalentSpecialValueFor("duration")}):SetStackCount(count-1)
		else
			self:Destroy()
		end
	end
end

function modifier_worked_up_stack:IsDebuff()
	return false
end

function modifier_worked_up_stack:GetEffectName()
	return "particles/units/heroes/hero_bristleback/bristleback_warpath_dust.vpcf"
end