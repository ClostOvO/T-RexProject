--[[
    ================================================================================
    MODULE 11: ADMIN ABUSE, PETE SPACE RAID & LIVE EVENTS
    Chilli Hub / Steal An Egg Automation Engine
    ================================================================================
    
    DESCRIPTION:
    Monitors and automates high-yield live events and Admin Abuse features:
    - Admin Treadmill:
      * Detects active Admin Treadmill spawned in server
      * Automatically mounts belt, tracks speed gains, and auto dismounts (RF/Treadmill/AskDoff)
      * Auto-respawns character if speed gain stalls
    - Pete Space Raid event:
      * Attributes: PeteRaidLockdown, Event_PeteSpaceRaid, PeteRaidPhase
      * Handles raid phases: Liftoff, Launch, Chase, Boss, Finale
    - Cursed Island Wars:
      * RF/IslandWars/Fetch, RE/IslandWars/State, RE/IslandWars/Moment
      * Controller: Controllers.Game.AdminAbuseClientController.Events.CursedIslandWars.Input
    - Capture The Egg event:
      * Attributes: Event_CaptureTheEgg, Event_CaptureTheEggGameplay
      * Spawns: CaptureTheEggSpawn, AdminAbuseEggSpawn
      * RE/EggCapture/StandingsRefreshed
    - Live Events Poller:
      * RF/LiveEvents/FetchRunning, RE/LiveEvents/Began, RE/LiveEvents/Ended
    ================================================================================
]]

