modifier_stats_system_handler = class({})


-- OTHER
MOVESPEED_TABLE = {0,25,50,75,100,150}
MANA_TABLE = {0,3,6,9,12,18}
MANA_REGEN_TABLE = {0,5,10,15,20,30}
HEAL_AMP_TABLE = {0,20,40,60,80,120}

-- OFFENSE
ATTACK_DAMAGE_TABLE = {0,35,70,105,140,200}
SPELL_AMP_TABLE = {0,15,30,45,60,90}
COOLDOWN_REDUCTION_TABLE = {0,5,10,15,20,30}
ATTACK_SPEED_TABLE = {0,35,70,105,140,200}
STATUS_AMP_TABLE = {0,5,10,15,20,30}

-- DEFENSE
ARMOR_TABLE = {0,5,10,15,20,30}
MAGIC_RESIST_TABLE = {0,6,12,18,24,35}
DAMAGE_BLOCK_TABLE = {0,20,40,60,80,120}
ATTACK_RANGE_TABLE = {0,100,200,300,400,600}
HEALTH_TABLE = {0,2,4,6,8,12}
HEALTH_REGEN_TABLE = {0,5,10,15,20,30}
STATUS_REDUCTION_TABLE = {0,5,10,15,20,30}

ALL_STATS = 2

function modifier_stats_system_handler:OnCreated()
	self:OnIntervalThink()
	self:StartIntervalThink(0.5)
end

function modifier_stats_system_handler:OnIntervalThink()
	self:UpdateStatValues()
	if IsServer() then self:GetParent():CalculateStatBonus() end
end

function modifier_stats_system_handler:UpdateStatValues()
	-- OTHER
	local netTable = CustomNetTables:GetTableValue("stats_panel", tostring(self:GetCaster():entindex()) )
	self.ms = MOVESPEED_TABLE[tonumber(netTable["ms"]) + 1]
	self.mp = 400 + MANA_TABLE[tonumber(netTable["mp"]) + 1] * self:GetParent():GetIntellect()
	self.mpr = 4 + MANA_REGEN_TABLE[tonumber(netTable["mpr"]) + 1]
	self.ha = HEAL_AMP_TABLE[tonumber(netTable["ha"]) + 1]
	
	-- OFFENSE
	self.ad = ATTACK_DAMAGE_TABLE[tonumber(netTable["ad"]) + 1]
	self.sa = SPELL_AMP_TABLE[tonumber(netTable["sa"]) + 1]
	self.cdr = COOLDOWN_REDUCTION_TABLE[tonumber(netTable["cdr"]) + 1]
	self.as = ATTACK_SPEED_TABLE[tonumber(netTable["as"]) + 1]
	self.sta = STATUS_AMP_TABLE[tonumber(netTable["sta"]) + 1]
	
	-- DEFENSE
	self.pr = ARMOR_TABLE[tonumber(netTable["pr"]) + 1]
	self.mr = MAGIC_RESIST_TABLE[tonumber(netTable["mr"]) + 1]
	self.db = DAMAGE_BLOCK_TABLE[tonumber(netTable["db"]) + 1]
	self.ar = ATTACK_RANGE_TABLE[tonumber(netTable["ar"]) + 1]
	self.hp = 300 + HEALTH_TABLE[tonumber(netTable["hp"]) + 1] * self:GetParent():GetStrength()
	self.hpr = 5 + HEALTH_REGEN_TABLE[tonumber(netTable["hpr"]) + 1]
	self.sr = STATUS_REDUCTION_TABLE[tonumber(netTable["sr"]) + 1]
	
	self.allStats =  ALL_STATS * tonumber(netTable["all"])
end

function modifier_stats_system_handler:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
	}
	return funcs
end

function modifier_stats_system_handler:GetModifierMoveSpeedBonus_Constant() return self.ms end
function modifier_stats_system_handler:GetModifierManaBonus() return self.mp end
function modifier_stats_system_handler:GetModifierConstantManaRegen() return self.mpr end
function modifier_stats_system_handler:GetModifierHealAmplify_Percentage() return self.ha end

function modifier_stats_system_handler:GetModifierBaseAttack_BonusDamage() return self.ad end
function modifier_stats_system_handler:GetModifierSpellAmplify_Percentage() return self.sa end
function modifier_stats_system_handler:GetCooldownReduction() return self.cdr end
function modifier_stats_system_handler:GetModifierAttackSpeedBonus_Constant() return self.as end
function modifier_stats_system_handler:GetModifierStatusAmplify_Percentage() return self.sta end

function modifier_stats_system_handler:GetModifierPhysicalArmorBonus()
	local bonusarmor = 0
	if not self:GetParent():IsRangedAttacker() then bonusarmor = 6 end
	return self.pr + bonusarmor
end
function modifier_stats_system_handler:GetModifierMagicalResistanceBonus() return self.mr end

function modifier_stats_system_handler:GetModifierTotal_ConstantBlock(params) 
	if RollPercentage( 50 ) and not self:GetParent():IsRangedAttacker() and params.attacker ~= self:GetParent() then 
		return self.db
	end
end

function modifier_stats_system_handler:GetModifierAttackRangeBonus() 
	if self:GetParent():IsRangedAttacker() then 
		return self.ar
	end
end

function modifier_stats_system_handler:GetModifierHealthBonus() return self.hp end
function modifier_stats_system_handler:GetModifierConstantHealthRegen() return self.hpr end
function modifier_stats_system_handler:GetModifierStatusResistance() return self.sr end

function modifier_stats_system_handler:GetModifierBonusStats_Strength() return self.allStats end
function modifier_stats_system_handler:GetModifierBonusStats_Agility() return self.allStats end
function modifier_stats_system_handler:GetModifierBonusStats_Intellect() return self.allStats end

function modifier_stats_system_handler:IsHidden()
	return true
end

function modifier_stats_system_handler:IsPermanent()
	return true
end

function modifier_stats_system_handler:IsPurgable()
	return false
end

function modifier_stats_system_handler:RemoveOnDeath()
	return false
end

function modifier_stats_system_handler:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT
end