
function CelestialCurse(keys)
	local caster = keys.caster
	local target=keys.target
	local ability = keys.ability
	local modifier = "modifier_curse"

	if target:HasModifier(modifier) then
		ability:ApplyDataDrivenModifier(caster, target, modifier_2, {})
		local health = target:GetHealth()
		target:SetModifierStackCount(modifier, ability, health)
	end



end

function CurseTrigger(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local modifier = "modifier_curse"
	local modifier_3 = "modifier_health"
	local modifier_4 = "modifier_mental_thrusts_debuff"
	local modifier_5 = "modifier_mental_thrusts_reduction"
	local ability_partner = caster:FindAbilityByName("vardor_mental_thrusts")
	local divisor = ability:GetLevelSpecialValueFor("stack_divisor", ability_level)
	local target_teams = ability:GetAbilityTargetTeam()
	local target_types = ability:GetAbilityTargetType()
	local target_flags = ability:GetAbilityTargetFlags()

	local enemies_found = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, 2000, target_teams, target_types, target_flags, FIND_CLOSEST, false)
	for _,hero in pairs(enemies_found) do
		if hero:HasModifier(modifier) then
			target = hero
		end
	end
	if target:IsAlive() then
	if target:HasModifier(modifier) and (keys.attack_damage > 20) then
		local health_stack = target:GetModifierStackCount( modifier, ability)
		local health = target:GetHealth()
		if health_stack > health then
			ability:ApplyDataDrivenModifier(caster, caster, modifier_3, {})
			local save = caster:GetModifierStackCount( modifier_3, ability)
			local difference = (health_stack - health) + save
			if difference < divisor then
				caster:SetModifierStackCount(modifier_3, ability, difference)
			else
				local stacks = math.floor(difference / divisor)
				local current_stack = target:GetModifierStackCount(modifier_4, ability_partner)
				if current_stack < 0 then
					ability_partner:ApplyDataDrivenModifier( caster, target, modifier_4, {})
					target:SetModifierStackCount( modifier_4, ability_partner , current_stack + stacks)
				else
					ability_partner:ApplyDataDrivenModifier( caster, target, modifier_4, {})
					target:SetModifierStackCount( modifier_4, ability_partner, current_stack + stacks)
				end
				caster:SetModifierStackCount(modifier_3, ability, 0)
				target:SetModifierStackCount(modifier, ability, health)

				if target:HasModifier(modifier_5) then
					for i=1,current_stack do
					target:RemoveModifierByName(modifier_5)
					end
				end
				for i=1,current_stack do
					ability_partner:ApplyDataDrivenModifier( caster, target, modifier_5, { Duration = duration } )
				end
			end
		end
	end
	end
end

function CurseEndDamage(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local ability_level = ability:GetLevel() - 1
	local multi = ability:GetLevelSpecialValueFor("health_damage", ability_level)
	local ability_partner = caster:FindAbilityByName("vardor_mental_thrusts")
	local current_stack = target:GetModifierStackCount("modifier_mental_thrusts_debuff", ability_partner)

	local damage = current_stack * multi
	local dmg_Table = {
						victim = target,
						attacker = caster,
						damage = damage,
						damage_type = DAMAGE_TYPE_PURE,
						}

	print(damage)
	ApplyDamage(dmg_Table)
	
end
