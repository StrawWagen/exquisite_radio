
local newEvent = {
    defaultPercentChancePerMin = 0.005,

    navmeshEvent = true,
    variants = {
        {
            variantName = "the_exquisite_radio",
            getIsReadyFunc = nil,
            unspawnedStuff = {
                {
                    class = "exquisite_radio",
                    spawnAlgo = "steppedRandomRadius",
                    timeout = nil, -- no timeout since this will dissapear even if someone finds it rn

                }
            },
            thinkInterval = nil, -- makes it default to terminator_Extras.activeEventThinkInterval
            concludeOnMeet = true,
        },
    },
}

terminator_Extras.RegisterEvent( newEvent, "exquisite_radio" )