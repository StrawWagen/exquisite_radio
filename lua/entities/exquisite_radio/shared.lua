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

function ENT:SetupDataTables()
    self:NetworkVar( "Int", 0, "Channel" )

end

ENT.Songs = {
    [0] = "ambient/_period.wav", -- no song
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
    [14] = "exquisite/exquisite14.mp3", -- Serenade D957 No.4 - Schubert

}