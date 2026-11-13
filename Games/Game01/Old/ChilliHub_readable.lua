f.wispSay = j
local q = f.nostat
s.on = function()
    local sb = O[26]
    return sb.wisp or N("Event")
end

local sb = f.Wisp

local function ib()
    local Ob = O[64]
    local db = Ob()
    Ob = db and db.WispCompanion
    return db, type(Ob) == "table" and Ob or nil
end

local function Ob(db)
    if not db then return end
    if db.Accepted then
        if db.Unlocked then return end
    else
        return
    end
    return (type(sb) == "table" and sb.List or {})[tonumber(db.Stage) or 1]
end

local function db(Yb, ob)
    return type(Yb.Progress) == "table"
        and tonumber(Yb.Progress[ob.Id]) or 0
end

local function Yb(ob, cb)
    return type(ob.Claimed) == "table" and ob.Claimed[cb.Id]
end

-- ... [Auto-Steal, Treadmill, Wisp Quest, Bloom, Star, Banjo, Combat,
--      Alien/Fishing, Island Wars, ESP, Predictor, Fuse Predictor,
--      HUD, Finder, Priority queue, Egg Predictor] all as in the original
--      (all readable, only variable names are mangled) ...

-- The readable half ends right before this line, which is the VM entry:
-- local t1 = function(G, G, l, s, i, X) if s <= 0 then ...