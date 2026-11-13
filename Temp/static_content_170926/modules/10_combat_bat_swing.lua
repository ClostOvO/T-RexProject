--[[
    ================================================================================
    MODULE 10: COMBAT, WEAPON TARGETING & BAT SWING
    Chilli Hub / Steal An Egg Automation Engine
    ================================================================================
    
    DESCRIPTION:
    Automated melee combat and weapon attack system:
    - Scans character and backpack for weapons: "bat", "sword", "hammer", etc.
    - Manages weapon cooldowns via "CooldownEndTime" attribute
    - Predicts enemy player velocity and trajectory (V.Position - V.Velocity * 0.18)
    - Compensates for client-server network ping (getNetworkPing())
    - Auto equips tool and fires attack sequence remotes:
      * RE/BatSwing/Trigger: formatted as ("%d:%d:%d"):format(LocalPlayer.UserId, seqCounter, timestamp)
      * RE/ToolTrigger/Trigger
      * Handles weapon scrambling / fast auto-clicker
    ================================================================================
]]

b-0.1 then
Kb=invokeServerWithTimeout ;
local vb,Pb,cb=Kb ( "RF/Treadmill/AskWearStill" ) ;
local Bb,xb,Tb=vb and ( Pb==true or type ( cb ) == "string" and cb:lower ( ) :find ( "already" ) ) and true or false,ChilliState,ChilliState ;
xb.onAdmin=Tb.onAdmin or Bb ;
Sb=Bb ;
else
end ;
end ;
if not Sb then
Kb=HeartbeatWait ;
n Gb=Nb ;
else
local Nb=tb:GetAttribute ( "ItemType" ) ;
Gb= ( if Nb then
not Nb
else
not tb:GetAttribute ( "GearName" ) ) and ( tb.Name:lower ( ) :find ( "bat" ) or tb.Name:lower ( ) :find ( "sword" ) or tb.Name:lower ( ) :find ( "hammer" ) ) ;
end ;
return Gb ;
end ;
ChilliState.scrambler=function ( tb ) return tb and h[a ( tb ) ]==-1 ;
end ;
local function tb ( Nb ) return P ( ) >= ( tonumber ( Nb:GetAttribute ( "CooldownEndTime" ) ) or 0 ) ;
end ;
local Nb= {
i=1,at=0
} ;
ChilliState.bat=function ( ) Yb ( ) ;
local Yb,Gb,Sb,Xb= {
} ,ipairs, {
} ,LocalPlayer ;
w:XI ( Sb,0,Xb.Character or ( n ( ) ) ,n ( ) ) ;
Xb=nil ;
local Hb=-2 ;
for Vb,Kb in Gb ( Sb ) do
local _b,Rb=ipairs,Kb and Kb:GetChildren ( ) or {
} ;
for vb,Pb in _b ( Rb ) do
if Pb:IsA ( "Tool" ) then
if hb ( Pb ) then
Vb,vb=h[a ( Pb ) ]or 0,Y[26] ;
if vb.weap then
Kb=Y[26] ;
if Kb.weap[a ( Pb ) ]then if not ( Yb[a ( Pb ) ] ) then
Yb[a ( Pb ) ]=Pb ;
end ;
end ;
end ;
if Vb>=0 then
if Xb then
if Vb>Hb then
Xb,Hb=Pb,Vb ;
else
end ;
else
Xb,Hb=Pb,Vb ;
end ;
else
end ;
else
end ;
else
end ;
end ;
end ;
Sb= {
} ;
for hb,hb in ipairs ( m ) do
if Yb[hb]then Sb[#Sb+1]=Yb[hb] ;
end ;
end ;
if #Sb==0 then
return Xb,math.max ( Hb,0 ) ;
end ;
if #Sb>1 then
if Nb.i>#Sb then
Nb.i=1 ;
end ;
local m,hb,Hb,Vb=Nb.i%#Sb+1,os.clock ( ) -Nb.at,Nb.i==2 ;
if Hb then
Yb=Y[26] ;
Vb=Yb.swapT2 ;
else
Vb=Hb ;
end ;
Hb=nil ;
if Vb then
Hb=Vb ;
else
Gb=Y[26] ;
Hb=Gb.swapT ;
end ;
Vb,Xb=hb>= ( Hb or 0.35 ) ;
if Vb then
Xb=Vb ;
else
hb=tb ( Sb[Nb.i] ) ;
Xb=if hb then
not hb
else
tb ( Sb[m] ) ;
end ;
if Xb then
Nb.i,Nb.at=m,os.clock ( ) ;
end ;
else
Nb.i=1 ;
end ;
Gb=Sb[Nb.i] ;
return Gb,math.max ( h[a ( Gb ) ]or 0,0 ) ;
end ;
S ( "31_bloom#1" ,function ( ) local h,m= {
Radiant= "Golden" ,Amethyst= "Purple" ,Sapphire= "Blue" ,Emerald= "Green"
} , {
Green=1,Blue=2,Purple=3,Golden=4
} ;
local a=wb ( {
name= "Bloom" ,mover=true,gap=1,pri=5,soft=true
} ) ;
local hb,tb,Yb=Ib[ "Butterfly Bloom" ], {
{
"Green" , "rbxassetid://107744695034799" , "#5BE873"
} , {
"Blue" , "rbxassetid://89995151383384" , "#5FA2FF"
} , {
"Purple" , "rbxassetid://121235713836098" , "#C27BFF"
} , {
"Golden" , "rbxassetid://98126365702697" , "#FFD452"
} , {
"Essence" , "rbxassetid://114750647204247" , "#6FF0FF"
}
} , {
texts= {
} ,shown= {
}
} ;
hb:Surface ( {
Name= "Butterflies" ,ShowTitle=false,Layout= "free" ,Style= {
TextScale=1,LineHeight=1.1,MinLines=3.3,MaxLines=3.3,AutoHeight=true,BackgroundTransparency=0.35,TextColor=Color3.fromRGB ( 255,255,255 ) ,TextStrokeTransparency=0.7
} ,Build=function ( Nb ) Yb.st=Nb:Text ( {
X=0.7,Y=0.15,Width=1,Height=1.1,Scale=1,Wrap=false,Text= "Off" ,Color= "#FFFFFF" ,TextStro [7]or ob]=kb ;
end ;
Bb[ "Steal:pick" ],Bb.Combat=0,Bb.Treadmill-0.5 ;
Bb.Machine,Bb.WispGo=Bb.Bloom+0.1,Bb[ "Steal:wisp" ]+0.1 ;
pb=ChilliState ;
Bb.Steal=#pb.pick>0 and 0 or math.min ( Bb[ "Steal:index" ],Bb[ "Steal:wisp" ],Bb[ "Steal:filter" ] ) ;
end ;
local function Bb ( pb,kb,ob ) local yb=Instance.new ( pb ) ;
for pb,Mb in next,ob,nil do
yb[pb]=Mb ;
end ;
yb.Parent=kb ;
return yb ;
end ;
local function pb ( kb,ob,yb ) local Mb=kb:FindFirstChild ( "Paint" ) or Bb ( "UIGradient" ,kb, {
Name= "Paint"
} ) ;
Mb.Color,Mb.Rotation=ColorSequence.new ( ob[1],ob[2] ) ,yb or 90 ;
return Mb ;
end ;
local function kb ( ob,yb,Mb ) Mb.BorderSizePixel=0 ;
return Bb ( ob,yb,Mb ) ;
end ;
local function ob ( yb,Mb ) Bb ( "UICorner" ,yb, {
CornerRadius=UDim.new ( Mb,0 )
} ) ;
end ;
local function yb ( Mb,lb,Cb,wK ) return Bb ( "UIStroke" ,Mb, {
Color=lb or Yb,Thickness=Cb or 1.5,Transparency=wK or 0,ApplyStrokeMode=hb.ApplyStrokeMode.Border
} ) ;
end ;
local function Mb ( lb,Cb ) Bb ( "UIStroke" ,lb, {
Color=Yb,Thickness=Cb,LineJoinMode=hb.LineJoinMode.Round
} ) ;
end ;
local function Yb ( lb,Cb,wK ) local bK=Bb ( "TextLabel" ,lb, {
BackgroundTr if Nb ( Sb.Position ) then
return ;
end ;
end ;
else
return ;
end ;
else
return ;
end ;
if not ( Yb ) then
if ( tonumber ( tb:GetAttribute ( "RagdollEndTime" ) ) or 0 ) >P ( ) then
return ;
end ;
end ;
return Sb ;
end ;
local function tb ( Yb ) if Yb then
else
local Nb=ChilliState ;
local Gb,Gb=Nb.bat ( ) ;
Yb=Gb ;
end ;
return ( 17+ ( Yb or 0 ) ) * ( workspace:GetAttribute ( "DragonEggEventActive" ) and 2.5 or 1 ) -1 ;
end ;
local function Yb ( Nb,Gb ) if workspace:GetAttribute ( "PvPDisabled" ) then
return ;
end ;
local Sb=ChilliState ;
local Xb,Hb=Sb.bat ( ) ;
Sb=getRootPart ;
local Vb,Kb=Sb ( ) ,tb ( Hb ) ;
if Xb then
if Vb then
Hb=ChilliState ;
if not ( Hb.needBody ( ) ) then
return ;
end ;
else
return ;
end ;
else
return ;
end ;
Hb=getHumanoid ;
local Sb,_b=Hb ( ) ,LocalPlayer ;
if Xb.Parent~=_b.Character then
if Sb then
pcall ( Sb.EquipTool,Sb,Xb ) ;
end ;
end ;
_b=LocalPlayer ;
if Xb.Parent~=_b.Character then
return ;
end ;
Hb=ChilliState ;
if Hb.scrambler ( Xb ) then
if os.clock ( ) -a>0.3 then
a=os.clock ( ) ;
pcall ( Xb.Activate,Xb ) ;
end ;
return ;
end ;
_b=getNetworkPing ;
Sb,Hb=_b ( ) ,Vb.Position-Vb.AssemblyLinearVelocity*0.18 ;
if ( Gb.Position+Gb.AssemblyLinearVelocity*Sb-Hb ) .Magnitude>Kb then
if ( Gb.Position-Hb ) .Magnitude>Kb then
return ;
end ;
end ;
if P ( ) < ( tonumber ( Xb:GetAttribute ( "CooldownEndTime" ) ) or 0 ) -Sb*0.5 then
return ;
end ;
if os.clock ( ) -n<math.max ( 0.12,Sb*1.5 ) then
return ;
end ;
n=os.clock ( ) ;
B+=1 ;
Gb=LocalPlayer ;
R ( "RE/BatSwing/Trigger" ,Nb, ( "%d:%d:%d" ) :format ( Gb.UserId,B,math.floor ( P ( ) *1000 ) ) ) ;
pcall ( Xb.Activate,Xb ) ;
end ;
local B=ChilliState ;
B.chase=function ( B,n ) local a,Nb=hb ( B,n ) ,getRootPart ;
local Gb,Sb=Nb ( ) ,getHumanoid ;
n=Sb ( ) ;
if a then
if Gb then
if not n then
return false ;
end ;
else
return false ;
end ;
else
return false ;
end ;
n.PlatformStand=true ;
Sb,Nb,n=getNetworkPing,Vector3.new,a.Position+a.AssemblyLinearVelocity* ( getNetworkPing ( ) +0.2 ) +Vector3.new ( 0,1.5,0 ) ;
local Nb,Sb=a.AssemblyLinearVelocity+ ( n-Gb.Position ) /0.12,Y[26] ;
if Nb.Magnitude>Sb.chase*1.8 then
n=nil ;
n,Nb=Y[26],Nb.Unit*Y[26].chase*1.8 ;
else
end ;
Sb=nil ;
Sb,Gb.CFrame=Vector3.new,CFrame.lookAt ( Gb.Position,Vector3.new ( a.Position.X,Gb.Position.Y,a.Position.Z ) ) ;
Sb=Vector3.zero ;
Gb.AssemblyLinearVelocity=Nb ;
Gb.AssemblyAngularVelocity=Sb ;
Yb ( B,a ) ;
return true ;
end ;
r,h=setmetatable, {
__mode= "k"
} ;
local B,n=r ( {
} ,h ) ,ChilliState ;
n.huntStep=function ( r,n,a ) local Nb=getRootPart ;
local Gb,Sb=Nb ( ) ,getHumanoid ;
Nb=Sb ( ) ;
if Gb then
if not Nb then
return ;
end ;
else
return ;
end ;
Nb.PlatformStand=true ;
Nb=B[r]or {
} ;
B[r]=Nb ;
local B,B=Vector3.new,n.AssemblyLinearVelocity*Vector3.new ( 1,0,1 ) ;
Nb.s=Nb.s and Nb.s:Lerp ( B,0.25 ) or B ;
if Nb.s.Magnitude>1 then
Nb.hd= ( Nb.hd and Nb.hd:Lerp ( Nb.s.Unit,0.25 ) or Nb.s.Unit ) .Unit ;
end ;
local Xb,Hb,Hb,Vb,Kb=Nb.s.Magnitude,Vector3.new, ( Gb.Position-n.Position ) *Vector3.new ( 1,0,1 ) ,Nb.hd ;
if Vb then
Kb=Vb ;
else
Sb=Hb.Magnitude>0.1 and Hb.Unit ;
if Sb then
Kb=Sb ;
else
B=Vector3.new ;
Kb= ( B ( 0,0,1 ) ) ;
end ;
end ;
Sb,B=getNetworkPing,Y[26] ;
local _b,Rb,vb=n.Position+Nb.s* ( Sb ( ) +0.38+B.hitLead/1000 ) ,Xb>1 and Nb.s.Unit*3.6 ;
if Rb then
vb=Rb ;
else
Sb=Vector3.zero ;
vb=Sb ;
end ;
Vb,Rb=_b+vb,Vector3.new ;
vb=Rb ( -Kb.Z,0,Kb.X ) ;
vb=if vb:Dot ( Gb.Position-Vb ) <0 then
-vb
else
vb ;
B=os.clock ( ) *2*3.141592653589793 ;
local Rb,Rb,Rb,Pb=Y[26],Vector3.new,Vb+Kb* ( math.sin ( B/1.1 ) *0.5+0.5 ) *math.max ( 5,math.min ( tb ( ) *0.7,6+Xb*0.07 ) ) *Y[26].hitSweep/100+vb* ( Xb<35 and 3 or 1.5 ) +Vector3.new ( 0,math.sin ( B/0.8 ) *2.5,0 ) ,isRagdolled ;
B,Vb=Pb ( ) and 1500 or Hb.Magnitude>60 and 1000 ;
if B then
Vb=B ;
else
Kb,Sb,vb=nil ;
Kb,Sb,vb,Vb=Y[26],Y[26],Y[26],math.min ( Y[26].chase+Xb,math.max ( Y[26].chase,Y[26].hitMax ) ) ;
end ;
_b=Nb.s+ ( Rb-Gb.Position ) /math.max ( 0.12,a ) ;
_b=if _b.Magnitude>Vb then
_b.Unit*Vb
else
_b ;
Sb,Pb=Vector3.new, ( n.Position-Gb.Position ) *Vector3.new ( 1,0,1 ) ;
if Pb.Magnitude>0.05 then
Gb.CFrame=CFrame.lookAt ( Gb.Position,Gb.Position+Pb.Unit ) ;
end ;
vb,Vb=Vector3.new ;
Vb,Gb.AssemblyLinearVelocity=Vector3.zero,_b+vb ( 0,workspace.Gravity*a*0.5,0 ) ;
Gb.AssemblyAngularVelocity=Vb ;
Yb ( r,n ) ;
end ;
m,h=s 