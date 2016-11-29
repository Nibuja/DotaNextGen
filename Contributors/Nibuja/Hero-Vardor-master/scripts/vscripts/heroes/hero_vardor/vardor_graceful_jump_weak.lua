

function Jump(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local origin_point = caster:GetAbsOrigin()
    local target_point = keys.target_points[1]
    local difference_vector = target_point - origin_point
	local charge_speed = ability:GetLevelSpecialValueFor("speed", (ability:GetLevel() - 1)) * 1/30

    caster:Stop()
    ProjectileManager:ProjectileDodge(caster)

    ability:ApplyDataDrivenModifier(caster, caster, "modifier_movement", {Duration = 1} )

        -- Motion Controller Data
    ability.target = target
    ability.velocity = charge_speed
    ability.graceful_jump_z = 0
    ability.initial_distance = (GetGroundPosition(target:GetAbsOrigin(), target)-GetGroundPosition(caster:GetAbsOrigin(), caster)):Length2D()
    ability.traveled = 0

end

function OnMotionDone(caster, target, ability)
	
	--Emit Sound (if wanted)

	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_warlock/warlock_rainofchaos_start_ripple_fb_mid.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)

	DoDamage(caster, target, ability)

end

function DoDamage(caster, target, ability)

	local damage = ability:GetLevelSpecialValueFor("damage", (ability:GetLevel() - 1))
	dmg_Table = {
						attacker = caster,
						damage = damage,
						damage_type = DAMAGE_TYPE_MAGICAL,
						}

    local target_loc = target:GetAbsOrigin()
    local target_types = ability:GetAbilityTargetType()
    local target_flags = ability:GetAbilityTargetFlags() 
    local hero_search = FindUnitsInRadius(caster:GetTeamNumber(), target_loc, nil,  150, DOTA_UNIT_TARGET_TEAM_ENEMY, target_types,  target_flags, FIND_CLOSEST, false)
    for _,hero in pairs(hero_search) do
		dmg_Table.victim = hero
		ApplyDamage(dmg_Table)
	end
end


function JumpHorizonal( keys )
    -- Variables
    local caster = keys.target
    local ability = keys.ability
    local target = ability.target

    local target_loc = GetGroundPosition(target:GetAbsOrigin(), target)
    local caster_loc = GetGroundPosition(caster:GetAbsOrigin(), caster)
    local direction = (target_loc - caster_loc):Normalized()

    local max_distance = ability:GetLevelSpecialValueFor("max_range", ability:GetLevel()-1)


    -- Max distance break condition
    if (target_loc - caster_loc):Length2D() >= max_distance then
        caster:InterruptMotionControllers(true)
    end

    -- Moving the caster closer to the target until it reaches the enemy
    if (target_loc - caster_loc):Length2D() > 100 then
        -- caster:GetAbsOrigin() -> Ortsvektor | direction -> Vektor | velocity -> Nummer
        caster:SetAbsOrigin(caster:GetAbsOrigin() + direction * ability.velocity)
        ability.traveled = ability.traveled + ability.velocity
    else
        caster:InterruptMotionControllers(true)

        -- Move the caster to the ground
        caster:SetAbsOrigin(GetGroundPosition(caster:GetAbsOrigin(), caster))
    

    OnMotionDone(caster, target, ability)
    end
end


--[[Moves the caster on the vertical axis until movement is interrupted]]
function JumpVertical( keys )
    -- Variables
    local caster = keys.target
    local ability = keys.ability
    local target = ability.target
    local caster_loc = caster:GetAbsOrigin()
    local caster_loc_ground = GetGroundPosition(caster_loc, caster)

    -- If we happen to be under the ground just pop the caster up
    if caster_loc.z < caster_loc_ground.z then
        caster:SetAbsOrigin(caster_loc_ground)
    end

    -- For the first half of the distance the unit goes up and for the second half it goes down
    if ability.traveled < ability.initial_distance/2 then
        -- Go up
        -- This is to memorize the z point when it comes to cliffs and such although the division of speed by 2 isnt necessary, its more of a cosmetic thing
        ability.graceful_jump_z = ability.graceful_jump_z + ability.velocity/2
        -- Set the new location to the current ground location + the memorized z point
        caster:SetAbsOrigin(caster_loc_ground + Vector(0,0,ability.graceful_jump_z))
    elseif caster_loc.z > caster_loc_ground.z then
        -- Go down
        ability.graceful_jump_z = ability.graceful_jump_z - ability.velocity/2
        caster:SetAbsOrigin(caster_loc_ground + Vector(0,0,ability.graceful_jump_z))
    end

end


function OnUpgrade(keys)
    local caster = keys.caster
    local ability = keys.ability
    local ability_level = keys.ability:GetLevel()
    local sub_ability_name = "vardor_graceful_jump"
    local ability_handle = caster:FindAbilityByName(sub_ability_name)
    local sub_ability_level = ability_handle:GetLevel()

    if sub_ability_level ~= ability_level then
        ability_handle:SetLevel(ability_level)
    end
    
end
