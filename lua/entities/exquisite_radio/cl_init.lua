include( "shared.lua" )

function ENT:Draw()
    self:DrawModel()
end

local SongNames = {
    [0] = "Off",
    [1] = "EXQUISITE1",
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
}

local nextRecieve = 0
local shopItemColor = Color( 73, 73, 73, 255 )
local Tuner

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
    if pnl.glee_easyCloseFirst then
        pnl.glee_easyCloseFirst()

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

    pnl.gleeOld_Think = pnl.Think

    pnl.glee_easyCloseFirst = callFirst

    function pnl:Think()
        if not system.HasFocus() then
            justTabbedIn = true
            self:gleeOld_Think()
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
            self:gleeOld_Think()
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

        self:gleeOld_Think()

    end
end


net.Receive( "OpenExquisiteRadioMenu", function()
    if nextRecieve > CurTime() then return end
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