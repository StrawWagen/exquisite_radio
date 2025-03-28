AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

resource.AddWorkshop( "3453321951" ) -- songs + spawnicon

ENT.Songs = {
    [0] = "ambient/_period.wav",
    [1] = "exquisite/exquisite1.mp3", -- Clair de lune - Claude Debussy
    [2] = "exquisite/exquisite2.mp3", -- Unaccompanied Cello Suite No. 1 in G major, BWV 1007: I. Prélude
    [3] = "exquisite/exquisite3.mp3", -- Chopin_Nocturne_op.9_No.2
    [4] = "exquisite/exquisite4.mp3", -- Moonlight Sonata
    [5] = "exquisite/exquisite5.mp3", -- Symphony No. 5 - Beethoven
    [6] = "exquisite/exquisite6.mp3", -- Funeral March (by Chopin) - Chopin
    [7] = "exquisite/exquisite7.mp3", -- Morning Mood (by Grieg) - Grieg
    [8] = "exquisite/exquisite8.mp3", -- In The Hall Of The Mountain King (by Grieg) - Grieg
    [9] = "exquisite/exquisite9.mp3", -- Pachabelly - Huma-Huma
    [10] = "exquisite/exquisite10.mp3", -- Ride of the Valkyries - Wagner
    [11] = "exquisite/exquisite11.mp3", -- From Russia With Love - Huma-Huma
    [12] = "exquisite/exquisite12.mp3", -- Messiah - Handel
    [13] = "exquisite/exquisite13.mp3", -- Midsummer Night's Dream - Mendelssohn

}

-- YOU NEED TO EXPORT SONGS WITH CONSTANT BITRATE!!!!!!

util.AddNetworkString( "OpenExquisiteRadioMenu" )
util.AddNetworkString( "PlayExquisiteRadio" )

function ENT:Initialize()
    self:SetModel( "models/props_lab/citizenradio.mdl" )
    self:PhysicsInit( SOLID_VPHYSICS )
    self:SetMoveType( MOVETYPE_VPHYSICS )
    self:SetSolid( SOLID_VPHYSICS )

    local phys = self:GetPhysicsObject()
    if IsValid( phys ) then
        phys:Wake()
        phys:SetMass( 25 )

    end

    self:SetUseType( CONTINUOUS_USE )

    self.takenDamageTimes = 0
    self.nextTakeDamageTime = 0
    self.audioDSP = 0
    self.audioPitch = 100
    self.nextSoundHint = 0

    self.ActiveSong = 0

    self.nextResetGuiCreated = 0

end

function ENT:Use( _, caller )
    if not caller:IsPlayer() then return end

    self.nextResetGuiCreated = CurTime() + 0.15
    if self.createdGUI then return end

    self.createdGUI = true

    net.Start( "OpenExquisiteRadioMenu" )
        net.WriteUInt( self:EntIndex(), 16 )
        net.WriteUInt( self.ActiveSong, 16 )

    net.Send( caller )

end

function ENT:Think()
    if self.ActiveSong > 0 and self.nextSoundHint < CurTime() then
        self.nextSoundHint = CurTime() + 5
        local radius = 400
        if self.RadioBroken then
            radius = 200

        end
        sound.EmitHint( SOUND_COMBAT, self:GetPos(), radius, 1, self )
        if DYN_NPC_SQUADS and math.random( 0, 100 ) < 15 then
            DYN_NPC_SQUADS.SaveReinforcePointAllNpcTeams( self:GetPos(), nil, 0 )

        end
    end

    if self.ActiveSong > 0 and self:WaterLevel() >= 3 then
        self.takenDamageTimes = self.takenDamageTimes + 1
        if self.takenDamageTimes == 14 then
            self:TakeDamageRandomizeSong( true )

        end
    end

    if self.nextResetGuiCreated > CurTime() then return end
    self.nextResetGuiCreated = math.huge
    self.createdGUI = nil

end

local nextRecieve = 0

