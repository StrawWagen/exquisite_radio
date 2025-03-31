ENT.Type = "anim"
ENT.Base = "base_anim"

-- CREDITS!
-- First was from Swept's Radios 2 https://steamcommunity.com/sharedfiles/filedetails/?id=1368958015 by SweptThrone
-- Then modified/rewritten for Hunter's Glee by StrawWagen
-- Credit to the Exquisite Radio inspiration goes to mathias4044 and his exquisite "the weight of flowing water" piece 

ENT.PrintName = "Exquisite Radio"
ENT.Author = "StrawWagen + mathias4044"
ENT.Purpose = "Play some EXQUISITE music."
ENT.Instructions = "Press E to play music."
ENT.Category = "Fun + Games"
ENT.Spawnable = true
ENT.Editable    = true

function ENT:SetupDataTables()
    local i = 1
    self:NetworkVar( "Int", "Channel" )
    self:NetworkVar( "Bool", "Unbreakable", { KeyName = "unbreakable", Edit = { order = i + 1, type = "Bool" } } )
    self:NetworkVar( "Bool", "CreatorOnly", { KeyName = "creatoronly", Edit = { order = i + 1, type = "Bool", title = "Only changable by it's owner?" } } )
    self:NetworkVar( "Bool", "ShowSongName", { KeyName = "showsongname", Edit = { order = i + 1, type = "Bool", title = "Show current song name?" } } )

end

ENT.Songs = {
    [0] = { song = "ambient/_period.wav", name = "Off" }, -- no song
    [1] = { song = "exquisite/exquisite1.mp3", name = "Clair de lune - Claude Debussy" },
    [2] = { song = "exquisite/exquisite2.mp3", name = "Unaccompanied Cello Suite No. 1 in G major, BWV 1007: I. Prélude" },
    [3] = { song = "exquisite/exquisite3.mp3", name = "Chopin_Nocturne_op.9_No.2" },
    [4] = { song = "exquisite/exquisite4.mp3", name = "Moonlight Sonata" },
    [5] = { song = "exquisite/exquisite5.mp3", name = "Symphony No. 5 - Beethoven" },
    [6] = { song = "exquisite/exquisite6.mp3", name = "Funeral March - Chopin" },
    [7] = { song = "exquisite/exquisite7.mp3", name = "Morning Mood - Grieg" },
    [8] = { song = "exquisite/exquisite8.mp3", name = "In The Hall Of The Mountain King - Grieg" },
    [9] = { song = "exquisite/exquisite9.mp3", name = "Pachabelly - Huma-Huma" },
    [10] = { song = "exquisite/exquisite10.mp3", name = "Ride of the Valkyries - Wagner" },
    [11] = { song = "exquisite/exquisite11.mp3", name = "From Russia With Love - Huma-Huma" },
    [12] = { song = "exquisite/exquisite12.mp3", name = "Messiah - Handel" },
    [13] = { song = "exquisite/exquisite13.mp3", name = "Midsummer Night's Dream - Mendelssohn" },
    [14] = { song = "exquisite/exquisite14.mp3", name = "Serenade D957 No.4 - Schubert" },
    [15] = { song = "exquisite/exquisite15.mp3", name = "Prelude Op. 28 no. 15 - Chopin" },
    [15] = { song = "exquisite/exquisite16.mp3", name = "Hungarian Dance No. 5 - Johannes Brahms" },

}

--[[
    [] = { song = "", name = "" },
--]]