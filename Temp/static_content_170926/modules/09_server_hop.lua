--[[
    ================================================================================
    MODULE 09: SERVER HOP & AUTO-HOPPING SYSTEM
    Chilli Hub / Steal An Egg Automation Engine
    ================================================================================
    
    DESCRIPTION:
    Implements the complete server hopping architecture:
    - Queries public game servers via Roblox Web API
      https://games.roblox.com/v1/games/<PlaceId>/servers/Public
    - Sort modes: "Least Players" (Ascending), "Most Players" (Descending), "Random"
    - Avoids server re-entry using persistent file cache (ChilliLibrary/SAE_AutoHop.json)
      with 30-minute expiration window
    - Auto-hop trigger conditions:
      * "Until An Egg Matches"
      * "Steal Then Hop"
      * "After A Rare Spawns"
      * TeleportInitFailed retry recovery
    ================================================================================
]]

Eb,Lb ) ;
if nb then
mb[#mb+1]=pb ;
elseif
pb.tg then
local Zb=Y[26] ;
if Zb.steal then
mb[#mb+1]=pb ;
elseif
pb.kind== "wisp" then
mb[#mb+1]=pb ;
elseif
pb.kind== "pick" then
mb[#mb+1]=pb ;
end ;
end ;
end ;
else
end ;
end ;
else
end ;
end ;
if Qb then
Wb=ChilliState ;
Wb.fieldFresh=kb<=2 ;
end ;
for Zb in next,Ub,nil do
if not ( db[Zb] ) then
Ub[Zb]=nil ;
end ;
end ;
ub=ChilliState ;
Qb=#ub.pick ;
for Ub=Qb,1,-1 do
rb=ChilliState ;
if not ( db[rb.pick[Ub]] ) then
table.remove ( ChilliState.pick,Ub ) ;
end ;
end ;
Wb,Qb=next,ChilliState ;
ab=Qb.skip ;
for Ub in Wb,ab,nil do
if not ( db[Ub] ) thenHop "," autoHop ",false,function(xb)if not(xb)then Bb(" Idle "," idle ");return;end;if E.busy then return;elseif not(E.ready)then return;end;E:Dialog({Title=" Auto Hop ",Warn=" WARNING ",Body=" Auto Hop keeps joining new servers to find eggs that match its filters. Turn it off to stop. ",Tip=" \ "Steal Then Hop\" and \"After A Rare Spawns\" stop at night." ,Cancel= "Cancel" ,Accept= "Turn On" ,no=function ( ) cb:Set ( false ) ;
end
} ) ;
end , "Joins new servers to find eggs that match the filters below" ) ;
Hb=ChilliState ;
local xb=Hb.PS ;
local Tb=xb.Paint ;
local qb=xb.Bold ;
local Fb=xb.Escape ;
local Db,Ub,Zb,rb,fb,jb,db,Jb,nb,Qb,mb,ib,eb,Lb,ab,Eb,ub,Wb,pb,kb,ob,yb=Color3.new ( 1,1,1 ) ,3.8,1.2, "No egg matches here" , "After stealing a match" , {
idle= {
"IDLE" , "#9AA3B5"
} ,scan= {
"SCANNING" , "#7FD8FF"
} ,found= {
"FILTER EGG HERE" , "#4DFF7A"
} ,night= {
"NIGHT" , "#9C8CFF"
} ,rare= {
"WAITING" , "#FF7AE0"
} ,steal= {
"AUTO STEAL BUSY" , "#FFC24D"
} ,joining= {
"JOINING SERVER" , "#FF9A3D"
} ,race= {
"RACING EVENT" , "#FFD452"
} ,star= {
"SHOOTING STAR" , "#FFEE8C"
}
} , {
Slot= {
"ON NEST" , "#4DFF7A"
} ,Dropped= {
"DROPPED" , "#FFC24D"
} ,Carried= {
"BEING CARRIED" , "#FF8A5C"
}
} , {
} , {
} ,0,0,1,false ;
local function Mb ( lb ) local Cb=tostring ( lb.Spec.Text or "" ) ;
local wK=ub.. "|" ..Cb:gsub ( "%d" , "0" ) ;
if lb.WK==wK then
return lb.WU ;
end ;
local bK=lb.Get ( ) ;
if bK.Text~=Cb then
return ;
end ;
local hK,tK=bK.Size,bK.TextWrapped ;
bK.TextWrapped,bK.Size=false,UDim2.fromOffset ( 100000,math.max ( 1,hK.Y.Offset ) ) ;
Cb=bK.TextBounds.X ;
bK.Size=hK ;
bK.TextWrapped=tK ;
if Cb<=0 then
return ;
end ;
lb.WK,lb.WU=wK,Cb/ub ;
return lb.WU ;
end ;
local function lb ( ) if Rb then
local Cb=Y[26] ;
if Cb.autoHop~=true then
yb,mb,Qb=nil,0,2 ;
return ;
end ;
else
yb,mb,Qb=nil,0,2 ;
return ;
end ;
local Cb=Rb.Record ;
local wK,bK,hK=xb.AssetInfo ( Cb.AssetCategory ) ,tonumber ( Cb.AssetScale ) or 1,type ( Cb.Mutations ) == "table" and Cb.Mutations or {
} ;
hK=if#hK==0 then
if type ( Cb.BaseMutation ) == "string" then
if Cb.BaseMutation~= "" then
{
Cb.BaseMutation
}
else
hK
else
hK
else
hK ;
yb,mb,Qb= {
i=wK,m=hK,a=Rb.Area,s=db[Rb.State]or db.Slot,v=wK.EarningRate*xb.ScaleFactor ( bK ) *xb.MutationMultiplier ( hK )
} ,vb,2 ;
end ;
local function db ( ) local Cb=Y[26] ;
local wK=Cb.autoHop==true ;
Cb=wK and Kb or "idle" ;
local Kb,bK,hK=jb[Cb],wK and Vb or "Turn on Auto Hop to start hunting" ,yb~=nil ;
local Vb=Color3.fromHex ( Kb[2] ) ;
if wK then
if Cb~= "night" then
local jb=Y[26] ;
if jb.hopWhen~=rb then
local jb=math.max ( 0, ( hb.Window or 0 ) -P ( ) ) ;
bK=if jb>0 then
bK.. ( " | hop run %s left" ) :format ( xb.FormatClock ( jb ) )
else
bK ;
else
end ;
else
end ;
else
end ;
Jb.a ( {
Background=Kb[2]
} ) ;
Jb.t ( {
Text=Kb[1],Color=Vb
} ) ;
Kb,Cb=Jb.v, {
} ;
Cb.Text on=type ( Vb.Icon ) == "string" and Vb.Icon~= "" and Vb.Icon or nil
} ;
Hb[_b]=Xb ;
return Xb ;
end ;
Gb.Income=function ( hb,Xb,Hb ) if type ( Xb ) ~= "number" then
return 0 ;
elseif
Xb<=0 then
return 0 ;
end ;
return math.max ( math.round ( hb.EarningRate*Gb.ScaleFactor ( Xb ) *Gb.MutationMultiplier ( Hb ) ) ,1 ) ;
end ;
Gb.IsShown=function ( hb ) if typeof ( hb ) ~= "Instance" then
return false ;
elseif
not ( hb:IsDescendantOf ( A ) ) then
return false ;
end ;
while hb do
if hb:IsA ( "GuiObject" ) then
if not ( hb.Visible ) then
return false ;
end ;
end ;
if hb:IsA ( "LayerCollector" ) then
return hb.Enabled ;
end ;
hb=hb.Parent ;
end ;
return false ;
end ;
end ) ;
S ( "15_hop#1" ,function ( ) local hb=t.dec ( t.rd ( "ChilliLibrary/SAE_AutoHop.json" ) ) or {
} ;
hb.Visited=type ( hb.Visited ) == "table" and hb.Visited or {
} ;
local Gb=hb.Visited ;
local function Xb ( ) t.wr ( "ChilliLibrary/SAE_AutoHop.json" ,t.enc ( hb ) or "{}" ) ;
end ;
local Hb=P ( ) -1800 ;
for Vb,Kb in next,Gb,nil do
if Kb<Hb then
Gb[Vb]=nil ;
end ;
end ;
Gb[A.JobId]=P ( ) ;
Xb ( ) ;
local Vb,Kb,_b,Rb,vb,Pb= {
} ,0,false ;
V ( s.TeleportInitFailed,function ( cb ) local Bb=LocalPlayer ;
if cb==Bb then
local cb=ChilliState ;
if cb.hopping then
_b=false ;
if vb then
Vb[vb]=true ;
end ;
task.spawn ( Pb,ChilliState.hopping ) ;
end ;
end ;
end ) ;
Hb=LocalPlayer ;
V ( Hb.OnTeleport,function ( cb ) if cb==Enum.TeleportState.Started then
_b=true ;
elseif
cb==Enum.TeleportState.InProgress then
_b=true ;
end ;
end ) ;
local function cb ( Bb ) if Rb then
if os.clock ( ) -Kb<60 then
local xb=Rb ;
return xb ;
end ;
end ;
local xb,Tb,qb= {
} ,Bb== "Random" and 3 or 6, "" ;
for Fb=1,Tb,1 do
local Tb,Db=pcall ( A.HttpGet,A, ( "https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=%s&excludeFullGames=true&limit=100%s" ) :format ( A.PlaceId,Bb== "Most Players" and "Desc" or "Asc" ,qb ) ) ;
Fb=t.dec ( Tb and Db ) ;
if type ( Fb ) ~= "table" then
break ;
end ;
for Tb,Tb in ipairs ( Fb.data or {
} ) do
if Tb.id~=A.JobId then
xb[#xb+1]=Tb ;
end ;
end ;
if #xb>0 then
if Bb~= "Random" then
break ;
elseif
not ( Fb.nextPageCursor ) then
break ;
end ;
elseif
not ( Fb.nextPageCursor ) then
break ;
end ;
qb= "&cursor=" ..Fb.nextPageCursor ;
end ;
Bb=nil ;
Bb,Rb=os.clock ( ) ,xb ;
Kb=Bb ;
return xb ;
end ;
Pb=function ( Kb ) for Bb=1,2,1 do
local xb,Tb=ipairs, {
2,1
} ;
for qb,Fb in xb ( Tb ) do
local xb,Tb,Db= {
} ,ipairs,w[76] ( cb ( Kb ) ) ;
for cb,cb in Tb ( w:iI ( Db ) ) do
if ( cb.maxPlayers or 0 ) - ( cb.playing or 0 ) >=Fb then
qb=Vb ;
if not ( qb[cb.id] ) then
if Bb==1 then
if not ( Gb[cb.id] ) then
xb[#xb+1]=cb ;
end ;
else
xb[#xb+1]=cb ;
end ;
end ;
end ;
end ;
if #xb>0 then
table.sort ( xb,function ( cb,Bb ) if Kb== "Most Players" then
return cb.playing>Bb.playing ;
end ;
return cb.playing<Bb.playing ;
end ) ;
local cb=xb[math.random ( 1,Kb== "Random" and#xb or math.min ( #xb,100 ) ) ] ;
qb,Db,Tb=cb.id,P ( ) ,cb.id ;
Gb[qb]=Db ;
vb,_b=Tb,false ;
Xb ( ) ;
Fb=ChilliState ;
Fb.beforeTeleport ( ) ;
u ( "Server Hop" , ( "Joining a server with %d players" ) :format ( cb.playing or 0 ) ) ;
pcall ( s.TeleportToPlaceInstance,s,A.PlaceId,cb.id,LocalPlayer ) ;
task.delay ( 6,function ( ) local Gb=ChilliState ;
if Gb.hopping then
local Gb=vb ;
if Gb==cb.id then
if not ( _b ) then
local Gb=Vb ;
Gb[cb.id]=true ;
Pb ( Kb ) ;
end ;
end ;
end ;
end ) ;
return true ;
end ;
end ;
Vb,Rb= {
} ,nil ;
end ;
local Gb=ChilliState ;
Gb.hopping=nil ;
return false ;
end ;
local Gb=ChilliState ;
Gb.hop=function ( Gb ) local Vb=ChilliState ;
if Vb.hopping then
return true ;
end ;
local Kb,_b=ChilliState ;
if Gb then
_b=Gb ;
else
Vb=Y[26] ;
_b=Vb.hopMode ;
end ;
Kb.hopping=_b or "Least Players" ;
Kb=ChilliState ;
return Pb ( Kb.hopping ) ;
end ;
local Gb,Vb,Kb,_b,Rb,vb,Pb,cb=Ib[ "Egg Finder" ], "Idle" , "idle" , {
} ;
local function Bb ( xb,Tb ) Vb,Kb=xb,Tb ;
end ;
cb=y ( Gb, "Auto d;end;local function Hb(db,Wb)local pb=db~=nil;nb:SetDock(pb and 5 or 0,{Gap=0.22});for kb,kb in next,cb,nil do kb.Set({Visible=pb});end;if not(pb)then return;end;jb(cb.Icon,db);local kb,IK=cb.Name.Set,{};IK.Text=Zb(db.Name);kb(IK);AK(cb.Rarity,db);pb,kb=Wb.Result,#Wb.Items;IK=Fb(Yb,(" Fusing %d of 3 pets "):format(kb));if pb then IK=(wK(a," Result locked in, claim it at the machine "));else if Wb.Reward then IK=(wK(a," Fuse finished, claim your egg "));else if Wb.Locked then local gK=Wb.Duration>1000000000 and Wb.Duration-P()or 0;IK=wK(hb,gK>0 and" Fusing "..fb..Kb.FormatClock(gK)or" Fusing ");else end;end;end;local Kb,gK,GK=pb and(tonumber(pb.AssetScale)or 1),cb.Info.Set,{};GK.Text=wK(a,Bb(pb and Tb(db,Kb,pb.Mutations)or Tb(db,Wb.Items[1].Scale,Wb.Items[1].Mutations))).." \10 "..Fb(Yb,pb and(" %.2fx fused egg "):format(Kb)or(" %d/3 loaded "):format(kb)).." \10 "..IK;gK(GK);end;vb=function()if not(nb)then return;end;yb=2;table.clear(ib);local Kb,vb=0,0;local function db(Wb,pb)Kb+=1;local kb=mb[Kb];if kb then else kb=nb:Text({Name=" Line ",Width=1,Height=1,Wrap=true,Visible=false});mb[Kb]=kb;end;kb.Set({Visible=true,Text=Wb});ib[#ib+1]={Handle=kb,Gap=pb};end;local function Wb(pb,kb)db(wK(kb,pb),#ib>0);end;local function pb(kb)db(Fb(h,kb));end;local f
utor cannot queue a script for the next server" ) ;
end ;
end ;
end ;
end ) ;
local h=ChilliState ;
h.beforeTeleport=function ( ) local h=Y[26] ;
R ( h.autoExec ) ;
end ;
local h=LocalPlayer ;
V ( h.OnTeleport,function ( R ) if R==Enum.TeleportState.Started then
local R=ChilliState ;
R.beforeTeleport ( ) ;
end ;
end ) ;
M ( b, "Server Hop Mode" , "hopMode" , {
"Most Players" , "Random" , "Least Players"
} , "Least Players" ) ;
b:Button ( "Server Hop" , "Hop" ,function ( ) task.spawn ( ChilliState.hop ) ;
end ) ;
local R=b:Input ( "Job ID" , "Paste a server Job ID..." ) ;
R.Skip=true ;
b:Button ( "Join Job ID" , "Join" ,function ( ) local c=tostring ( R.Value ) :match ( "%x+%-%x+%-%x+%-%x+%-%x+" ) ;
if c then
pcall ( s.TeleportToPlaceInstance,s,A.PlaceId,c,LocalPlayer ) ;
else
u ( "Join Job ID" , "Paste a valid Job ID first" ) ;
end ;
end ) ;
b:Button ( "Copy Current Job ID" , "Copy" ,function ( ) pc[16] ( 0.66,0.12 ) ;
o[11].TextStrokeTransparency=0.6 ;
o[12] ( o[13],o[11],DK ) ;
o[15]=k ;
o[14]= {
} ;
o[14].bc=t ;
o[14].a=b[13] ( 1,0 ) ;
o[14].p=b[16] ( 0.95,0.05 ) ;
o[14].s=b[16] ( 0.2,0.2 ) ;
o[14].z=10 ;
o[14].v=false ;
Bb= ( o[15] ( o[14],DK ) ) ;
M ( Bb,1 ) ;
b[10] ( n,Bb ) ;
o[17]=a ;
o[18]=Q ;
o[16]= {
} ;
o[16].r=90 ;
o[16].Color=b[18] ( b[12] ( 255,222,90 ) ,b[12] ( 255,150,20 ) ) ;
o[17] ( o[18],o[16],Bb ) ;
o[20]=a ;
o[21]=m ;
o[19]= {
} ;
o[19].Thickness=1.5 ;
o[19].Color=b[12] ( 70,40,0 ) ;
o[20] ( o[21],o[19],Bb ) ;
local o= {
{
0.36,0.58,0.3,45
} , {
0.58,0.48,0.56,-50
}
} ;
for xb,xb in ipairs ( o ) do
M ( k ( y ( c,xb[1],xb[2],xb[3],0.14, {
bs=0,bc=t,r=xb[4],z=11
} ) ,Bb ) ,1 ) ;
end ;
T[#T+1]= {
b=DK,st=Tb,dot=Bb,n=mb.n,l=mb.n:lower ( ) ,r=mb.r,c=NK.color
} ;
qK ( DK,function ( ) local o,Bb=U ( ) ,mb.n ;
local xb=table.find ( o,Bb ) ;
if xb then
table.remove ( o,xb ) ;
else
o[#o+1]=Bb ;
end ;
f ( o ) ;
end ) ;
end ;
F ( ) ;
end ;
GK ( 1,0.3, "Select all" ,sK,function ( ) local F=U ( ) ;
for U,U in ipairs ( T ) do
if U.b.Visible then
if not ( table.find ( F,U.n ) ) then
F[#F+1]=U.n ;
end ;
end ;
end ;
f ( F ) ;
end ,tb ) ;
GK ( 2,0.3, "Clear" ,XK,function ( ) f ( {
} ) ;
end ,tb ) ;
GK ( 3,0.3, "Done" ,AK,function ( ) ab.view= "ac" ;
end ,tb ) ;
b8.only=BK ( 2, "Only these eggs" ,function ( ) d ( ) ;
r=0 ;
kb ( ) ;
ab.view= "eg" ;
end ) ;
local function T ( F ) ab.drawer=ab.drawer~=F and F or nil ;
ab.view=nil ;
end ;
local function F ( ) if Vb ( ) then
ab.drawer,ab.view=nil,ab.view~= "ac" and "ac" 