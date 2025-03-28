include( "shared.lua" )

local volumeVar = CreateClientConVar( "exquisite_radio_cl_volume", 1, true, false, "Exquisite Radio volume, 0 to disable radio", 0, 1 )

function ENT:Draw()
    self:DrawModel()
end

local SongNames = {
    [0] = "Off",
    [1] = "Clair de lune - Claude Debussy",
    [2] = "Unaccompanied Cello Suite No. 1 in G major, BWV 1007: I. Prélude",
    [3] = "Chopin_Nocturne_op.9_No.2",
    [4] = "Moonlight Sonata - Beethoven",
    [5] = "Symphony No. 5 - Beethoven",
    [6] = "Funeral March - Chopin",
    [7] = "Morning Mood - Grieg",
    [8] = "In The Hall Of The Mountain King - Grieg",
    [9] = "Pachabelly - Huma-Huma",
    [10] = "Ride of the Valkyries - Wagner",
    [11] = "From Russia With Love - Huma-Huma",
    [12] = "Messiah - Handel",
    [13] = "Midsummer Night's Dream - Mendelssohn",
    [14] = "Serenade D957 No.4 - Schubert"

}

local uiScaleVert = ScrH() / 1080
local uiScaleHoris = ScrW() / 1920

function sizeScaled( sizeX, sizeY )
    if sizeX and sizeY then
        return sizeX * uiScaleHoris, sizeY * uiScaleVert

    elseif sizeX then
        return sizeX * uiScaleHoris

    elseif sizeY then
        return sizeY * uiScaleVert

    end
end

local input_IsKeyDown = input.IsKeyDown
local input_IsMouseDown = input.IsMouseDown

local justTabbedIn = false

local function ShutDownPanel( pnl )
    if pnl.exquisite_easyCloseFirst then
        pnl.exquisite_easyCloseFirst()

    end
    if not IsValid( pnl ) then return end
    pnl:Close()

end

function easyClosePanel( pnl, callFirst )
    pnl.keyWasDown = {}

    local clientsMenuKey = input.LookupBinding( "+menu" )
    if clientsMenuKey then
        clientsMenuKey = input.GetKeyCode( clientsMenuKey )
        pnl.keyWasDown[clientsMenuKey] = true
    end

    local clientsUseKey = input.LookupBinding( "+use" )
    if clientsUseKey then
        clientsUseKey = input.GetKeyCode( clientsUseKey )
        pnl.keyWasDown[clientsUseKey] = true
    end

    pnl.exquisiteOld_Think = pnl.Think

    pnl.exquisite_easyCloseFirst = callFirst

    function pnl:Think()
        if not system.HasFocus() then
            justTabbedIn = true
            self:exquisiteOld_Think()
            return

        end
        -- bail if they open any menu, or press use
        if input_IsKeyDown( KEY_ESCAPE ) then ShutDownPanel( self ) return end
        if clientsUseKey then
            if input_IsKeyDown( clientsUseKey ) then
                if not pnl.keyWasDown[clientsUseKey] then
                    ShutDownPanel( self )
                    return

                else
                    pnl.keyWasDown[clientsUseKey] = true

                end
            else
                pnl.keyWasDown[clientsUseKey] = nil

            end
        end

        if clientsMenuKey then
            if input_IsKeyDown( clientsMenuKey ) then
                if not pnl.keyWasDown[clientsMenuKey] then
                    ShutDownPanel( self )
                    return

                else
                    pnl.keyWasDown[clientsMenuKey] = true

                end
            else
                pnl.keyWasDown[clientsMenuKey] = nil

            end
        end

        if not input_IsMouseDown( MOUSE_LEFT ) and not input_IsMouseDown( MOUSE_RIGHT ) then
            self:exquisiteOld_Think()
            justTabbedIn = nil
            return

        end

        if justTabbedIn then return end

        -- close when clicking off menu
        local myX, myY = self:GetPos()
        local myWidth, myHeight = self:GetSize()
        local mouseX, mouseY = input.GetCursorPos()

        if mouseX < myX or mouseX > myX + myWidth then ShutDownPanel( self ) return end
        if mouseY < myY or mouseY > myY + myHeight then ShutDownPanel( self ) return end

        self:exquisiteOld_Think()

    end
end

