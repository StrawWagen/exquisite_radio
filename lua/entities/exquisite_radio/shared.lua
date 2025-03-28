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