--[[
    ================================================================================
    MODULE 01: AUTO STEAL & EGG PATHING ENGINE
    Chilli Hub / Steal An Egg Automation Engine
    ================================================================================
    
    DESCRIPTION:
    Implements the automated egg stealing logic, priority sorting (Nearest, Highest
    Value, Lowest Rarity), delivery mechanics, separation line crossing on foot to
    evade anti-cheat teleport rollback, and egg drop/redeem remotes.
    
    KEY REMOTES & MECHANISMS:
    - AskFieldEggSnapshot        = Fetches active field egg spawns
    - DropFieldEgg               = Drops carried egg into pen
    - AskCarryEgg                = Picks up target field egg
    - SeparationLine Crossing    = Steps across X=552.2 on foot before fast glide
    - Server Hop Modes           = "Until An Egg Matches", "Steal Then Hop", "After A Rare Spawns"
    ================================================================================
]]

B ;
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
local pb,kb,ob=1,1, {
} ;
local function yb ( Mb ) ob[#ob+1]=Mb ;
Mb ( ) ;
end ;
local function Mb ( lb ) local Cb=Gb ( "ScreenGui" ,lb ) ;
Cb.Name,Cb.ResetOnSpawn,Cb.IgnoreGuiInset,Cb.ZIndexBehavior=I:GenerateGUID ( false ) :gsub ( "-" , "" ) :sub ( 1,12 ) ,false,true,N.ZIndexBehavior.Sibling ;
Cb:SetAttribute ( "ChilliRB" ,true ) ;
return Cb ;
end ;
local function I ( ) local lb=workspace.CurrentCamera ;
local Cb=lb and lb.ViewportSize or q ;
return ( Cb.X<1 or Cb.Y<1 ) and q or Cb ;
end ;
local q ;
local function lb ( ) if q then
if q.closeDD then
q.closeDD ( ) ;
end ;
end ;
end ;
b.Window=function ( Cb ) local wK=setmetatable ( {
Tabs= {
} ,Opts= {
} ,ByPath= {
} ,St= {
} ,open=false,cols= {
} ,rest=s ( 0.5,0.475 )
} ,eb ) ;
q=wK ;
local bK=gethui and gethui ( ) or t ( "CoreGui" ) ;
wK.par=bK ;
for t,t in ipairs ( bK:GetChildren ( ) ) do
if t:IsA ( "ScreenGui" ) then
if t:GetAttribute ( "ChilliRB" ) then
t:Destroy ( ) ;
elseif
t:GetAttribute ( "ChilliLibraryOwned" ) or t.Name== "Settings" or t.Name== "ChilliQuickBar" then
if t:GetAttribute ( "ChilliScriptOwner" ) ~= "Joiner" then
t:Destroy ( ) ;
end ;
end ;
end ;
end ;
wK.dirP= "ChilliLibrary/Games/" ..Cb.Game ;
db ( "ChilliLibrary" ) ;
db ( "ChilliLibrary/Games" ) ;
db ( wK.dirP ) ;
db ( wK.dirP.. "/configs" ) ;
local t,db=I ( ) ,O ( ) ;
local hK=O ( ) ;
pcall ( function ( ) db,hK=g:GetGuiInset ( ) ;
end ) ;
local g,tK=U ( t.X-db.X-hK.X,1 ) ,U ( t.Y-db.Y-hK.Y,1 ) ;
local db,hK=0.45*g,0.55*tK ;
if db/hK>1.34 then
db=hK*1.34 ;
else
hK=db/1.34 ;
end ;
if u then
t=Z ( 1.3,g*0.98/U ( db,1 ) ,tK*0.98/U ( hK,1 ) ) ;
db,hK=db*t,hK*t ;
else
end ;
wK.base=s ( db/g,hK/tK ) ;
wK.size=wK.base ;
local t=Mb ( {
DisplayOrder=6,Enabled=false
} ) ;
wK.gui=t ;
local db=gb ( {
p=t,n= "Frame" ,A=R,P=S ( 0.5,0,1.55,0 ) ,S=wK.size,B=K,T=0.4,sb ( 0.008 )
} ) ;
wK.main=db ;
local hK=gb ( {
p=db,n= "Top" ,A=c,P=x,S=s ( 1,0.125 ) ,B=G ( 111,0,2 ) ,sb ( 0.06,G ( 58,0,0 ) )
} ) ;
g=gb ( {
p=hK,n= "Color" ,A=c,P=x,S=s ( 1,0.88 ) ,B=V,Xb ( m ( {
0,G ( 253,86,89 )
} , {
1,G ( 255,11,15 )
} ) )
} ) ;
gb ( {
p=g,n= "Transparent" ,A=R,P=B,S=s ( 0.988,0.87 ) ,B=K,T=0.9
} ) ;
local zK=Kb ( {
p=g,n= "Label" ,A=R,x=Cb.Title,W=true,X=W,Z=6
} ,n ) ;
wK.tl,wK.t0=zK,Cb.Title ;
local YK=Sb ( {
p=hK,n= "Close" ,A=R,O=1,Z=99,Ob ( )
} ) ;
Cb=gb ( {
p=gb ( {
p=YK,n= "Main" ,A=R,P=B,S=T,B=G ( 126,0,0 ) ,sb ( 0.09,G ( 76,0,0 ) )
} ) ,n= "Color" ,A=c,P=x,S=s ( 1,0.9 ) ,B=V,Xb ( m ( {
0,G ( 255,130,130 )
} , {
1,G ( 239,28,28 )
} ) )
} ) ;
gb ( {
p=Cb,n= "Transparent" ,A=R,P=B,S=s ( 0.96,0.88 ) ,B=K,T=0.9
} ) ;
Kb ( {
p=Cb,n= "Label" ,A=R,P=B,S=s ( 1.14,0.98 ) ,x= "X" ,W=true,Z=6
} ,Q ) ;
do
local Q,AK ;
local function IK ( ) local gK=0.06637302041053772/pb ;
return S ( gK,0,0.6588137149810791,0 ) ;
end ;
local function gK ( NK,GK ) local SK=IK ( ) ;
if AK then
AK:Cancel ( ) ;
end ;
AK=_b ( YK, {
Size=S ( SK.X.Scale*NK,0,SK.Y.Scale*NK,0 )
} ,GK ) ;
end ;
Yb ( YK.MouseEnter,function ( ) Q=true ;
gK ( 1.04,0.12 ) ;
end ) ;
Yb ( YK.MouseLeave,function ( ) Q=false ;
gK ( 1,0.12 ) ;
end ) ;
Yb ( YK.MouseButton1Down,function ( ) gK ( 0.96,0.06 ) ;
end ) ;
Yb ( YK.MouseButton1Up,function ( ) gK ( Q and 1.04 or 1,0.09 ) ;
end ) ;
end ;
Fb ( YK,function ( ) wK:Show ( false ) ;
end ) ;
Cb= {
{
"SideButtons" ,1,-1
} , {
"SideButtonsRight" ,0,1
}
} ;
for Q,AK in ipairs ( Cb ) do
tK=gb ( {
p=db,n=AK[1],A=O ( AK[2],0.5 ) ,T=1,Z=99
} ) ;
wK.cols[Q]= {
f=tK,e=AK[3],ly=Gb ( "UIListLayout" , {
p=tK,n= "TabLayout" ,H=p,Y=d
} ) ,pd=Gb ( "UIPadding" , {
p=tK,n= "TabPadding"
} )
} ;
end ;
local Q,Cb,tK=Sb ( {
p=db,n= "ResizeGrip" ,A=O ( 1,1 ) ,Selectable=false,Z=120,Ob ( )
} ) , {
} , {
{
0.5,0.9
} , {
0.68,0.54
} , {
0.84,0.22
}
} ;
for AK,AK in ipairs ( tK ) do
Cb[#Cb+1]=gb ( {
p=Q,n= "GripBar" ,A=R,P=s ( AK[1],AK[1] ) ,S=s ( AK[2],0.13 ) ,R=-45,B=V,T=0.35,Z=121
} ) ;
end ;
local tK,AK,IK ;
local function gK ( NK ) for GK,GK in ipairs ( Cb ) do
z ( GK,NK and 0.05 or 0.35,0.1 ) ;
end ;
end ;
Yb ( Q.MouseEnter,function ( ) gK ( true ) ;
end ) ;
Yb ( Q.MouseLeave,function ( ) if not ( tK ) then
gK ( false ) ;
end ;
end ) ;
Pb ( {
Q
} ,function ( Cb ) local NK,GK ;
NK,GK,tK=vb ( Cb ) ,db.AbsoluteSize,true ;
AK,IK=NK,GK ;
gK ( true ) ;
end ,function ( Cb ) local NK=vb ( Cb ) -AK ;
wK:Resize ( IK.X+NK.X*2,IK.Y+NK.Y*2 ) ;
end ,function ( ) tK=false ;
gK ( false ) ;
end ) ;
do
local Cb,tK ;
wK.dragStop=Pb ( {
hK
} ,function ( AK ) local IK=vb ( AK ) ;
if wK.open then
if wK.anim then
return false ;
elseif
Tb ( hK,IK ) then
if Tb ( YK,IK ) then
return false ;
end ;
else
return false ;
end ;
else
return false ;
end ;
local AK,gK,NK=t.AbsoluteSize,db.Position ;
NK,Cb=O ( gK.X.Scale+gK.X.Offset/AK.X,gK.Y.Scale+gK.Y.Offset/AK.Y ) ,IK ;
tK=NK ;
end ,function ( AK ) local IK,gK=t.AbsoluteSize,vb ( AK ) -Cb ;
local Cb,AK=db.AbsoluteSize.X/IK.X,db.AbsoluteSize.Y/IK.Y ;
local NK,GK,SK,sK=Cb*0.5,0.998-Cb*0.5,AK*0.5,0.98+AK*0.5 ;
db.Position=s ( D ( tK.X+gK.X/IK.X,Z ( NK,GK ) ,U ( NK,GK ) ) ,D ( tK.Y+gK.Y/IK.Y,Z ( SK,sK ) ,U ( SK,sK ) ) ) ;
wK.rest=db.Position ;
end ) ;
end ;
local Cb=gb ( {
p=db,n= "SearchBar" ,A=c,P=s ( 0.5,1.022 ) ,S=s ( 1,0.0749 ) ,B=K,T=0.4,Z=6,sb ( 0.05 )
} ) ;
Kb ( {
p=Cb,n= "Caption" ,A=v,P=s ( 0.02,0.5 ) ,S=s ( 0.13,0.5 ) ,x= "Search" ,X=W,Z=7
} ) ;
g=gb ( {
p=Cb,n= "Field" ,A=P,P=s ( 0.982,0.5 ) ,S=s ( 0.82,0.6 ) ,B=K,T=0.6,Z=7,sb ( 0.1 )
} ) ;
local tK,AK=gb ( {
p=g,n= "Underline" ,A=O ( 0.5,1 ) ,P=s ( 0.5,1 ) ,S=s ( 0,0.11 ) ,B=V,Z=9
} ) ,Gb ( "TextBox" , {
p=g,n= "Input" ,A=v,P=s ( 0.025,0.5 ) ,S=s ( 0.9,0.62 ) ,PH= "Filter features..." ,PC3=Ib,X=W,Z=8
} ) ;
Hb ( AK ) ;
local IK,gK=Sb ( {
p=g,n= "Clear" ,A=P,P=s ( 0.985,0.5 ) ,S=s ( 0.075,0.74 ) ,V=false,Z=9,Ob ( true )
} ) , {
45,-45
} ;
for NK,NK in ipairs ( gK ) do
gb ( {
p=IK,n= "Arm" ,A=R,P=B,S=s ( 0.82,0.2 ) ,R=NK,B=G ( 255,72,72 ) ,Z=10
} ) ;
end ;
Bb ( IK,1.12,0.9 ) ;
Fb ( IK,function ( ) if AK:IsFocused ( ) then
AK:ReleaseFocus ( ) ;
end ;
AK.Text= "" ;
end ) ;
rb ( AK,g,tK ) ;
Ab ( AK, "Text" ,function ( ) IK.Visible=AK.Text~= "" ;
if not ( wK.sbQuiet ) then
if wK.Cur then
wK.Cur.q=AK.Text ;
wK:Search ( AK.Text ) ;
end ;
end ;
end ) ;
wK.sbox=AK ;
local g ;
local function tK ( ) local AK,IK=0.0749/kb,0.022/kb ;
Cb.Size=s ( 1,AK ) ;
local gK=db.AbsoluteSize.Y ;
local NK=db.AbsolutePosition.Y+gK+ ( AK+IK ) *gK<=t.AbsoluteSize.Y ;
if NK==g then
return ;
end ;
g=NK ;
if NK then
Cb.AnchorPoint,Cb.Position=c,s ( 0.5,1+IK ) ;
else
Cb.AnchorPoint,Cb.Position=O ( 0.5,1 ) ,s ( 0.5,-IK ) ;
end ;
end ;
Ab ( db, "AbsolutePosition" ,tK ) ;
Ab ( db, "AbsoluteSize" ,tK ) ;
yb ( function ( ) hK.Size=S ( 1,0,0.125/kb,0 ) ;
zK.Position,zK.Size=S ( 0.5687711238861084/pb,0,0.5,0 ) ,S ( 0.8620089292526245/pb,0,0.7499999403953552,0 ) ;
YK.Position,YK.Size=S ( 1-0.04500001668930054/pb,0,0.4339999854564667,0 ) ,S ( 0.06637302041053772/pb,0,0.6588137149810791,0 ) ;
Q.Position,Q.Size=s ( 1-0.002/pb,1-0.005/kb ) ,s ( 0.05/pb,0.05/kb ) ;
local Q,db=ipairs,wK.cols ;
for Cb,Cb in Q ( db ) do
Cb.Kb ( ) ;
end ;
else
local Kb=invokeServerWithTimeout ;
local vb,Pb,cb=Kb ( "RF/Treadmill/AskWearStill" ) ;
Kb=getRootPart ;
local Bb=Kb ( ) ;
Kb=Bb and Bb.Anchored or vb and ( Pb==true or type ( cb ) == "string" and cb:lower ( ) :find ( "already" ) ) ;
Sb=Kb or os.clock ( ) -Hb<3 ;
if not Sb then
task.wait ( 0.3 ) ;
end ;
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
task.spawn ( function ( ) local Yb,Gb=game:GetService ( "AdService" ) , {
egg=0,cash=0
} ;
local function Sb ( ) local Xb,Hb=pcall ( Yb.GetAdAvailabilityNowAsync,Yb,Enum.AdFormat.RewardedVideo ) ;
return Xb and Hb and Hb.AdAvailabilityResult==Enum.AdAvailabilityResult.IsAvailable ;
end ;
local function Yb ( Xb,Hb ) local Vb ;
local Kb,_b,Rb=Xb.OnClientEvent:Connect ( function ( vb ) Vb=vb==nil and true or vb ;
end ) ,pcall ( Hb ) ,os.clock ( ) ;
while true do
Hb,Xb=_b and Vb==nil and IsScriptActive ;
if Hb then
local vb=Y[26] ;
Xb=vb.watchAds ;
else
Xb=Hb ;
end ;
if not ( Xb and os.clock ( ) -Rb<120 ) then
break ;
end ;
task.wait ( 0.2 ) ;
end ;
Kb:Disconnect ( ) ;
Rb=_b and Vb ;
return Rb ;
end ;
while true do
local Xb=IsScriptActive ;
if not Xb then
break ;
end ;
task.wait ( 3 ) ;
Xb=Y[26] ;
if Xb.watchAds and Sb ( ) then
local Xb,Hb=os.clock ( ) ,N:FindFirstChild ( "AdEggBoostRemotes" ) ;
local Vb=Hb and ( Hb:FindFirstChild ( "AskAdGrowthBoost" ) ) ;
local Kb=Hb and ( Hb:FindFirstChild ( "AdGrowthBoostResult" ) ) ;
if Vb and Kb then
if Xb>=Gb.egg then
Hb=Yb ( Kb,function ( ) local _b,Rb=Vb:InvokeServer ( ) ;
if _b==false then
error ( tostring ( Rb ) ) ;
end ;
end ) ;
Gb.egg=os.clock ( ) + ( type ( Hb ) == "table" and Hb.completed==true and 30 or 120 ) ;
if type ( Hb ) == "table" then
if Hb.completed==true then
u ( "Ads" , "Egg growth +5 min" , "ok" ) ;
end ;
end ;
end ;
end ;
Hb=workspace:FindFirstChild ( "RVBillboard_Cash_Reward" ) ;
Kb=Hb and ( Hb:FindFirstChild ( "Remotes" ) ) ;
local Vb=Kb and ( Kb:FindFirstChild ( "ShowAd" ) ) ;
Xb,Hb=Kb and ( Kb:FindFirstChild ( "AdResult" ) ) ,Y[26] ;
if Hb.watchAds then
if Vb then
if Xb then
if os.clock ( ) >=Gb.cash then
if Sb ( ) then
Kb=Yb ( Xb,function ( ) Vb:FireServer ( ) ;
end ) ;
Gb.cash=os.clock ( ) + ( Kb and 30 or 120 ) ;
if Kb then
u ( "Ads" , "Cash ad watched" , "ok" ) ;
end ;
end ;
end ;
end ;
end ;
end ;
end ;
end ;
end ) ;
local Yb=wb ( {
name= "Progress" ,gap=5,fail= {
}
} ) ;
Yb.on=function ( ) local Gb=Y[26] ;
local Sb,Xb=Gb.claimCash ;
if Sb then
Xb=Sb ;
else
Gb=Y[26] ;
Xb=Gb.claimIndex ;
end ;
Sb=nil ;
if Xb then
Sb=Xb ;
else
Gb=Y[26] ;
Sb=Gb.upBase ;
end ;
Gb=nil ;
if Sb then
Gb=Sb ;
else
Xb=Y[26] ;
Gb=Xb.upTread ;
end ;
Sb=nil ;
if Gb then
Sb=Gb ;
else
Xb=Y[26] ;
Sb=Xb.trails ;
end ;
return Sb ;
end ;
local Gb= {
{
"LimitedEgg" , "GravityDisruptor" , "LimitedEgg" , "MechaReroll"
} , {
"BrainrotEgg" , "BeeLauncher" , "BrainrotEgg"
} , {
"MonsterEgg" , "BeeLauncher" , "MonsterEgg" , "Mecha"
}
} ;
Yb.fn=function ( ) local Sb=Y[64] ;
local Xb=Sb ( ) ;
if not ( Xb ) then
return ;
end ;
local Hb,Vb=tonumber ( Xb.Money ) or 0,Y[26] ;
if Vb.claimCash then
Sb=invokeServerWithTimeout ;
local Kb,_b=Sb ( "RF/AwayEarnings/FetchSummary" ) ;
if Kb then
if type ( _b ) == "table" then
local Kb=tonumber ( _b.ClaimableAmount ) ;
if Kb then
if Kb>0 then
local Kb=invokeServerWithTimeout ;
Kb ( "RF/AwayEarnings/AskCollect" , {
Kind= "Claim"
} ) ;
end ;
end ;
end ;
end ;
end ;
Sb=Y[26] ;
if Sb.claimIndex then
local Kb,_b,Rb=type ( Xb.Index ) == "table" and Xb.Index or {
} ,type ( Xb.IndexClaimedCategories ) == "table" and Xb.IndexClaimedCategories or {
} ,next ;
for vb,Pb in Rb,Kb,nil do
if Pb==true then
if _b[vb]~=true then
Vb=invokeServerWithTimeout ;
Vb ( "RF/Codex/AskRedeemAll" ) ;
break ;
end ;
end ;
end ;
_b,Rb=type ( Xb.GearInventory ) == "table" and Xb.GearInventory or {
} ,ipairs ;
for vb,Pb in Rb ( Gb ) do
if ( Yb.fail[Pb[1]]or 0 ) <os.clock ( ) and ( tonumber ( _b[Pb[2]] ) or 0 ) <=0 then
vb=N.Data:FindFirstChild ( Pb[3] ) ;
local Gb,_b=pcall ( require,vb ) ;
local Rb,vb=true,false ;
if Gb then
if type ( _b ) == "table" then
local Gb,cb,Bb,xb=ipairs, {
} ,_b.Entries,Pb[4]and ( _b[Pb[4].. "Entries" ]or type ( _b[Pb[4]] ) == "table" and _b[Pb[4]].Entries ) ;
w:XI ( cb,0,Bb,xb ) ;
Bb,xb=vb,Rb ;
for _b,_b in Gb ( cb ) do
for Gb,Gb in ipairs ( type ( _b ) == "table" and _b or {
} ) do
Bb,xb=true,if Kb[Gb.AssetId]then xb
else
false ;
end ;
end ;
if Bb then
if xb then
Yb.fail[Pb[1]]=os.clock ( ) +60 ;
cb=invokeServerWithTimeout ;
cb ( "RF/Codex/AskRedeemLimitedEgg" ,Pb[1] ) ;
end ;
end ;
end ;
end ;
end ;
end ;
end ;
Vb=Y[26] ;
if Vb.upBase then
Sb=GameModules ;
local Gb,Kb=Sb.Bases,tonumber ( Xb.BaseUpgradeLevel ) or 1 ;
local _b,Rb=Gb and Gb.BASES and Gb.BASES[Kb+1],callRequiredModuleMethod ;
Gb=Rb ( "Bases" , "GetMaxBaseLevel" ) ;
if _b then
if Hb>= ( tonumber ( _b.Cost ) or math.huge ) then
if Gb then
if Kb<Gb then
R ( "RE/Homestead/AskBaseTierRaise" ) ;
return ;
end ;
else
R ( "RE/Homestead/AskBaseTierRaise" ) ;
return ;
end ;
end ;
end ;
end ;
Sb=Y[26] ;
if Sb.upTread then
Vb=callRequiredModuleMethod ;
local Gb=Vb ( "Tread" , "GetByUpgradeLevel" , ( tonumber ( Xb.TreadmillUpgradeLevel ) or 0 ) +1 ) ;
if type ( Gb ) == "table" then
if Gb._id then
if Hb>= ( tonumber ( Gb.Price ) or math.huge ) then
local Kb=invokeServerWithTimeout ;
Kb ( "RF/Treadmill/AskTierRaise" ,Gb._id ) ;
return ;
end ;
end ;
end ;
end ;
Vb=Y[26] ;
if Vb.trails then
local Gb,Vb,Kb=type ( Xb.TrailInventory ) == "table" and Xb.TrailInventory or {
} ,next,GameModules ;
local Xb,_b=Kb.Trails ;
if Xb then
Kb=GameModules ;
_b=Kb.Trails.Directory ;
else
_b=Xb ;
end ;
Xb=nil ;
for Rb,vb in Vb,_b or {
} ,nil do
Sb=type ( vb ) == "table" and tonumber ( vb.Price ) ;
Rb=type ( vb ) == "table" and vb._id or Rb ;
Xb=if Sb then
if Sb<=Hb then
if Gb[Rb]~=true then
if Yb.fail[Rb]then Xb
else
if Xb then
if Sbt = no limit ) ",Kb);_b=ChilliState;local function Pb(cb)local Bb=ChilliState;vb.sp=Bb.names(cb);end;Vb:Dropdown(" Hatch Specific Eggs ",_b.eggList,{},Pb,true," Only hatch these eggs ( empty = all ) ",Kb);y(Vb," Auto Equip Best "," equip ",false,nil," Equip Best when a better pet appears ");Sb.on=function()local Vb=Y[26];local Kb,_b=Vb.hatch;if Kb then _b=Kb;else Vb=Y[26];_b=Vb.placeIdx;end;return _b or(L(" Farm "));end;Sb.fn=function()local Vb,Kb,_b={},pairs,w[76](Q());for Pb,cb in Kb(w:iI(_b))do if type(cb)==" table "then if cb.Placement then local Bb=callRequiredModuleMethod;if Bb(" Egg "," IsReadyToHatch ",Pb)==true then Vb[#Vb+1]={Pb,cb};end;end;end;end;Kb,_b={[" Ready now "]=tostring(#Vb)};_b,Kb.Hatched=Y[42],tostring(Y[42].hatched);k(" hs ",Rb,Kb);_b=Y[26];if not(_b.hatch)then Kb=Y[26];if not(Kb.placeIdx)then return;end;end;_b=Y[26];if _b.hatch then if vb.maxV then if vb.maxV<=(vb.minV or 0)then Kb=Y[11];Kb(" Max Hatch Value must be above Min Hatch Value, nothing will hatch "," warn ");end;end;end;_b=Y[26];local Rb,Pb=_b.placeIdx;if Rb then Kb=ChilliState;Pb=Kb.indexMissing();else Pb=Rb;end;_b,Kb,Rb=Pb or{},ipairs,0;for cb,Bb in Kb(Vb)do if Rb>=4 then break;end;Pb,cb=Bb[1],d(Bb[2]);local Vb,Kb=(Sb.bad[Pb]or 0)<os.clock();if Vb then local xb=Y[26];local Tb,qb=xb.hatch;if Tb then xb=Y[67];qb=(xb(vb,cb));else qb=Tb;end;Kb=qb or _b[cb.cat];else Kb=Vb;end;if Kb then cb=ChilliState;if cb.protect(Pb,Bb[2])then else Vb=Rb+1;if Xb(Pb)then local Xb=Y[42];Xb.hatched=Xb.hatched+1;else Sb.bad[Pb]=os.clock()+10;end;task.wait(0.2);Rb=Vb;end;else end;end;end;local Sb=wb({name=" Equip ",gap=8});Sb.on=function()local Xb=Y[26];return Xb.equip;end;Sb.fn=function()local Sb=invokeServerWithTimeout;local Xb,Vb=Sb(" RF/Haul/FetchWearBestStatus ");if Xb then if Vb then Sb=invokeServerWithTimeout;Sb(" RF/Haul/WearBest ");end;end;end;end);S(" 20_farm#3 ",function()local Sb,Xb,Vb=Ib[" Keep Eggs "];local Kb,_b={},ChilliState;local Rb=#_b.RANY;for vb=Rb,2,-1 do _b=nil;_b,Kb[#Kb+1]=ChilliState,ChilliState.RANY[vb];end;Sb:Text(" Keep Eggs Info "," Kept eggs are never placed, hatched or sold, in your bag or your pen. ");Rb=y(Sb," Keep Matching Eggs "," keepOn ",true);local function _b(vb)local Pb,cb=ipairs;for Bb,xb in Pb(vb)do cb=cb or{};Bb=ChilliState;cb[Bb.RIDX[xb]or 0]=true;end;Xb=cb;o();end;Sb:Dropdown(" Keep Rarities ",Kb,{},_b,true,nil,Rb);Sb:Slider(" Keep Min Value ",0,0,0,function(Sb)Vb=Sb>0 and Sb or nil;o();end," log ",nil,nil,Rb);local Sb=ChilliState;Sb.protect=function(Sb,Kb)Sb=Y[26];if Sb.keepOn then if type(Kb)~=" table "then return false;elseif not(Xb)then if not(Vb)then return false;end;end;else return false;end;local _b,Rb,vb=d(Kb),Xb~=nil;if Rb then Sb=Xb;vb=Sb[_b.r]==true;else vb=Rb;end;Rb=vb or Vb~=nil and _b.v>=Vb;return Rb;end;end);S(" 20_farm#4 ",function()local Sb={Boss=" Fractured ",Scrambled=" Scrambled ",Enchanted=" Enchanted ",Nitro=" Nitro ",Spectral=" Spectral ",Alien=" Abducted ",DarkMatter=" Dark Matter "};local Xb=wb({name=" Mutate ",mover=true,gap=1,pri=3,soft=true,bad={}});local Vb=Ib[" Auto Mutation "];local Kb=y(Vb," Auto Mutate "," mutate ",false,function(_b)if not(_b)then bb(Xb);end;end);local _b,Rb=p(" mst ",Vb:Text(" Mutate Status "," Off ",Kb)),{Boss=true,Scrambled=true,Enchanted=true,Nitro=true,Spectral=true,Alien=true,DarkMatter=true};local vb=Vb:Dropdown(" Mutations To Use ",{" Fractured "," Scrambled "," Enchanted "," Nitro "," Spectral "," Abducted "," Dark Matter "},{" Fractured "," Scrambled "," Enchanted "," Nitro "," Spectral "," Abducted "," Dark Matter "},function(Pb)for cb,Bb in next,Sb,nil do Rb[cb]=table.find(Pb,Bb)~=nil;end;end,true,nil,Kb);task.delay(5,function()if IsScriptActiveand not(pcall(isfile," ChilliLibrary/SAE_alien.txt ")and isfile(" ChilliLibrary/SAE_alien.txt "))then local Pb=Rb.Alien;if if Pb then not Pb else next(Rb)then local Pb=table.clone(vb.Value or{});Pb[#Pb+1]=" Abducted ";W(" addAlien ",function()vb:Set(Pb);end);end;pcall(writefile," ChilliLibrary/SAE_alien.txt "," 1 ");end;if IsScriptActiveand not(pcall(isfile," ChilliLibrary/SAE_darkmatter.txt ")and isfile(" ChilliLibrary/SAE_darkmatter.txt "))then local Pb=Rb.DarkMatter;if if Pb then not Pb else next(Rb)then local Pb=table.clone(vb.Value or{});Pb[#Pb+1]=" Dark Matter ";W(" addDM ",function()vb:Set(Pb);end);end;pcall(writefile," ChilliLibrary/SAE_darkmatter.txt "," 1 ");end;end);local vb,Pb,cb={},{},ChilliState;local function Bb(xb)local Tb=ChilliState;vb.rar=Tb.minRar(xb);o();end;Vb:Dropdown(" Mutate Min Rarity ",cb.RANY," Any ",Bb,false," Only eggs of this rarity and above get mutated ",Kb);Vb:Slider(" Mutate Min Value ",0,0,0,function(Bb)vb.minV=Bb>0 and Bb or nil;o();end," log ",nil," Skip eggs worth less than this ( 0 = off ) ",Kb);cb=ChilliState;local function Bb(xb)local Tb=ChilliState;vb.sp=Tb.names(xb);o();end;Vb:Dropdown(" Mutate Target Eggs ",cb.eggList,{},Bb,true," Only mutate these eggs ( empty = all ) ",Kb);local Bb,xb={[" Highest Value "]=" Best value ",[" Best Rarity "]=" Best rarity ",[" Biggest Size "]=" Biggest "},Y[26];xb.mutFirst=" Best value ";Vb:Dropdown(" Mutate Priority ",{" Highest Value "," Best Rarity "," Biggest Size "}," Highest Value ",function(Vb)local Tb=Y[26];Tb.mutFirst=Bb[Vb]or" Best value ";end,false," Which egg gets mutated first ",Kb);xb=ChilliState;local Vb=xb.nostat;local function Kb()local Bb,xb,Tb,qb,Fb,Db={},{Boss=0,Scrambled=0,Enchanted=0,Nitro=0,Spectral=0,Alien=0,DarkMatter=0},ipairs,{},LocalPlayer,LocalPlayer;w:XI(qb,0,Fb.Character or(n()),Db.Character and(n()));for Fb,Db in Tb(qb)do for Tb,Tb in ipairs(Db and Db:GetChildren()or{})do if Tb:IsA(" Tool ")then if Tb:GetAttribute(" ItemType ")==" MutationConsumable "then Fb=Tb:GetAttribute(" MutationId ")or Tb:GetAttribute(" MutationTemplate ")or" Boss ";Bb[Fb]=Bb[Fb]or Tb;xb[Fb]=(xb[Fb]or 0)+(tonumber(Tb:GetAttribute(" Uses "))or tonumber(Tb.Name:match(" %[X ( %d+ ) %] "))or 1);end;end;end;end;return Bb,xb;end;cb=ChilliState;cb.mutItems=Kb;local cb=wb({name=" Bag ",gap=2,info=true});cb.on=function()return L(" Farm ");end;cb.fn=function()local cb,cb=Kb();k(" bag ",Vb,{Fractured=tostring(cb.Boss),Scrambled=tostring(cb.Scrambled),Enchanted=tostring(cb.Enchanted),Nitro=tostring(cb.Nitro),Spectral=tostring(cb.Spectral),Abducted=tostring(cb.Alien),[" Dark Matter "]=tostring(cb.DarkMatter)});end;local function Vb(cb)cb=cb or(Kb());if not(next(cb))then _b(" No consumables in your bag ");return;end;local Bb,xb,Tb={},pairs,w[76](Q());for qb,Fb in xb(w:iI(Tb))do local Tb,Db=type(Fb)==" table "and Fb.Placement;if Tb then local Ub=ChilliState;Db=not Ub.reserved[qb];else Db=Tb;end;if Db then local Db,Ub=d(Fb),false;for Fb,Fb in ipairs(Db.m)do U,function(a)local hb=Kb.IsShown(Yb)and Yb.AbsoluteSize.X>0;local Yb=hb and GK~=nil and Kb.IsShown(GK);if Yb then if not(tK)then Rb=true;end;end;tK=Yb;if not(hb)then return;end;if Yb then if HK.Frame.Visible then IK+=a;if IK>=0.05 then HK.Rays.Rotation=(HK.Rays.Rotation+IK*6)%360;IK=0;end;end;end;hK+=a;if Yb and Rb or hK>=1 then hK=0;if Yb then Rb=false;pcall(h);end;pcall(vb);end;Pb();end);end;do local h,a,hb,Yb,Nb,Gb,Hb,_b=" #9FB8FF "," #4DFF7A "," #FFC24D "," #FFFFFF "," #CDE7FF "," #FFDF8A ",2.9,0.0909;local Fb=Kb.Paint;local Ub=Kb.Bold;local Zb=Kb.Escape;local rb=Kb.MutationText;local fb=Kb.Separator();local jb,db,Jb,nb=cb(0,255,255,255,0.5,222,238,255,1,255,255,255),3.15,{0," #8F98A8 ",0.3," #C6CDDA ",0.85," #FFFFFF ",1.45," #7CFF9E ",1.9," #4FE0FF ",2.85," #6FA0FF ",3.8," #C08BFF ",5.8," #FF9A3D ",9.5," #FF5C5C ",12," #FFD34D ",20," #FF4DE8 "};local cb,Qb,mb,ib,eb,Lb,ab={},{},{},{},0,0,0.06;local Eb=-1;local ub=-1;local Wb,pb,kb,ob,yb,Mb=-1,4,3,false,0;local lb,Cb=0.01,150;local function wK(bK,hK)return Ub(Fb(bK,hK));end;local function Ub(bK)return(" %.2fx "):format(bK);end;local function bK(hK)return(" %.2fx - %.2fx "):format(hK.Min,hK.Max);end;local function hK(tK,zK)local YK=callRequiredModuleMethod;local AK=YK(" Rec "," WeightKgForScale ",tK,zK);return type(AK)==" number "and AK>0 and AK or nil;end;local function tK(zK)return zK and fb..Fb(Nb,xb(zK))or" ";end;local function zK(YK)local AK=" #FFFFFF ";for IK=1,#Jb,2 do AK=if YK+0.001>=Jb[IK]then Jb[IK+1]else AK;end;return AK;end;local function Jb()if Mb then local YK=Mb;return YK;end;local YK,AK=pcall(function()local IK=GameModules;return(debug.getupvalues or getupvalues)(IK.Rec.DrawAssetScale);end);local IK,gK=pairs,YK and type(AK)==" table "and AK or{};for NK,GK in IK(gK)do if type(GK)==" table "then if type(GK.SCALE_BANDS)==" table "then AK,YK,NK=GK.SCALE_BANDS,tonumber(GK.SCALE_DOUBLING_ODDS)or lb,tonumber(GK.SCALE_HARD_CAP)or Cb;Mb,lb,Cb=AK,YK,NK;break;end;if type(GK[1])==" table "then if GK[1].min then if GK[1].weight then Mb=GK;break;end;end;end;end;end;if not(Mb)then gK={0.85,1.05,2000,1.45,1.55,250,1.9,2.1,125,2.85,3.15,62.5,3.8,4.2,31.25,0.3,0.45,18,0.1,0.2,5,5.8,6.2,15.625,9.5,12.5,3,12,17,0.05,20,35,1.0E-4};Mb={};IK=#gK;for AK=1,IK,3 do YK=Mb;YK[#YK+1]={min=gK[AK],max=gK[AK+1],weight=gK[AK+2]};end;end;gK=Mb;return gK;end;local function Mb(YK,AK,IK)local gK=callRequiredModuleMethod;local NK=gK(" Fuse "," BandWeightBias ",YK,AK,IK);if type(NK)==" number "then return NK;end;return math.exp(math.log((YK[1]+YK[2]+YK[3])/3)/0.6931471805599453*(math.log((AK+IK)/2)/0.6931471805599453)*0.6);end;local function YK()local AK=Y[64];local IK=AK();if not(IK)then return;end;local gK,NK,GK,SK=tb(IK.FusionSlots),tb(IK.Inventory),{},IK.FusionEggReward;for sK=1,3,1 do AK=NK[gK[sK]];if type(AK)==" table "then GK[#GK+1]={Category=AK.Category,Scale=tonumber(AK.Scale)or 1,Mutations=tb(AK.Mutations),Raw=AK};end;end;return{Items=GK,Locked=IK.FusionLocked==true,Duration=tonumber(IK.FusionDuration)or 0,Reward=SK,Result=type(SK)==" table "and type(SK.Egg)==" table "and SK.Egg or nil};end;local function AK(IK)local gK=IK.Get();if Lb>0 then if gK.Text==tostring(IK.Spec.Text or" ")then return gK;end;end;ob=true;end;local function IK(gK)local NK=AK(gK);if not(NK)then return;end;local GK,SK=NK.Size,NK.TextWrapped;NK.TextWrapped=false;NK.Size=m(100000,Sb(1,GK.Y.Offset));gK=NK.TextBounds.X;NK.Size=GK;NK.TextWrapped=SK;if gK>0 then SK=Lb;return gK/SK;end;ob=true;end;local function gK(NK,GK)local SK=AK(NK);if not(SK)then return;end;NK=SK.Size;SK.Size=m(Sb(1,Xb(GK*Lb+0.5)),100000);GK=SK.TextBounds.Y;SK.Size=NK;if GK>0 then SK=Lb;return GK/SK;end;ob=true;end;local function m(Xb,AK,NK,GK,SK)local sK,XK=nb,{Parent=Xb,X=AK,Width=NK,Height=NK,Corner=0.35,Background=" #000000 ",BackgroundTransparency=GK,StrokeThickness=_b,StrokeTransparency=0,ZIndex=SK};return sK:Imag
=Tb(" #9AA3B5 "," Players ")..qb(Tb(" #FFFFFF ",#g:GetPlayers().." / "..g.MaxPlayers));Kb(Cb);Kb,Cb=Jb.d,{};Cb.Text=Tb(" #E6ECF5 ",Fb(bK));Kb(Cb);Jb.b({FillColor=Vb});if hK~=eb then eb,Qb=hK,2;Kb=ab;for jb,jb in ipairs(Kb)do jb({Visible=hK});end;end;if not(hK)then return;end;Kb,Cb=yb.i,yb.s;local jb,bK,tK,zK=Kb.Icon,Color3.fromHex(Cb[2]),Kb.Rarity:upper(),Kb.Gradient;hK=tK==" SECRET ";jb=jb and(if tonumber(jb)then" rbxassetid:// "..jb else jb);wK=hK and xb.SecretGradient or zK;Jb.i({Visible=jb~=nil,Image=jb or" ",StrokeColor=Kb.Color});Jb.n({Text=Fb(Kb.Name),Color=wK~=nil and Db or Kb.Color,Gradient=wK,GradientRotation=hK and xb.SecretRotation or typeof(zK)==" Instance "and zK:IsA(" UIGradient ")and zK.Rotation or 0});Jb.h({StrokeColor=bK});Jb.x({Text=Cb[1],Color=bK});Vb,bK,zK={},qb(Tb(" #4DFF7A "," $ "..xb.FormatRate(yb.v))),qb(Tb(hK and" #D0D6E2 "or Kb.Hex,Fb(tK)));w:XI(Vb,0,bK,zK,Tb(" #CDE7FF ",Fb(yb.a)));wK=xb.MutationText(yb.m);if wK~=" "then Vb[#Vb+1]=wK;end;if mb>1 then Vb[#Vb+1]=Tb(" #9FB8FF ",mb.." matches ");end;tK,hK=Jb.f,{};hK.Text=table.concat(Vb,xb.Separator());tK(hK);end;local function Vb()ob=false;local Kb,Tb,qb=math.max(1,Eb-0.7-0.5),Mb(nb.v),2.6;if Tb then Jb.su=Tb+0.1;else ob=true;end;Tb=math.min(Jb.su or 4,Kb*0.45);local Fb,jb=Jb.t,{};jb.Width=math.max(1,Kb-Tb-0.3);Fb(jb);Jb.v({X=0.7+Kb-Tb,Width=math.max(0.5,Tb)});Jb.d({Width=Kb});if eb then Fb,jb=Mb(nb.x),math.max(1,Eb-Ub-0.5);if Fb then Jb.cu=Fb+0.9;else ob=true;end;Fb=math.min(Jb.cu or 4,jb*0.5);Jb.l({Width=Kb});local Kb,Tb=Jb.n,{};Tb.Width=math.max(1,jb-Fb-0.3);Kb(Tb);Kb,Tb=Jb.h,{};Tb.X,Tb.Width=Ub+jb-Fb,Fb;Kb(Tb);Jb.x({Width=Fb});Jb.f({Width=jb});qb=5.9;else end;Jb.c({Width=Eb,Height=qb});Jb.a({Height=qb});if qb~=kb then kb=qb;Lb:SetContentLines(qb);end;end;Gb:Surface({Name=" Finder Status ",ShowTitle=false,Layout=" free ",Style={TextScale=1,LineHeight=1.1,MinLines=2,MaxLines=7,BackgroundTransparency=0.5,TextColor=Db,TextStrokeTransparency=0.7},Build=function(Kb)Lb=Kb;local function Tb(qb,Fb,Db)Db.Parent=Db.Parent or nb.c;Db.Wrap=false;local jb=Kb[Fb](Kb,Db);nb[qb]=jb;Jb[qb]=function(qb)local Fb;for mb,eb in next,qb,nil do if Db[mb]~=eb then Fb=Fb or{};Fb[mb]=eb;else end;end;if Fb then jb.Set(Fb);end;end;end;Tb(" c "," Frame ",{Height=2.6,Corner=0.35});Tb(" a "," Frame ",{Width=0.22,Height=2.6,Corner=0.11,Background=" #9AA3B5 "});Tb(" t "," Text ",{X=0.7,Y=0.3,Height=Zb,Scale=1.2,Font=xb.RarityFont,TextStrokeTransparency=1});Tb(" v "," Text ",{Y=0.3,Height=Zb,Align=" Right "});Tb(" d "," Text ",{X=0.7,Y=0.3+Zb,Height=1});Tb(" b "," Bar ",{X=0.7,Y=2.6,Width=1,Height=0.3,Corner=0.15,Background=" #2A2F3A ",Visible=false});Tb(" l "," Frame ",{X=0.7,Y=2.6,Height=0.06,Background=" #FFFFFF ",BackgroundTransparency=0.85,Visible=false});Tb(" i "," Image ",{X=0.7,Y=2.9,Width=2.6,Height=2.6,Corner=0.35,BackgroundTransparency=0.45,StrokeThickness=0.0909,Visible=false});Tb(" n "," Text ",{X=Ub,Y=2.9,Height=Zb,Scale=1.2,Font=xb.NameFont,TextStrokeTransparency=1,StrokeTransparency=0.2,Visible=false});Tb(" h "," Frame ",{Y=2.9+(Zb-0.95)/2,Height=0.95,Corner=0.3,BackgroundTransparency=0.35,StrokeThickness=0.0909,Visible=false});Tb(" x "," Text ",{Parent=nb.h,Height=0.95,Scale=0.78,Align=" Center ",Font=xb.RarityFont,TextStrokeTransparency=1});Tb(" f "," Text ",{X=Ub,Y=2.9+Zb,Height=1,Visible=false});ab={Jb.l,Jb.n,Jb.h,Jb.f,Jb.i};Kb:OnResize(function(Tb,qb,Fb)if qb==Wb then if Fb==pb then return;end;end;Tb=nil;Tb,Wb,pb=qb/math.max(Fb,1),qb,Fb;Eb,ub,Qb=Tb,Fb,2;qb,Tb=Jb.n,{};Tb.StrokeThickness=0.9/math.max(Kb:TextSize(),1);qb(Tb);end);end});V(O,function(Kb)if Lb then if not(xb.IsShown(Lb:Root()))then return;end;else return;end;ib+=Kb;if ib>=1 then ib=0;pcall(lb);end;pcall(db);if Qb>0 or ob then Qb=math.max(Qb-1,0);pcall(Vb);end;end);local Vb,Kb={[" Until An Egg Matches "]=rb,[" Steal Then Hop "]=fb,[" After A Rare Spawns "alse;end);end;Xb=ChilliState;Xb.agBusy=false;end;local Xb,Hb=w:zI(15,16,{[1]=Y,[15]=Y,[8]=Y,[21]=Y,[52]=hb,[53]=Y,[54]=hb,[55]=hb,[56]=hb,[57]=hb,[58]=Y,[41]=Y,[59]=hb,[60]=hb,[61]=hb,[51]=Y,[62]=hb},b,h,nil),ChilliState;Hb.agKick=function()local Hb=ChilliState;if Hb.agBusy then return;elseif not IsScriptActivethen return;end;local Hb,Vb=ChilliState,ChilliState;Hb.agBusy,_b.since,Vb.agAt=true,os.clock(),os.clock();task.spawn(function()if not(pcall(Xb,os.clock()))then local Xb=hb[52];Xb();end;end);end;local Xb,Hb,Vb=false,false,false;local function Rb()local vb=Y[26];local Pb,cb=vb.antiGuard;if Pb then vb=ChilliState;local Bb,xb=vb.tpNow;if Bb then local Tb=Y[26];xb=Tb.steal;else xb=Bb;end;Bb=nil;if xb then local Tb=ChilliState;Bb=Tb.tpCodium();else Bb=xb;end;cb=not Bb;else cb=Pb;end;vb=nil;if cb then Pb=ChilliState;vb=not Pb.agBusy;else vb=cb;end;Pb=nil;if vb then cb=ChilliState;Pb=not cb.rag;else Pb=vb;end;cb=nil;if Pb then local Bb,xb=Y[4];if Bb then vb=Y[4].name~=" Steal ";if vb then xb=vb;else local vb=ChilliState;local Tb=vb.cmode(true)~=" Tween ";if Tb then vb=ChilliState;xb=vb.cmode(true)~=" Teleport ";else xb=Tb;end;end;else xb=Bb;end;cb=not xb;else cb=Pb;end;return cb;end;local function vb()local Pb=Vb;Vb=Xb or Hb;if Vb then if not(Pb)then if Rb()then local Pb=ChilliState;Pb.agKick();end;end;end;end;local Pb,Pb=LocalPlayer,tostring(LocalPlayer.UserId);local function cb()local Bb,xb=_b.area;if Bb then local Tb=getWorldInstance;xb=Tb(" Areas "," GuardAreas ",_b.area);else xb=Bb;end;Bb=xb and(xb:FindFirstChild(" Guard "));return Bb and Bb:GetAttribute(" GuardState ")~=" Sleeping "and(Bb:GetAttribute(" TargetPlayer ")==Pb or Bb:GetAttribute(" WakeTargetPlayer ")==Pb);end;task.spawn(function()local Pb=GameModules;local Bb=Pb.Egg;if Bb then if not(Bb.CarryChanged)then return;end;else return;end;V(Bb.CarryChanged,function(Pb)Xb=type(Pb)==" table "and Pb.IsCarrying==true and Pb.GuardDisabled~=true;_b.area=Xb and type(Pb.AreaId)==" string "and Pb.AreaId or nil;_b.dirty=true;Pb=hb[59];if Pb then _b.dirty=nil;vb();end;end);end);local Xb,Pb=0,RunService;V(Pb.Heartbeat,function(Pb)local Bb=ChilliState;if Bb.agBusy then local xb,Tb,Tb,Tb=os.clock()-_b.since,hb[54],hb[54],math.max(hb[54]().busy,hb[54]().rel+1);if xb>Tb then local xb=hb[52];xb();end;end;if _b.dirty then _b.dirty=nil;vb();end;if Kb then if Vb then if os.clock()-(_b.kAt or 0)>0.3 then if Rb()then if cb()then _b.kAt=os.clock();Bb=ChilliState;Bb.agKick();end;end;end;end;end;Xb+=Pb;Bb=Y[26];if Bb.antiGuard then if Xb<0.03 then return;end;else return;end;Xb=0;Pb=hb[62];Bb=Pb()~=nil;if Bb~=Hb then Hb=Bb;vb();end;end);table.insert(ChilliState.cleanup,hb[52]);end);Gb={Golden=Color3.fromRGB(255,206,84),Silver=Color3.fromRGB(205,216,236),Rainbow=Color3.fromRGB(255,120,220),Scrambled=Color3.fromRGB(186,120,255),Boss=Color3.fromRGB(255,104,104),Enchanted=Color3.fromRGB(104,236,255),Sakura=Color3.fromRGB(255,166,214),GreatBloom=Color3.fromRGB(176,255,166),Monstrous=Color3.fromRGB(150,255,110),Nitro=Color3.fromRGB(255,150,64),Spectral=Color3.fromRGB(110,235,220),Alien=Color3.fromRGB(181,255,165),Musical=Color3.fromRGB(255,130,210),DarkMatter=Color3.fromRGB(150,110,255)};S(" 12_hud#1 ",function()local hb=I(" TweenService ");local Gb=Color3.fromRGB;local Xb=UDim2.fromScale;local Hb=UDim2.fromOffset;local Vb=Vector2.new;local Kb=t.q;local _b=TweenInfo.new;local Rb=Enum.EasingStyle;local vb=Enum.EasingDirection;local Pb,cb,Bb=gethui and gethui()or I(" CoreGui "),{" Best Rarity "," Biggest Weight "," Best Mutation "," Highest Value "," Lowest Value "},{};Bb[cb[1]]=" Rarity ";Bb[cb[2]]=" Weight ";Bb[cb[3]]=" Mutation ";Bb[cb[4]]=" Value ";Bb[cb[5]]=" Lowest ";local xb=E.ByPath[" Farm > Auto Steal > Steal Priority "];local Tb=xb and xb.Value or cb[4];if xb then table.insert(xb.ls,function(qb)Tb=qb;end);end;local function qb()return X:GenerateGUID(false):gsub(" - "," "):sub(1,14);end;local function Fb(Db,Ub)return Db and(Db:FindFirstChild(Ub));end;local function Db(Ub)return Ub:FindFirstChildOfClass(" UIGradient ");end;local function Ub(Zb)return(Zb and Zb.Value)==true;end;local function Zb()local rb,fb,jb,db={},{},0,ChilliState;for Jb,Jb in ipairs(db.pick)do if not(fb[Jb])then fb[Jb]=true;rb[#rb+1]=Jb;end;end;db=Y[26];if db.steal then local db,Jb=ChilliState,ChilliState;for nb,Qb in ipairs(db.stealSort(Jb.allEggs()))do if Qb.tg then if fb[Qb.Uid]then else if jb<8 then nb=jb+1;fb[Qb.Uid]=true;rb[#rb+1]=Qb.Uid;jb=nb;else end;end;else end;end;end;jb=ChilliState;return rb,jb.curUid;end;local function rb()local fb=ChilliState;fb.rank.Steal=0;fb=ChilliState;if fb.order then local fb=ChilliState;fb.order();end;end;local function fb(jb)local db,db=ChilliState,table.find(ChilliState.pick,jb);if db then table.remove(ChilliState.pick,db);end;end;local function jb(db)fb(db);table.insert(ChilliState.pick,1,db);local Jb=ChilliState;Jb.skip[db]=nil;rb();Jb=ChilliState;Jb.retarget();end;local function db(Jb)fb(Jb);local fb=ChilliState;if fb.curUid==Jb then local fb=ChilliState;fb.stopSteal();end;end;local function fb()local Jb=Y[26];if not(Jb.steal)then local Jb=ChilliState;if Jb.autoSteal then local Jb=ChilliState;Jb.autoSteal:Set(true);end;end;end;local function Jb(nb,Qb)local mb=Zb();local ib=table.find(mb,nb);nb=ib and ib+Qb;if nb then if not(mb[nb])then return;end;else return;end;mb[ib],mb[nb]=mb[nb],mb[ib];local Qb,eb=math.max(ib,nb),#mb;for nb=1,eb,1 do ib=nil;ib,Qb=ChilliState,if table.find(ChilliState.pick,mb[nb])then math.max(Qb,nb)else Qb;end;table.clear(ChilliState.pick);table.move(mb,1,Qb,1,ChilliState.pick);rb();end;local function nb()pcall(function()local Qb=Fb(I(" SoundService ")," Gameplay ");local mb=_(" Sound ",{SoundId=" rbxassetid://100671636189844 ",Volume=3.4,PlaybackSpeed=0.93+math.random()*0.13,SoundGroup=Qb and Qb:IsA(" SoundGroup ")and Qb or nil,Parent=Pb});mb:Play();I(" Debris "):AddItem(mb,3);end);end;local Qb=_b(0.3,Rb.Back,vb.Out);local mb=_b(0.24,Rb.Quad,vb.In);local ib=_b(0.22,Rb.Quad,vb.In);local eb=_b(0.16,Rb.Quad,vb.Out);local function Lb(ab,Eb,ub)local Wb=hb:Create(ab,Eb,ub);Wb:Play();return Wb;end;local function hb(...)local ab,Eb={...},{};for ub=1,#ab,2 do Eb[#Eb+1]=ColorSequenceKeypoint.new(ab[ub],ab[ub+1]);end;return ColorSequence.new(Eb);end;local function ab(Eb,ub,Wb,pb,kb)return{Color=ColorSequence.new(Eb,ub),Rotation=Wb,Stroke=pb,Light=kb};end;local Eb={};Eb.Hud=ab(Gb(0,118,255),Gb(72,204,255),-90,Gb(0,28,76),Gb(172,226,255));Eb.Steal=ab(Gb(60,255,0),Gb(136,255,0),-90,Gb(11,72,0),Gb(190,255,180));Eb.Queued=ab(Gb(118,118,132),Gb(172,172,186),-90,Gb(28,28,34),Gb(214,214,226));Eb.Pri=ab(Gb(25f.Position=S(Cb.e<0 and-0.025/pb or 1+0.025/pb,0,0.558,0);Cb.f.Size=S(0.2612044513/pb,0,1,0);Cb.pd.PaddingTop=H(0.067/kb,0);end;g=nil;tK();wK:Reflow();end);t.Parent=bK;wK:Mgr();return wK;end;eb.Resize=function(t,g,Q)local db=t.gui.AbsoluteSize;if db.X<=0 then return;elseif db.Y<=0 then return;end;t.size=s(D(g/db.X,0.2,0.98),D(Q/db.Y,0.22,0.98));t.main.Size=t.size;db,g=U(1,t.size.X.Scale/t.base.X.Scale),U(1,t.size.Y.Scale/t.base.Y.Scale);if r(db-pb)<1.0E-4 then if r(g-kb)<1.0E-4 then return;end;end;pb,kb=db,g;for t,t in ipairs(ob)do cb(t);end;end;eb.Scale=function(t,g)local Q=t.gui.AbsoluteSize;t:Resize(t.base.X.Scale*Q.X*g,t.base.Y.Scale*Q.Y*g);end;eb.Show=function(t,g)g=if g==nil then not t.open else g;if t.open==g then return;end;t.open=g;local Q,db,ob=t.main,t.rest,t.wt~=nil;if t.wt then t.wt:Cancel();end;t.anim=true;if g then if not(ob)then Q.Position=S(db.X.Scale,db.X.Offset,db.Y.Scale+0.245,db.Y.Offset);end;Q.Size=t.size;t.wt=_b(Q,{Position=db},0.34,o);else lb();t.dragStop();Q.Size=t.size;t.wt=_b(Q,{Position=S(db.X.Scale,db.X.Offset,1.55,0)},0.26,o,N.EasingDirection.In);end;local g=t.wt;local function Q(o)if t.wt==g then t.wt=nil;if o==N.PlaybackState.Completed then t.anim=false;end;end;end;g.Completed:Connect(Q);end;eb.Reflow=function(t)local g,Q=ipairs,t.cols;for o,db in g(Q)do local g={};for Q,Q in ipairs(t.Tabs)do if Q.ci==o then g[#g+1]=Q;end;end;o=#g;if o>0 then local t=Z(0.13,0.895*kb/(o+(o-1)*0.1769230769230769))/kb;db.ly.Padding=H(t*0.1769230769230769,0);for Q,o in ipairs(g)do o.btn.LayoutOrder,o.btn.Size=Q,S(1,0,t,0);end;end;end;end;eb.Tab=function(t,g,Q,o)local db=t;local t=setmetatable({W=db,Name=g,Disp=o or g,Sections={},q=" ",ci=Q==" Right "and 2 or 1},ub);t.btn,t.base=Db({p=db.cols[t.ci].f,n=o or g,S=S(1,0,0.13,0),O=#db.Tabs+1,Text=o or g});local Q=Gb(" ScrollingFrame ",{p=db.main,n=g.." Page ",a=true,A=R,T=1,C=true,Z=5,CanvasSize=X(0,0),ScrollBarImageColor3=V,ScrollingDirection=N.ScrollingDirection.Y,VerticalScrollBarInset=N.ScrollBarInset.None,V=false});t.page=Q;t.ly=Gb(" UIListLayout ",{p=Q,n=" ContentLayout ",H=p,Y=d,G=H(0,2)});Gb(" UIPadding ",{p=Q,n=" ContentPadding ",PaddingLeft=H(0.014000000432133675,0),PaddingRight=H(0.014000000432133675,0)});local g=-1;t.canvas=function()local o=f(t.ly.AbsoluteContentSize.Y);local ob=o>0 and f(o+U(8,Q.AbsoluteSize.Y*0.06/kb))or 0;if r(ob-g)>=1 then g=ob;Q.CanvasSize=X(0,ob);end;o=U(0,ob-Q.AbsoluteSize.Y);if Q.CanvasPosition.Y>o then Q.CanvasPosition=O(Q.CanvasPosition.X,o);end;end;Ab(t.ly," AbsoluteContentSize ",t.canvas);Ab(Q," AbsoluteSize ",function()Q.ScrollBarThickness=U(2,F(Q.AbsoluteSize.X*0.006/pb+0.5));t.canvas();end);yb(function()local g,o=0.1454/kb,1-0.01500005/kb;Q.Position,Q.Size=S(0.5000000596046448,0,(g+o)/2,0),S(0.9900000095367432,0,o-g,0);end);Fb(t.btn,function()db:Select(t);end);db.Tabs[#db.Tabs+1]=t;db:Reflow();if not(db.Cur)then db:Select(t);end;return t;end;eb.Select=function(t,g)if type(g)==" string "then local Q,o=ipairs,t.Tabs;for db,db in Q(o)do if db.Name==g then g=db;else end;end;else end;if type(g)~=" table "then return;end;lb();for Q,Q in ipairs(t.Tabs)do Q.page.Visible=Q==g;local o,db=Q.base,{};db.BackgroundColor3=Q==g and G(255,54,54)or G(175,0,0);_b(o,db,0.14);end;t.Cur=g;t.sbQuiet=true;t.sbox.Text=g.q;t.sbQuiet=false;task.defer(function()for t,t in ipairs(g.Sections)do t:Fit();end;g.canvas();end);cb(g.onOpen);end;local function t(g)return S(0.97,0,0,g);end;local g,Q,o,db,kb,ob=0.22,0.09999999633202186,0.67569,0.3388905,0.5388904999999999,0.6192006943127453;ub.Section=function(ub,Cb,wK,bK)local hK,tK=ub.W,ub;local zK=setmetatable({W=hK,t=ub,Name=Cb,Disp=bK or Cb,open=wK~=false,rows={},n=0},Wb);zK.f=gb({p=ub.page,n=Cb.." Section ",T=1,S=Nb(0),AutomaticSize=N.AutomaticSize.Y,O=#ub.Sections+1,Z=3,Gb(" UIListLayout ",{n=" SectionLayout ",H=p,Y=d,G=H(0,2)})});local YK=Kb({p=zK.f,n=bK or Cb,A=R,O=1,S=S(0.97,0,0,36),x=bK or Cb,W=true,Z=4},true);local Cb=gb({p=YK,n=" ArrowClip ",A=R,P=s(0.4,0.5),S=X(1,1),T=1,C=true,Z=6});local AK,IK=gb({p=Cb,n=" Arrow ",A=R,P=B,S=X(1,1),T=1,Z=6}),ipairs;hK={{g+Q*2,o+Q*2,e},{g,o,i}};for g,Q in IK(hK)do bK,wK=ipairs,{{db,45},{1-db,-45}};for o,o in bK(wK)do gb({p=AK,n=" Arm ",A=R,P=s(o[1],kb),R=o[2],S=s(Q[2],Q[1]),B=V,Z=5+g,Xb(Q[3])});end;end;local function g()local Q,o=YK.AbsoluteSize.X,YK.AbsoluteSize.Y;if Q<=0 then return;elseif o<=0 then return;end;local db,kb=o*0.65,o*0.15;o=db*ob;Cb.Size=X(db*1.35,db*1.35);Cb.Position=S(0,U((Q-Z(YK.TextBounds.X,Q))/2-kb-o,o),0.5,0);AK.Size=X(db,db);end;local function Q()local o,db,kb=tK.page,Cb.AbsolutePosition.Y,Cb.AbsolutePosition.Y+Cb.AbsoluteSize.Y;Cb.Visible=db>=o.AbsolutePosition.Y and kb<=o.AbsolutePosition.Y+o.AbsoluteSize.Y;end;Ab(YK," TextBounds ",g);Ab(YK," AbsoluteSize ",g);Ab(YK," AbsolutePosition ",Q);Ab(tK.page," CanvasPosition ",Q);Fb(Sb({p=YK,n=" SectionButton ",S=T,Z=8}),function()zK:Expand(not zK.open);end);zK.hd=YK;zK.ar=AK;zK.g=gb({p=zK.f,n=" CollapsibleContent ",T=1,C=true,O=2,S=Nb(0),Z=3});zK.b=gb({p=zK.g,n=" Content ",T=1,S=Nb(0),AutomaticSize=N.AutomaticSize.Y,Z=3,Gb(" UIListLayout ",{n=" OptionLayout ",H=p,Y=d})});Ab(zK.b," AbsoluteSize ",function()if not(zK.tw)then zK.g.Size=S(1,0,0,zK.open and zK.b.AbsoluteSize.Y or 0);end;if r(zK.b.AbsoluteSize.X-(zK.lw or 0))>0.5 then zK.lw=zK.b.AbsoluteSize.X;zK:Fit();end;end);yb(function()zK:Fit();end);ub.Sections[#ub.Sections+1]=zK;zK:Expand(zK.open,false);task.defer(function()zK:Fit();g();Q();end);return zK;end;Wb.Fit=function(g)local Q=g.f.AbsoluteSize.X;Q=if Q<=0 then g.t.page.AbsoluteSize.X else Q;if Q>0 then g.hd.Size=S(0.97,0,0,U(1,F(Q/pb*0.97/16+0.5)));end;for Q,Q in ipairs(g.rows)do if Q.fit then Q.fit();end;end;end;Wb.Expand=function(g,Q,o)lb();g.open=Q;if g.tw then g.tw:Cancel();g.tw=nil;end;local db=g.g;local ub=Q and g.b.AbsoluteSize.Y or 0;db.ClipsDescendants=true;if Q then db.Visible=true;end;if o==false then db.Size,db.Visible,db.ClipsDescendants,g.ar.Rotation=Nb(ub),Q,not Q,Q and 0 or-90;return;end;local o,kb=g.ar,{};kb.Rotation=Q and 0 or-90;_b(o,kb,0.24);local Q=_b(db,{Size=Nb(ub)},0.28,y);g.tw=Q;local function o()if g.tw==Q then g.tw=nil;db.Visible,db.ClipsDescendants=g.open,not g.open;db.Size=S(1,0,0,g.open and g.b.AbsoluteSize.Y or 0);end;end;Q.Completed:Connect(o);end;local function g(Q,o,db)Q.nt=Vb(Kb({p=Q.m,n=" Note ",A=v,P=s(0.025,0.755),S=sll(w.Apply);end;table.clear(N.pa);N.dirty=true;end;if N.dirty then if I then if os.clock()-g>=0.1 then A=os.clock();N.dirty=false;g=A;local w,h=pcall(t);if not(w)then N.dirty=true;if not(N.warned)then N.warned=true;b.errs[#b.errs+1]=" canvas "..j(h);end;end;end;end;end;end);end;Wb.CreateCanvas=Wb.Surface;Wb.CreateText=function(w,h)return w:Text(h.Name,h.Text);end;Wb.CreateToggle=function(w,h)return w:Toggle(h.Name,h.Default,h.Callback,h.Note);end;Wb.CreateDropdown=function(w,h)return w:Dropdown(h.Name,h.Options,h.Default,h.Callback,h.Multi,h.Note);end;end;return b;end;end;end,fI=function(w,b,h,t,z,Y,A,I,g,N,G,S,s)if z<=163 then if z<=161 then local X,O=0,Y[5];local H,V=w[123](O,N),1+N;if H<=150 then return 59,I,Y,N,S,G,X,O,H;else return 52,I,X,N,S,O,H,s,t;end;elseif z<=162 then return 98,I[4],Y,N,S,G,b,s,t;else local X,O,H,V=I[5],s(g),w[6],N+Y;local K=w[123](G,V);if K>=128 then return 91,X,O,H,V,G,K,s,t;else return 166,X,O,H,V,K,b,s,t;end;end;elseif z<=164 then return 206>=b and 14 or 106,I,Y,N,S,G,b,s,t;elseif z<=165 then local z=(A+t*S)%256;w[101](g,h,(w[9](w[123](G,Y+h),b,z)));return 33,I,Y,N,z,G,b,s,t;else return 81,I,Y,N,S+1,G,b,s,t;end;end,w=function(w,w,b,h,t,z,Y,A)if h<=65 then if Y==0 then return 105,b,Y,t;else return 120,b,w,t;end;else local w,h=(t-128)*128,16384*(A-128);local t=w+z+h;return 70,3+b,Y,t;end;end,T=function(w,b,h,t,z,Y,A,I,g)if t<=94 then local N,G,S=h[3],h[5],h[1];local s,X=N+G,G<=0;N,G=s>=S,s<=S;S=X and N or not X and G;h[3]=s;if S then return 60,z,Y,I,s;else return 98,z,Y,I,g;end;elseif t<=95 then local h=I-128;local t=A*128+h;return 35,2+z,Y,t,g;else local h=w[123](b,2+z);return 128<=h and 123 or 119,z,h,I,g;end;end,[57]=buffer.writestring,[104]=buffer.writef64,[82]=table.move,[35]=2.14304743E8,cw=function(w,b,h,t,z,Y,A,I,g,N,G,S,s,X)if b<=128 then local O,H,V=1+N,145,27;local K,_=0,(H*((228+A)%256)+V)%256;return 119,O,228,H,V,K,_,w[101],w.tI,w[123](X,K+O),w[9];elseif b<=129 then return 47,s,N,1+A,t,Y,z,h,I,G,S;else local b,s,O,O,H=N+1,(101+A)%256,0,w[14],w.tI;local V=w[22](X,0+b);O(H,0,(w[9](w.NI[s],V,1701143909)));b=w.SI[s];return 145,w[125](w.tI,g),N,A,t,Y,z,h,I,G,S;end;end,Ow=function(w,b,h,t,z,Y,A,I,g)if t<=98 then local N,G=Y-1,1+0;return 92,{I-G,nil,N+0,G,z},g,b;elseif t<=99 then local t,I=w[94](3*g),1+0;return 20,{I,1-I,g+0,nil,z},t,b;else local t=w[123](A,3+g);local w,A,I,N=2097152*(b-128),(Y-128)*16384,h-128,t%128*128;local b=(t-t%128)*2097152+w+A+(N+I);return 90,z,g+4,b;end;end,J={43220,4224182433,1101652741,2907877367,2732551145,3175966666,1338680352,863295049,1044496931},NI={},[77]=2.592941504E9,[71]=function(w,b,b,h,t,z,Y,A,I,g,N,G,S,s,s,X,O,O)local O,H,V,K,_,R,v,P,c,B,x,T,q,F,D,U,Z,r,f=w[94],w[82],w[76],w[109],w[53],w[84],w[9],w[123],w[14],w[22],w[101],w[46],w.TI,w[11],w[92],w.BI,w[28],w[103],w[75];return function(j,j)local d,J,n,Q,m,i,e,L,a,E,u,W,p,k,o,y,M,l,C=O,H,V,K,_,R,v,P,c,B,x,T,q,F,D,U,Z,r,f;return function(...)local O,H,V,K,_,R,v,P,c,B,x,T;local q,F,D,U,Z=LocalPlayer;local r,f=Y[2],d(X);local Y,X;if g==248 then Y,X=s,g;while true do local wb=N[Y];if wb<81 then if wb>=40 then if wb<60 then if wb<50 then if wb>=45 then if wb<47 then if wb~=46 then f[h[Y]][t[Y]]=b[Y];else f[G[Y]]=f[h[Y]]();end;elseif wb<48 then f[A[Y]]=d(h[Y]);elseif wb==49 then f[A[Y]](f[G[Y]],z[Y]);else f[G[Y]]=f[h[Y]]-A[Y];end;else if wb<42 then if wb==41 then H,B,Z=h[Y],G[Y],A[Y];U,_=f[H],H+B;x=f[_];J(f,H+1,_-1,Z+1,U);J(x,1,x.n,Z+B,U);else f[A[Y]]=f[h[Y]]//f[G[Y]];end;else if wb<43 then f[A[Y]][t[Y]]=f[h[Y]];else if wb~=44 then H=h[Y];f[H],f[H+1]=f[G[Y]],b[Y];else H,B,Z=h[Y],G[Y],A[Y];U=H+B;_=f[U];x=_.n;v=B+x-1;_.n=v;J(_,1,x,B,_);J(f,H+1,U-1,1,_);f[H]=n(f[H](Q(_,1,_.n)));end;end;end;end;else if wb<55 then if wb>=52 then if wb>=53 then if wb~=54 then f[A[Y]]=w[G[Y]];else f[A[Y]][f[G[Y]]]=f[h[Y]];end;else local bb,hb,tb=h[Y],e(G[Y],(i(e(q,(i(m(q,29),7))),536870911))),I[6];local zb=e(tb[bb],371010975);tb[bb]=zb;tb,bb=I[5],zb+1;zb=L(tb,bb);local Yb,Ab;if zb<128 then Yb,Ab=zb,bb+1;else local Ib=L(tb,bb+1);if Ib<128 then Yb,Ab=zb-128+Ib*128,bb+2;else local gb=L(tb,bb+2);if gb<128 then Yb,Ab=(zb-128)*128+(Ib-128)*16384+gb,bb+3;else local Nb=L(tb,bb+3);Yb,Ab=(zb-128)*2097152+(Ib-128)*16384+(gb-128)+Nb%128*128+(Nb-Nb%128)*2097152,bb+4;end;end;end;bb,zb=hb*16843009,Ab+Yb;local Ib=zb-Yb%4;for Yb=Ab,Ib-1,4 do a(tb,Yb,(e(E(tb,Yb),bb)));end;for bb=Ib,zb-1,1 do u(tb,bb,(e(L(tb,bb),hb)));end;h[Y]=93;G[Y]=210;A[Y]=5;N[Y]=98;end;elseif wb~=51 then f[A[Y]][f[G[Y]]]=z[Y];else f[A[Y]]=j[h[Y]][f[G[Y]]];end;else if wb<57 then if wb~=56 then f[h[Y]]=e(f[A[Y]],f[G[Y]]);else f[h[Y]]=f[A[Y]];end;else if wb>=58 then if wb==59 then f[G[Y]]=f[h[Y]]..b[Y];else f[h[Y]]=f[G[Y]]~=A[Y];end;else H,B=G[Y],h[Y];Z={n=B-H+1};J(f,H,B,1,Z);f[A[Y]]=Z;end;end;end;end;else if wb<70 then if wb<65 then if wb<62 then if wb~=61 then H=j[A[Y]];f[G[Y]]=H[4][H[6]];else q=f[h[Y]];end;else if wb>=63 then if wb==64 then B,H=h[Y],A[Y]+1;for bb=1,G[Y],1 do B=i(e(B,(W(B,13))),536870911);B=e(B,(m(B,13)));B=i(e(B,(W(B,14))),536870911);h[H]=e(h[H],(i(m(B,0),127)));G[H]=e(G[H],(i(m(B,7),127)));A[H]=e(A[H],(i(m(B,14),127)));N[H]=e(N[H],(i(m(B,21),127)));H=H+1;end;N[Y]=98;else f[A[Y]]=-f[h[Y]];end;else f[A[Y]](z[Y],t[Y]);end;end;else if wb<67 then if wb==66 then Y=f[h[Y]];else p[b[Y]]=f[h[Y]];end;else if wb>=68 then if wb~=69 then f[h[Y]]=A[Y]-f[G[Y]];else f[A[Y]]=f[h[Y]](Q(f[G[Y]],1,f[G[Y]].n));end;elseif D then local bb=A[Y];local hb=D[bb];if hb then hb[4]=hb;hb[5]=f[bb];hb[6]=5;D[bb]=nil;end;hb=h[Y];bb=D[hb];if bb then bb[4]=bb;bb[5]=f[hb];bb[6]=5;D[hb]=nil;end;end;end;end;else if wb<75 then if wb>=72 then if wb<73 then f[G[Y]]=f[h[Y]]~=f[A[Y]];elseif wb==74 then f[h[Y]]=f[A[Y]]<=f[G[Y]];else f[G[Y]]=f[A[Y]]*h[Y];end;elseif wb==71 then local bb,hb,tb=G[Y],f[h[Y]],A[Y];local zb,Yb=i(hb,4294967295),i(tb,4294967295);local hb,tb,Ab,Ib=i(zb,65535),m(zb,16),i(Yb,65535),m(Yb,16);zb=i(hb*Ab+W(i(hb*Ib+tb*Ab,65535),16),4294967295);tb=nil;repeat Ab=zb%4294967296;if Ab~=Ab then tb=0;break;end;tb=Ab-Ab%1;until true;f[bb]=tb;else f[h[Y]]=f[A[Y]]+G[Y];end;else if wb>=78 then if wb>=79 then if wb~=80 then H=A[Y];f[H],f[H+1]=G[Y],f[h[Y]];else f[A[Y]]={};end;else Y=if f[h[Y]]<A[Y]then Y else G[Y];end;else if wb<76 then f[A[Y]]=h[Y]<f[G[Y]];else if wb~=77 then H=f[h[Y]];f[G[Y]]=n(Q(H,A[Y],H.n));else Hace" ,false,function ( vb ) if not ( vb ) then
bb ( Vb ) ;
end ;
end ) ;
y ( Kb, "Place And Hatch Missing Index Eggs" , "placeIdx" ) ;
local vb,Pb,cb,Bb= {
Always= "Always" ,[ "Steal Idle" ]= "Steal is idle" ,[ "After Steal" ]= "Right after a steal" ,[ "Night Only" ]= "Only at night"
} , {
[ "Biggest Size" ]= "Biggest" ,[ "Highest Value" ]= "Best value" ,[ "Smallest Size" ]= "Smallest" ,[ "Lowest Value" ]= "Lowest value" ,[ "Backpack Order" ]= "Backpack"
} ,Y[26],Y[26] ;
cb.placeWhen= "Always" ;
Bb.placeFirst= "Best value" ;
Kb:Dropdown ( "Place Egg Rule" , {
"Always" , "Steal Idle" , "After Steal" , "Night Only"
} , "Always" ,function ( cb ) local xb=Y[26] ;
xb.placeWhen=vb[cb]or "Always" ;
end ,false,nil,Rb ) ;
Kb:Dropdown ( "Place Egg Order" , {
"Biggest Size" , "Highest Value" , "Smallest Size" , "Lowest Value" , "Backpack Order"
} , "Highest Value" ,function ( vb ) local cb=Y[26] ;
cb.placeFirst=Pb[vb]or "Best value" ;
end ,false,nil,Rb ) ;
local vb,Pb,cb= {
} , {
} ,ChilliState ;
Bb=#cb.RANY ;
for xb=2,Bb,1 do
cb=nil ;
cb,Pb[#Pb+1]=ChilliState,ChilliState.RANY[xb] ;
end ;
local function cb ( Bb ) local xb,Tb=ipairs ;
for qb,Fb in xb ( Bb ) do
Tb=Tb or {
} ;
qb=ChilliState ;
Tb[qb.RIDX[Fb]or 0]=true ;
end ;
vb.rar=Tb ;
end ;
Kb:Dropdown ( "Place Rarities" ,Pb, {
} ,cb,true, "Only place eggs of the picked rarities (empty = all)" ,Rb ) ;
Pb=ChilliState ;
local function cb ( Bb ) local xb=ChilliState ;
vb.sp=xb.names ( Bb ) ;
end ;
Kb:Dropdown ( "Place Specific Eggs" ,Pb.eggList, {
} ,cb,true, "Only place these eggs (empty = all)" ,Rb ) ;
Kb:Slider ( "Min Place Value" ,0,0,0,function ( Pb ) vb.minV=Pb>0 and Pb or nil ;
end , "log" ,nil, "Skip eggs worth less than this (0 = off)" ,Rb ) ;
Kb:Slider ( "Max Place Value" ,0,0,1000,function ( Kb ) vb.maxV=Kb>0 and Kb<1000000000000 and Kb or nil ;
end , "log" ,nil, "Only place eggs worth less than this, keep the better ones (far right = no limit)" ,Rb ) ;
local Kb,Rb=0,ChilliState ;
local Pb,Bb=Rb.onSteal,ChilliState ;
Bb.onSteal=function ( Rb ) Kb=os.clock ( ) ;
if Pb then
Pb ( Rb ) ;
end ;
end ;
local function Rb ( ) local Pb=Y[63] ;
local Bb,xb,Tb,qb,Fb=Pb ( ) ,Vector3.zero,next, {
} ,ChilliState ;
w:XI ( qb,0,workspace:FindFirstChild ( "PlacedEggRenders" ) ,Fb.hidden ) ;
Pb=0 ;
for Db,Ub in Tb,qb,nil do
Db,Fb=ipairs,w[76] ( Ub:GetChildren ( ) ) ;
for Tb,qb in Db ( w:iI ( Fb ) ) do
if qb:IsA ( "Model" ) then
Tb,Ub=LocalPlayer,qb.Name:find ( LocalPlayer.UserId.. "_" ,1,true ) ;
if Ub==1 then
local Tb,Fb=Pb+1,xb+qb:GetPivot ( ) .Position ;
Pb,xb=Tb,Fb ;
else
end ;
else
end ;
end ;
end ;
if Pb>0 then
return xb/Pb ;
end ;
return Bb and Bb.PetArea and Bb.PetArea.Position ;
end ;
local Pb=w:zI ( 17,18, {
[63]=Y,[20]=Y,[28]=Y
} ,b,h,nil ) ;
local function Bb ( xb ) local Tb=callRequiredModuleMethod ;
if Tb ( "Egg" , "WearEggTool" ,xb ) ==false then
return false ;
end ;
Tb=os.clock ( ) +2 ;
while os.clock ( ) <Tb do
if hb ( ) ==xb then
return true ;
end ;
if os.clock ( ) >Tb-1.3 then
local Tb,qb=ipairs,n ( ) and n ( ) :GetChildren ( ) or {
} ;
for Fb,Fb in Tb ( qb ) do
if Fb:GetAttribute ( "UID" ) ==xb then
local xb,xb=getHumanoid,getHumanoid ;
pcall ( getHumanoid ( ) .EquipTool,getHumanoid ( ) ,Fb ) ;
end ;
end ;
end ;
task.wait ( 0.1 ) ;
end ;
return false ;
end ;
cb=ChilliState ;
cb.wear=Bb ;
local function cb ( ) local xb=Y[26] ;
local Tb=xb.placeWhen ;
if Tb== "Steal is idle" then
xb=Y[26] ;
local qb=xb.steal ;
return if qb then
Sb.empty~=nil
else
not qb ;
end ;
if Tb== "Right after a steal" then
xb=os.clock ( ) -Kb ;
return xb<12 ;
end ;
if Tb== "Only at night" then
return e ( ) <14 ;
end ;
return true ;
end ;
local function Sb ( ) local Kb,xb,Tb,qb=Q ( ) , {
} , {
} ,Y[26] ;
local Fb,Db=qb.placeIdx ;
if Fb then
qb=ChilliState ;
Db=qb.indexMissing ( ) ;
else
Db=Fb ;
end ;
local Ub,Zb,rb=Db or {
} , {
} ,0 ;
for fb,fb in pairs ( Kb ) do
if type ( fb ) == "table" then
if fb.Placement then
Fb=rb+1 ;
Zb[fb.AssetCategory or fb.Category or "" ]=true ;
rb=Fb ;
else
end ;
else
end ;
end ;
qb=pairs ;
for fb,jb in qb ( Kb ) do
if type ( jb ) == "table" then
if not ( jb.Placement ) then
if ( Vb.bad[fb]or 0 ) <os.clock ( ) then
Db=ChilliState ;
if not ( Db.reserved[fb] ) then
Fb=ChilliState ;
if not ( Fb.protect ( fb,jb ) ) then
local db=d ( jb ) ;
db.uid=fb ;
if Ub[db.cat]and not Zb[db.cat]then Zb[db.cat]=true ;
Tb[#Tb+1]=db ;
else
local Ub=Y[26] ;
if Ub.place then
local Ub=Y[67] ;
if Ub ( vb,db ) then
xb[#xb+1]=db ;
end ;
end ;
end ;
end ;
end ;
end ;
end ;
end ;
end ;
qb=Y[64] ;
local Ub,Zb=qb ( ) ,0 ;
for fb in next,Ub and type ( Ub.EquippedAssets ) == "table" and Ub.EquippedAssets or {
} ,nil do
Zb+=1 ;
end ;
Db=0 ;
for fb,fb in pairs ( Kb ) do
Db=if type ( fb ) == "table" then
if fb.Placement then
Db
else
Db+1
else
Db ;
end ;
Fb,qb=pcall ( function ( ) local fb=GameModules ;
return fb.Bases.GetAssetEquipCapacity ( Ub and tonumber ( Ub.BaseUpgradeLevel ) or 0 ) ;
end ) ;
_b ( vb.maxV and vb.maxV<= ( vb.minV or 0 ) and "Max Place Value must be above Min Place Value, nothing will be placed" or ( "Eggs placed %d/%d - %d/%d pets equipped, %d in bag" ) :format ( rb,30,Zb,Fb and tonumber ( qb ) or 0,Db ) ) ;
return rb,xb,Kb,Tb ;
end ;
local Kb=wb ( {
name= "PlaceInfo" ,gap=2,info=true
} ) ;
Kb.on=function ( ) return L ( "Farm" ) ;
end ;
Kb.fn=Sb ;
Vb.want=function ( ) local Kb,_b,vb,xb=Sb ( ) ;
if Kb>=30 then
return ;
elseif
#_b+#xb==0 then
return ;
elseif
#xb==0 then
if not ( cb ( ) ) then
return ;
end ;
end ;
local Sb=Y[26] ;
if Sb.placeFirst~= "Backpack" then
local Sb=Y[26] ;
Hb ( _b,Sb.placeFirst ) ;
end ;
for Sb,cb in ipairs ( xb ) do
table.insert ( _b,Sb,cb ) ;
end ;
return {
list=_b,room=30-Kb,recs=vb
} ;
end ;
Vb.run=function ( Sb,Kb ) local _b=Rb ( ) ;
if not ( _b ) then
return ;
end ;
local Rb=Y[11] ;
Rb ( "Walking to your pen" ) ;
Rb=Vector3.new ;
if not ( tb ( _b+Rb ( 0,3,0 ) ,Kb ) ) then
return ;
end ;
local vb,cb,xb,Tb=Pb ( Sb.recs ) ,math.min ( Sb.room,#Sb.list ) ,0,0 ;
for Pb=1,cb,1 do
if not ( Kb ( ) ) then
break ;
end ;
Rb=Sb.list[Pb] ;
if Bb ( Rb.uid ) then
_b=false ;
for Sb=1,8,1 do
xb+=1 ;
Pb=vb[xb] ;
if not Pb then
break ;
end ;
Sb=invokeServerBoolean ;
if Sb ( "RF/EggWorld/AskPlaceEgg" , {
Uid=Rb.uid,LocalCFrame=Pb[1]
} ) then
Tb+=1 ;
local Sb=Y[42] ;
Sb.placed=Sb.placed+1 ;
_b=true ;
break ;
end ;
end ;
if not _b then
Vb.bad[Rb.uid]=os.clock ( ) +60 ;
end ;
task.wait ( 0.25 ) ;
else
Vb.bad[Rb.uid]=os.clock ( ) +20 ;
end ;
end ;
Rb=callRequiredModuleMethod ;
Rb ( "Egg" , "DoffEggTool" ) ;
if Tb>0 then
vb=Y[11] ;
vb ( "Placed " ..Tb.. " egg(s)" , "ok" ) ;
end ;
end ;
Vb.on=function ( ) local Sb=Y[26] ;
local Vb,Kb=Sb.place ;
if Vb then
Kb=Vb ;
else
Sb=Y[26] ;
Kb=Sb.placeIdx ;
end ;
return Kb ;
end ;
end ) ;
S ( "20_farm#2" ,function ( ) local Sb=wb ( {
name= "Hatch" ,gap=2,bad= {
} ,info=true
} ) ;
local Vb=Ib[ "Auto Hatch & Equip" ] ;
local Kb,_b=y ( Vb, "Auto Hatch" , "hatch" ,false ) ,ChilliState ;
local Rb,vb,Pb=_b.nostat, {
} ,ChilliState ;
local function cb ( Bb ) local xb=ChilliState ;
vb.rar=xb.minRar ( Bb ) ;
end ;
Vb:Dropdown ( "Hatch Min Rarity" ,Pb.RANY, "Any" ,cb,false, "Hatch eggs of the chosen rarity and every rarity above it" ,Kb ) ;
Vb:Slider ( "Min Hatch Value" ,0,0,0,function ( Pb ) vb.minV=Pb>0 and Pb or nil ;
end , "log" ,nil, "Skip eggs worth less than this (0 = off)" ,Kb ) ;
Vb:Slider ( "Max Hatch Value" ,0,0,1000,function ( Pb ) vb.maxV=Pb>0 and Pb<1000000000000 and Pb or nil ;
end , "log" ,nil, "Only hatch eggs worth less than this, keep the better ones (far righ+1]=function()p();g();Ub();end;xb.ls[#xb.ls+1]=function()for t,Y in ipairs(Mb)do Y.pn.Position=s(ob(t));end;end;Zb.ls[#Zb.ls+1]=wK;hb.qSync=function()wK();p();g();Ub();u();end;return ub;end;eb.ConfigTab=function(t)local Y=t;t=Y.setTab:Section(" Defaults ",true);t:Button(" Reset to Defaults "," Reset ",function()Y:Default();end," Reset every feature to its built-in default "," Done! ").Quick=false;t:Button(" Turn Off All Toggles "," Turn Off ",function()for g,g in ipairs(Y.Opts)do if g.Type==" toggle "then if g.Value then if g.Tab~=" Settings "then if g.Tab~=" Config "then if g.Tab~=" Quick "then g:Set(false);end;end;end;end;end;end;end," Switch off every enabled toggle in the feature tabs "," Done! ");local g,P=Y:Tab(" Config "," Right "),Y:List();t=g:Section(" Config ",true);local q=t:Text(" Startup Config "," Startup Config: "..Y.Startup);q.NoSave=true;local d=t:Toggle(" Auto Save Config ",Y.AutoSave,function(Q)if not(Y.ready)then return;end;Y.AutoSave=Q;Y:Mgr(true);if Q then Y:Save();end;end," Auto save: "..Y.Active);local Q=t:Toggle(" Auto Load Config ",Y.AutoLoad,function(u)if not(Y.ready)then return;end;Y.AutoLoad=u;Y:Mgr(true);if u then Y:Load(Y.Startup);end;end," Auto load: "..Y.Startup);d.Skip=true;Q.Skip=true;t=g:Section(" Profiles ",true);local u=t:Input(" New Co 