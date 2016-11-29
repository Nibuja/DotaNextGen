--Hero: Vardor
--Ability: Mental Thrusts
--Author: Nibuja
--Date: 11.09.2016 

--[[ MentalThrustsHit:
Increases the Stack counter each time of landed Attack
]]
function MentalThrustsHit(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local modifier_1 = "modifier_mental_thrusts_debuff" 
	local modifier_2 = "modifier_mental_thrusts_reduction"
	local modifier_3 = "modifier_yari_throw"
	local ability_level = ability:GetLevel() - 1

	local duration = ability:GetLevelSpecialValueFor("duration", ability_level) 
	local max_health = target:GetMaxHealth()

	if (target:IsHero()) and (target:IsAlive()) and (max_health > 15) and (not caster:IsIllusion()) and (not caster:HasModifier(modifier_3)) then
		if target:HasModifier(modifier_1) then
			current_stack = target:GetModifierStackCount(modifier_1, ability) + 1

			ability:ApplyDataDrivenModifier( caster, target, modifier_1, { Duration = duration } )
			target:SetModifierStackCount( modifier_1, ability, current_stack)
		else
			ability:ApplyDataDrivenModifier( caster, target, modifier_1, { Duration = duration } )
			target:SetModifierStackCount( modifier_1, ability, 1 )

			current_stack = 1
		end
		if target:HasModifier(modifier_2) then
			for i=1,current_stack do
				target:RemoveModifierByName(modifier_2)
			end
		end
		for i=1,current_stack do
			ability:ApplyDataDrivenModifier( caster, target, modifier_2, { Duration = duration } )
		end
	end
end
