--[[
    ================================================================================
    MODULE 03: BUTTERFLY BLOOM & WISP COMPANION
    Chilli Hub / Steal An Egg Automation Engine
    ================================================================================
    
    DESCRIPTION:
    Automates the Butterfly Bloom event: automatically claims the event net from
    the NetStand tree, queries the client swarm controller, calculates 3D trajectory
    and velocity predictions, catches butterflies by tier priority score, and crafts
    essences.
    
    KEY REMOTES & MECHANISMS:
    - RF/Butterflies/AskClaimNet         = Claims event butterfly net tool
    - RF/Butterflies/AskTradeUp          = Trades up butterfly essences
    - RF/Butterflies/AskCraftEssence     = Crafts essences at machine
    - Swarm Controller                   = ReplicatedStorage.Controllers.Game.AdminAbuseClientController.Events.ButterflyBloom.Swarm
    - Priority Scoring Formula           = (Distance / Speed) - (TierWeight * 1000)
    ================================================================================
]]

true ;
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
return Pb ( "Waiting
hen not hb else tb(Sb[m]);end;if Xb then Nb.i,Nb.at=m,os.clock();end;else Nb.i=1;end;Gb=Sb[Nb.i];return Gb,math.max(h[a(Gb)]or 0,0);end;S(" 31_bloom#1 ",function()local h,m={Radiant=" Golden ",Amethyst=" Purple ",Sapphire=" Blue ",Emerald=" Green "},{Green=1,Blue=2,Purple=3,Golden=4};local a=wb({name=" Bloom ",mover=true,gap=1,pri=5,soft=true});local hb,tb,Yb=Ib[" Butterfly Bloom "],{{" Green "," rbxassetid://107744695034799 "," #5BE873 "},{" Blue "," rbxassetid://89995151383384 "," #5FA2FF "},{" Purple "," rbxassetid://121235713836098 "," #C27BFF "},{" Golden "," rbxassetid://98126365702697 "," #FFD452 "},{" Essence "," rbxassetid://114750647204247 "," #6FF0FF "}},{texts={},shown={}};hb:Surface({Name=" Butterflies ",ShowTitle=false,Layout=" free ",Style={TextScale=1,LineHeight=1.1,MinLines=3.3,MaxLines=3.3,AutoHeight=true,BackgroundTransparency=0.35,TextColor=Color3.fromRGB(255,255,255),TextStrokeTransparency=0.7},Build=function(Nb)Yb.st=Nb:Text({X=0.7,Y=0.15,Width=1,Height=1.1,Scale=1,Wrap=false,Text=" Off ",Color=" #FFFFFF ",TextStrokeTransparency=0.6});local Gb,Sb={},24;for Xb,Hb in ipairs(tb)do local Vb=0.7+(Xb-1)*4.7;Gb[Xb]=Nb:Image({X=Vb,Y=1.35,Width=1.85,Height=1.85,Image=Hb[2],BackgroundTransparency=1});Yb.texts[Hb[1]]=Nb:Text({X=Vb+2.05,Y=1.6,Width=3,Height=1.35,Scale=1.2,Wrap=false,Text=" 0 ",Color=Hb[3],TextStrokeTransparency=0.6});end;Nb:SetContentLines(3.3);function Yb.lay()local Xb,Hb={},0;for Vb,Kb in ipairs(tb)do Xb[Vb]=2.05+#(Yb.shown[Kb[1]]or" 0 ")*0.62;Hb+=Xb[Vb];end;local Vb,Kb=math.max(0.5,(Sb-1.4-Hb)/(#tb-1)),0.7;for Hb,_b in ipairs(tb)do Gb[Hb].Set({X=Kb});local tb,Gb=Yb.texts,_b[1];local _b,Rb=tb[Gb].Set,{X=Kb+2.05};Rb.Width=Xb[Hb]-2.05+0.3;_b(Rb);Kb+=Xb[Hb]+Vb;end;end;local tb;Nb:OnResize(function(Nb,Nb,Gb)if Nb~=tb then tb=Nb;Sb=Nb/math.max(Gb,1);Yb.lay();end;end);end});local tb=y(hb," Auto Butterfly Bloom "," bloom ",false,function(Nb)if not(Nb)then bb(a);end;end);M(hb," Catch Mode "," bfMode ",{" Stand "," Chase "," Circle "," Patrol "}," Stand ",nil,false,nil,tb);M(hb," Catch Priority "," bfPri ",{" Rarest "," Nearest "}," Rarest ",nil,false," Only for Chase mode ",tb);local Nb={Golden=true,Purple=true,Blue=true,Green=true};hb:Dropdown(" Catch Butterflies ",{" Radiant Butterfly "," Amethyst Butterfly "," Sapphire Butterfly "," Emerald Butterfly "},{" Radiant Butterfly "," Amethyst Butterfly "," Sapphire Butterfly "," Emerald Butterfly "},function(Gb)Nb={};for Sb,Xb in ipairs(Gb)do Sb=h[Xb:match(" ^ ( %a+ ) ")];if Sb then Nb[Sb]=true;end;end;end,true," Only for Chase mode ",tb);l(hb," Tween Speed "," bfSpeed ",100,600,320," studs/s ",10,nil,nil,tb);local Gb,Sb,Xb={},ipairs,{" Spawned "," Escaped "};for Hb,Hb in Sb(Xb)do tb=NetworkingRemotes;hb=tb:FindFirstChild(" RE/Butterflies/ "..Hb);if hb then V(hb.OnClientEvent,function(tb,Hb)local Vb=type(tb)==" table "and tb or type(Hb)==" table "and Hb;if Vb then if Vb.Id then Gb[Vb.Id]=Vb;end;end;end);end;end;Xb=NetworkingRemotes;hb=Xb:FindFirstChild(" RE/Butterflies/Removed ");if hb then V(hb.OnClientEvent,function(tb)Gb[tb]=nil;end);end;local tb,Xb=14,0;pcall(function()tb=tonumber(require(N.Shared.Flags.ButterflyFlags).NetReach:Get())or tb;end);local function Hb()local Vb=tonumber(workspace:GetAttribute(" ButterflyBloomEndsAt "));return workspace:GetAttribute(" Event_ButterflyBloom ")==true and(if Vb then P()<Vb else not Vb);end;local function Vb()local Kb=tonumber(workspace:GetAttribute(" ButterflyBloomEndsAt "));return math.min(Kb and Kb-P()or math.huge,e());end;local function Kb()local _b=getRootPart;local Rb,vb,Pb=_b(),Vb()>25;if vb then Pb=vb;else if Rb then _b=nil;_b,Pb=Vector3.new,(Rb.Position-Vector3.new(6700,74,-364)).Magnitude<300;else Pb=Rb;end;end;return Pb;end;local function _b()local Rb=getWorldInstance;return Rb(" Areas "," ButterflyBloom "," Bounds ");end;local function Rb()local vb=Y[64];local Pb=vb();return Pb and type(Pb.Butterflies)==" table "and Pb.Butterflies or{};end;local function vb()local Pb,cb=Rb().NetClaimed==true;if Pb then cb=Pb;else local Pb=LocalPlayer;cb=Pb:GetAttribute(" EnchantedTreeUnlocked ")==true;end;return cb;end;local Pb=ChilliState;Pb.bloomWants=function()local Pb=Y[26];return Pb.bloom and Hb()and Kb()and vb();end;local function Pb(cb)local Bb=ChilliState;Bb.bfSay=cb;end;local function cb(Bb)return Bb:GetAttribute(" ButterflyNet ")==true or Bb:GetAttribute(" ItemType ")==" ButterflyNet "or Bb.Name==" Butterfly Net ";end;local Bb=RaycastParams.new();Bb.FilterType=Enum.RaycastFilterType.Exclude;local function xb(Tb)local qb,Fb={},LocalPlayer;w:XI(qb,0,Fb.Character,workspace:FindFirstChild(" ButterflyBloomSwarm "));Bb.FilterDescendantsInstances=qb;local Db,Db,Db,Ub=Vector3.new,Vector3.new,workspace:Raycast(Tb+Vector3.new(0,25,0),Vector3.new(0,-120,0),Bb),getHumanoid;qb=Ub();Ub=nil;if Db then Fb=Vector3.new;Ub=Fb(Tb.X,Db.Position.Y+(qb and qb.HipHeight or 2)+1,Tb.Z);else Ub=Db;end;return Ub or Tb;end;local function Bb(Tb)local qb=getWorldInstance;local Fb=qb(" Machines "," ButterflyStation ",Tb);qb=Fb and(Fb:FindFirstChild(" Anchor ")or Fb);return qb and(qb:IsA(" BasePart ")and qb.Position or qb:IsA(" Model ) and qb:GetPivot ( ) .Position ) ;
end ;
local function Tb ( qb,Fb ) local Db,Db=LocalPlayer,LocalPlayer ;
pcall ( LocalPlayer.RequestStreamAroundAsync,LocalPlayer,qb ) ;
local Db,Ub,Zb=setPlayerCFrame,CFrame.new,Vector3.new ;
Db ( Ub ( qb+Zb ( 0,3,4 ) ) ) 