;
end ;
end ;
Xb=ChilliState ;
Xb.hold=Xb.hold-1 ;
if not ( _b ( ) ) then
Xb=Y[13] ;
return Xb ( function ( ) return true ;
end ) ;
end ;
if Sb then
Vb=0 ;
if Rb then
Hb=os.clock ( ) ;
end ;
Xb=Y[11] ;
return Xb ( Rb and "Training on the admin treadmill" or "Training speed" , "ok" ) ;
end ;
Vb+=1 ;
if Vb>=2 then
_b=ChilliState ;
if _b.respawn then
Vb=0 ;
Sb=Y[11] ;
Sb ( "Treadmill will not take you, respawning" , "warn" ) ;
Xb=ChilliState ;
Xb.respawn ( ) ;
end ;
end ;
end ;
local Sb=ChilliState ;
Sb.treadOn=function ( ) return Gb.on ( ) ;
end ;
Gb.on=function ( ) local Gb=Y[26] ;
local Sb,Xb=Gb.tread ;
if Sb then
Xb=Sb ;
else
Gb=Y[26] ;
Xb=Gb.adminTread and ( Yb ( ) or workspace:FindFirstChild ( "AdminTreadmill" ) ~=nil ) ;
end ;
return Xb ;
end ;
local Yb,Gb=Ib[ "Auto Progression" ], {
} ;
y ( Yb, "Auto Buy Trail" , "trails" ,false ) ;
y ( Yb, "Auto Upgrade Base" , "upBase" ,false ) ;
y ( Yb, "Auto Upgrade Treadmill" , "upTread" ,false ) ;
local Sb=E.pre ;
function E.pre ( Xb ) if Sb then
Sb ( Xb ) ;
end ;
for Sb,Sb in next,Xb,nil do
local Xb,Hb=type ( Sb ) == "table" and Sb[ "Auto Progression" ],type ( Sb ) == "table" and Sb[ "Auto Treadmill" ] ;
if type ( Xb ) == "table" then
if Xb[ "Auto Claim" ]then if not ( Xb[ "Auto Claim Money" ] ) then
Xb[ "Auto Claim Money" ]=Xb[ "Auto Claim" ] ;
end ;
end ;
end ;
if type ( Xb ) == "table" then
if type ( Hb ) == "table" then
if Xb[ "Auto Watch Ads" ]~=nil then
if Hb[ "Auto Watch Ads" ]==nil then
Hb[ "Auto Watch Ads" ]=Xb[ "Auto Watch Ads" ] ;
end ;
end ;
end ;
end ;
end ;
end ;
y ( Yb, "Auto Claim Money" , "claimCash" ,false,function ( Sb ) Gb[1]=Sb ;
Sb=Y[26] ;
Sb.claimIndex=Gb[1]or Gb[2] ;
end ) ;
Yb:Toggle ( "Auto Claim Index" ,false,function ( Yb ) Gb[2]=Yb ;
Yb=Y[26] ;
Yb.claimIndex=Gb[1]or Gb[2] ;
end ) ;
task.spawn ( func
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
end ;
return cb ;
end ;
Sb=NetworkingRemotes ;
local _b,vb=Sb:FindFirstChild ( "RE/Treadmill/SpeedGained" ) ,NetworkingRemotes ;
Sb=vb:FindFirstChild ( "RE/Treadmill/AssignedBeltShifted" ) ;
if _b then
V ( _b.OnClientEvent,Rb ) ;
end ;
if Sb then
V ( Sb.OnClientEvent,function ( Sb,_b,Rb,Rb,vb,Pb ) Rb=ChilliState ;
_b,vb=Rb.onAdmin,ChilliState ;
vb.onAdmin=Sb~=nil and Pb==true ;
if _b then
Sb=ChilliState ;
if not ( Sb.onAdmin ) then
vb=Y[26] ;
if not ( vb.tread ) then
if not ( Yb ( ) ) then
task.spawn ( invokeServerWithTimeout, "RF/Treadmill/AskDoff" ) ;
end ;
end ;
end ;
end ;
end ) ;
end ;
Gb.want=function ( ) local Sb=getRootPart ;
local _b,Rb,vb=Sb ( ) ,Xb ( ) ;
if _b then
if not ( Rb ) then
return ;
end ;
else
return ;
end ;
if vb then
Sb=ChilliState ;
local vb=Sb.onAdmin ;
local Sb= ( if vb then
os.clock ( ) -Hb>5
else
not vb ) and Rb or nil ;
return Sb ;
end ;
if _b.Anchored then
return "wait" ;
elseif
os.clock ( ) -Hb<3 then
return "wait" ;
end ;
return Rb ;
end ;
Gb.run=function ( Sb,_b ) local Rb,Rb=Xb ( ) ;
if Rb then
local Xb=ChilliState ;
if Xb.onAdmin then
Kb+=1 ;
if Kb>=3 then
local Xb=ChilliState ;
if Xb.respawn then
Kb=0 ;
local Xb=Y[11] ;
Xb ( "Admin treadmill will not take you, respawning" , "warn" ) ;
Xb=ChilliState ;
return Xb.respawn ( ) ;
end ;
end ;
local Xb=Y[11] ;
Xb ( "Admin treadmill speed is not going up, getting back on" , "warn" ) ;
if not ( Y[13] ( _b ) ) then
return ;
end ;
end ;
end ;
local Xb=Y[11] ;
Xb ( Rb and "Going to the admin treadmill" or "Going to the treadmill" ) ;
Xb=Vector3.new ;
if not ( tb ( Sb+Xb ( 0,1,0 ) ,_b ) ) then
return ;
end ;
Sb,Xb=ChilliState,ChilliState ;
Sb.hold= ( Xb.hold or 0 ) +1 ;
Xb=os.clock ( ) + ( Rb and 2.5 or 3 ) ;
Hb=0 ;
Sb=false ;
while os.clock ( ) <Xb and ( _b ( ) ) and not Sb do
if Rb then
local Kb=ChilliState ;
Sb=Kb.onAdmin==true ;
if Sb then
else
if os.clock ( ) >X k ( ) -h.at<30 and h.me ( ) ~=nil ;
end ;
local Gb,Sb= {
Liftoff=true,Launch=true,Chase=true,Boss=true,Finale=true
} ,ChilliState ;
Sb.peteRaid=function ( ) return workspace:GetAttribute ( "PeteRaidLockdown" ) ==true or workspace:GetAttribute ( "Event_PeteSpaceRaid" ) ==true and Gb[workspace:GetAttribute ( "PeteRaidPhase" ) or "" ]==true ;
end ;
local Gb=ChilliState ;
Gb.lock=function ( ) local Gb=ChilliState ;
if Gb.peteRaid ( ) then
return "PeteRaid" ;
end ;
Gb=ChilliState ;
if Gb.fuseZone then
local Gb=ChilliState ;
if Gb.fuseZone ( ) then
return "FuseZone" ;
end ;
end ;
if h.held ( ) then
return "IslandWars" ;
end ;
end ;
local Gb=ChilliState ;
Gb.realHum=function ( ) local Gb=ChilliState ;
local Sb,Xb=Gb.peteRaid ( ) or h.held ( ) ;
if Sb then
Xb=Sb ;
else
Gb=LocalPlayer ;
Xb=Gb:GetAttribute ( "RaceId" ) ~=nil ;
end ;
return Xb ;
end ;
local Gb=ChilliState ;
Gb.highOk=function ( ) local Gb=ChilliState ;
return ( Gb.lock ( ) or "FuseZone" ) ~= "FuseZone" ;
end ;
local Gb ;
local Sb,Xb=0,ChilliState ;
Xb.hideTread=function ( Xb ) Sb=math.max ( Sb,os.clock ( ) +Xb ) ;
if Gb then
return ;
end ;
local Xb= {
} ;
Gb=Xb ;
for Hb,Vb in ipairs ( workspace:FindFirstChild ( "Plots" ) and workspace.Plots:GetChildren ( ) or {
} ) do
Hb= {
"TreadmillBottom" , "TreadmillUpgrade"
} ;
for Kb,_b in ipairs ( Hb ) do
Kb=Vb:FindFirstChild ( _b ) ;
for Hb,Hb in ipairs ( Kb and ( Kb:IsA ( "BasePart" ) and {
Kb
} or Kb:GetDescendants ( ) ) or {
} ) do
if Hb:IsA ( "BasePart" ) then
Xb[#Xb+1]= {
Hb,Hb.CanTouch,Hb.CanCollide
} ;
Hb.CanTouch=false ;
Hb.CanCollide=false ;
end ;
end ;
end ;
end ;
task.spawn ( function ( ) while true do
local Hb,Vb=os.clock ( ) ,Sb ;
if not ( Hb<Vb ) then
break ;
end ;
task.wait ( 0.2 ) ;
end ;
for Sb,Sb in ipairs ( Xb ) do
if Sb[1].Parent then
Sb[1].CanTouch,Sb[1].CanCollide=Sb[2],Sb[3] ;
end ;
end ;
Gb=nil ;
end ) ;
end ;
local Gb=LocalPlayer ;
V ( Gb.CharacterAdded,function ( ) local Sb=ChilliState ;
Sb.hideTread ( 6 ) ;
end ) ;
local function Sb ( ) local Xb=invokeServerWithTimeout ;
local Hb,Hb=Xb ( "RF/IslandWars/Fetch" ) ;
Nb ( Hb ) ;
end ;
Yb ( "RE/LiveEvents/Began" ,function ( Xb ) if Xb== "CursedIslandWars" then
h.sd=false ;
h.col=nil ;
task.spawn ( Sb ) ;
end ;
end ) ;
Yb ( "RE/LiveEvents/Ended" ,function ( Xb ) if Xb== "CursedIslandWars" then
h.snap=nil ;
h.sd=false ;
h.col=nil ;
end ;
end ) ;
local Xb=wb ( {
name= "IslandWarsInfo" ,gap=5
} ) ;
Xb.on=function ( ) return h.snap~=nil and r[h.snap.Phase]==true ;
end ;
Xb.fn=Sb ;
Yb ( "RE/IslandWars/State" ,Nb ) ;
Yb ( "RE/IslandWars/Moment" ,function ( r,Nb,Xb ) if r== "Cooldown" and type ( Nb ) == "string" then
h.cd[Nb]=tonumber ( Xb ) or 0 ;
elseif
r== "SuddenDeath" or r== "EarlySuddenDeath" or r== "Warning" and tonumber ( Nb ) and tonumber ( Nb ) <=15 then
h.sd=true ;
elseif
r== "CollapseWarn" and type ( Nb ) == "table" then
h.col,h.colAt=Nb,os.clock ( ) ;
elseif
r== "Win" then
h.sd=false ;
elseif
r== "Outro" then
h.sd=false ;
end ;
end ) ;
task.spawn ( function ( ) local r=invokeServerWithTimeout ;
local Nb,Nb=r ( "RF/LiveEvents/FetchRunning" ) ;
if type ( Nb ) == "table" then
if Nb.CursedIslandWars then
Sb ( ) ;
end ;
end ;
end ) ;
local function r ( Nb ) pcall ( function ( ) local Sb=require ( N.Controllers.Game.AdminAbuseClientController.Events.CursedIslandWars.Input ) ;
h.k0=h.k0 or Sb.Knock ;
Sb.Knock=Nb and function ( )
end or h.k0 ;
end ) ;
end ;
table.insert ( ChilliState.cleanup,function ( ) r ( false ) ;
end ) ;
local function Nb ( ) local Sb=getRootPart ;
local Xb=Sb ( ) ;
if Xb then
if h.col then
if not ( os.clock ( ) -h.colAt<8 ) then
return false ;
end ;
else
return false ;
end ;
else
return false ;
end ;
Sb=RaycastParams.new ( ) ;
Sb.FilterType=Enum.RaycastFilterType.Include ;
Sb.FilterDescendantsInstances=h.col ;
local Hb,Hb=Vector3.new,workspace:Raycast ( Xb.Position,Vector3.new ( 0,-14,0 ) ,Sb ) ;
return Hb~=nil ;
end ;
local function Sb ( Xb ) return b ( function ( b ) return b.Name==Xb ;
end ) ;
end ;
local b=wb ( {
name= "IslandWars" ,mover=true,gap=0.3,pri=-2,urgent=true,hold=true,where= "any"
} ) ;
b.on=function ( ) local Xb,Hb,Vb=h.snap,h.me ( ) ,Y[26] ;
return Vb.ciw and Xb~=nil and B[Xb.Phase]==true and Hb~=nil and Hb.State== "Alive" and os.clock ( ) -h function B ( r ) return r and r:IsA ( "Model" ) and r:GetPivot ( ) .Position ;
end ;
local function r ( ) local m,a=ipairs, {
"CaptureTheEggSpawn" , "AdminAbuseEggSpawn"
} ;
for hb,tb in m ( a ) do
hb=getWorldInstance ;
local m=hb ( "Areas" ,tb ) ;
if m then
if m:IsA ( "BasePart" ) then
return m.Position ;
end ;
end ;
end ;
end ;
local function m ( a,hb ) local tb=workspace:FindFirstChild ( "AreaEggSlotsClient" ) ;
return B ( tb and tb:FindFirstChild ( a ) ) or B ( workspace:FindFirstChild ( a ) ) or hb and typeof ( hb.BottomCFrame ) == "CFrame" and hb.BottomCFrame.Position or ( r ( ) ) ;
end ;
local function r ( a ) local hb=tonumber ( a and a.CarrierUserId ) ;
return hb and hb>0 and hb or nil ;
end ;
local function a ( hb,tb ) local Yb=Y[22] ;
local Nb=Yb ( hb ) ;
Yb=nil ;
if Nb then
Yb=Nb ;
else
hb=nil ;
hb,Yb=LocalPlayer,r ( tb ) ==LocalPlayer.UserId ;
end ;
return Yb ;
end ;
local function hb ( tb,Yb,Nb ) local Gb=getRootPart ;
local Sb,Xb=Gb ( ) ,getHumanoid ;
Gb=Xb ( ) ;
if not ( Sb ) then
return ;
end ;
if Gb then
Gb.PlatformStand=true ;
end ;
Gb=tb-Sb.Position ;
local Hb,Vb=Gb.Magnitude>Yb*Nb and Sb.Position+Gb.Unit*Yb*Nb or tb,Vector3.new ;
tb,Nb=Vb ( Gb.X,0,Gb.Z ) ,setPlayerCFrame ;
Xb,Vb=tb.Magnitude>0.5 and CFrame.lookAt ( Hb,Hb+tb ) ;
if Xb then
Vb=Xb ;
else
Gb=CFrame.new ;
Vb= ( Gb ( Hb ) ) ;
end ;
Nb ( Vb ) ;
end ;
local function tb ( Yb,Nb ) local Gb,Sb,Xb,Hb,Vb=ipairs,w[76] ( workspace:GetChildren ( ) ) ,14 ;
for Kb,_b in Gb ( w:iI ( Sb ) ) do
Kb=_b.Name== "SmartPromptPart" and _b:IsA ( "BasePart" ) and _b:FindFirstChild ( "CarryAreaEgg" ) ;
if Kb then
if Kb:IsA ( "ProximityPrompt" ) then
local Rb=Vector3.new ;
local vb=Rb ( _b.Position.X-Nb.X,0,_b.Position.Z-Nb.Z ) .Magnitude ;
if vb<Xb then
Xb,Hb,Vb=vb,Kb,_b ;
else
end ;
else
end ;
else
end ;
end ;
Sb,Gb=Hb and workspace:FindFirstChild ( "AreaEggSlotsClient" ) ,ipairs ;
Nb=Sb and Sb:GetChildren ( ) or {
} ;
for Kb,_b in Gb ( Nb ) do
Kb=_b.Name~=Yb and B ( _b ) ;
if Kb then
Sb=Vector3.new ;
if Sb ( Kb.X-Vb.Position.X,0,Kb.Z-Vb.Position.Z ) .Magnitude+1.5<Xb then
return ;
end ;
end ;
end ;
return Hb ;
end ;
local function B ( Yb,Nb ) local Gb=getHumanoid ;
local Sb,Xb=Gb ( ) ,LocalPlayer ;
Gb=Xb.Character ;
if Sb then
if Gb then
if Gb:FindFirstChildWhichIsA ( "Tool" ) then
pcall ( Sb.UnequipTools,Sb ) ;
end ;
end ;
end ;
Gb,Sb=os.clock ( ) +1.4,0 ;
while os.clock ( ) <Gb and ( Nb ( ) ) do
Xb=h ( Yb ) ;
if a ( 