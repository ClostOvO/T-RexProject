--[[
    ================================================================================
    MODULE 00: CORE RUNTIME & UPVALUE ENVIRONMENT
    Chilli Hub / Steal An Egg Automation Engine
    ================================================================================
    
    DESCRIPTION:
    Contains the core service initializations, safe network remote wrappers with
    15-second timeout protections, character accessors, game coordinate math,
    and rarity/mutation tier constants.
    
    KEY EXPORTS & GLOBALS:
    - NetworkingRemotes          = ReplicatedStorage.Packages.Networking
    - invokeServerWithTimeout    = Remote invoker protected by 15-second watchdog
    - fireServer(remote, ...)    = Safe fire-and-forget remote caller
    - callRequiredModuleMethod   = Metatable caller for internal ReplicatedStorage modules
    - getHumanoid()              = Character Humanoid accessor
    - getRootPart()              = Character HumanoidRootPart accessor
    - isInsideSafeZone(pos)      = Returns true if pos.X < 552.2 and pos.Y < 1000
    - getSeparationLinePos()     = Vector3.new(552.2, 67.67, 0)
    - getRiftMachinePos()        = Vector3.new(528.7, 70.57, -364.11)
    - isRagdolled()              = Checks LocalPlayer:GetAttribute("RagdollEndTime")
    ================================================================================
]]

