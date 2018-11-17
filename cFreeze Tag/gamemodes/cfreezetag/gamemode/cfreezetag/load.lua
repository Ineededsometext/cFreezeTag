-- Enumerations

ROUND_WAITING = 0
ROUND_IN_PROGRESS = 1
ROUND_RUNNERS_WIN = 2
ROUND_FREEZER_WIN = 3
ROUND_INTERMISSION = 4

TEAM_RUNNER = 0
TEAM_FREEZER = 1
TEAM_BOTH = 2

-- Master Table

FRZ = FRZ or {}
FRZ.RoundStatus = ROUND_WAITING
FRZ.Abilities = FRZ.Abilities or { 
	Freezer = {}, 
	Runner = {} 
}

-- Teams

team.SetUp( 1, "Runners", Color( 0, 100, 255 ) )
team.SetUp( 2, "Freezer", Color( 255, 25, 0 ) )
team.SetUp( 3, "Spectator", Color( 255, 255, 255 ) )

-- ConVars

CreateClientConVar( "frz_minimum_players", "2", true, true, "The minimum amount of players before the round starts." )
CreateClientConVar( "frz_round_time", "300", true, true, "How long will rounds last." )
CreateClientConVar( "frz_intermission_time", "30", true, true, "How long will intermissions last." )
CreateClientConVar( "frz_blind_time", "20", true, true, "How long will the freezer be blinded." )
CreateClientConVar( "frz_abilities_enabled", "1", true, true, "Should abilities be enabled?" )
CreateClientConVar( "frz_stamina_enabled", "1", true, true, "Should stamina be enabled?" )
CreateClientConVar( "frz_pushing_enabled", "0", true, true, "Should pushing be enabled?" )
CreateClientConVar( "frz_ability_cooldown", "30", true, false, "How long will the player wait for another ability." )
CreateClientConVar( "frz_runner_speed", "250", true, true, "The speed of the runners." )
CreateClientConVar( "frz_freezer_speed", "300", true, true, "The speed of the freezers." )
CreateClientConVar( "frz_player_stamina", "50", true, true, "The amount of player stamina." )

timer.Create( "[cFreezeTag] Console Variable Update", 0, 0, function()
    FRZ.MinimumPlayers = GetConVar( "frz_minimum_players" ):GetInt()
    FRZ.RoundTime = GetConVar( "frz_round_time" ):GetInt()
    FRZ.IntermissionTime = GetConVar( "frz_intermission_time" ):GetInt()
    FRZ.BlindTime = GetConVar( "frz_blind_time" ):GetInt()

    FRZ.AbilityCooldown = GetConVar( "frz_ability_cooldown" ):GetInt()
    FRZ.RunnerSpeed = GetConVar( "frz_runner_speed" ):GetInt()
    FRZ.FreezerSpeed = GetConVar( "frz_freezer_speed" ):GetInt()
    FRZ.PlayerStamina = GetConVar( "frz_player_stamina" ):GetInt()

    FRZ.AbilitiesEnabled = GetConVar( "frz_abilities_enabled" ):GetBool()
    FRZ.StaminaEnabled = GetConVar( "frz_stamina_enabled" ):GetBool()
    FRZ.PushEnabled = GetConVar( "frz_pushing_enabled" ):GetBool()
end )

-- Loading files..

local function LoadCore( dir )
	for k, v in pairs( file.Find( dir .. "/sv_*.lua", "LUA" ) ) do
		if ( SERVER ) then
			include( "core/" .. v )
		end
	end
		
	for k, v in pairs( file.Find( dir .. "/cl_*.lua", "LUA" ) ) do
		if ( SERVER ) then
			AddCSLuaFile( "core/" .. v )
		else
			include( "core/" .. v )
		end
	end
		
	for k, v in pairs( file.Find( dir .. "/sh_*.lua", "LUA" ) ) do
		if ( SERVER ) then
			AddCSLuaFile( "core/" .. v )
		end

		include( "core/" .. v )
	end
end

local function LoadModules( dir )
	for k, v in pairs( file.Find( dir .. "/sv_*.lua", "LUA" ) ) do
		if ( SERVER ) then
			include( "modules/" .. v )
		end
	end
		
	for k, v in pairs( file.Find( dir .. "/cl_*.lua", "LUA" ) ) do
		if ( SERVER ) then
			AddCSLuaFile( "modules/" .. v )
		else
			include( "modules/" .. v )
		end
	end
		
	for k, v in pairs( file.Find( dir .. "/sh_*.lua", "LUA" ) ) do
		if ( SERVER ) then
			AddCSLuaFile( "modules/" .. v )
		end

		include( "modules/" .. v )
	end
end

local function LoadAbilities( dir )
	for k, v in pairs( file.Find( dir .. "/*.lua", "LUA" ) ) do
		Ability = {}
	
		if ( SERVER ) then 
			AddCSLuaFile( "abilities/" .. v ) 
		end
		include( "abilities/" .. v )

		local class = string.gsub( v, ".lua", "" )

		if ( Ability.Team == TEAM_FREEZER ) then
			FRZ.Abilities[ "Freezer" ][ class ] = Ability
		elseif ( Ability.Team == TEAM_RUNNER ) then
			FRZ.Abilities[ "Runner" ][ class ] = Ability
		elseif ( class != "example" ) then
			FRZ.Abilities[ "Freezer" ][ class ] = Ability
			FRZ.Abilities[ "Runner" ][ class ] = Ability
		end
	end

	Ability = nil
end

LoadCore( "cfreezetag/gamemode/cfreezetag/core" )
LoadModules( "cfreezetag/gamemode/cfreezetag/modules" )
LoadAbilities( "cfreezetag/gamemode/cfreezetag/abilities" )

if ( SERVER ) then
    AddCSLuaFile( "cfreezetag/gamemode/cfreezetag/config.lua" )
end

include( "cfreezetag/gamemode/cfreezetag/config.lua" )

-- Finished loading!