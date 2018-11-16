FRZ.Blinded = false
FRZ.Time = 0
FRZ.TimeType = 0
FRZ.Stamina = 0
FRZ.StaminaLerp = 0
FRZ.AbilityName = ""
FRZ.AbilityIcon = "000"
FRZ.Scoreboard = false
FRZ.PlayerAvatars = {}

surface.CreateFont( "RoundInfo", {
    font = "calibri",
    size = ScreenScale( 10 ),
    antialiasing = true,
    shadow = true
} )

surface.CreateFont( "RoundTime", {
    font = "calibri",
    size = ScreenScale( 15 ),
    antialiasing = true,
    shadow = true
} )

surface.CreateFont( "Leaderboard", {
    font = "Calibri",
    size = ScreenScale( 10 ),
    antialiasing = true
} )

net.Receive( "AbilityCD", function()
    FRZ.OnCooldown = net.ReadBool()
    FRZ.AbilityCooldown = net.ReadFloat()
end )

function GM:HUDPaint()
    FRZ.HUDPaint()
end

function GM:ScoreboardHide()
	FRZ.Scoreboard = false
	
    for _, avatar in pairs( FRZ.PlayerAvatars ) do
        avatar:Remove()
    end
end

function GM:ScoreboardShow()
	FRZ.Scoreboard = true
end

net.Receive( "Blind", function()
    FRZ.Blinded = true
end )

net.Receive( "UnBlind", function()
    FRZ.Blinded = false
end )

net.Receive( "RoundStatus", function()
    FRZ.RoundStatus = net.ReadInt( 32 )
    FRZ.Freezer = net.ReadEntity()
end )

net.Receive( "Timers", function()
    FRZ.Time = net.ReadFloat()
    FRZ.TimeType = net.ReadInt( 32 )
end )

net.Receive( "Stamina", function()
    FRZ.Stamina = net.ReadFloat()
    FRZ.VeryTired = net.ReadBool()
end )

net.Receive( "Ability" , function()
    local name = net.ReadString()
    local icon = net.ReadString()

    if ( isstring( name ) and isstring( icon ) ) then
        FRZ.AbilityName = name
        FRZ.AbilityIcon = icon
    else
        FRZ.AbilityName = "ABILITY COOLDOWN"
        FRZ.AbilityIcon = " "
    end
end )