local gotSongs
local knowsDisabled
local attempts = 0
local function doContent()
    local volume = volumeVar:GetFloat()
    if volume <= 0 then
        LocalPlayer():ChatPrint( "You've disabled the Exquisite Radio\n'exquisite_radio_cl_volume 1' to enable" )
        knowsDisabled = true
        return

    end

    if gotSongs then return end

    local exists = file.Exists( "sound/exquisite/exquisite1.mp3", "GAME" )
    if exists then
        gotSongs = true
        print( "Exquisite Radio: Songs already mounted." )
        return

    end

    if attempts >= 2 then return end
    attemtps = attempts + 1
    print( "Exquisite Radio: Mounting songs..." )

    steamworks.DownloadUGC( "1743176373", function( path )
        if not path then return end
        gotSongs = game.MountGMA( path )
        if gotSongs then
            print( "Exquisite Radio: Songs... mounted!" )

        else
            print( "Exquisite Radio: Mounting FAILURE!" )

        end
    end )
end

local upOff = Vector( 0, 0, 25 )
local color_white = Color( 255, 255, 255 )

function ENT:DrawUseHint() -- twolemons cfc spawnpoint pr
    local pos = self:GetPos() + upOff
    local ang = ( pos - EyePos() ):Angle()

    ang[1] = 0
    ang:RotateAroundAxis( ang:Up(), -90 )
    ang:RotateAroundAxis( ang:Forward(), 90 )

    cam.Start3D2D( pos, ang, 0.15 )
        draw.SimpleText( "Press E (45+ MB)", "CloseCaption_BoldItalic", 0, 0, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    cam.End3D2D()
end

function ENT:Draw()
    self:DrawModel()

    if gotSongs then return end
    if knowsDisabled then return end
    self:DrawUseHint()

end

function ENT:Initialize() -- dont display the hint if they are already subscribed on ws
    local exists = file.Exists( "sound/exquisite/exquisite1.mp3", "GAME" )
    if not exists then return end
    gotSongs = true

end

local nextRecieve = 0
local shopItemColor = Color( 73, 73, 73, 255 )
local Tuner

net.Receive( "OpenExquisiteRadioMenu", function()
    if nextRecieve > CurTime() then return end

    doContent()
    nextRecieve = CurTime() + 0.01

    local selfEnt = Entity( net.ReadUInt( 16 ) )
    local activeSong = net.ReadUInt( 16 )

    if Tuner and IsValid( Tuner ) then
        Tuner:Close()

    end

    Tuner = vgui.Create( "DFrame" )
    Tuner:SetSize( sizeScaled( 500, 75 ) )
    Tuner:SetTitle( "" )
    Tuner:SetVisible( true )
    Tuner:SetDraggable( false )
    Tuner:ShowCloseButton( true )
    Tuner:MakePopup()
    Tuner:Center()

    function Tuner:Paint( w, h )
        draw.RoundedBox( 0, 0, 0, w, h, shopItemColor )
    end

    easyClosePanel( Tuner )

    local SongSlider = vgui.Create( "DNumSlider", Tuner )
    local margin = sizeScaled( 15 )
    SongSlider:DockMargin( margin, margin, margin, margin )
    SongSlider:Dock( FILL )
    SongSlider:SetMin( 0 )
    SongSlider:SetMax( table.Count( SongNames ) + -1 )
    SongSlider:SetDecimals( 0 )
    SongSlider:SetValue( activeSong )
    SongSlider:SetText( "▶ " .. SongNames[math.Round( activeSong )] )
    SongSlider.OnValueChanged = function( _, val )
        SongSlider:SetText( "▶ " .. SongNames[math.Round( val )] )
        net.Start( "PlayExquisiteRadio" )
            net.WriteEntity( selfEnt )
            net.WriteUInt( math.Round( val ), 16 )

        net.SendToServer()
    end
end )

net.Receive( "ExquisiteRadioPlaySong", function()
    local volume = volumeVar:GetFloat()
    if volume <= 0 then return end

    local radio = net.ReadEntity()
    local songInd = net.ReadInt( 10 )
    local lvl = net.ReadInt( 8 )
    local pitch = net.ReadInt( 8 )
    local dsp = net.ReadInt( 8 )

    local lvlMul = 0.75 + ( volume * 0.25 ) -- decrease the lvl, but not to 0
    lvl = lvl * lvlMul

    radio:EmitSound( radio.Songs[ songInd ], lvl, pitch, volume, CHAN_ITEM, SND_NOFLAGS, dsp )

end )