net.Receive( "PlayExquisiteRadio", function()
    if nextRecieve > CurTime() then return end
    nextRecieve = CurTime() + 0.005

    local selfEnt = net.ReadEntity()
    local songIndex = net.ReadUInt( 16 )

    if not IsValid( selfEnt ) then nextRecieve = CurTime() + 0.1 return end

    selfEnt.spammingHints = true

    local lvl = 83
    if selfEnt.RadioBroken then
        lvl = 80

    end

    local filterAllPlayers = RecipientFilter()
    filterAllPlayers:AddAllPlayers()

    selfEnt:EmitSound( selfEnt.Songs[math.Round( songIndex )], lvl, selfEnt.audioPitch, 1, CHAN_ITEM, nil, selfEnt.audioDSP, filterAllPlayers )
    selfEnt.ActiveSong = math.Round( songIndex )

    selfEnt:DoNextSong()

end )

function ENT:OnRemove()
    local filterAllPlayers = RecipientFilter()
    filterAllPlayers:AddAllPlayers()

    self:EmitSound( "ambient/_period.wav", 75, 100, 1, CHAN_ITEM, nil, self.audioDSP, filterAllPlayers )

end

function ENT:TakeDamageRandomizeSong( damaged )
    local rand = math.random( 1, table.Count( self.Songs ) - 1 )

    local lvl = 83
    if self.RadioBroken then
        lvl = 80

    end

    local filterAllPlayers = RecipientFilter()
    filterAllPlayers:AddAllPlayers()

    self:EmitSound( self.Songs[rand], lvl, self.audioPitch, 1, CHAN_ITEM, nil, self.audioDSP, filterAllPlayers )
    self.ActiveSong = rand

    self:DoNextSong()

    if not damaged then return end

    self:EmitSound( "ambient/energy/spark" .. math.random( 1, 6 ) .. ".wav" )
    self.takenDamageTimes = self.takenDamageTimes + 1

    if self.takenDamageTimes < 15 then return end
    if self.takenDamageTimes == 15 then
        self.RadioBroken = true
        self:EmitSound( "ambient/energy/zap" .. math.random( 5, 6 ) .. ".wav", 75, 100, CHAN_STATIC )
        timer.Simple( math.Rand( 0.5, 1 ), function()
            if not IsValid( self ) then return end
            self:TakeDamageRandomizeSong()
            print( "a" )

        end )
    end
    self:EmitSound( "ambient/energy/zap" .. math.random( 1, 3 ) .. ".wav", 75, 100, CHAN_STATIC )
    local target = 55 + ( self.takenDamageTimes % 5 )
    self.audioDSP = target
    self.audioPitch = math.random( 98, 102 )

end

function ENT:DoNextSong()
    local timerName = "exquisite_radio_nextsong_" .. self:GetCreationID()
    timer.Remove( timerName )
    if self.ActiveSong <= 1 then return end

    local activePath = self.Songs[self.ActiveSong]
    local duration = SoundDuration( activePath )
    timer.Create( timerName, duration + 1, 1, function()
        if not IsValid( self ) then return end
        self:TakeDamageRandomizeSong( false )

    end )
end

function ENT:PhysicsCollide( data )
    if data.Speed < 750 then return end
    if self:IsPlayerHolding() then return end

    if self.nextTakeDamageTime > CurTime() then return end
    self.nextTakeDamageTime = CurTime() + 1

    self:TakeDamageRandomizeSong( true )

end

function ENT:OnTakeDamage( dmg )
    self:TakePhysicsDamage( dmg )

    if self.nextTakeDamageTime > CurTime() then return end
    self.nextTakeDamageTime = CurTime() + 0.1

    self:TakeDamageRandomizeSong( true )

end

local GAMEMODE = GAMEMODE or GM
if not GAMEMODE.RandomlySpawnEnt then return end

GAMEMODE:RandomlySpawnEnt( "exquisite_radio", 1, 1, 25 )