ait ( ) ;
N=os.clock ( ) ;
end ;
end ;
local A=game ;
local function I ( g ) return A:GetService ( g ) ;
end ;
local g=I ( "Players" ) ;
local N=I ( "ReplicatedStorage" ) ;
local s=I ( "RunService" ) ;
RunService=s ;
local s=I ( "TeleportService" ) ;
local X=I ( "HttpService" ) ;
local O=g.LocalPlayer ;
LocalPlayer=O ;
local O=N:WaitForChild ( "Packages" ) :WaitForChild ( "Networking" ) ;
NetworkingRemotes=O ;
local O=Vector3.new ;
Vector3.new=O ;
local O=CFrame.new ;
CFrame.new=O ;
local O=Vector3.zero ;
Vector3.zero=O ;
local O=RunService.Heartbeat ;
local H=getgenv and getgenv ( ) or _G ;
if H.ChilliHubSaeCleanup then
pcall ( H.ChilliHubSaeCleanup ) ;
end ;
local V,K,_=true, {
} , {
cleanup= {
} ,agFlash=function ( )
end
} ;
IsScriptActive=V ;
ChilliState=_ ;
local function V ( _,R ) local v=_:Connect ( R ) ;
K[#K+1]=v ;
return v ;
end ;
HeartbeatWait=function ( ) return O:Wait ( ) ;
end ;
local function _ ( R,v ) local P=Instance.new ( R ) ;
P.Name=X:GenerateGUID ( false ) :gsub ( "-" , "" ) :sub ( 1,14 ) ;
for R,c in next,v,nil do
if R~= "Parent" then
P[R]=c ;
end ;
end ;
P.Parent=v.Parent ;
return P ;
end ;
local R= {
Egg= "Client.EggState" ,Assets= "Data.Assets" ,Mut= "Shared.Modules.Mutations" ,Save= "Shared.Save" ,Cycle= "Shared.Util.AreaEggCycle" ,Wall= "Client.AreaEggResetWall" ,Plot= "Client.PlotState" ,Rec= "Shared.Util.EggRecords" ,Fuse= "Shared.Util.FuseKernel" ,Bases= "Data.Bases" ,Tread= "Data.Treadmills" ,Trails= "Data.Trails" ,Gears= "Data.Gears" ,Areas= "Data.Areas" ,Wisp= "Data.WispQuests" ,Cat= "Shared.Modules.ButterflyCatalog" ,Fmt= "Packages.FormatNumber.Simple"
} ;
local v=setmetatable ( {
} , {
__index=function ( P,c ) local B=N ;
for x in R[c]:gmatch ( "[^.]+" ) do
B=B and ( B:FindFirstChild ( x ) ) ;
end ;
local R,x=pcall ( require,B ) ;
if R then
if x then
rawset ( P,c,x ) ;
return x ;
end ;
end ;
end
} ) ;
GameModules=v ;
invokeServerWithTimeout=function ( R,... ) local v=NetworkingRemotes ;
local P=v:FindFirstChild ( R ) ;
if not P then
return false ;
end ;
local R=coroutine.running ( ) ;
local v=table.pack ( ... ) ;
local c,B ;
local x=false ;
local function T ( q ) if c then
return ;
end ;
c=q or {
false, "timeout" ,n=2
} ;
if q then
if B then
task.cancel ( B ) ;
end ;
end ;
if x then
task.spawn ( R ) ;
end ;
end ;
task.spawn ( function ( ) T ( table.pack ( pcall ( P.InvokeServer,P,table.unpack ( v,1,v.n ) ) ) ) ;
end ) ;
if not c then
B,x=task.delay ( 15,T ) ,true ;
coroutine.yield ( ) ;
else
end ;
local R,v,P=table.unpack,c,c.n ;
return R ( v,1,P ) ;
end ;
local function R ( v,... ) local P=NetworkingRemotes ;
local c=P:FindFirstChild ( v ) ;
if c then
pcall ( c.FireServer,c,... ) ;
end ;
end ;
callRequiredModuleMethod=function ( v,P,... ) local c=GameModules ;
local B=c[v] ;
if B then
if not ( B[P] ) then
return nil ;
end ;
else
return nil ;
end ;
local v,c,x=pcall ( B[P],... ) ;
if v then
return c,x ;
end ;
return nil ;
end ;
getHumanoid=function ( ) local v=LocalPlayer ;
local P,c=v.Character ;
if P then
v=LocalPlayer ;
c=v.Character:FindFirstChildOfClass ( "Humanoid" ) ;
else
c=P ;
end ;
return c ;
end ;
getRootPart=function ( ) local v=LocalPlayer ;
local P,c=v.Character ;
if P then
v=LocalPlayer ;
c=v.Character:FindFirstChild ( "HumanoidRootPart" ) ;
else
c=P ;
end ;
return c ;
end ;
local function v ( ) local P=getHumanoid ;
local c=P ( ) ;
local P,B=c~=nil and c.Health>0 ;
if P then
c=getRootPart ;
B=c ( ) ~=nil ;
else
B=P ;
end ;
return B ;
end ;
local function P ( ) return workspace:GetServerTimeNow ( ) ;
end ;
getNetworkPing=function ( ) local c,c,c,B=LocalPlayer,LocalPlayer,pcall ( LocalPlayer.GetNetworkPing,LocalPlayer ) ;
return c and math.clamp ( tonumber ( B ) or 0.2,0,1 ) or 0.2 ;
end ;
local c ;
Y[13]=c ;
setPlayerCFrame=function ( c ) local B=getRootPart ;
local x=B ( ) ;
if x then
if x.Anchored then
B=ChilliState ;
if ( B.hold or 0 ) ==0 then
if not ( Y[13] ( function ( ) local x=IsScriptActive ;
return x ;
end ) ) then
return ;
end ;
end ;
end ;
else
return ;
end ;
B=getRootPart ;
local x=B ( ) ;
if not x then
return ;
end ;
pcall ( function ( ) x.CFrame=c ;
local c=Vector3.zero ;
x.AssemblyLinearVelocity=c ;
c=Vector3.zero ;
x.AssemblyAngularVelocity=c ;
end ) ;
end ;
local function c ( ) local B=getHumanoid ;
local x=B ( ) ;
return math.max ( x and x.WalkSpeed or 16,16 ) ;
end ;
getWorldInstance=function ( ... ) local B,x= {
...
} ,workspace:FindFirstChild ( "World" ) or workspace:FindFirstChild ( "__OBJECTS" ) ;
for T,T in ipairs ( B ) do
x=x and ( x:FindFirstChild ( T ) ) ;
end ;
return x ;
end ;
local B ;
getSeparationLinePos=function ( ) if not ( B and B.Parent ) then
local x=getWorldInstance ;
local T=x ( "Areas" , "SeparationLine" ) ;
B=T and T:IsA ( "BasePart" ) and T or nil ;
end ;
local x,T=B and B.Position ;
if x then
T=x ;
else
local B=Vector3.new ;
T= ( B ( 552.2,67.67,0 ) ) ;
end ;
return T ;
end ;
getRiftMachinePos=function ( ) local B=getWorldInstance ;
local x=B ( "Machines" , "RiftMachine" , "Rift" , "Meshes/VoidPortal_Cube.003" ) ;
local T,q=x and ( x:IsA ( "BasePart" ) ) ;
if T then
B=nil ;
B,q=Vector3.new,x.CFrame:PointToWorldSpace ( Vector3.new ( -26.776,1.75,18.665 ) ) ;
else
q=T ;
end ;
T=nil ;
if q then
T=q ;
else
x=Vector3.new ;
T= ( x ( 528.7,70.57,-364.11 ) ) ;
end ;
return T ;
end ;
isInsideSafeZone=function ( B ) local x,x=getSeparationLinePos,B.X<getSeparationLinePos ( ) .X and B.Y<1000 ;
return x ;
end ;
Y[63]=function ( ) local B=callRequiredModuleMethod ;
local x=B ( "Plot" , "ResolvePlot" ) ;
if type ( x ) == "table" then
if x.PlotFolder then
return x ;
end ;
end ;
end ;
local function B ( x,T ) pcall ( firetouchinterest,x,T,0 ) ;
pcall ( firetouchinterest,x,T,1 ) ;
end ;
isRagdolled=function ( ) local x,x=LocalPlayer,tonumber ( LocalPlayer:GetAttribute ( "RagdollEndTime" ) ) or 0 ;
return x>P ( ) ;
end ;
invokeServerBoolean=function ( x,... ) local T=invokeServerWithTimeout ;
local q,F=T ( x,... ) ;
return q and F~=false ;
end ;
local function x ( T ) T=math.max ( math.floor ( T ) ,0 ) ;
return T>=3600 and ( "%dh %02dm" ) :format ( T//3600,T%3600//60 ) or ( "%dm %02ds" ) :format ( T//60,T%60 ) ;
end ;
local T,q= {
"Common" , "Uncommon" , "Rare" , "Epic" , "Legendary" , "Mythic" , "Cosmic" , "Secret" , "Eternal" , "Divine"
} , {
} ;
for F=#T,1,-1 do
q[#q+1]=T[F] ;
end ;
local F,D= {
Scrambled= "Scrambled" ,Golden= "Golden" ,Rainbow= "Rainbow" ,Silver= "Silver" ,Sakura= "Bloom" ,GreatBloom= "Spirit Bloom" ,Boss= "Fractured" ,Enchanted= "Enchanted" ,Monstrous= "Parasite" ,Nitro= "Nitro" ,Spectral= "Spectral" ,Alien= "Abducted" ,Musical= "Musical" ,DarkMatter= "Dark Matter"
} , {
"K" , "M" , "B" , "T" , "Qa" , "Qi"
} ;
local function U ( Z ) Z=tonumber ( Z ) or 0 ;
local r=0 ;
while Z>=1000 and r<#D do
Z,r=Z/1000,r+1 ;
end ;
local f,lower ( ) :gsub ( "s$" , "" ) ;
if ub== "" then
return 0 ;
elseif
ub== "off" then
return 0 ;
end ;
local Wb,pb=ub:match ( "^([%d%.]+)([kmbt]?)$" ) ;
Wb=tonumber ( Wb ) ;
return Wb and eb ( Wb* ( mb[pb]or 1000000 ) ) or nil ;
end ;
b.s2v=Lb ;
local function mb ( eb,ub ) local Wb,pb,kb,ob=F ( eb.R*255+0.5 ) ,F ( eb.G*255+0.5 ) ,F ( eb.B*255+0.5 ) ,j ( ub ) :gsub ( "&" , "&amp;" ) :gsub ( "<" , "&lt;" ) :gsub ( ">" , "&gt;" ) ;
return ( "<font color=\"rgb(%d,%d,%d)\">%s</font>" ) :format ( Wb,pb,kb,ob ) ;
end ;
local eb,ub,Wb= {
} , {
} , {
} ;
eb.__index=eb ;
ub.__index=ub ;
Wb.__index=Wb ;
local pb,kb,o 