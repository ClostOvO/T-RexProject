--[[
    ================================================================================
    MODULE 04: PET FUSERY & MUTATIONS ENGINE
    Chilli Hub / Steal An Egg Automation Engine
    ================================================================================
    
    DESCRIPTION:
    Manages automated pet fusing and mutation consumables: loads selected pets
    into the fusion machine, manages briefings, handles reveals, and uses boss
    mutation consumables automatically based on priority filters.
    
    KEY REMOTES & MECHANISMS:
    - RF/Fusery/BeginFuse                       = Initiates fusion cycle
    - RF/Fusery/ConfirmBriefing                 = Confirms briefing dialog
    - RF/Fusery/LoadPet                         = Loads pet into slot
    - RF/Fusery/EjectPet                        = Removes pet from slot
    - RF/Fusery/FinishReveal                    = Finalizes fusion result
    - RF/BossMastery/AskUseMutationConsumable   = Applies mutation elixir/consumable
    ================================================================================
]]

ion ( ) local Hb=ChilliState ;
local Rb=Hb.mutPick ;
if Rb then
local vb,Pb=Q ( ) [Rb.uid],Kb ( ) ;
Hb=type ( vb ) == "table" and vb.Placement and d ( vb ) ;
for vb,vb in ipairs ( Hb and Rb.ks or {
} ) do
if Pb[vb]then if not ( Hb.ms[vb] ) then
if ( Xb.bad[Rb.uid..vb]or 0 ) <os.clock ( ) then
Hb.uid,Hb.k,Hb.tool=Rb.uid,vb,Pb[vb] ;
Hb.pick=true ;
return Hb ;
end ;
end ;
end ;
end ;
Pb=ChilliState ;
Pb.mutPick=nil ;
Xb.urgent=nil ;
Xb.soft=true ;
_b ( Hb and "Done with " ..Hb.n or "The chosen egg is gone" ) ;
end ;
Rb=Y[26] ;
if not ( Rb.mutate ) then
return ;
end ;
Rb=Vb ( Kb ( ) ) ;
if not Rb then
Xb.at=os.clock ( ) +5 ;
end ;
return Rb ;
end ;
local Hb= {
Boss=10,Scrambled=10,Nitro=10,Enchanted=100,Spectral=25,Alien=15,DarkMatter=30
} ;
pcall ( function ( ) local Kb,Rb=N.Shared:FindFirstChild ( "BossMasteryFlags" ,true ) ,N.Shared:FindFirstChild ( "ScrambleMutationFlags" ,true ) ;
Hb.Boss=require ( Kb ) .MutationConsumableSuccessPercent:Get ( ) ;
Hb.Nitro=Hb.Boss ;
Hb.Scrambled=require ( Rb ) .SuccessPercent:Get ( ) ;
end ) ;
local function Kb ( Rb,vb ) local Pb,cb=Gb ( Rb.uid ) ,ChilliState ;
local Bb=cb.eggPos ( Rb.uid ) ;
if Pb then
else
if Bb then
_b ( "Going to " ..Rb.n ) ;
cb=Vector3.new ;
if not ( tb ( Bb+cb ( 0,3,4 ) ,vb ) ) then
return ;
end ;
local xb=Pb ;
for Tb=1,15,1 do
xb=Gb ( Rb.uid ) ;
if xb then
break ;
end ;
task.wait ( 0.2 ) ;
end ;
Pb=xb ;
else
end ;
end ;
if not ( Pb ) then
Xb.bad[Rb.uid..Rb.k]=os.clock ( ) +30 ;
return _b ( Rb.n.. " is not in your pen" ) ;
end ;
cb=ChilliState ;
if not ( cb.needBody ( ) ) then
return _b ( "Turning visible to use " ..Sb[Rb.k] ) ;
end ;
_b ( "Mutating " ..Rb.n.. " with " ..Sb[Rb.k] ) ;
cb=Y[11] ;
cb ( "Mutating " ..Rb.n ) ;
Bb,cb=Vector3.new,Pb:GetPivot ( ) .Position+Vector3.new ( 0,3,4 ) ;
if not ( tb ( cb,vb ) ) then
return ;
end ;
vb=getHumanoid ;
cb=vb ( ) ;
if cb then
pcall ( cb.EquipTool,cb,Rb.tool ) ;
end ;
vb=LocalPlayer ;
if Rb.tool.Parent~=vb.Character then
pcall ( function ( ) local Gb ;
Gb,Rb.tool.Parent=LocalPlayer,LocalPlayer.Character ;
end ) ;
end ;
task.wait ( 0.3 ) ;
local Gb,vb=os.clock ( ) ,invokeServerWithTimeout ;
local Pb,Bb=vb ( "RF/BossMastery/AskUseMutationConsumable" ,Rb.uid ) ;
if Pb and type ( Bb ) == "table" and Bb.Success then
if Bb.Mutated then
_b ( Rb.n.. " got " ..Sb[Rb.k] ) ;
u ( "Mutated" ,Rb.n.. " got " ..Sb[Rb.k], "ok" ) ;
else
_b ( ( "%s roll missed on %s (%s%% chance)" ) :format ( Sb[Rb.k],Rb.n,tostring ( Hb[Rb.k]or "?" ) ) ) ;
end ;
else
Xb.bad[Rb.uid..Rb.k]=os.clock ( ) +600 ;
_b ( ( "%s refused on %s: %s" ) :format ( Sb[Rb.k],Rb.n,type ( Bb ) == "table" and tostring ( Bb.Message or "no reason" ) or "no answer" ) ) ;
end ;
task.wait ( math.max ( 0,1- ( os.clock ( ) -Gb ) ) ) ;
if cb then
pcall ( cb.UnequipTools,cb ) ;
end ;
return true ;
end ;
Xb.run=function ( Gb,Sb ) if Gb.pick then
return Kb ( Gb,Sb ) ;
end ;
local Hb ;
while Gb and ( Sb ( ) ) do
Hb=Kb ( Gb,Sb ) ;
Gb=Hb and Sb ( ) and Vb ( ) ;
end ;
return Hb ;
end ;
Xb.on=function ( ) local Gb=Y[26] ;
local Sb,Xb=Gb.mutate ;
if Sb then
Xb=Sb ;
else
Gb=ChilliState ;
Xb=Gb.mutPick~=nil ;
end ;
return Xb ;
end ;
end ) ;
S ( "20_farm#5" ,function ( ) local Gb,Sb=wb ( {
name= "Treadmill" ,mover=true,gap=2,pri=9,soft=true
} ) ,ChilliState ;
Sb.treadT=y ( Ib[ "Auto Treadmill" ], "Auto Treadmill" , "tread" ,false,function ( Xb ) if not ( Xb ) then
bb ( Gb ) ;
end ;
end ) ;
y ( Ib[ "Admin Treadmill" ], "Use Admin Treadmill" , "adminTread" ,false,function ( Xb ) if not ( Xb ) then
bb ( Gb ) ;
end ;
end ) ;
y ( Ib[ "Auto Treadmill" ], "Auto Watch Ads" , "watchAds" ,false ) ;
Sb=ChilliState ;
local Xb,Hb,Vb,Kb,_b=Sb.nostat,0,0,0 ;
local function Rb ( ) Hb=os.clock ( ) ;
local vb=ChilliState ;
vb.treadAt=Hb ;
vb=ChilliState ;
if vb.onAdmin then
Kb=0 ;
end ;
end ;
local vb=wb ( {
name= "SpeedInfo" ,gap=1,info=true
} ) ;
vb.on=function ( ) return true ;
end ;
vb.fn=function ( ) local vb=Y[64] ;
local Pb=vb ( ) ;
vb=Pb and tonumber ( Pb.Money ) ;
k ( "tst" ,Xb, {
[ "Speed power" ]=Pb and U ( Pb.SpeedPower ) or "--" ,Cash=vb and "$" ..U ( vb ) or "--"
} ) ;
Pb=LocalPlayer ;
vb=Pb:FindFirstChild ( "leaderstats" ) ;
vb=vb and ( vb:FindFirstChild ( "Speed" ) ) ;
vb=vb and tonumber ( vb.Value ) ;
if vb then
if _b then
if vb>_b then
Rb ( ) ;
end ;
end ;
end ;
_b=vb ;
end ;
local function Xb ( ) local _b,vb=workspace:FindFirstChild ( "AdminTreadmill" ) ,Y[26] ;
local Pb=vb.adminTread and ( _b or Yb ( ) ) ;
if Pb then
vb=_b and ( _b:FindFirstChild ( "Pad" ) or _b:FindFirstChildWhichIsA ( "BasePart" ,true ) ) ;
local cb,Bb=vb and vb.Position ;
if cb then
Bb=cb ;
else
local cb=Vector3.new ;
Bb= ( cb ( 540.05,68.6,-369.7 ) ) ;
end ;
return Bb,true ;
end ;
_b=Y[63] ;
vb,Pb=_b ( ) ,Y[26] ;
local _b,cb=Pb.tread and vb and vb.PlotFolder:FindFirstChild ( "TreadmillBottom" ) ;
if _b then
vb=Vector3.new ;
cb=vb ( _b.Position.X,72,_b.Position.Z ) ;
else
cb=_b ;
end ion ( ) local m=Rb ( ) ;
local tb,Nb=m.Counts or {
} ,ChilliState ;
local Gb=Nb.bfRec or {
} ;
local function Xb ( Vb ) Vb=math.max ( 0,math.floor ( Vb+0.5 ) ) ;
return ( "%d:%02d" ) :format ( Vb//60,Vb%60 ) ;
end ;
local Vb,Kb=tonumber ( workspace:GetAttribute ( "ButterflyBloomEndsAt" ) ) ,P ( ) ;
local _b,vb=workspace:GetAttribute ( "Event_ButterflyBloom" ) ==true and ( Vb and "Butterfly Bloom live, " ..Xb ( Vb-Kb ) .. " left" or "Butterfly Bloom live" ) or "Waiting for Butterfly Bloom" ,Y[26] ;
Xb=vb.bloom ;
vb,Vb=if Xb then
not Xb
else
"Off | " .._b ;
if vb then
Vb=vb ;
else
Kb,Xb=Y[4]==a ;
if Kb then
Nb=ChilliState ;
Xb=Nb.bfSay ;
else
Xb=Kb ;
end ;
if Xb then
local a=ChilliState ;
Vb=a.bfSay.. " | " .._b ;
else
Vb=Xb ;
end ;
end ;
local a,Nb=Vb or _b, {
} ;
Nb.Green=tb.Green ;
Nb.Blue=tb.Blue ;
Nb.Purple=tb.Purple ;
Nb.Golden=tb.Golden ;
Nb.Essence=m.Essence ;
W ( "bst" ,function ( ) if not ( Yb.st ) then
return ;
end ;
Yb.st.Set ( {
Text=a
} ) ;
local m ;
for a,tb in next,Yb.texts,nil do
local Xb=Gb[a]and ( "%d/%d" ) :format ( Nb[a]or 0,Gb[a] ) or tostring ( Nb[a]or 0 ) ;
if Yb.shown[a]~=Xb then
Yb.shown[a]=Xb ;
tb.Set ( {
Text=Xb
} ) ;
m=true ;
else
end ;
end ;
if m then
Yb.lay ( ) ;
end ;
end ) ;
end ;
local m,a,tb=Ib[ "Butterfly Bloom" ],false,false ;
local function Yb ( ) local Nb,Gb=Y[26],Y[26] ;
Nb.bfTrade,Gb.bfSmart=a and not tb,a and tb ;
o ( ) ;
end ;
local Nb,Gb=m:Toggle ( "Auto Trade Up" ,false,function ( Xb ) a=Xb ;
Yb ( ) ;
end ) , {
} ;
Sb,hb= {
"Emerald To Sapphire" , "Sapphire To Amethyst" , "Amethyst To Radiant"
} ,function ( a ) Gb= {
} ;
for Xb,Vb in ipairs ( a ) do
Xb=Gb ;
Xb[#Xb+1]=h[Vb:match ( "^(%a+)" ) ] ;
end ;
end ;
m:Dropdown ( "Trade Up Tiers" ,Sb, {
} ,hb,true,nil,Nb ) ;
m:Toggle ( "Smart Trade For Essence" ,false,function ( h ) tb=h ;
Yb ( ) ;
end ,nil,Nb ) ;
y ( m, "Auto Craft Essence" , "bfCraft" ,false ) ;
local h,m= {
Green=10,Blue=10,Purple=50
} , {
Green=240,Blue=115,Purple=40,Golden=1
} ;
pcall ( function ( ) local a,tb=require ( N.Shared.Flags.ButterflyFlags ) , {
Green= "GreenToBlueCost" ,Blue= "BlueToPurpleCost" ,Purple= "PurpleToGoldenCost"
} ;
for Yb,Nb in next,tb,nil do
h[Yb]=tonumber ( a[Nb]:Get ( ) ) or h[Yb] ;
end ;
for tb in next,m,nil do
m[tb]=tonumber ( a[ "Essence" ..tb]:Get ( ) ) or m[tb] ;
end ;
end ) ;
hb=ChilliState ;
hb.bfRec=m ;
local function a ( hb ) for tb,Yb in next,m,nil do
if ( hb[tb]or 0 ) <Yb then
return false ;
end ;
end ;
return true ;
end ;
local function hb ( tb ) local Yb,Nb,Xb,Vb=tb.Green or 0,tb.Blue or 0,tb.Purple or 0,tb.Golden or 0 ;
for Kb=60,1,-1 do
tb=math.max ( 0,Kb*m.Golden-Vb ) ;
local Vb=math.max ( 0,Kb*m.Purple+h.Purple*tb-Xb ) ;
local Xb=math.max ( 0,Kb*m.Blue+h.Blue*Vb-Nb ) ;
if Yb>=Kb*m.Green+h.Green*Xb then
return {
Green=Xb,Blue=Vb,Purple=tb
} ;
end ;
end ;
end ;
local tb=wb ( {
name= "Machine" ,mover=true,gap=20,pri=6,soft=true
} ) ;
tb.on=function ( ) local Yb=Y[26] ;
local Nb,Xb=Yb.bfTrade ;
if Nb then
Xb=Nb ;
else
Yb=Y[26] ;
Xb=Yb.bfSmart ;
end ;
Nb=nil ;
if Xb then
Nb=Xb ;
else
Yb=Y[26] ;
Nb=Yb.bfCraft ;
end ;
return Nb ;
end ;
tb.want=function ( ) if Hb ( ) then
return ;
else
local Yb=LocalPlayer ;
if Yb:GetAttribute ( "EnchantedTreeUnlocked" ) ~=true then
return ;
end ;
end ;
local Yb,Nb=Rb ( ) .Counts or {
} ,Y[26] ;
if Nb.bfCraft then
if a ( Yb ) then
return true ;
end ;
end ;
Nb=Y[26] ;
if Nb.bfSmart then
local Nb=hb ( Yb ) ;
return Nb and Nb.Green+Nb.Blue+Nb.Purple>0 or nil ;
end ;
local Nb,Xb=ipairs,Gb ;
for Hb,Vb in Nb ( Xb ) do
Hb=Y[26] ;
if Hb.bfTrade then
local Nb,Nb=Y[26], ( Yb[Vb]or 0 ) - ( Y[26].bfCraft and m[Vb]or 0 ) ;
if Nb>=h[Vb]then return true ;
end ;
end ;
end ;
end ;
local function Yb ( Nb ) local Xb=LocalPlayer ;
if Xb:GetAttribute ( "InEnchantedTree" ) then
return true ;
end ;
Xb=getWorldInstance ;
local Hb=Xb ( "Build" , "EnchantedTreeInterior" , "Markers" , "EnterTrigger" , "EnchantedTreeEntrance" , "EnchantedTreePrompt" ) ;
Xb=Hb and Hb.Parent ;
local Vb=Xb and ( Xb:IsA ( "Attachment" ) and Xb.WorldPosition or Xb:IsA ( "BasePart" ) and Xb.Position ) ;
if not ( Vb ) then
return false ;
end ;
Xb=LocalPlayer ;
local Kb=Xb.Character ;
local function _b ( ) local vb=Nb ( ) ;
local Nb ;
if vb then
local Pb=LocalPlayer ;
Nb=Pb.Character==Kb ;
else
Nb=vb ;
end ;
return Nb ;
end ;
if not ( qb ( _b ) ) then
return false ;
end ;
Xb=getRootPart ;
local Nb=Xb ( ) ;
if Nb then
Xb=isInsideSafeZone ;
if Xb ( Nb.Position ) then
local vb=Y[17] ;
if not ( vb ( _b, "Enchanted Tree" ,0.3 ) ) then
return false ;
end ;
end ;
end ;
if not ( qb ( _b ) ) then
return false ;
end ;
Xb=Vector3.new ;
Nb=Vb+Xb ( 0,0,-12 ) ;
for vb=1,2,1 do
vb=getRootPart ;
Xb=vb ( ) ;
if Xb then
if _b ( ) then
if e ( ) >0 then
if not ( ( Xb.Position-Nb ) .Magnitude>500 ) then
break ;
end ;
else
break ;
end ;
else
break ;
end ;
else
break ;
end ;
vb=Y[11] ;
vb ( "Ragdoll TP to the Enchanted Tree" ) ;
vb=Vector3.new ;
zb ( Nb+vb ( 0,3,0 ) ,_b ) ;
end ;
Xb=LocalPlayer ;
if Xb.Character~=Kb then
return false ;
end ;
Xb=getRootPart ;
local Kb=Xb ( ) ;
if Kb then
if ( Kb.Position-Nb ) .Magnitude>60 then
if not ( Fb ( {
Pos=Nb,Name= "the tree"
} ,_b ) ) then
return false ;
end ;
end ;
end ;
for vb=1,4,1 do
_b,vb,Kb=setPlayerCFrame,CFrame.new,Vector3.new ;
_b ( vb ( Vb+Kb ( 0,3,-6 ) ) ) ;
pcall ( fireproximityprompt,Hb ) ;
Nb=os.clock ( ) +4 ;
while true do
vb,Xb=os.clock ( ) <Nb ;
if vb then
local Nb=LocalPlayer ;
Xb=not Nb:e if wb<91 then
if wb<86 then
if wb>=83 then
if wb>=84 then
if wb==85 then
f[A[Y]]=f[h[Y]]-t[Y] ;
else
H,B,Z=h[Y],A[Y],G[Y] ;
U=f[H] ;
J ( f,H+1,H+B,Z+1,U ) ;
end ;
else
H=A[Y] ;
f[H],f[H+1]=z[Y],t[Y] ;
f[h[Y+1]]=f[A[Y+1]] ;
H=G[Y+2] ;
B,Z,U=f[H],f[H+1],f[H+2] ;
f[H]=B ( Z,U ) ;
f[h[Y+3]]=f[A[Y+3]][f[G[Y+3]]] ;
Y=Y+3 ;
end ;
else
if wb==82 then
f[h[Y]]=b[Y]+t[Y] ;
else
f[h[Y]]=e ( f[A[Y]],G[Y] ) ;
end ;
end ;
else
if wb>=88 then
if wb<89 then
f[G[Y]]=f[h[Y]]+f[A[Y]] ;
elseif
wb~=90 then
local bb,hb,tb=G[Y],b[Y],z[Y] ;
local zb,Yb=i ( hb,42949672 