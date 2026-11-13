--[[
    ================================================================================
    MODULE 02: TREADMILL & SPEED AUTOMATION
    Chilli Hub / Steal An Egg Automation Engine
    ================================================================================
    
    DESCRIPTION:
    Controls the automated treadmill speed farming loop, automatic belt upgrades,
    speed gain listeners, treadmill hiding to improve performance, and anti-stuck
    respawn routines.
    
    KEY REMOTES & MECHANISMS:
    - RF/Treadmill/AskWearStill         = Mounts the player onto treadmill belt
    - RF/Treadmill/AskDoff              = Dismounts player safely
    - RF/Treadmill/AskTierRaise         = Upgrades treadmill tier/multiplier
    - RE/Treadmill/SpeedGained          = Real-time speed increase event
    - RE/Treadmill/AssignedBeltShifted  = Belt position change event
    - hideTread(duration)               = Hides treadmill visual mesh
    ================================================================================
]]

;
Zb=os.clock ( ) +0.6 ;
while os.clock ( ) <Zb and ( Fb ( ) ) do
local Fb,Ub,Zb=setPlayerCFrame,CFrame.new,Vector3.new ;
Fb ( Ub ( qb+Zb ( 0,3,4 ) ) ) ;
Db=HeartbeatWait ;
Db ( ) ;
end ;
end ;
local function qb ( Fb ) local Db=ChilliState ;
if Db.hideTread then
local Ub=ChilliState ;
Ub.hideTread ( 20 ) ;
end ;
if Y[13] ( Fb ) then
Db=Y[14] ;
if not ( Db ( Fb ) ) then
return false ;
end ;
else
return false ;
end ;
Db=getRootPart ;
local Ub,Zb=Db ( ) ,getRiftMachinePos ;
local rb,rb=Vector3.new,Zb ( ) +Vector3.new ( 0,3,0 ) ;
if Ub then
Zb=isInsideSafeZone ;
if Zb ( Ub.Position ) then
if ( Ub.Position-rb ) .Magnitude>6 then
Db=Y[50] ;
return Db ( rb,Fb,250 ) ;
end ;
end ;
end ;
return true ;
end ;
local function Fb ( Db,Ub ) local Zb=LocalPlayer ;
local rb=Zb.Character ;
local function fb ( ) local jb=Ub ( ) ;
local Ub ;
if jb then
local db=LocalPlayer ;
Ub=db.Character==rb ;
else
Ub=jb ;
end ;
return Ub ;
end ;
Zb=getRootPart ;
local Ub=Zb ( ) ;
if Ub then
Zb=isInsideSafeZone ;
if Zb ( Ub.Position ) then
if not ( qb ( fb ) ) then
return false ;
end ;
end ;
end ;
Ub=ChilliState ;
return Ub.reach ( Db,fb ) ;
end ;
local function Db ( Ub ) local Zb=Bb ( "NetStand" ) ;
if Zb then
local rb=ChilliState ;
if not ( rb.enterTree ( Ub ) ) then
return false ;
end ;
else
return false ;
end ;
local rb=false ;
for fb=1,5,1 do
if not ( Ub ( ) ) then
break ;
end ;
Tb ( Zb,Ub ) ;
fb=invokeServerWithTimeout ;
local Zb,jb=fb ( "RF/Butterflies/AskClaimNet" ) ;
rb=Zb and jb==true ;
if rb then
break ;
end ;
task.wait ( 0.8 ) ;
end ;
Ub=ChilliState ;
Ub.leaveTree ( ) ;
return rb or Rb ( ) .NetClaimed==true ;
end ;
local Ub ;
pcall ( function ( ) Ub=require ( N.Controllers.Game.AdminAbuseClientController.Events.ButterflyBloom.Swarm ) ;
end ) ;
local function Zb ( rb,fb ) local jb,db ;
local Jb=GameModules ;
local nb,Qb,mb=Jb.Cat,P ( ) , {
} ;
local function Jb ( ib,eb,Lb ) if typeof ( Lb ) ~= "Vector3" then
return ;
else
local ab=Nb ;
if not ( ab[eb.Tier] ) then
return ;
end ;
end ;
local Nb,Nb,Nb=Y[26],Y[26], ( Lb-rb ) .Magnitude/Y[26].bfSpeed- ( Y[26].bfPri~= "Nearest" and ( m[eb.Tier]or 0 ) *1000 or 0 ) - ( ib==fb and 1 or 0 ) ;
if if jb then
Nb<db
else
not jb then
jb,db= {
id=ib,p=Lb,f=eb
} ,Nb ;
end ;
end ;
if Ub then
if Ub.Each then
pcall ( function ( ) local m=Ub ;
for Nb,Ub in m.Each ( ) do
local m,rb=type ( Ub ) == "table" and Ub.Flight,type ( Ub ) == "table" and Ub.Body ;
if type ( m ) == "table" then
if typeof ( rb ) == "Instance" then
Ub=m.Id or Nb ;
mb[Ub]=true ;
Jb ( Ub,m,rb:IsA ( "BasePart" ) and rb.Position or rb:IsA ( "Model" ) and rb:GetPivot ( ) .Position ) ;
end ;
end ;
end ;
end ) ;
end ;
end ;
if nb and not next ( mb ) then
for m,Nb in next,Gb,nil do
if not ( mb[m] ) then
local Gb,Ub=pcall ( nb.PositionAt,Nb,Qb ) ;
if Gb then
Jb ( m,Nb,Ub ) ;
end ;
end ;
end ;
end ;
if jb then
local m,Nb=pcall ( nb and nb.VelocityAt,jb.f,Qb ) ;
local Gb,Ub=m and typeof ( Nb ) == "Vector3" ;
if Gb then
m=Vector3.new ;
Ub=m ( Nb.X,0,Nb.Z ) ;
else
Ub=Gb ;
end ;
Nb=nil ;
if Ub then
Nb=Ub ;
else
m=Vector3.zero ;
Nb=m ;
end ;
jb.v=Nb ;
end ;
return jb ;
end ;
a.want=function ( ) if not ( Hb ( ) ) then
return Pb ( "Waiting for the next Butterfly Bloom" ) ;
end ;
if not ( vb ( ) ) then
return Pb ( "Needs the Enchanted Tree for the net, finish the wisp quest" ) ;
end ;
if e ( ) <=0 then
return Pb ( "Night, waiting" ) ;
end ;
if not ( Kb ( ) ) then
local m=w[76] ( math.max ( Vb ( ) ,0 ) ) ;
return Pb ( ( "Bloom ends in %ds, not worth the trip" ) :format ( w:iI ( m ) ) ) ;
end ;
return _b ( ) or true ;
end ;
a.run=function ( m,Nb ) local Gb=ChilliState ;
if not ( Gb.needBody ( ) ) then
local Vb=ChilliState ;
if Vb.hideTread then
local Vb=ChilliState ;
Vb.hideTread ( 20 ) ;
end ;
return ;
end ;
Gb=getHumanoid ;
local Vb=Gb ( ) ;
if not ( Rb ( ) .NetClaimed ) then
Pb ( "Claiming the butterfly net" ) ;
if Y[13] ( Nb ) then
if not ( Db ( Nb ) ) then
return Pb ( "Could not claim the net" ) ;
end ;
else
return Pb ( "Could not claim the net" ) ;
end ;
end ;
local Kb,_b=typeof ( m ) == "Instance" and m.Position ;
if Kb then
_b=Kb ;
else
m=Vector3.new ;
_b= ( m ( 6700,74,-364 ) ) ;
end ;
Kb=getRootPart ;
local vb=Kb ( ) ;
local Db ;
if vb and ( vb.Position-_b ) .Magnitude>300 then
if os.clock ( ) <Xb then
return Pb ( "Ragdoll TP did not land, trying again soon" ) ;
end ;
pcall ( Vb.UnequipTools,Vb ) ;
if not ( qb ( Nb ) ) then
return Pb ( "Stuck on treadmill" ) ;
end ;
Kb=getRootPart ;
vb=Kb ( ) ;
if vb then
Gb=isInsideSafeZone ;
if Gb ( vb.Position ) then
m=Y[17] ;
if not ( m ( Nb, "Butterfly bloom" ) ) then
return ;
end ;
end ;
end ;
if not ( qb ( Nb ) ) then
return Pb ( "Stuck on treadmill" ) ;
end ;
local Ub=Vector3.new ;
local rb,fb=xb ( _b+Ub ( 0,0,6 ) ) ,LocalPlayer ;
local jb=fb.Character ;
local function db ( ) local Jb=Nb ( ) ;
local nb ;
if Jb then
local Qb=LocalPlayer ;
nb=Qb.Character==jb ;
else
nb=Jb ;
end ;
return nb ;
end ;
fb=false ;
for Jb=1,2,1 do
Pb ( ( "Ragdoll TP to the bloom (try %d/2)" ) :format ( Jb ) ) ;
fb=zb ( function ( ) return rb ;
end ,db ) ;
if fb then
break ;
elseif
not ( db ( ) ) then
break ;
end ;
task.wait ( 0.5 ) ;
end ;
Ub=LocalPlayer ;
if Ub.Character~=jb then
return Pb ( "Reset, going back to the safe zone" ) ;
end ;
fb=fb or ( if Nb ( ) then
if Fb ( {
Pos=rb,Name= "the bloom"
} ,Nb ) then
true
else
fb
else
fb ) ;
Ub=LocalPlayer ;
if Ub.Character~=jb then
return Pb ( "Reset, going back to the safe zone" ) ;
end ;
if not fb then
Xb=os.clock ( ) +10 ;
return Pb ( "Ragdoll TP did not land, trying again soon" ) ;
end ;
Db=vb ;
else
Db=vb ;
end ;
local Xb,vb,Ub,rb=os.clock ( ) ,os.clock ( ) ,0,RunService ;
local fb,jb=V ( rb.Stepped,function ( ) local db=Y[26] ;
if db.bfMode~= "Stand" then
return ;
elseif
os.clock ( ) -Ub<0.5 then
return ;
end ;
Ub=os.clock ( ) ;
local Ub,Jb=ipairs,w[76] ( g:GetPlayers ( ) ) ;
for nb,nb in Ub ( w:iI ( Jb ) ) do
db=LocalPlayer ;
for Ub,Ub in ipairs ( nb~=db and nb.Character and nb.Character:GetChildren ( ) or {
} ) do
if Ub:IsA ( "BasePart" ) then
if Ub.CanCollide then
Ub.CanCollide=false ;
end ;
end ;
end ;
end ;
end ) ,math.huge ;
local Ub=os.clock ( ) ;
local function db ( Jb ) if Jb.Magnitude<jb-2 or Jb.Magnitude<8 then
local nb,Qb,mb=Jb.Magnitude,os ;
mb,jb=Qb.cl d ;
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
Gb.cas and mb then
if ib then
if ab then
if not ( Wb ) then
db:Destroy ( ) ;
return false ;
end ;
else
db:Destroy ( ) ;
return false ;
end ;
else
db:Destroy ( ) ;
return false ;
end ;
else
db:Destroy ( ) ;
return false ;
end ;
for pb,pb in ipairs ( mb:GetChildren ( ) ) do
if pb~=eb then
if pb:IsA ( "GuiObject" ) then
if pb.Name~= "EmptyLast" then
pb:Destroy ( ) ;
end ;
end ;
end ;
end ;
local pb=Fb ( db, "EquipBest" ) ;
if pb then
pb:Destroy ( ) ;
end ;
pb=db:FindFirstChildOfClass ( "UIAspectRatioConstraint" ) ;
local kb,ob=pb and pb.AspectRatio or 1.25,I ( "UserInputService" ) .MouseEnabled ;
local PK=not ob ;
local FK,mK= ( if ob then
PK
else
1.2 ) or 1, ( if ob then
PK
else
1.15 ) or 1 ;
ob=0.86/mK ;
local eK=ob/kb ;
db.Size=Xb ( 0.3*FK,0.62*FK*mK ) ;
pb=pb or _ ( "UIAspectRatioConstraint" , {
Parent=db
} ) ;
pb.AspectRatio,pb.AspectType=ob,Enum.AspectType.FitWithinMaxSize ;
local function mK ( LK ) return UDim2.new ( LK.X,UDim.new ( LK.Y.Scale*eK,LK.Y.Offset ) ) ;
end ;
Jb.Size,Jb.Position,ib.Size=mK ( Jb.Size ) ,mK ( Jb.Position ) ,mK ( ib.Size ) ;
local LK=mb.AnchorPoint.Y ;
local function aK ( EK,uK ) mb.Size,mb.Position=UDim2.new ( mb.Size.X,UDim.new ( uK-EK,0 ) ) ,UDim2.new ( mb.Position.X,UDim.new ( EK+ ( uK-EK ) *LK,0 ) ) ;
end ;
FK,mK=mb.Size.Y.Scale,mb.Position.Y.Scale ;
aK ( ( mK-FK*LK ) *eK,1- ( 1- ( mK+FK* ( 1-LK ) ) ) *eK ) ;
FK=mb.Size.Y.Scale ;
pb,kb,PK=mb.Position.Y.Scale-FK*LK,0.1*eK,0.02*eK ;
local eK=_ ( "Frame" , {
BackgroundTransparency=1,BorderSizePixel=0,AnchorPoint=Vb ( 0.5,0 ) ,Position=Xb ( 0.5,pb+PK ) ,Size=Xb ( 0.9,kb ) ,Parent=db
} ) ;
aK ( pb+PK*1.5+kb,pb+FK ) ;
local function LK ( EK ) if EK then
pcall ( EK.Set,EK,EK.Value~=true ) ;
end ;
Kb ( KK ) ;
end ;
local function EK ( uK,WK ) local pK=ab:Clone ( ) ;
pK.Size=Xb ( 0.48,1 ) ;
pK.LayoutOrder=uK ;
pK.Parent=eK ;
pK.Activated:Connect ( WK ) ;
return rK ( pK ) ;
end ;
_K= {
Toggle=EK ( 1,function ( ) local uK=ChilliState ;
LK ( uK.autoSteal ) ;
end ) ,Guard=EK ( 2,function ( ) local uK=ChilliState ;
LK ( uK.agT ) ;
end )
} ;
pb=_K.Toggle.Button ;
pb.AnchorPoint,pb.Position=Vb ( 0,0.5 ) ,Xb ( 0,0.5 ) ;
_ ( "UIListLayout" , {
FillDirection=Enum.FillDirection.Horizontal,HorizontalAlignment=Enum.HorizontalAlignment.Center,VerticalAlignment=Enum.VerticalAlignment.Center,SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new ( 0.03,0 ) ,Parent=eK
} ) ;
pb=Db ( Jb ) ;
if pb then
pb.Color=hb ( 0,Gb ( 200,18,24 ) ,0.53,Gb ( 255,88,90 ) ,1,Gb ( 214,28,34 ) ) ;
end ;
sK=Fb ( Jb, "Title" ) ;
ub ( sK, "Steal Panel" ) ;
local hb=Fb ( Jb, "PlusEquip" ) ;
XK=hb and rK ( hb ) ;
if XK then
pb,ob,PK=hb.Size,hb.Position,hb.AnchorPoint.X ;
hb.AnchorPoint,hb.Position,hb.Size=Vb ( 1,hb.AnchorPoint.Y ) ,UDim2.new ( ob.X.Scale+pb.X.Scale* ( 1-PK ) ,ob.X.Offset+pb.X.Offset* ( 1-PK ) ,ob.Y.Scale,ob.Y.Offset ) ,UDim2.new ( pb.X.Scale*0.6,pb.X.Offset*0.6,pb.Y.Scale,pb.Y.Offset ) ;
jK ( XK,Eb.Steal ) ;
ub ( XK.Label, "Sort: " .. ( Bb[Tb]or tostring ( Tb ) ) ) ;
nK ( XK ) ;
local Gb=0 ;
local function Bb ( ) if os.clock ( ) -Gb<0.25 then
return ;
end ;
Gb=os.clock ( ) ;
local Gb=cb[ ( table.find ( cb,Tb ) or 4 ) %#cb+1] ;
if xb then
pcall ( xb.Set,xb,Gb ) ;
end ;
if Tb~=Gb then
Tb=Gb ;
o ( ) ;
end ;
Kb ( iK ) ;
end ;
,Size=h ( 0.26,0.2 ) ,ZIndex=20
} ) ;
PK ( eK,0.24 ) ;
cK ( eK,Ub,1.5,0.2 ) ;
LK=HK ;
LK.ActionGradient=BK ( eK,jb ) ;
aK=HK ;
aK.ActionText=FK ( eK,0.5,0.5,1.02,1.12, {
AnchorPoint=a ( 0.5,0.5 ) ,TextTruncate=nb,ZIndex=21
} ) ;
local function Hb ( ) task.spawn ( dK ) ;
end ;
eK.Activated:Connect ( H 