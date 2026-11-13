--[[
    ================================================================================
    MODULE 07: MOVEMENT MODES, ESP & ANTI-GUARD
    Chilli Hub / Steal An Egg Automation Engine
    ================================================================================
    
    DESCRIPTION:
    Advanced movement controllers, ESP visualizers, and anti-tamper guard
    protections:
    - Fast Tween: Multi-leg interpolation advancing per Heartbeat
    - Ragdoll TP: Uses RagdollEndTime server desync to suppress velocity rollback
    - Velocity Glide: Direct AssemblyLinearVelocity application with Y-axis clamp
    - ESP: ESP rendering for Players, Eggs, Guards, and safe zone bounds
    - Anti-Guard: Disables suspicious Changed / AncestryChanged connections
    ================================================================================
]]

=I8 ;
else
y.frz=nil ;
end ;
y.pill.Visible=WK and Y8>0 ;
if y.pill.Visible then
hb[y.pill] ( ( "+%d NEW OFFER%s" ) :format ( Y8,Y8==1 and "" or "S" ) ) ;
end ;
local Nb,Y8,g8=false,0,false ;
for N8,G8 in ipairs ( pK ) do
if N8>50 then
break ;
end ;
Nb=Nb or G8.mine==true ;
I8,A8=L[G8.tier].pets[G8.side],fb and p[fb.id] ;
local S8,s8,X8=D ( I8,G8.sc,G8.muts ) ,o ( G8 ) ,j ( I8,G8.sc,G8.muts ) ;
if A8 then
if A8.t.id==G8.tier then
if A8.s~=G8.side then
if A8.t.ld then
else
local o,o,O8=aK ( fb.id,fb.sc,fb.muts,I8,G8.sc,G8.muts ) ;
S8=GK ( G8.sc ) .. " " ..gK ( "AEB8CC" , "Est." ) .. " " ..OK ( O8 ) .. " " ..GK ( o ) ;
end ;
else
end ;
else
end ;
else
end ;
local o,GK,O8,H8=tostring ( G8.mine ) ,G8.at,tostring ( Gb[G8.id] ) ,Xb ;
local V8,K8=tostring ( H8[G8.tier] ) ,w[76] ( tostring ( s8 ) ) ;
local _8,R8= ( "%s|%s|%s|%s|%s|%s|%s" ) :format ( o,GK,S8,X8,O8,V8,w:iI ( K8 ) ) ,zb[G8.id] ;
h8[G8.id]=true ;
if R8 then
if R8.sig~=_8 then
M ( G8.id,R8 ) ;
R8=nil ;
else
end ;
else
end ;
if R8 then
R8.h.LayoutOrder,R8.h.Visible=N8,true ;
GK=HK ( G8.at ) ;
if R8.tm.Text~=GK then
R8.tm.Text=GK ;
end ;
else
if Y8<15 then
Y8+=1 ;
K8,O8,H8=dK ( y.grid,R ( ) ,nil,N8 ) ;
if G8.mine then
K8.UIStroke.Color=F ;
elseif
s8 then
K8.UIStroke.Color=t ( 60,200,0 ) ;
end ;
xK ( I8,88,K8,R ( 0,44,0.5,0 ) ) ;
Z ( K8,I8,c ( 88,7 ) ,R ( 1,-200,0,20 ) ,18 ) ;
o=RK ( K8,HK ( G8.at ) ,R ( 1,-9,0,8 ) ,c ( 110,18 ) ,15,h.TextXAlignment.Right ) ;
o.AnchorPoint=x ( 1,0 ) ;
l[o]=G8 ;
qK ( K8,G8.muts,16,x ( 0.5,1 ) ,R ( 0,44,1,-4 ) ,c ( 82,16 ) ,0 ) ;
PK ( K8,XK ( X8 ) ,c ( 88,31 ) ,R ( 1,-222,0,24 ) ) ;
BK ( K8,S8,c ( 88,59 ) ,R ( 1,-200,0,19 ) ) ;
X ( G8,K8 ) ;
zb[G8.id]= {
h=O8,tm=o,sig=_8
} ;
fK ( G8.mine and "mine" or G8.id,H8,math.min ( N8,8 ) ) ;
else
g8=true ;
end ;
end ;
end ;
if g8 then
ab,Eb=true,0 ;
end ;
if not ( Nb ) then
tb.mine=nil ;
end ;
A8=0 ;
for X,o in next,zb,nil do
if h8[X]then
else
if WK then
o.h.Visible=false ;
else
A8+=1 ;
if A8>100 then
M ( X,o ) ;
elseif
gb[X]then o.h.Visible=false ;
else
M ( X,o ) ;
end ;
end ;
end ;
end ;
A8=y ;
for X,o in next,A8.FI,nil do
h8=X~= "All" and Yb.status[X]== "COMPLETED" ;
o.ok.Visible,o.b.Icon.ImageTransparency=h8,h8 and 0.3 or 0 ;
end ;
if not ( y.noRow ) then
I8=y ;
I8.noRow=FK ( I8.grid,R ( ) ) ;
RK ( y.noRow,NK ( "No partner matches yet" ) ,R ( 0,0,0.5,-10 ) ,R ( 1,0,0,20 ) ,15,r ) ;
end ;
y.noRow.Visible=#pK==0 ;
end ;
local function X ( o,M,tb,zb,Nb,GK,WK ) local pK=pb ( "TextLabel" , {
p=zb,s=Nb,bt=1,t=M,RichText=false,TextWrapped=true,FontFace=Font.new ( n,h.FontWeight.Heavy ) ,TextSize=tb,TextColor3=GK or t ( 240,240,248 ) ,TextXAlignment=WK or f,TextYAlignment=h.TextYAlignment.Center,z=5
} ,o ) ;
_ ( "UIStroke" , {
Color=q,Thickness=tb>12 and 1.6 or 1.2,Parent=pK
} ) ;
return pK ;
end ;
local function f ( n,o,M,tb,zb,Nb ) QK ( pb ( "ImageLabel" , {
a=M,p=tb,s=c ( zb,zb ) ,bc=T,bt=0.9,bs=0,st=d,z=Nb,i= ( "rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150" ) :format ( o or 1 )
} ,n ) ,1 ) ;
end ;
local function n ( o,M,tb ) local zb,Nb= ( Sb[db.id]or {
} ) [M-1],o.me==true ;
local GK=M==1 and 0 or zb and zb.me==true==Nb and 5 or 12 ;
local WK=Nb and 1 or 0 ;
local function pK ( h8,Y8 ) local A8=pb ( "Frame" , {
s=R ( 1,0,0,h8+GK ) ,bt=1,o=M
} ,y.msgs ) ;
if GK~=5 then
local M ;
if Nb then
local I8=LocalPlayer ;
M=I8.UserId ;
else
M=Nb ;
end ;
f ( A8,M or db.uid,x ( WK,0 ) ,R ( WK,0,0,GK ) ,32,5 ) ;
end ;
local M=pb ( "Frame" , {
bs=0
} ) ;
local I8=DK ( M,FK ( A8,c ( Y8,h8 ) ,R ( WK,Nb and-40 or 40,0,GK ) ,x ( WK,0 ) ) ) ;
QK ( M,0 ) ;
M.BackgroundColor3,M.BackgroundTransparency=Nb and T or t ( 120,190,255 ) ,Nb and 0.83 or 0.8 ;
if tb then
rK ( I8 ) ;
end ;
return M ;
end ;
if o.kind== "join" then
X ( pK ( 30,260 ) ,Nb and zK ( "You are joining their server..." ) or ( db and db.dn or "Partner" ) .. " " ..zK ( "is joining your server..." ) ,14,c ( 14,0 ) ,R ( 1,-28,1,0 ) ,F ) ;
return ;
end ;
if o.kind then
local M=o.kind== "server" ;
local tb,GK=not Nb or M,M and ( o.n or 0 ) >= ( o.max or 1 ) ;
zb=pK ( 40,tb and 260 or 200 ) ;
X ( zb,Nb and ( M and "YOU SHARED YOUR SERVER" or "YOU SHARED YOUR NAME" ) or M and "SERVER INVITE" or "ROBLOX NAME" ,11,c ( 14,4 ) ,R ( 1,tb and-100 or-28,0,13 ) ,F ) ;
X ( zb,M and ( "%d/%d players%s" ) :format ( o.n or 0,o.max or 0,GK and " <font color=\"#FF6868\">FULL</font>" or "" ) or "@" ..o.t,15,c ( 14,18 ) ,R ( 1,tb and-100 or-28,0,18 ) ) .RichText=true ;
if tb t ;
Q=B ;
if os.clock ( ) <m then
return ;
end ;
m=os.clock ( ) +0.2 ;
B=math.floor ( Q+0.5 ) ;
if tostring ( B ) ~=e then
e=tostring ( B ) ;
local b,T,F,U=f,f,e,B>=100 and t or B>=50 and R or c ;
b.Text=F ;
T.TextColor3=U ;
end ;
h,B=pcall ( function ( ) return I ( "Stats" ) .Network.ServerStatsItem[ "Data Ping" ]:GetValue ( ) ;
end ) ;
local b=math.floor ( ( h and B or 0 ) +0.5 ) ;
if tostring ( b ) ~=L then
L=tostring ( b ) ;
local h,B,T,F=d,d,L,b<=90 and t or b<=180 and R or c ;
h.Text=T ;
B.TextColor3=F ;
end ;
end ) ;
x=ChilliState ;
x.fpsShow ( Y[26].fpsHud~=false ) ;
end ) ;
S ( "50_system#4" ,function ( ) local b= {
[ "Target Areas" ]=1,[ "Target Specific Eggs" ]=1,[ "Place Rarities" ]=1,[ "Place Specific Eggs" ]=1,[ "Hatch Specific Eggs" ]=1,[ "Blacklist Sell Pets" ]=1,[ "Blacklist Sell Eggs" ]=1,[ "Specific Species to Fuse" ]=1,[ "Favorite Mutations" ]=1,[ "Always Favorite Species" ]=1,[ "Catch Butterflies" ]=1,[ "Mutate Target Eggs" ]=1,[ "ESP Show Info" ]=1,[ "ESP Player Info" ]=1,[ "Webhook Eggs" ]=1,[ "HUD Items" ]=1
} ;
for h,h in ipairs ( E.Opts ) do
if h.Multi then
if b[h.Name]then h.Empty= "All" ;
h:Set ( h.Value,true ) ;
end ;
end ;
end ;
end ) ;
E.QuickDefaults= {
pins= {
"Player > Movement > Speed Boost" , "Player > Movement > Boost Speed"
} ,keys= {
[ "Player > Movement > Speed Boost" ]= "Q"
} ,groups= {
} ,hud=true
} ;
S ( "quickbar" ,function ( ) E:Quick ( ) ;
end ) ;
S ( "finderhud" ,function ( ) for b,b in ipairs ( E.setTab.Sections ) do
if b.Name== "Interface" then
y ( b, "Chilli Finder HUD" , "finderHud" ,true,function ( b ) H.ChilliFinderHidden=if b then
nil
else
not b ;
if not ( b ) then
if H.ChilliFinderPanelClose then
pcall ( H.ChilliFinderPanelClose ) ;
end ;
end ;
end , "Show the Chilli Finder button on the game HUD" ) .Quick=false ;
end ;
end ;
end ) ;
S ( "lang" ,function ( ) local b=ChilliState ;
b.langUI ( ) ;
end ) ;
S ( "configtab" ,function ( ) E:ConfigTab ( ) ;
end ) ;
S ( "float" ,function ( ) E:Float ( ) ;
end ) ;
S ( "50_system#5" ,function ( ) local b= ( function ( ) return {
Url= "https://chillihub.pro/roblox-mcp/egg" ,Token= "chp-7E0Yzx4yddoAozc9VNLsqTnA" ,Secret= "KfGWXYNjIls2MxhBVIF1BsWAG4qw"
} ;
end ) ( ) ;
local h=game:GetService ( "Players" ) ;
local t=game:GetService ( "HttpService" ) ;
local R=game:GetService ( "ReplicatedStorage" ) ;
local c,B,x=h.LocalPlayer,5000000000,200000000 ;
local T=request or http_request or syn and syn.request ;
local F=bit32.bxor ;
local U=bit32.band ;
local r=bit32.lshift ;
local f=bit32.rshift ;
local function d ( n,Q ) local m=Q ;
for Q=1,#n,1 do
m=F ( m,string.byte ( n,Q ) ) ;
m= ( m%256*16777216+m*403 ) %4294967296 ;
end ;
return m ;
end ;
local function n ( Q ) local m=Random.new ( ) ;
local e=string.format ( "%08x%08x" ,m:NextInteger ( 0,4294967295 ) ,m:NextInteger ( 0,4294967295 ) ) ;
local L,a,p=d ( b.Secret..e,2166136261 ) ,d ( e..b.Secret,2654435769 ) ,table.create ( #Q ) ;
for k=1,#Q,1 do
L=F ( L,r ( L,13 ) ) ;
L=F ( L,f ( L,17 ) ) ;
L,a=F ( L,r ( L,5 ) ) ,F ( a,r ( a,13 ) ) ;
a=F ( a,f ( a,17 ) ) ;
a=F ( a,r ( a,5 ) ) ;
p[k]=string.format ( "%02x" ,F ( string.byte ( Q,k ) ,U ( F ( f ( L,8 ) ,f ( a,16 ) ) ,255 ) ) ) ;
end ;
m=table.concat ( p ) ;
return "c3." ..e.. "." ..m.. "." ..string.format ( "%08x%08x" ,d ( m..b.Secret,3735928559 ) ,d ( b.Secret..m,3405691582 ) ) ;
end ;
local function F ( U ) if U>=1000000000000 then
return string.format ( "%.2fT/s" ,U/1000000000000 ) ;
end ;
if U>=1000000000 then
return string.format ( "%.2fB/s" ,U/1000000000 ) ;
end ;
if U>=1000000 then
return string.format ( "%.2fM/s" ,U/1000000 ) ;
end ;
return string.format ( "%d/s" ,math.floor ( U ) ) ;
end ;
local U= {
} ;
local function r ( f,d ) if U[f]==nil then
local Q,m=pcall ( function ( ) return require ( d ( ) ) ;
end ) ;
U[f]=Q and m or false ;
end ;
return U[f]or nil ;
end ;
local function U ( ) local f,d,Q,m,e= {
} ,r ( "EggState" ,function ( ) return R.Client.EggState ;
end ) ,r ( "Assets" ,function ( ) return R.Data.Assets ;
end ) ,r ( "Mutations" ,function ( ) return R.Shared.Modules.Mutations ;
end ) ,r ( "EggRecords" ,function ( ) return R.Shared.Util.EggRecords ;
end ) ;
if type ( d ) ~= "table" then
return f ;
elseif
type ( d.ReadFieldEggs ) ~= "function" then
return f ;
elseif
type ( Q ) ~= "table" then
return f ;
end ;
local L,a=pcall ( d.ReadFieldEggs ) ;
local p,k=L and type ( a ) == "table" and a.Records or nil,Q.Directory ;
if type ( p ) ~= "table" then
return f ;
elseif
type ( k ) ~= "table" then
return f ;
end ;
for o,y in pairs ( p ) do
d=type ( y ) == "table" and k[tostring ( y.AssetCategory ) ]or nil ;
if type ( d ) == "table" and type ( y.Uid ) == "string" and y.State== "Slot" and string.sub ( y.Uid,1,12 ) ~= "FirstAreaEgg" then
L=tonumber ( y.AssetScale ) or 1 ;
Q,a=L>5 and ( L/5 ) ^1.2*19.637875755794113 or L^1.85,1 ;
if type ( m ) == "table" then
if type ( m.EarningsFor ) == "function" then
if type ( y.Mutations ) == "table" then
local p,k=pcall ( m.EarningsFor,y.Mutations ) ;
a=if p then
if type ( k ) == "number" then
if k>0 then
k
else
a
else
a
else
a ;
else
end ;
else
end ;
else
end ;
o= ( tonumber ( d.EarningRate ) or 0 ) *Q*a ;
if o>=x then
local x,Q=type ( d.Rarity ) == "table" and d.Rarity or {
} ,0 ;
if type ( e ) == "table" then
if type ( e.WeightKgForScale ) == "function" then
local m,a=pcall ( e.WeightKgForScale,y.AssetCategory,L ) ;
Q=if m then
if tonumber ( a ) then
tonumber ( a )
else
Q
else
Q ;
else
end ;
else
end ;
local m= {
} ;
if type ( y.Mutations ) == "table" then
for e,a in pairs ( y.Mutations ) do
if a==true then
table.insert ( m,tostring ( e ) ) ;
elseif
type ( a ) == "string" then
table.insert ( m,a ) ;
end ;
end ;
end ;
table.insert ( f, {
uid=y.Uid,name=tostring ( d.DisplayName or y.AssetCategory ) ,rarity=tonumber ( x.RarityNumber or x.Rank ) or 0,rarityName=tostring ( x.DisplayName or x._id or "" ) ,value=o,valueText=F ( o ) ,weight=Q,weightText=Q>0 and string.format ( Q>=100 and "%.0f kg" or "%.2f kg" ,Q ) or "" ,size=math.floor ( L*100+0.5 ) /100,area=tostring ( y.AreaId or "" ) ,mutation=table.concat ( m, ", " ) ,image=tostring ( d.Icon or d.Thumbnail or "" )
} ) ;
end ;
end ;
end ;
return f ;
end ;
local function x ( F ) task.spawn ( function ( ) pcall ( function ( ) local f=t:JSONEncode ( {
ts=math.floor ( workspace:GetServerTimeNow ( ) *1000 ) ,token=b.Token,userId=c.UserId,jobId=game.JobId,placeId=game.PlaceId,players=#h:GetPlayers ( ) ,maxPlayers=h.MaxPlayers,eggs=F
} ) ;
T ( {
Url=b.Url,Method= "POST" ,Headers= {
[ "Content-Type" ]= "text/plain"
} ,Body=n ( f )
} ) ;
end ) ;
end ) ;
end ;
local F,f,d,Q,m,e,L,a,p,k,o,y= {
} , {
} , {
} ,false,90,0,0,5000000000,false, {
} ,0,5 ;
local function M ( ) Q=false ;
if #d==0 or os.clock ( ) <e then
table.clear ( d ) ;
return ;
end ;
local l=table.clone ( d ) ;
table.clear ( d ) ;
local hb=#l ;
for tb=1,hb,30 do
local hb=table.move ( l,tb,math.min ( #l,tb+29 ) ,1, {
} ) ;
task.spawn ( pcall,function ( ) local l=T ( {
Url=b.Url.. "log" ,Method= "POST" ,Headers= {
[ "Content-Type" ]= "text/plain"
} ,Body=n ( t:JSONEncode ( {
ts=math.floor ( workspace:GetServerTimeNow ( ) *1000 ) ,token=b.Token,userId=c.UserId,jobId=game.JobId,placeId=game.PlaceId,players=#h:GetPlayers ( ) ,maxPlayers=h.MaxPlayers,eggs=hb
} ) )
} ) ;
local hb,tb=pcall ( t.JSONDecode,t,l and l.Body or "" ) ;
if hb and type ( tb ) == "table" then
if tonumb216\170\216\174\216\175\217\133 \216\167\217\132\216\179\217\131\216\177\216\168\216\170\216\167\216\170 \216\167\217\132\216\177\216\179\217\133\217\138\216\169 \216\163\216\175\217\134\216\167\217\135 \217\129\217\130\216\183. "," \217\134\216\179\216\174 "," \216\170\217\133 \216\167\217\132\217\134\216\179\216\174! "," \216\186\217\138\216\177 \217\133\216\173\216\179\217\134 - \216\186\217\138\216\177 \216\162\217\133\217\134 "," \216\177\216\179\217\133\217\138 "},es={" # falso detectado "," Est\195\161s usando una copia falsa y modificada de #. No est\195\161 bien optimizada y no es segura. Usa solo los scripts oficiales de abajo. "," Copiar "," \194\161Copiado! "," No optimizado - No es seguro "," Oficial "},zh={" \230\163\128\230\181\139\229\136\176\229\129\135\229\134\146\231\154\132 # "," \228\189\160\230\173\163\229\156\168\228\189\191\231\148\168\232\162\171\228\191\174\230\148\185\232\191\135\231\154\132\229\129\135\229\134\146 #\227\128\130\229\174\131\230\178\161\230\156\137\231\187\143\232\191\135\232\137\175\229\165\189\228\188\152\229\140\150\239\188\140\228\185\159\228\184\141\229\174\137\229\133\168\227\128\130\232\175\183\229\143\170\228\189\191\231\148\168\228\184\139\230\150\185\231\154\132\229\174\152\230\150\185\232\132\154\230\156\172\227\128\130 "," \229\164\141\229\136\182 "," \229\183\178\229\164\141\229\136\182\239\188\129 "," \230\156\170\231\187\143\228\188\152\229\140\150 - \228\184\141\229\174\137\229\133\168 "," \229\174\152\230\150\185 "}};local function A()local g=ChilliState;local N,s=g.L;if N then g=ChilliState;s=g.L.code;else s=N;end;N=s or" en ";if N~=" en "then if z[N]then return N;end;end;N,g=pcall(function()return I(" LocalizationService ").RobloxLocaleId:lower():match(" ^%a+ ");end);g=N and(g==" tl "and" fil "or g);return z[g]and g or" en ";end;local function I(g)return(g:gsub(" [%w%p] "," %0\226\128\139 "));end;local function g(N)local s=b.." /fk "..N.." .png ";local b,X=pcall(function()if not(isfile(s))then local _,R=writefile,crypt and(crypt.base64decode or crypt.base64 and crypt.base64.decode);_(s,(R or base64_decode or base64decode)(t[N]));end;return(getcustomasset or getsynasset)(s);end);return b and X or" ";end;local function b()local t=z[A()];local z=" <font size=\ "13\" color=\"#3DDC84\">" ..t[6].. "</font>" ;
local A= {
Title=t[1]:gsub ( "#" ,w ) ,Rows= {
{
"Chilli Hub" ..z,h[1],g ( 1 ) ,nil,I ( h[1] )
} , {
"Venyx" ..z,h[2],g ( 2 ) ,true,I ( h[2] )
}
} ,Copy=t[3],Copied=t[4],Wait=5,Big=1.25
} ;
A.Warn,A.Body=t[5],t[2]:gsub ( "#" ,w ) ;
E:Dialog ( A ) ;
end ;
local function w ( h,t ) local z,A=h and h.Parent and h.Text~=t ;
if z then
local I,g=h.Text,ChilliState ;
local h,N=g.tr ;
if h then
g=ChilliState ;
N=g.tr ( t ) ;
else
N=h ;
end ;
A=I~= ( N or t ) ;
else
A=z ;
end ;
return A ;
end ;
local h,t=setmetatable, {
__mode= "k"
} ;
local z=h ( {
} ,t ) ;
local function h ( t,A ) if w ( t,A ) then
local I=z[t] ;
if I then
if I>=5 then
return ;
end ;
end ;
else
return ;
end ;
z[t]= ( z[t]or 0 ) +1 ;
local z,I=pcall ( getconnections,t:GetPropertyChangedSignal ( "Text" ) ) ;
if z then
for z,z in ipairs ( I ) do
pcall ( z.Disable,z ) ;
end ;
end ;
t.Text=A ;
end ;
task.spawn ( function ( ) while true do
local t=IsScriptActive ;
if not t then
break ;
end ;
t=ChilliState ;
local z=t.fake ;
local A,I=not z ;
if z then
I=A ;
else
t=w ( E.tl,E.t0 ) ;
local z ;
if t then
z=t ;
else
local g=ChilliState ;
z=w ( g.fbL, "Finder" ) ;
end ;
if z then
I=z ;
else
local w=ChilliState ;
local z=w.fakeG ;
if z then
w=ChilliState ;
I=w.fakeG ( ) ;
else
I=z ;
end ;
end ;
end ;
if I then
A=ChilliState ;
A.fake=true ;
task.spawn ( pcall,b ) ;
end ;
t=ChilliState ;
if t.fake then
A=ChilliState ;
h ( A.fbL, "Finder" ) ;
end ;
task.wait ( 1 ) ;
end ;
end ) ;
end ) ;
S ( "90_run#1" ,function ( ) local w= {
Mutate=true,Bloom=true,Combat=true,Machine=true,Banjo=true
} ;
for b,b in ipairs ( C ) do
if w[b.name]then b.vis=true ;
end ;
end ;
local function w ( b ) local h=ChilliState ;
return h.rank[b.name]or b.pri or 9 ;
end ;
local function b ( h ) local t,z=pcall ( h.on ) ;
return t and z ;
end ;
local function h ( ) table.sort ( C,function ( t,z ) local A,I=t.mover and w ( t ) or 99,z.mover and w ( z ) or 99 ;
if A~=I then
return A<I ;
end ;
return t.i<z.i ;
end ) ;
end ;
local t,z=ChilliState,ChilliState ;
t.order=function ( ) local t=ChilliState ;
if t.unblock then
local t=ChilliState ;
t.unblock ( ) ;
end ;
h ( ) ;
end ;
z.rank2=w ;
h ( ) ;
local function h ( t ) local z=ChilliState ;
local A,I=z.lock ;
if A then
z=ChilliState ;
I=z.lock ( ) ;
else
I=A ;
end ;
return I~=nil and t.name~=I ;
end ;
local function t ( ) local z=ChilliState ;
if z.invisBusy then
local A,I=ChilliState,ChilliState ;
A.busyAt=I.busyAt or os.clock ( ) ;
I,A=ChilliState,os.clock ( ) -ChilliState.busyAt ;
if A>20 then
local A,I=ChilliState,ChilliState ;
A.invisBusy=false ;
I.busyAt=nil ;
end ;
else
local A=ChilliState ;
A.busyAt=nil ;
end ;
z=ChilliState ;
local A,I=z.invisBusy ;
if A then
I=A ;
else
z=nil ;
z,I=ChilliState,os.clock ( ) < ( ChilliState.invisSettle or 0 ) ;
end ;
return I ;
end ;
local z=ChilliState ;
z.needVis=function ( z,A ) local I=z.vis ;
return ( if type ( I ) == "function" then
I ( A )
else
I ) ==true ;
end ;
local function z ( A ) return A.rank or w ( A ) ;
end ;
local w=ChilliState ;
w.better=function ( w ) local A=ChilliState ;
for I,I in ipairs ( A.queue or {
} ) do
if I~=w then
if not ( I.aux ) then
return z ( I ) <math.max ( w.erank or 0,z ( w ) ) ;
end ;
end ;
end ;
return false ;
end ;
local function w ( A,I,g ) local N=ChilliState ;
if N.lagoonGate then
local S=ChilliState ;
if not ( S.lagoonGate ( A,g ) ) then
return false ;
end ;
end ;
N=ChilliState ;
local S=N.needVis ( A,I ) ;
if S then
N=ChilliState ;
if N.invisible ( ) then
A.flipped=true ;
I=ChilliState ;
if not ( I.body ( false ) ) then
return false ;
end ;
end ;
end ;
if not ( S ) then
I=ChilliState ;
if I.invisWant ( ) then
N=ChilliState ;
if not ( N.invisible ( ) ) then
if A.name~= "Steal" then
local A=ChilliState ;
A.body ( true ) ;
end ;
end ;
end ;
end ;
return g ( ) ;
end ;
local function A ( I,g ) local N=Y[4] ;
if N then
bb ( N ) ;
local S=os.clock ( ) ;
while true do
local s=N.busy and IsScriptActive ;
if not ( s and os.clock ( ) -S<10 ) then
break ;
end ;
task.wait ( ) ;
end ;
if N.busy then
N.busy=false ;
if Y[4]==N then
Y[4]=nil ;
end ;
end ;
end ;
Y[4],I.busy,I.t0,I.plan,I.idle,I.erank=I,true,os.clock ( ) ,g,nil,z ( I ) ;
local N=I.tok ;
local function S ( ) local s=IsScriptActiveand I.tok==N and b ( I ) and v ( ) and not h ( I ) and not t ( ) ;
return s ;
end ;
task.spawn ( function ( ) local N,s=pcall ( function ( ) if not ( w ( I,g,S ) ) then
return "prep" ;
end ;
return I.run ( g,S ) ;
end ) ;
I.acted=N and s==true ;
if not ( N ) then
local w=Y[11] ;
w ( I.name.. ": " ..tostring ( s ) :sub ( 1,60 ) , "err" ) ;
end ;
if s== "prep" then
I.at=math.max ( I.at,os.clock ( ) +2 ) ;
end ;
if I.flipped then
if not ( I.acted ) then
if os.clock ( ) -I.t0<8 then
I.at=math.max ( I.at,os.clock ( ) +2 ) ;
end ;
end ;
end ;
I.flipped=nil ;
s=getHumanoid ;
local w,g=s ( ) ,getRootPart ;
N=g ( ) ;
if w then
if w.PlatformStand then
g=ChilliState ;
if g.lock then
s=ChilliState ;
if not ( s.lock ( ) ) then
w.PlatformStand=false ;
end ;
else
w.PlatformStand=false ;
end ;
end ;
end ;
if N then
if not ( N.Anchored ) then
s=Vector3.zero ;
N.AssemblyLinearVelocity=s ;
end ;
end ;
N,g=Y[2alse ;
if Hb then
if Hb.token then
if ub.s then
else
ub.s=Hb ;
Vb=true ;
end ;
else
end ;
else
end ;
if Ub.user~=nil then
if Ub.user~= "" then
if ub.u then
else
ub.u=Ub.user ;
Vb=true ;
end ;
else
end ;
Ub.user=nil ;
ib ( ) ;
else
end ;
if Hb then
pcall ( delfile,Pb ) ;
end ;
if Vb then
pb ( ub ) ;
end ;
local function Wb ( ) ub=kb ( ) ;
local kb=ub.s ;
return type ( kb ) == "table" and L ( kb.endTs ) and kb.endTs>_b ( ) *1000 and kb or nil ;
end ;
ab.sess=Wb ( ) ;
local function kb ( ) local ob=ub ;
ob.s=ab.sess ;
pb ( ub ) ;
end ;
local function ob ( ) return ab.sess~=nil and _b ( ) *1000<ab.sess.endTs ;
end ;
Vb=ab.sess and ab.sess.username or ub.rt and ( ub.u or "?" ) ;
ab.who=Vb or nil ;
local function Vb ( ) return ob ( ) or ab.who~=nil ;
end ;
local function yb ( Mb ) return b[21] ( 0,_b ( ) - ( Mb.at or 0 ) /1000 ) ;
end ;
local function Mb ( ... ) local lb,Cb= {
...
} , {
} ;
for wK=1,#lb,2 do
Cb[#Cb+1]=ColorSequenceKeypoint.new ( lb[wK],lb[wK+1] ) ;
end ;
return b[18] ( Cb ) ;
end ;
local lb= {
} ;
b[45]= {
} ;
w:XI ( b[45],0, "Golden" ,b[12] ( 255,206,70 ) ) ;
b[46]=b[45] ;
lb.Golden=b[46] ;
b[47]= {
} ;
w:XI ( b[47],0, "Silver" ,b[12] ( 215,225,240 ) ) ;
b[48]=b[47] ;
lb.Silver=b[48] ;
lb.Rainbow= {
"Rainbow"
} ;
b[49]= {
} ;
w:XI ( b[49],0, "Scrambled" ,b[12] ( 190,130,255 ) ) ;
b[50]=b[49] ;
lb.Scrambled=b[50] ;
b[51]= {
} ;
w:XI ( b[51],0, "Enchanted" ,b[12] ( 100,225,255 ) ) ;
b[52]=b[51] ;
lb.Enchanted=b[52] ;
b[53]= {
} ;
w:XI ( b[53],0, "Bloom" ,b[12] ( 255,160,210 ) ) ;
b[54]=b[53] ;
lb.Sakura=b[54] ;
b[55]= {
} ;
w:XI ( b[55],0, "Abducted" ,b[12] ( 181,255,165 ) ) ;
b[56]=b[55] ;
lb.Alien=b[56] ;
b[57]= {
} ;
w:XI ( b[57],0, "Spectral" ,b[12] ( 110,240,220 ) ) ;
b[58]=b[57] ;
lb.Spectral=b[58] ;
b[59]= {
} ;
w:XI ( b[59],0, "Musical" ,b[12] ( 255,130,210 ) ) ;
b[60]=b[59] ;
lb.Musical=b[60] ;
b[61]= {
} ;
w:XI ( b[61],0, "Dark Matter" ,b[12] ( 150,110,255 ) ) ;
b[62]=b[61] ;
lb.DarkMatter=b[62] ;
local Cb=Mb ( 0,b[12] ( 255,80,80 ) ,0.25,b[12] ( 255,210,60 ) ,0.5,b[12] ( 90,230,110 ) ,0.75,b[12] ( 70,160,255 ) ,1,b[12] ( 210,90,255 ) ) ;
local function wK ( bK ) local hK,tK=b[20] ( yb ( bK ) ) ,ob ( ) and "" or " ago" ;
return ( hK<60 and hK.. "s" or hK<3600 and hK//60 .. "m" or hK//3600 .. "h" ) ..tK ;
end ;
local function bK ( ) local hK=ab.ws ;
ab.ws=nil ;
ab.aj=nil ;
ab.ajKey=nil ;
if hK then
pcall ( function ( ) hK:Close ( ) ;
end ) ;
end ;
end ;
local function hK ( ) ab.dirty=true ;
end ;
local function tK ( zK ) local YK= {
} ;
YK[1]=ab ;
YK[2]=ab ;
YK[3]= ( b[19] ( ) ) ;
YK[1].msg=zK ;
YK[2].msgAt=YK[3] ;
hK ( ) ;
end ;
local zK ;
ab.ajSend=function ( YK ) local AK= {
} ;
local IK=ab.ws ;
if IK then
AK[1]= ( b[20] ( _b ( ) *1000 ) ) ;
YK.ts=AK[1] ;
task.defer ( pcall,function ( ) IK:Send ( jb ( b[6]:JSONEncode ( YK ) ,vb ) ) ;
end ) ;
end ;
end ;
local function YK ( AK,IK ) if zK then
if not ( zK.fly ) then
ab.ajSend ( {
a= "x" ,j=zK.e.jobId,r=IK or "other"
} ) ;
end ;
end ;
zK=nil ;
if AK then
tK ( AK ) ;
end ;
hK ( ) ;
end ;
local function AK ( ) return L ( workspace:GetAttribute ( "AreaEggCyclePeriodSeconds" ) ) or 300 ;
end ;
local function IK ( ) local gK,NK=AK ( ) ,_b ( ) ;
return Ub.night>0 and math.ceil ( NK/gK ) *gK-NK<Ub.night+10 ;
end ;
local function gK ( ) if not ( zK ) then
return ;
end ;
zK.tries+=1 ;
ab.tried[zK.e.jobId]=os.clock ( ) ;
local NK,GK=ab.ajSend, {
a= "t"
} ;
GK.j=zK.e.jobId ;
NK ( GK ) ;
Nb.ChilliFinderJoinAt=os.clock ( ) ;
pcall ( function ( ) b[5]:SetTeleportSetting ( "__ChilliFinderAt" ,os.time ( ) ) ;
end ) ;
local NK,GK,SK=zK,zK,os.clock ( ) +3 ;
NK.fly=nil ;
GK.next=SK ;
pcall ( function ( ) b[5]:SetTeleportSetting ( "__ChilliFinderAuto" ,ab.auto and zK.e.jobId or false ) ;
end ) ;
if Ub.reload then
pcall ( function ( ) b[5]:SetTeleportSetting ( "__ChilliFinderAutoLoad" ,true ) ;
end ) ;
SK,GK=queue_on_teleport or queueonteleport or syn and syn.queue_on_teleport or fluxus and fluxus.queue_on_teleport,tostring ( Nb.ChilliFinderUrl or "https://api.luarmor.net/files/v4/loaders/130307ddb90b87125e0a381843ee1563.lua" ) ;
if SK then
if not ( Nb.ChilliHubSaeCleanup ) then
if not ( Nb.VenyxSAE ) then
if rawget ( _G, "__ChilliFinderQueued" ) ~=true then
if pcall ( SK, ( "local ok, on = pcall(function() return game:GetService(\"TeleportService\"):GetTeleportSetting(\"__ChilliFinderAutoLoad\") end)\10if ok and on == true then if not game:IsLoaded() then game.Loaded:Wait() end loadstring(game:HttpGet(%q))() end" ) :format ( GK ) ) then
_G.__ChilliFinderQueued=true ;
end ;
end ;
end ;
end ;
end ;
end ;
if Nb.ChilliFinderBeforeTeleport then
pcall ( Nb.ChilliFinderBeforeTeleport ) ;
end ;
GK=zK.e.placeId==107778070777162 and b[1].PlaceId~=107778070777162 and os.time ( ) or nil ;
if GK or ab.pl.go then
ab.pl.go=GK ;
pcall ( writefile,ab.PLF,b[6]:JSONEncode ( ab.pl ) ) ;
end ;
local NK=zK ;
task.spawn ( function ( ) local GK,SK=pcall ( b[5].TeleportToPlaceInstance,b[5],NK.e.placeId,NK.e.jobId,b[9] ) ;
if not ( GK ) then
if zK==NK then
local GK,sK,XK,OK=zK,zK,tostring ( SK ) :sub ( 1,40 ) ,os.clock ( ) +0.1 ;
GK.why=XK ;
sK.next=OK ;
if zK.a then
ab.failed[NK.e.jobId]=os.clock ( ) + ( Ub.gap>0 and 0 or 120 ) ;
YK ( ) ;
task.delay ( 0.1,ab.autoNext ) ;
end ;
end ;
end ;
end ) ;
end ;
ab.unlock=function ( NK,GK ) local SK=NK.lk and db ( NK.lk,e ( GK ) ,true ) ;
if type ( SK ) == "table" then
if type ( SK.j ) == "string" then
NK.jobId=SK.j ;
NK.lk=nil ;
return true ;
end ;
end ;
end ;
local function NK ( GK ) local SK=e ( GK.id ) ;
ab.kk=ab.kk or {
} ;
ab.kk[SK]=nil ;
if ab.ws then
ab.ajSend ( {
a= "k" ,id=GK.id
} ) ;
local sK=b[19] ( ) +4 ;
repeat
task.wait ( 0.05 ) ;
until ab.kk[SK]or b[19] ( ) >sK ;
else
local sK=cb ( Rb.. "joiner/key?s=" ..ab.sess.token.. "&id=" ..SK,ab.sess.secret ) ;
ab.kk[SK]=sK and sK.kk ;
end ;
GK=ab.kk[SK] ;
return GK and GK.k ;
end ;
local function GK ( SK,sK ) if SK and SK.lk then
if ab.unl then
return ;
elseif
not ( ob ( ) ) then
return ;
end ;
ab.unl=true ;
if not sK then
tK ( "Opening server..." ) ;
end ;
task.spawn ( function ( ) local XK= {
} ;
local OK=NK ( SK ) ;
ab.unl=nil ;
if OK and ab.unlock ( SK,OK ) then
GK ( SK,sK ) ;
else
if not ( sK ) then
tK ( "Could not open this server" ) ;
end ;
XK[1]=ab.failed ;
XK[2]=SK.jobId ;
XK[3]=b[19] ( ) +30 ;
XK[1][XK[2]]=XK[3] ;
if sK then
task.defer ( ab.autoNext ) ;
end ;
end ;
end ) ;
return ;
end ;
if not ( ob ( ) ) then
return tK ( ab.who and "No active booking. Book hours at chillihub.pro" or "Sign in with an active Finder booking first" ) ;
end ;
if not ( Eb ( ) ) then
return tK ( "Finder runs in another script" ) ;
end ;
if SK and SK.jobId then
if SK.placeId then
if SK.jobId==b[1].JobId then
return ;
end ;
else
return ;
end ;
else
return ;
end ;
if IK ( ) then
return tK ( "Night is close, join again after the reset" ) ;
end ;
local NK,XK,OK= {
e=SK,tries=0,next=0,why= "" ,a=sK,force=not sK and Ub.gap>0
} ,os.clock ( ) ,sK and 8 or Ub.gap>0 and Ub.gap ;
NK.stop=XK+ ( OK or 15 ) ;
zK=NK ;
ab.dirty=true ;
gK ( ) ;
end ;
Kb ( b[5].TeleportInitFailed,function ( NK,SK,sK ) if NK~=b[9]then return ;
elseif
not ( zK ) then
return ;
end ;
local XK,OK=b[19] ( ) ,b[11].TeleportResult ;
if SK==OK.IsTeleporting then
if zK.a then
local HK,VK,KK,_K=zK,zK,zK,XK+0.25 ;
HK.fly=nil ;
VK.next=_K ;
KK.tries=0 ;
return ;
end ;
end ;
NK=SK==OK.GameFull and "full" or ( SK==OK.GameEnded or SK==OKend ;
end ;
_b=invokeServerWithTimeout ;
_b ( "RF/Fusery/BeginFuse" ) ;
Sb.at=0 ;
Hb=Y[71] ;
m ( "Fusing 3 " ..Hb ( Vb.cat ) .. " for the wisp quest" ) ;
end ;
h.fn=function ( ) local h,Sb=tb ( ) ;
if not ( Sb ) then
return m ( "Reading quest" ) ;
end ;
local tb=type ( hb ) == "table" and tonumber ( hb.StageCount ) or 4 ;
if Sb.Unlocked then
k ( "wst" ,a, {
Stage= ( "%d / %d" ) :format ( tb,tb ) ,Progress= "Complete"
} ) ;
return m ( "Done, the Enchanted Tree is open" ) ;
end ;
if not ( Sb.Accepted ) then
k ( "wst" ,a, {
Stage= ( "0 / %d" ) :format ( tb ) ,Progress= "Not accepted"
} ) ;
end ;
local Xb=Yb ( Sb ) ;
if Xb then
k ( "wst" ,a, {
Stage= ( "%d / %d" ) :format ( tonumber ( Sb.Stage ) or 1,tb ) ,Progress= ( "%d / %d" ) :format ( Nb ( Sb,Xb ) ,tonumber ( Xb.Target ) or 1 )
} ) ;
end ;
Xb=Y[26] ;
if not ( Xb.wisp ) then
return m ( "Off" ) ;
end ;
if h.FusionLocked then
if type ( h.FusionEggReward ) == "table" then
Xb=invokeServerWithTimeout ;
Xb ( "RF/Fusery/FinishReveal" ) ;
end ;
end ;
if not ( Sb.Accepted ) then
Xb=type ( hb ) == "table" and tonumber ( hb.RequiredSpeedPower ) or 50000000000 ;
if ( tonumber ( h.SpeedPower ) or 0 ) <Xb then
return m ( "Needs " ..U ( Xb ) .. " speed power to meet the wisp" ) ;
end ;
local a=getWorldInstance ;
local hb=a ( "Build" ) ;
if hb then
if not ( hb:GetAttribute ( "EnchantedForestZoneRevealed" ) ) then
return m ( "Waiting for the Enchanted Forest to open" ) ;
end ;
else
return m ( "Waiting for the Enchanted Forest to open" ) ;
end ;
a=ChilliState ;
a.wispGo= {
B ( "EnchantedForestZone" , "WispSpawn" ) , "Accept"
} ;
return m ( "Going to accept the quest" ) ;
end ;
Xb=Yb ( Sb ) ;
if Xb then
if not ( Gb ( Sb,Xb ) ) then
if Nb ( Sb,Xb ) >= ( tonumber ( Xb.Target ) or 1 ) then
h=invokeServerWithTimeout ;
h ( "RF/WispCompanion/Request" , "Claim" ,Xb.Id ) ;
return m ( "Claimed " ..tostring ( Xb.Title ) ) ;
end ;
end ;
end ;
if ( tonumber ( Sb.Stage ) or 1 ) >=tb then
if not ( Sb.Returning ) then
h=invokeServerWithTimeout ;
h ( "RF/WispCompanion/Request" , "BeginReturn" ) ;
end ;
local h=ChilliState ;
h.wispGo= {
B ( "EnchantedForestZone" , "Zone13Props" , "EnchantedTree" , "WispAnchor" ) or B ( "EnchantedForestZone" , "WispAnchor" ) , "Return"
} ;
return m ( "Returning the wisp" ) ;
end ;
if not Xb then
return m ( "Reading quest" ) ;
end ;
if Xb.Event== "PetFused" then
return r ( Xb ) ;
end ;
m ( tostring ( Xb.Title ) .. ( type ( Xb.Match ) == "table" and Xb.Match.Rarity and " - waiting for that egg in this server" or "" ) ) ;
end ;
local h=wb ( {
name= "WispGo" ,mover=true,gap=3,pri=4
} ) ;
h.on=function ( ) local B=Y[26] ;
return B.wisp ;
end ;
h.want=function ( ) local B=ChilliState ;
local r,m=B.wispGo ;
if r then
B=ChilliState ;
m=B.wispGo[1] ;
else
m=r ;
end ;
r=nil ;
if m then
B=ChilliState ;
r=B.wispGo ;
else
r=m ;
end ;
return r or nil ;
end ;
h.run=function ( h,B ) local r=h[1] ;
if Y[13] ( B ) then
local m=Y[14] ;
if not ( m ( B ) ) then
return ;
end ;
else
return ;
end ;
local m=getRootPart ;
local a=m ( ) ;
if a then
m=isInsideSafeZone ;
if m ( a.Position ) then
local hb=Y[17] ;
if not ( hb ( B, "Wisp" ,0.3 ) ) then
return ;
end ;
end ;
end ;
m,a=LocalPlayer,LocalPlayer ;
pcall ( LocalPlayer.RequestStreamAroundAsync,LocalPlayer,r ) ;
local m=getRootPart ;
local a=m ( ) ;
if not ( a ) then
return ;
end ;
if ( a.Position-r ) .Magnitude>1200 then
if e ( ) >0 then
m=Vector3.new ;
zb ( r+m ( 0,3,3 ) ,B ) ;
end ;
end ;
m=getRootPart ;
a=m ( ) ;
if a then
if ( a.Position-r ) .Magnitude>40 then
local a,hb=ChilliState,Vector3.new ;
if not ( a.stepTo ( r+hb ( 0,0,3 ) ,B ) ) then
return ;
end ;
end ;
end ;
m=getHumanoid ;
local a,hb=m ( ) ,0 ;
while true do
local tb,Yb=a and B ( ) and hb<3 ;
if tb then
m=getRootPart ;
Yb= ( m ( ) ) ;
else
Yb=tb ;
end ;
tb=nil ;
if Yb then
local B=getRootPart ;
tb= ( B ( ) .Position-r ) .Magnitude>6 ;
else
tb=Yb ;
end ;
if not tb then
break ;
end ;
a:MoveTo ( r ) ;
hb+=task.wait ( 0.2 ) ;
end ;
task.wait ( 0.5 ) ;
r=invokeServerWithTimeout ;
r ( "RF/WispCompanion/Request" ,h[2] ) ;
m=ChilliState ;
m.wispGo=nil ;
end ;
end ) ;
S ( "34_star#1" ,function ( ) local h,B= {
pay=nil,caught=0,slipped=0,askAt=0,jumped= {
}
} ,ChilliState ;
B.SS=h ;
local r=wb ( {
name= "Star" ,mover=true,gap=0.5,pri=2
} ) ;
B=Ib[ "Shooting Star" ] ;
local m=B:Text ( "Shooting Star Status" , "Off" ) ;
local a= {
Set=function ( hb,hb,tb ) if hb== "Status" then
m:Set ( tb ) ;
end ;
end
} ;
y ( B, "Auto Catch Shooting Star" , "star" ,false,function ( B ) if not ( B ) then
bb ( r ) ;
end ;
end ) ;
local function B ( m ) if type ( m ) == "table" then
if m.Id~=nil then
if h.pay then
if not ( h.pay.Id==m.Id ) then
h.slipped=0 ;
end ;
else
h.slipped=0 ;
end ;
h.pay=m ;
end ;
end ;
end ;
local function m ( ) h.askAt=os.clock ( ) +15 ;
task.spawn ( function ( ) local hb=invokeServerWithTimeout ;
local tb,Yb=hb ( "RF/ShootingStar/AskState" ) ;
if tb then
B ( Yb ) ;
end ;
end ) ;
end ;
local function hb ( tb,Yb ) local Nb=NetworkingRemotes ;
local Gb=Nb:FindFirstChild ( tb ) ;
if Gb then
if Gb:IsA ( "RemoteEvent" ) then
V ( Gb.OnClientEvent,Yb ) ;
end ;
end ;
end ;
hb ( "RE/ShootingStar/Fall" ,B ) ;
hb ( "RE/ShootingStar/Wander" ,function ( B,tb ) if h.pay then
if h.pay.Id==B then
if type ( tb ) == "table" then
h.pay.Leg=tb ;
end ;
end ;
end ;
end ) ;
hb ( "RE/ShootingStar/Slipped" ,function ( B ) if h.pay then
if h.pay.Id==B then
h.slipped=h.slipped+1 ;
h.hold=nil ;
end ;
end ;
end ) ;
hb ( "RE/ShootingStar/Claimed" ,function ( B ) if h.pay then
if h.pay.Id==B then
h.caught=h.caught+1 ;
h.pay=nil ;
bb ( r ) ;
u ( "Shooting Star" , "Caught a star" , "ok" ) ;
end ;
end ;
end ) ;
hb ( "RE/ShootingStar/Expired" ,function ( B ) if h.pay then
if h.pay.Id==B then
h.pay=nil ;
bb ( r ) ;
end ;
end ;
end ) ;
m ( ) ;
local function B ( hb ) local tb=workspace:FindFirstChild ( "ShootingStarClient" ) ;
local Yb=tb and ( tb:FindFirstChild ( "Buddy" ) ) ;
tb=Yb and ( Yb:FindFirstChild ( "RootPart" ) ) ;
if tb then
if tb:IsA ( "BasePart" ) then
return tb.Position ;
end ;
end ;
tb,Yb=P ( ) ,hb.Leg ;
if type ( Yb ) == "table" then
if typeof ( Yb.From ) == "Vector3" then
if typeof ( Yb.To ) == "Vector3" then
local Nb=tonumber ( Yb.StartAt ) or tb ;
local Gb= ( tonumber ( Yb.ArriveAt ) or Nb ) -Nb ;
local Sb,Xb=Gb>0 and math.clamp ( ( tb-Nb ) /Gb,0,1 ) or 1,Yb.To-Yb.From ;
local tb,Nb,Hb=Yb.From:Lerp ( Yb.To,Sb ) ,Sb<1 and Xb.Magnitude>0.5 ;
if Nb then
Gb=Vector3.new ;
Hb=Gb ( Xb.X,0,Xb.Z ) .Unit ;
else
Hb=Nb ;
end ;
return tb,Hb or nil ;
end ;
end ;
end ;
Yb=hb.Landing ;
if typeof ( Yb ) == "CFrame" then
return Yb.Position ;
end ;
return typeof ( Yb ) == "Vector3" and Yb or nil ;
end ;
local function hb ( tb ) local Yb=P ( ) ;
return tb and Yb>= ( tonumber ( tb.LandAt ) or Yb ) and ( tonumber ( tb.ExpiresAt ) or math.huge ) >Yb ;
end ;
local tb=ChilliState ;
tb.starWants=function ( ) local tb=Y[26] ;
return tb.star and hb ( h.pay ) ;
end ;
r.on=function ( ) if os.clock ( ) >=h.askAt then
m ( ) ;
end ;
if h.pay then
if ( tonumber ( h.pay.ExpiresAt ) or math.huge ) <=P ( ) then
h.pay=nil ;
end ;
end ;
local tb=Y[26] ;
return tb.star and hb ( h.pay ) ;
end ;
r.want=function ( ) local hb=Y[22] ;
if hb ( ) then
return ;
end ;
return h.pay ;
end ;
r.run=function ( hb,tb ) local Yb=LocalPlayer ;
local Nb=Yb.Character ;
local function Gb ( ) local Sb,Xb=tb ( ) and h.pay==hb ;
if Sb then
local tb=LocalPlayer ;
Xb=tb.Character==Nb ;
else
Xb=Sb ;
end ;
return Xb ;
end ;
if Y[13] ( Gb ) then
Yb=Y[14] ;
if not ( Yb ( Gb ) ) then
return ;
end ;
else
return ;
end ;
Yb=getRootPart ;
local tb=Yb ( ) ;
Yb=nil ;
if tb then
local Nb=isInsideSafeZone ;
Yb=Nb ( tb.Position ) ;
else
Yb=tb ;
end ;
if Yb then
local Nb=Y[17] ;
if not ( Nb ( Gb, "Shooting Star" ) ) then
return ;
end ;
end ;
local function Nb ( ) local Sb=B ( hb ) ;
local Xb ;
if Sb then
local Hb=Vector3.new ;
Xb=Sb+Hb ( 0,3,3 ) ;
e ( "UICorner" , {
CornerRadius=UDim.new ( 0,10 ) ,Parent=Nb
} ) ;
_ ( "UIStroke" , {
Color=t ( 82,82,107 ) ,Thickness=1.5,Parent=Nb
} ) ;
p=y ;
p.tb=mK ( Nb, "Message..." ,c ( 12,0 ) ,R ( 1,-24,1,0 ) ,t ( 240,240,248 ) ,t ( 120,124,150 ) ) ;
jK ( tb, "SEND" ,nil,c ( 80,40 ) ,function ( ) s ( y.tb.Text ) ;
end ,B ( 1,0 ) ,x ( 1,0 ) ) ;
Sb=y ;
Sb.emptyC=RK ( M,NK ( "Accept a request, or send one from Find" ) ,R ( 0,10,0.5,-11 ) ,R ( 1,-20,0,22 ) ,16,r ) ;
V ( y.tb.FocusLost,function ( w ) if w then
s ( y.tb.Text ) ;
end ;
end ) ;
ZK ( zb,function ( ) tK ( false ) ;
end ) ;
task.spawn ( function ( ) pcall ( function ( ) local w=require ( N.Packages.TopBarPlus ) ;
for b,b in pairs ( w.getIcons ( ) ) do
if b.name== "ChilliShrineFusion" then
b:destroy ( ) ;
end ;
end ;
local b=next ( w.getIcons ( ) ) ~=nil ;
nb=w.new ( ) :setName ( "ChilliShrineFusion" ) :setImage ( e ( "Xenorath" ) ) :setImageScale ( 0.85 ) :setCaption ( "Fusion Finder" ) :setOrder ( 102 ) ;
if not ( b ) then
nb:align ( "Right" ) ;
end ;
nb:bindEvent ( "selected" ,function ( ) H.ShrineFinderWant=true ;
end ) ;
nb:bindEvent ( "deselected" ,function ( ) H.ShrineFinderWant=false ;
end ) ;
end ) ;
if not ( nb ) then
H.ShrineFinderWant=true ;
end ;
end ) ;
end ;
local w=V ( O,function ( ) local b=os.clock ( ) ;
if mb~=1 then
if mb~=0 then
return ;
elseif
b<eb then
return ;
end ;
eb=b+2 ;
local h=LocalPlayer ;
if not ( AK ( h, "PlayerGui" , "PetFuse" , "FuseMain" ) ) then
return ;
end ;
if pcall ( F ) then
mb=1 ;
else
pcall ( game.Destroy,y.gui ) ;
pcall ( game.De yb ( ) ;
wK ( Zb ) ;
y.gui.Enabled,y.wsc.Scale=true,Tb*0.6 ;
SK ( y.wsc, {
Scale=Tb
} ,0.32,U ) ;
else
local Q,i=y.wsc, {
} ;
i.Scale=Tb*0.6 ;
SK ( Q,i,0.18,h.EasingStyle.Quad,h.EasingDirection.In ) .Completed:Once ( function ( ) if not ( Jb ) then
y.gui.Enabled=false ;
end ;
end ) ;
end ;
if nb then
task.spawn ( pcall,function ( ) if F then
nb:select ( ) ;
else
nb:deselect ( ) ;
end ;
end ) ;
end ;
end ;
local function F ( ) local Q=LocalPlayer ;
local i,p=Q.PlayerGui,I ( "SoundService" ) ;
local o,M,tb=i.PetFuse.FuseMain,AK ( i, "HUD" , "GameHUD" , "BottomLeft" , "Money" , "Value" ) ,AK ( i, "Index" , "Frame" , "TabButtons" , "World" ) ;
Kb,Pb,cb=o,M,tb ;
local zb,Yb,Ib,Nb,Sb=y,Kb.FuseInputs.Input1,Kb.Fuse,Kb.Info1,AK ( N, "Controllers" , "GUI" , "BackpackController" , "Main" , "InventoryTemplate" ) ;
_b,Rb,vb=Yb,Ib,Nb ;
zb.INVT=Sb ;
pcall ( function ( ) local Vb,Kb=next,GameModules ;
local _b,Rb=Kb.Mut.All ( ) ;
for Kb,vb in Vb,_b,Rb do
k[Kb]=vb.IconAssetId and "rbxassetid://" ..tostring ( vb.IconAssetId ) ;
end ;
end ) ;
k.Boss,k.Scrambled,k.Enchanted,k.Nitro,k.Spectral=J.fractured,J.scramble,J.essence,J.nitro,J.spectral ;
task.spawn ( q ) ;
tb=y ;
tb.snd=_ ( "Sound" , {
SoundId= "rbxassetid://100671636189844" ,Volume=3.4,Parent=p
} ) ;
pcall ( function ( ) y.snd.SoundGroup=p:FindFirstChild ( "Gameplay" ) ;
end ) ;
local p=I ( "CoreGui" ) ;
pcall ( function ( ) local k=gethui ( ) ;
if typeof ( k ) == "Instance" then
p=k ;
end ;
end ) ;
o,M=_ ( "f mb then mb:Destroy();mb=nil;end;end);Jb(" ESP Guard Size ",_b,function(tb)Rb=tb;for tb,tb in next,nb,nil do vb(tb);end;end);end;do local tb=I(" TextService ");local Vb=Kb(0,138,255,205,0.5,125,225,255,1,210,135,255);local _b,Rb,vb,Pb=Kb(0,7,73,66,1,35,17,79),false,0;local Kb,Bb,xb,Tb,Fb,Zb={},{},{},{},0.75,{Name=true,Tool=true};local function rb(nb)nb=tostring(nb or" ");return nb:match(" ^%d+$ ")and" rbxassetid:// "..nb or nb;end;local function nb(Qb)if not(Qb)then return" ";end;local mb=rb(Qb.TextureId);if mb~=" "then return mb;end;local ib={" Icon "," Image "," Thumbnail "," TextureId "};for eb,Lb in ipairs(ib)do eb=Qb:GetAttribute(Lb);if type(eb)==" string "then if rb(eb)~=" "then return rb(eb);end;end;end;for ib,ib in ipairs(Qb:GetDescendants())do mb=if ib:IsA(" Decal ")then rb(ib.Texture)else if ib:IsA(" Texture ")then rb(ib.Texture)else if ib:IsA(" ImageLabel ")then rb(ib.Image)else if ib:IsA(" ImageButton ")then rb(ib.Image)else mb;if mb~=" "then return mb;end;end;return" ";end;local function rb(Qb,mb)local ib=Qb.." @ "..mb;if Tb[ib]then return Tb[ib];end;local eb=_(" GetTextBoundsParams ",{Text=Qb,Font=Hb,Size=mb,Width=1000});local Lb,ab=pcall(tb.GetTextBoundsAsync,tb,eb);eb:Destroy();Tb[ib]=Lb and ab.X or(utf8.len(Qb)or#Qb)*mb*0.56;return Tb[ib];end;local function tb(Tb,Qb,mb,ib)return Db({Parent=Tb,AnchorPoint=a(0,0.5),FontFace=Hb,ZIndex=Qb,TextColor3=mb,TextTransparency=ib});end;local function Hb(Tb,Db)local Qb=_(" ImageLabel ",{Parent=Tb,AnchorPoint=a(0,0.5),BackgroundTransparency=1,ScaleType=Enum.ScaleType.Fit,ZIndex=Db});_(" UIAspectRatioConstraint ",{Parent=Qb});return Qb;end;local function a(Tb)local Db,Qb,mb,ib=Nb(1,Yb(math.clamp(hb()*0.024,26,35)*Fb)),Zb.Name==true or Zb.Username==true,Zb.Avatar==true,Zb.Tool==true and Tb.ti.Image~=" ";local hb,eb,Lb,ab,Eb=mb and Yb(Db*0.72)or 0,ib and Yb(Db*0.82)or 0,Yb(Db*0.7),Nb(1,Yb(Db*0.04)),Zb.Username==true and Tb.pl.Name or Tb.pl.DisplayName;Tb.n.Text,Tb.s.Text=Eb,Eb;local ub,Wb=Qb and Yb(math.clamp(rb(Eb,Lb)+4,Lb,230))or 0,hb>0 and hb+ab or 0;Eb=Qb and Wb+ub or hb;local Yb=Eb>0 and Eb+ab or 0;ab=Nb(ib and Yb+eb or Eb,1);local Nb,rb,Eb,pb=1/ab,1/Db,r(ub/ab,Lb/Db),r(eb/ab,eb/Db);Tb.b.Size,Tb.a.Visible,Tb.n.Visible,Tb.s.Visible,Tb.ti.Visible,Tb.ts.Visible=m(ab,Db),mb,Qb,Qb,ib,ib;Tb.a.Position,Tb.a.Size=r(0,0.5),r(hb/ab,hb/Db);Tb.n.Position,Tb.n.Size=r(Wb/ab,0.5),Eb;Tb.s.Position,Tb.s.Size=r(Wb/ab+Nb,0.5+rb),Eb;Tb.ti.Position,Tb.ti.Size=r(Yb/ab,0.5),pb;Tb.ts.Position,Tb.ts.Size=r(Yb/ab+Nb,0.5+rb),pb;end;local function hb(Yb,Nb,Tb,Db)local rb,Qb=fb(Nb,Pb,B(0,67,148),B(72,207,255)),Db or Tb;Nb,Db={Parent=Pb,Adornee=Qb,AlwaysOnTop=true,LightInfluence=0,MaxDistance=Xb,Size=m(1,1)},Vector3.new;Nb.StudsOffsetWorldSpace=Db(0,Qb~=Tb and math.clamp(Tb.Position.Y-Qb.Position.Y+3.1,3.8,6)or 3.1,0);Db=_(" BillboardGui ",Nb);Qb=_(" Frame ",{Parent=Db,Size=r(1,1),BackgroundTransparency=1});Tb=Hb(Qb,2);Tb.ScaleType=Enum.ScaleType.Crop;_(" UICorner ",{Parent=Tb,CornerRadius=UDim.new(1,0)});local r,m=tb(Qb,1,B(7,19,34),0.05),tb(Qb,2,Gb);Ub(m,0,0.044,1.4,_b,Vb);Nb=Hb(Qb,1);Nb.ImageColor3=Sb;Nb.ImageTransparency=0.35;local B={pl=Yb,hl=rb,b=Db,a=Tb,s=r,n=m,ts=Nb,ti=Hb(Qb,2)};a(B);return B;end;local function B(r)if r.nh then if r.nh.Parent then r.nh.NameDisplayDistance=r.nd;end;end;r.nh=nil;r.nd=nil;end;local function r(m,tb)local Yb=tb:FindFirstChildOfClass(" Humanoid ");if not(Yb)then return;end;if m.nh~=Yb then B(m);m.nh,m.nd=Yb,Yb.NameDisplayDistance;end;Yb.NameDisplayDistance=0;end;local function m(tb)jb(tb.cc);if tb.t then tb.t.hl:Destroy();tb.t.b:Destroy();tb.t=nil;end;B(tb);tb.ch=nil;end;local function B(tb)tb.v=tb.v+1;m(tb);end;local function m(tb)if tb.t then if not(tb.ch)then return;end;else return;end;local Yb=nb(tb.ch:FindFirstChildOfClass(" Tool "));tb.t.ti.Image,tb.t.ts.Image=Yb,Yb;a(tb.t);end;local function tb(Yb,Nb,Gb)B(Yb);local Sb=Yb.v;if Rb then if not Gb then return;end;else return;end;Yb.ch=Gb;task.spawn(function()local Xb=Gb:FindFirstChild(" Head ")or Gb:WaitForChild(" Head ",5);if Rb then if Yb.v~=Sb then return;elseif Xb then if Xb:IsA(" BasePart ")then local Hb=workspace;if not(Gb:IsDescendantOf(Hb))then return;end;else return;end;else return;end;else return;end;Pb=h(Pb);local h=Gb:FindFirstChild(" HumanoidRootPart ");Yb.t=hb(Nb,Gb,Xb,h and h:IsA(" BasePart ")and h or nil);r(Yb,Gb);h=Yb.cc;local function hb()task.defer(function()if Rb then if Yb.v==Sb then m(Yb);end;end;end);end;h[#h+1]=Gb.ChildAdded:Connect(function(Hb)if Hb:IsA(" Tool ")then hb();elseif Hb:IsA(" Humanoid ")then r(Yb,Gb);end;end);h[#h+1]=Gb.ChildRemoved:Connect(function(r)if r:IsA(" Tool ")then hb();end;end);h[#h+1]=Gb.AncestryChanged:Connect(function()if Yb.v==Sb then local r=workspace;if not(Gb:IsDescendantOf(r))then B(Yb);end;end;end);m(Yb);h,Xb=Nb.UserId,xb[Nb.UserId];if Xb==nil then local r,m=pcall(g.GetUserThumbnailAsync,g,h,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size100x100);Xb=r and m or" ";xb[h]=Xb;else end;if Rb then if Yb.v==Sb then if Yb.t then Yb.t.a.Image=Xb;end;end;end;end);end;local function h(r)local m=Kb[r];if not(m)then return;end;B(m);jb(m.pc);Kb[r]=nil;end;local function r(m)local hb=LocalPlayer;if m==hb then return;elseif Kb[m]then return;end;local hb={v=0,cc={},pc={}};Kb[m]=hb;hb.pc[1]=m.CharacterAdded:Connect(function(Yb)tb(hb,m,Yb);end);hb.pc[2]=m.CharacterRemoving:Connect(function(Yb)if hb.ch==Yb then B(hb);end;end);tb(hb,m,m.Character);end;local function B()for m,m in next,Kb,nil do if m.t then a(m.t);end;end;end;cb=db(" ESP Players ",function()Rb=true;vb+=1;local m=vb;Pb=qb();for a,a in ipairs(g:GetPlayers())do r(a);end;Bb[#Bb+1]=g.PlayerAdded:Connect(r);Bb[#Bb+1]=g.PlayerRemoving:Connect(h);local r=workspace.CurrentCamera;if r then Bb[#Bb+1]=r:GetPropertyChangedSignal(" ViewportSize "):Connect(B);end;task.spawn(function()while true do local r=vb;if not(m==r)then break;end;task.wait(1);if m==vb then for m,a in next,Kb,nil do local hb,Yb=m.Character,a.t and a.t.b;r=Yb and Yb.Parent and Yb.Adornee and Yb.Adornee:IsDescendantOf(workspace);if hb then Yb=workspace;if hb:IsDescendantOf(Yb)then if a.ch~=hb then tb(a,m,hb);elseif r then else tb(a,m,hb);end;end;end;end;end;end;end);end,function()Rb=false;vb+=1;jb(Bb);for r in next,Kb,nil do h(r);end;if Pb then Pb:Destroy();Pb=nil;end;end);b:Dropdown(" ESP Player Info ",{" Name "," Username "," Avatar "," Tool "},{" NameB=Kb and Kb.Position+Kb.AssemblyLinearVelocity* ( Vb/110 ) or m and ( tonumber ( m.Health ) or 0 ) >0 and typeof ( m.Model ) == "Instance" and a ( m.Model:FindFirstChild ( "Hitbox" ) or m.Model ) or Nb and ( tonumber ( Nb.Health ) or 0 ) >0 and typeof ( Nb.Model ) == "Instance" and a ( Nb.Model:FindFirstChild ( "Pivot" ,true ) or Nb.Model ) ;
if B then
Nb=Y[11] ;
Nb ( Kb and "Island Wars: shooting an enemy" or "Island Wars: shooting the enemy base" ) ;
hb ( Rb ) ;
tb ( B ) ;
m=Rb:FindFirstChild ( "Handle" ) and Rb.Handle:FindFirstChild ( "Muzzle" ) ;
local a,hb=m and m:IsA ( "Attachment" ) and m.WorldPosition ;
if a then
hb=a ;
else
local m ;
m,hb=Vector3.new,Xb.Position+Vector3.new ( 0,1.5,0 ) ;
end ;
if ( B-hb ) .Magnitude>1 then
h.shot=h.shot+1 ;
R ( "RE/IslandWars/Use" , "Launch" ,h.shot,hb, ( B-hb ) .Unit ) ;
h.cd.PumpkinLauncher=math.max ( h.cd.PumpkinLauncher or 0,_b+1.25 ) ;
end ;
end ;
end ;
end ;
end ;
Vb=HeartbeatWait ;
Vb ( ) ;
end ;
return true ;
end ;
Gb=Ib[ "Cursed Island Wars" ] ;
local B=p ( "ciw" ,Gb:Text ( "Cursed Island Wars Status" , "Waiting for Cursed Island Wars" ) ) ;
y ( Gb, "Auto Play Cursed Island Wars" , "ciw" ,true,function ( m ) r ( m and h.held ( ) ) ;
if not ( m ) then
bb ( b ) ;
end ;
end ) ;
Yb=Y[26] ;
Yb.ciwT= "Enemies and base" ;
Gb:Dropdown ( "Island Wars Target" , {
"Enemies And Base" , "Walls And Crystal"
} , "Enemies And Base" ,function ( b ) local r=Y[26] ;
r.ciwT=b== "Walls And Crystal" and "Walls and crystal" or "Enemies and base" ;
end ) ;
local b=wb ( {
name= "WarsInfo" ,gap=1
} ) ;
b.on=function ( ) return L ( "Admin Abuse" ) or L ( "Event" ) ;
end ;
b.fn=function ( ) local b,r,m=h.snap,h.me ( ) ,Y[26] ;
local h=m.ciw ;
B ( ( if h then
not h
else
"Off" ) or b and r and b.Phase.. " | Team " ..tostring ( r.Team ) .. " | " ..tostring ( r.State ) or b and "Watching, you are not on a team" or "Waiting for Cursed Island Wars" ) ;
end ;
end ) ;
S ( "40_esp#1" ,function ( ) local b=Ib.ESP ;
local h=gethui and gethui ( ) or I ( "CoreGui" ) ;
local B=Color3.fromRGB ;
local r=UDim2.fromScale ;
local m=UDim2.fromOffset ;
local a=Vector2.new ;
local hb=ColorSequenceKeypoint.new ;
local tb=ColorSequence.new ;
local Yb=math.floor ;
local Nb=math.max ;
local Gb=Color3.new ( 1,1,1 ) ;
local Sb=Color3.new ( 0,0,0 ) ;
local Xb=math.huge ;
local Hb=Font.new ( "rbxasset://fonts/families/GothamSSm.json" ,Enum.FontWeight.ExtraBold ) ;
local Vb=Font.new ( "rbxasset://fonts/families/FredokaOne.json" ,Enum.FontWeight.Regular ) ;
y ( b, "Inventory Values" , "espInv" ,true ) ;
local function Kb ( ... ) local _b,Rb= {
...
} , {
} ;
for vb=1,#_b,4 do
Rb[#Rb+1]=hb ( _b[vb],B ( _b[vb+1],_b[vb+2],_b[vb+3] ) ) ;
end ;
return tb ( Rb ) ;
end ;
local _b,Rb,vb=Kb ( 0,8,8,8,1,8,8,8 ) , {
t=Kb ( 0,255,231,158,0.4,255,196,66,1,214,142,12 ) ,s=Kb ( 0,122,76,0,0.55,62,38,0,1,20,12,0 ) ,o=B ( 255,232,152 )
} , {
} ;
vb.t=Kb ( 0,255,198,132,0.4,255,146,40,1,206,92,0 ) ;
vb.s=Kb ( 0,112,54,0,0.55,56,27,0,1,18,8,0 ) ;
vb.o=B ( 255,194,112 ) ;
local Pb,cb,Bb= {
t=Kb ( 0,255,105,105,0.4,255,28,40,1,184,0,18 ) ,s=Kb ( 0,124,0,15,0.55,61,0,9,1,18,0,3 ) ,o=B ( 255,128,138 )
} , {
t=Kb ( 0,170,255,160,0.45,58,255,55,1,20,109,0 ) ,s=Kb ( 0,10,52,6,1,3,16,0 ) ,o=B ( 58,255,55 )
} , {
} ;
Bb.t=Kb ( 0,255,255,255,0.5,222,222,222,1,255,255,255 ) ;
Bb.s=_b ;
local function xb ( Tb ) return {
t=tb ( {
hb ( 0,Tb:Lerp ( Gb,0.5 ) ) ,hb ( 0.4,Tb:Lerp ( Gb,0.1 ) ) ,hb ( 1,Tb:Lerp ( Sb,0.25 ) )
} ) ,s=tb ( {
hb ( 0,Tb:Lerp ( Sb,0.55 ) ) ,hb ( 0.55,Tb:Lerp ( Sb,0.75 ) ) ,hb ( 1,Tb:Lerp ( Sb,0.92 ) )
} )
} ;
end ;
local function hb ( ) local tb=workspace.CurrentCamera ;
return tb and tb.ViewportSize.Y or 1080 ;
end ;
local function tb ( Tb ) return Nb ( 6,Yb ( math.clamp ( hb ( ) *0.014,13,19 ) *Tb ) ) ;
end ;
local function Tb ( qb,Fb ) return Nb ( 30,Yb ( qb*Fb ) ) ;
end ;
local function qb ( ) return _ ( "ScreenGui" , {
Parent=h,Archivable=false,ResetOnSpawn=false,IgnoreGuiInset=true,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=48
} ) ;
end ;
local function h ( Fb ) return Fb and Fb.Parent and Fb or qb ( ) ;
end ;
local function Fb ( Db ) local Ub=_ ( "BillboardGui" , {
Parent=Db,AlwaysOnTop=true,LightInfluence=0,MaxDistance=Xb
} ) ;
Db=_ ( "Frame" , {
Parent=Ub,BackgroundTransparency=1,BorderSizePixel=0,Size=r ( 1,1 )
} ) ;
_ ( "UIListLayout" , {
Parent=Db,HorizontalAlignment=Enum.HorizontalAlignment.Center,VerticalAlignment=Enum.VerticalAlignment.Center,SortOrder=Enum.SortOrder.LayoutOrder
} ) ;
return Ub,Db ;
end ;
local function Db ( Ub ) Ub.BackgroundTransparency=1 ;
Ub.Text= "" ;
Ub.TextScaled=true ;
return _ ( "TextLabel" ,Ub ) ;
end ;
local function Ub ( Zb,rb,fb,jb,db,Jb ) local nb=_ ( "UIStroke" , {
ApplyStrokeMode=Enum.ApplyStrokeMode.Contextual,LineJoinMode=Enum.LineJoinMode.Round,Color=Gb,Transparency=rb
} ) ;
nb.Thickness=pcall ( function ( ) nb.StrokeSizingMode=Enum.StrokeSizingMode.ScaledSize ;
end ) and fb or jb ;
nb.Parent=Zb ;
return _ ( "UIGradient" , {
Parent=nb,Rotation=90,Color=db
} ) ,_ ( "UIGradient" , {
Parent=Zb,Rotation=90,Color=Jb
} ) ;
end ;
local function Zb ( rb,fb,jb,db ) local Jb=_ ( "Frame" , {
Parent=rb,BackgroundTransparency=1,BorderSizePixel=0,Size=r ( 1,db ) ,LayoutOrder=jb
} ) ;
rb,jb=Db ( {
Parent=Jb,Size=r ( 1,1 ) ,ZIndex=2,FontFace=fb,Position=m ( 1,1 ) ,TextColor3=Sb,TextTransparency=0.1
} ) ,Db ( {
Parent=Jb,Size=r ( 1,1 ) ,ZIndex=3,FontFace=fb,TextColor3=Gb
} ) ;
fb,db=Ub ( jb,0.05,0.05,1.2 ) ;
return {
h=Jb,sh=rb,l=jb,sg=fb,tg=db
} ;
end ;
local function rb ( fb,jb,db ) if fb.l.Text~=jb then
fb.l.Text,fb.sh.Text=jb,jb ;
end ;
if fb.p~=db then
fb.p,fb.tg.Color,fb.tg.Rotation,fb.sg.Color=db,db.t,db.r or 90,db.s ;
end ;
end ;
local function fb ( jb,db,Jb,nb ) return _ ( "Highlight" , {
Adornee=jb,Parent=db,DepthMode=Enum.HighlightDepthMode.AlwaysOnTop,FillTransparency=0.76,OutlineTransparency=0.02,FillColor=Jb,OutlineColor=nb
} ) ;
end ;
local function jb ( db ) for Jb,Jb in ipairs ( db ) do
pcall ( function ( ) Jb:Disconnect ( ) ;
end ) ;
end ;
table.clear ( db ) ;
end ;
local function db ( Jb,nb,Qb ) local mb,ib,eb=false,false,false ;
local function Lb ( ) if eb then
return ;
elseif
mb==ib then
return ;
end ;
ib=mb ;
if mb then
nb ( ) ;
else
Qb ( ) ;
end ;
end ;
table.insert ( ChilliState.cleanup,function ( ) eb=true ;
Qb ( ) ;
end ) ;
local function nb ( Qb ) mb=Qb ;
Lb ( ) ;
task.delay ( 0.35,Lb ) ;
end ;
return b:Toggle ( Jb,false,nb ) ;
end ;
local function Jb ( nb,Qb,mb ) b:Slider ( nb,50,200,75,function ( nb ) mb ( nb/100 ) ;
end , "%" ,5,nil,Qb ) ;
end ;
do
local nb= {
3.2,1.35,1.2,1,1.1,1
} ;
local Qb=Font.new ( "rbxassetid://12187365977" ,Enum.FontWeight.Bold ) ;
local mb,ib=Kb ( 0,255,255,255,0.2,206,212,224,0.42,74,80,94,0.58,42,46,56,0.78,158,166,182,1,250,252,255 ) , {
} ;
ib.t=Kb ( 0,255,255,255,0.5,222,238,255,1,255,255,255 ) ;
ib.s=_b ;
local eb=xb ( B ( 77,255,122 ) ) ;
local Lb,ab=xb ( B ( 143,227,255 ) ) , {
Golden=Rb
} ;
ab.Sakura=xb ( B ( 255,158,216 ) ) ;
ab.GreatBloom=xb ( B ( 124,255,196 ) ) ;
ab.Boss=xb ( B ( 255,122,122 ) ) ;
ab.Monstrous=xb ( B ( 192,139,255 ) ) ;
ab.Silver= {
t=Kb ( 0,255,255,255,0.45,214,222,232,1,150,160,175 ) ,s=Kb ( 0,60,66,78,0.55,30,33,40,1,10,11,14 )
} ;
ab.Rainbow= {
t=Kb ( 0,255,107,107,0.2,255,179,107,0.4,255,240,107,0.6,107,25 U,U in ipairs ( h and h:GetChildren ( ) or {
} ) do
t ( U ) ;
end ;
gb ( "hide" ..R,h and c and h.ChildAdded,function ( h ) task.defer ( t,h ) ;
end ) ;
end ;
gb ( "hideW" ,c and workspace.ChildAdded,function ( h ) if T[h.Name]then task.defer ( F ) ;
end ;
end ) ;
end ;
table.insert ( ChilliState.cleanup,function ( ) local h,t=Y[26],Y[26] ;
h.hideMine=false ;
t.hideOthers=false ;
F ( ) ;
end ) ;
local h=_ ( "ScreenGui" , {
Name= "" ,ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=-1000,Enabled=false,Parent=gethui and gethui ( ) or I ( "CoreGui" )
} ) ;
local t=_ ( "Frame" , {
Parent=h,Size=UDim2.fromScale ( 1,1 ) ,BackgroundColor3=Color3.new ( 0,0,0 ) ,BorderSizePixel=0
} ) ;
table.insert ( ChilliState.cleanup,function ( ) h:Destroy ( ) ;
end ) ;
local R=wb ( {
name= "Render" ,gap=180,at=math.huge
} ) ;
local c ;
B=y ( b, "Disable 3D Render" , "no3d" ,false,function ( T ) local F,F=RunService,RunService ;
pcall ( RunService.Set3dRenderingEnabled,RunService,not T ) ;
local F,U,r=pcall,setfpscap ;
if T then
local f ;
f,r=Y[26],math.min ( Y[26].fpsCap,40 ) ;
else
r=T ;
end ;
local f ;
if r then
f=r ;
else
local r=Y[26] ;
f=r.fpsCap ;
end ;
F ( U,f ) ;
pcall ( function ( ) local F=settings ( ) .Rendering ;
if T then
c=c or F.QualityLevel ;
F.QualityLevel=Enum.QualityLevel.Level01 ;
elseif
c then
local U=Y[26] ;
if not ( U.opt ) then
F.QualityLevel=c ;
c=nil ;
end ;
end ;
end ) ;
h.Enabled=T ;
R.at=T and os.clock ( ) +180 or math.huge ;
end ) ;
t.BackgroundColor3=Color3.new ( 1,1,1 ) ;
M ( b, "Background Color" , "no3dColor" , {
"White" , "Black"
} , "White" ,function ( c ) t.BackgroundColor3=c== "White" and Color3.new ( 1,1,1 ) or Color3.new ( 0,0,0 ) ;
end ,false,nil,B ) :When ( B ) ;
R.on=function ( ) local t=Y[26] ;
return t.no3d ;
end ;
R.fn=function ( ) local t,t=RunService,RunService ;
pcall ( RunService.Set3dRenderingEnabled,RunService,true ) ;
task.wait ( 2 ) ;
local t=Y[26] ;
if t.no3d then
local t,t=RunService,RunService ;
pcall ( RunService.Set3dRenderingEnabled,RunService,false ) ;
end ;
end ;
local t,R,c=I ( "StarterGui" ) ,setmetatable, {
__mode= "k"
} ;
local B,T,F=R ( {
} ,c ) ,setmetatable, {
__mode= "k"
} ;
local R,c,U=T ( {
} ,F ) , {
} , {
} ;
local function r ( f ) R[f]= ( R[f]or 0 ) +1 ;
f.Enabled=false ;
end ;
local function f ( d ) if d:IsA ( "LayerCollector" ) then
if d==h then
return ;
elseif
B[d]~=nil then
return ;
end ;
else
return ;
end ;
B[d]=d.Enabled ;
c[#c+1]=d:GetPropertyChangedSignal ( "Enabled" ) :Connect ( function ( ) local h=Y[26] ;
if not ( h.hideUI ) then
return ;
end ;
if d.Enabled then
B[d]=true ;
r ( d ) ;
else
h=R[d] ;
if h then
if h>0 then
R[d]=R[d]-1 ;
else
B[d]=false ;
end ;
else
B[d]=false ;
end ;
end ;
end ) ;
if d.Enabled then
r ( d ) ;
end ;
end ;
local h=ChilliState ;
h.hideUI=function ( h ) local r=Y[26] ;
if r.hideUI==h then
return ;
end ;
r=Y[26] ;
r.hideUI=h ;
r=LocalPlayer ;
local d=r:FindFirstChildOfClass ( "PlayerGui" ) ;
gb ( "hideUI" ,h and d and d.ChildAdded,f ) ;
if h then
for h,h in ipairs ( d and d:GetChildren ( ) or {
} ) do
f ( h ) ;
end ;
local h,f=ipairs,w[76] ( Enum.CoreGuiType:GetEnumItems ( ) ) ;
for d,n in h ( w:iI ( f ) ) do
if n~=Enum.CoreGuiType.All then
if t:GetCoreGuiEnabled ( n ) then
d=U ;
d[#d+1]=n ;
pcall ( t.SetCoreGuiEnabled,t,n,false ) ;
end ;
end ;
end ;
else
for h,h in ipairs ( c ) do
h:Disconnect ( ) ;
end ;
for h,f in next,B,nil do
if h.Parent then
if f then
h.Enabled=true ;
end ;
end ;
end ;
r=U ;
for h,h in ipairs ( r ) do
pcall ( t.SetCoreGuiEnabled,t,h,true ) ;
end ;
table.clear ( B ) ;
table.clear ( R ) ;
table.clear ( c ) ;
U= {
} ;
end ;
end ;
x=Y[26] ;
x.hideUI=false ;
F=ChilliState ;
if F.hudUI then
T=ChilliState ;
T.hudUI ( b ) ;
end ;
local h=Font.new ( "rbxasset://fonts/families/GothamSSm.json" ,Enum.FontWeight.ExtraBold ) ;
local t=Color3.fromRGB ( 58,255,55 ) ;
local R=Color3.fromRGB ( 255,214,84 ) ;
local c=Color3.fromRGB ( 255,96,96 ) ;
local B=Color3.fromRGB ( 150,150,158 ) ;
local T=E:State ( "FPS and Ping Position" , {
} ) ;
local F,U,r,f,d ;
local n,Q,m,e,L=1,0,0 ;
local function a ( ) if r then
local p=workspace.CurrentCamera ;
local k=p and p.ViewportSize or Vector2.new ( 1280,720 ) ;
k=if k.X<1 then
Vector2.new ( 1280,720 )
else
k ;
p=r ;
p.Scale=math.clamp ( k.X*0.085/132,0.7,1.4 ) *n ;
end ;
end ;
local function p ( k,o,M,l ) local hb= {
Parent=U,BackgroundTransparency=1,Position=UDim2.fromOffset ( k,9 ) ,Size=UDim2.fromOffset ( o,16 ) ,Text=l or "" ,TextColor3=M,TextScaled=true,TextXAlignment=Enum.TextXAlignment.Left,FontFace=h
} ;
return _ ( "TextLabel" ,hb ) ;
end ;
local function h ( ) if F then
F:Destroy ( ) ;
end ;
F,U,r,f,d,e,L,Q=nil,nil,nil,nil,nil,nil,nil,0 ;
end ;
local function k ( ) h ( ) ;
F=_ ( "ScreenGui" , {
DisplayOrder=58,IgnoreGuiInset=true,ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling
} ) ;
local o=T.Value ;
U=_ ( "Frame" , {
Parent=F,Active=true,BackgroundColor3=Color3.fromRGB ( 24,24,28 ) ,BackgroundTransparency=0.28,BorderSizePixel=0,Size=UDim2.fromOffset ( 132,34 ) ,Position=type ( o ) == "table" and type ( o.XOffset ) == "number" and type ( o.YOffset ) == "number" and UDim2.new ( tonumber ( o.XScale ) or 0,o.XOffset,tonumber ( o.YScale ) or 0,o.YOffset ) or UDim2.fromOffset ( 16,16 )
} ) ;
_ ( "UICorner" , {
Parent=U,CornerRadius=UDim.new ( 0,12 )
} ) ;
_ ( "UIStroke" , {
Parent=U,Color=Color3.new ( 1,1,1 ) ,Thickness=1,Transparency=0.9
} ) ;
r=_ ( "UIScale" , {
Parent=U
} ) ;
a ( ) ;
f=p ( 12,34,t ) ;
p ( 48,22,B, "FPS" ) ;
_ ( "Frame" , {
Parent=U,AnchorPoint=Vector2.new ( 0.5,0.5 ) ,BackgroundColor3=Color3.new ( 1,1,1 ) ,BackgroundTransparency=0.85,BorderSizePixel=0,Position=UDim2.new ( 0,74,0.5,0 ) ,Size=UDim2.fromOffset ( 1,14 )
} ) ;
d=p ( 82,30,t ) ;
p ( 113,14,B, "ms" ) ;
o=F ;
o.Parent=gethui and gethui ( ) or I ( "CoreGui" ) ;
local B,F,r,p ;
U.InputBegan:Connect ( function ( o ) if not ( B ) then
if o.UserInputState==Enum.UserInputState.Begin then
local M=ChilliState ;
if M.press ( o ) then
local M,l,hb=o.UserInputType==Enum.UserInputType.Touch and o or nil,Vector2.new ( o.Position.X,o.Position.Y ) ,U.Position ;
B,F,r,p=true,M,l,hb ;
end ;
end ;
end ;
end ) ;
gb ( "fpsDrag" ,I ( "UserInputService" ) .InputChanged,function ( o ) local M=B and U and ( F and o==F or ( if F then
not F
else
o.UserInputType==Enum.UserInputType.MouseMovement ) ) ;
if M then
local M,l=Vector2.new ( o.Position.X,o.Position.Y ) -r,U ;
l.Position=UDim2.new ( p.X.Scale,p.X.Offset+M.X,p.Y.Scale,p.Y.Offset+M.Y ) ;
end ;
end ) ;
gb ( "fpsEnd" ,I ( "UserInputService" ) .InputEnded,function ( r ) local p=B and ( F and r==F or ( if F then
not F
else
r.UserInputType==Enum.UserInputType.MouseButton1 ) ) ;
if p then
B=false ;
if U then
r=U.Position ;
T:Set ( {
XScale=r.X.Scale,XOffset=r.X.Offset,YScale=r.Y.Scale,YOffset=r.Y.Offset
} ) ;
end ;
end ;
end ) ;
end ;
if workspace.CurrentCamera then
V ( workspace.CurrentCamera:GetPropertyChangedSignal ( "ViewportSize" ) ,a ) ;
end ;
table.insert ( ChilliState.cleanup,h ) ;
local B=ChilliState ;
B.fpsSize=function ( B ) n=math.clamp ( ( tonumber ( B ) or 100 ) /100,0.6,1.6 ) ;
a ( ) ;
end ;
local B=ChilliState ;
B.fpsShow=function ( B ) if B then
k ( ) ;
else
h ( ) ;
end ;
end ;
b=RunService ;
gb ( "fpsC" ,b.RenderStepped,function ( b ) if not ( f ) then
return ;
end ;
b=math.clamp ( b,0.001,1 ) ;
local h,B=Q<=0 and 1/b ;
if h then
B=h ;
else
local T=Q ;
B=T+ ( 1/b-Q ) * ( 1-math.exp ( -b*8 ) ) ;
end HK,VK,KK=sK.AbsolutePosition-yb.AbsolutePosition,sK.AbsoluteSize,XK and a ( 14*Db ( ) ) or 0 ;
local XK,_K=HK.X<0 and-HK.X or HK.X+VK.X>OK.X and OK.X-VK.X-HK.X or 0,HK.Y-KK<0 and KK-HK.Y or HK.Y+VK.Y>OK.Y and OK.Y-VK.Y-HK.Y or 0 ;
if XK~=0 or _K~=0 then
sK.Position=sK.Position+B ( a ( XK ) ,a ( _K ) ) ;
end ;
end ;
local function sK ( XK,OK ) local HK,VK,KK,_K ;
local function RK ( vK,PK ) local cK=HK and ( VK and vK==VK or ( if VK then
not VK
else
vK.UserInputType==PK ) ) ;
return cK ;
end ;
wK ( hK ( "TextButton" ,XK, {
Active=true,AutoButtonColor=false,Position=B ( -12,-36 ) ,Size=R ( 1,24,1,45 ) ,Text= "" ,ZIndex=30
} ) .InputBegan,function ( vK ) if HK then
return ;
elseif
vK.UserInputState~=b.UserInputState.Begin then
return ;
else
local PK=ChilliState ;
if not ( PK.press ( vK ) ) then
return ;
end ;
end ;
local PK,cK,BK=vK.UserInputType==b.UserInputType.Touch and vK or nil,r ( vK.Position.X,vK.Position.Y ) ,XK.Position ;
HK,VK,KK,_K=true,PK,cK,BK ;
end ) ;
wK ( m.InputChanged,function ( vK ) if RK ( vK,b.UserInputType.MouseMovement ) then
local PK=r ( vK.Position.X,vK.Position.Y ) -KK ;
XK.Position=R ( _K.X.Scale,_K.X.Offset+PK.X,_K.Y.Scale,_K.Y.Offset+PK.Y ) ;
SK ( XK,true ) ;
end ;
end ) ;
wK ( m.InputEnded,function ( m ) if RK ( m,b.UserInputType.MouseButton1 ) then
local m=XK.Position ;
HK,VK=false,nil ;
Tb ( OK ) :Set ( {
XScale=m.X.Scale,XOffset=m.X.Offset,YScale=m.Y.Scale,YOffset=m.Y.Offset,Unit=Db ( ) ,Top=16
} ) ;
end ;
end ) ;
end ;
local function m ( XK,OK ) local HK,VK=XK.Id,XK.Col ;
local KK=tK ( yb,h ( 24,24,34 ) ,0.22, {
Active=true,AnchorPoint=r ( VK== "Left" and 1 or VK== "Right" and 0 or 0.5,0 ) ,AutomaticSize=Nb,Size=B ( 0,0 )
} ) ;
zK ( KK,14 ) ;
YK ( KK,h ( 82,82,107 ) ,1.6,Vb,0.3 ) ;
_ ( "UIPadding" , {
Parent=KK,PaddingTop=n ( 0,24 ) ,PaddingBottom=n ( 0,9 ) ,PaddingLeft=n ( 0,12 ) ,PaddingRight=n ( 0,12 )
} ) ;
Eb[#Eb+1]=_ ( "UIScale" , {
Parent=KK
} ) ;
local _K=tK ( KK,hb,nil, {
AutomaticSize=Ab,Position=R ( 0,-2,0,-36 ) ,Size=B ( 0,24 )
} ) ;
zK ( _K,8 ) ;
YK ( _K,tb,2,Vb,0.15 ) ;
Ub ( _K,XK.A,XK.B,-90 ) ;
IK ( _K,0.55,28 ) ;
_ ( "UIPadding" , {
Parent=_K,PaddingLeft=n ( 0,10 ) ,PaddingRight=n ( 0,10 )
} ) ;
NK ( _K,15, {
AutomaticSize=Ab,Text=HK:upper ( ) ,Size=B ( 0,24 ) ,TextTruncate=Hb
} ) ;
_K= {
Id=HK,F=KK,Col=VK,Order=OK,Body=hK ( "Frame" ,KK, {
AutomaticSize=Nb,Size=B ( 0,0 )
} )
} ;
ub[#ub+1]=_K ;
sK ( KK,HK ) ;
return _K ;
end ;
local Nb= {
} ;
Nb.Value= {
h ( 170,255,140 ) ,h ( 40,230,90 )
} ;
Nb.Size= {
h ( 255,244,200 ) ,h ( 235,190,95 )
} ;
Nb.Time= {
h ( 255,200,170 ) ,h ( 255,120,80 )
} ;
local function sK ( XK,OK,HK,VK ) local KK=tK ( XK,nil,1, {
AutomaticSize=Ab,LayoutOrder=HK,Size=B ( 0,VK+5 ) ,Visible=false
} ) ;
HK=NK ( KK,VK, {
AutomaticSize=Ab,Size=c ( 0,1 ) ,TextXAlignment=Sb,TextTruncate=Hb
} ) ;
Ub ( HK,Nb[OK][1],Nb[OK][2] ) ;
return {
F=KK,Text=HK
} ;
end ;
local function Nb ( XK,OK ) OK=OK and p ( OK ) or "" ;
if XK.Last~=OK then
XK.Last,XK.Text.Text,XK.F.Visible=OK,OK,OK~= "" ;
end ;
end ;
local function XK ( OK,HK,VK,KK ) local _K=hK ( "Frame" ,OK, {
Position=R ( 0,KK and 4 or 52,0,HK ) ,Size=R ( 1,KK and-8 or-146,0,VK )
} ) ;
_ ( "UIListLayout" , {
Parent=_K,FillDirection=Rb,HorizontalAlignment=KK and b.HorizontalAlignment.Center or b.HorizontalAlignment.Left,VerticalAlignment=b.VerticalAlignment.Center,SortOrder=_b,Padding=n ( 0,5 )
} ) ;
return _K ;
end ;
local function OK ( HK,VK,KK,_K,RK ) local vK=XK ( HK,VK,KK,RK ) ;
VK=NK ( vK,17, {
AutomaticSize=Ab,LayoutOrder=1,Size=B ( 0,21 )
} ) ;
_ ( "UISizeConstraint" , {
Parent=VK,MaxSize=r ( _K,21 )
} ) ;
return VK,sK ( vK, "Size" ,2,16 ) ;
end ;
local function HK ( VK,KK ) local _K=tK ( VK,xb,0.02, {
LayoutOrder=KK,Size=B ( 180,200 ) ,Visible=false
} ) ;
zK ( _K,14 ) ;
KK,VK=YK ( _K,hb,3,Vb ) ,tK ( _K,hb,0.7, {
Size=R ( 1,0,0,136 )
} ) ;
zK ( VK,14 ) ;
IK ( VK,0.82,30 ) ;
local RK,vK=hK ( "ImageLabel" ,_K, {
AnchorPoint=r ( 0.5,0 ) ,Position=R ( 0.5,0,0,6 ) ,ScaleType=Kb,Size=B ( 126,126 )
} ) ,tK ( _K,xb,nil, {
Position=B ( 7,7 ) ,Size=B ( 32,24 )
} ) ;
zK ( vK,7 ) ;
YK ( vK,tb,1.6 ) ;
local tb,xb,PK,cK=NK ( vK,15, {
Size=c ( 1,1 ) ,TextXAlignment=Sb
} ) ,NK ( _K,13, {
AnchorPoint=r ( 1,0 ) ,Position=R ( 1,-7,0,10 ) ,Size=R ( 1,-46,0,16 ) ,TextXAlignment=Xb,TextColor3=h ( 255,230,120 )
} ) ,OK ( _K,135,20,108,true ) ;
local vK,BK=NK ( _K,15, {
Position=R ( 0,6,0,155 ) ,Size=R ( 1,-12,0,16 ) ,TextXAlignment=Sb
} ) ,XK ( _K,172,23,true ) ;
return {
F=_K,Stroke=KK,Glow=VK,Image=RK,Rank=tb,Mu=xb,Name=PK,Rarity=vK,SC=cK,VC=sK ( BK, "Value" ,1,18 ) ,HC=sK ( BK, "Time" ,2,16 ) ,G= {
}
} ;
end ;
local function tb ( xb,VK ) local KK=tK ( xb,h ( 14,14,20 ) ,0.25, {
LayoutOrder=VK,Size=B ( 330,52 ) ,Visible=false
} ) ;
zK ( KK,10 ) ;
local xb,_K,RK,vK=YK ( KK,hb,2,Vb ) ,hK ( "ImageLabel" ,KK, {
Position=B ( 4,3 ) ,ScaleType=Kb,Size=B ( 46,46 )
} ) ,OK ( KK,3,22,122 ) ;
VK=XK ( KK,27,22 ) ;
local XK,OK,PK=NK ( VK,14, {
AutomaticSize=Ab,LayoutOrder=1,Size=B ( 0,18 ) ,TextTruncate=Hb
} ) ,sK ( VK, "Value" ,2,16 ) ,NK ( KK,15, {
AnchorPoint=r ( 1,0.5 ) ,Position=R ( 1,-10,0.5,0 ) ,Size=B ( 84,20 ) ,TextXAlignment=Xb,TextColor3=h ( 255,194,77 )
} ) ;
return {
F=KK,Stroke=xb,Image=_K,Name=RK,Rarity=XK,SC=vK,VC=OK,When= {
F=PK,Text=PK
} ,G= {
}
} ;
end ;
local function Ab ( Xb,Hb,xb,sK ) local XK=p ( xb.Uid ) .. "|" ..sK ;
bK ( Xb,true ) ;
if Xb.Key~=XK then
local OK,VK=xb.En,xb.Rec.Mutations ;
local KK,_K,_K=mb ( OK ) ;
Xb.Key=XK ;
GK ( Xb,_K ) ;
local XK,_K=Xb.Image,Hb.Egg and not ( lb and OK and OK.Icon ) and x ( xb.Rec ) or OK and OK.Icon ;
XK.Image=p ( _K or "" ) ;
Xb.Rank.Text,Xb.Mu.Text,Xb.Name.Text,Xb.Rarity.Text= "#" ..sK,Zb ( VK ) and table.concat ( VK, " " ) or "" ,p ( OK and OK.DisplayName or xb.Cat ) ,KK:upper ( ) ;
end ;
Nb ( Xb.VC,fb ( xb.Rate ) ) ;
Nb ( Xb.SC, ( "x%.2f" ) :format ( xb.Size ) ) ;
Nb ( Xb.HC,Hb.Egg and ob ( xb.Uid,xb.Rec ) ) ;
end ;
local function x ( Xb ) local Hb=math.max ( 0,os.time ( ) - ( o ( Xb ) or os.time ( ) ) ) ;
return Hb<60 and Hb.. "s ago" or Hb<3600 and Hb//60 .. "m ago" or Hb<86400 and Hb//3600 .. "h ago" or Hb//86400 .. "d ago" ;
end ;
local function Xb ( ) for Hb,xb in ipairs ( pb ) do
Hb=rb ;
local ob=Hb[xb.Show.Id]==true ;
bK ( xb.Panel,ob ) ;
if ob then
local ob,sK,XK=AK ( ) [xb.Show.Id],ipairs,xb.Cards ;
for AK,OK in sK ( XK ) do
Hb=ob[AK] ;
if Hb then
if AK<=ib then
Ab ( OK,xb.Show,Hb,AK ) ;
else
bK ( OK,false ) ;
end ;
else
bK ( OK,false ) ;
end ;
end ;
end ;
end ;
local Ab=Cb ;
if not ( Ab ) then
return ;
end ;
bK ( Ab,rb[ "Steal History" ]==true ) ;
local Hb=false ;
for xb,ob in ipairs ( kb ) do
local AK=Lb[xb] ;
if AK then
if xb<=ib+1 then
bK ( ob,true ) ;
local xb=p ( AK.At ) .. "|" ..p ( AK.Category ) .. "|" ..p ( lb ) ;
if ob.Key~=xb then
local Lb=Z ( AK.Category ) ;
local sK,sK,sK=mb ( Lb ) ;
ob.Key=xb ;
GK ( ob,sK ) ;
local xb,mb=ob.Image,lb and Lb and Lb.Icon and p ( Lb.Icon ) or Lb and Zb ( Lb.Egg ) and p ( Lb.Egg.Icon or "" ) ;
xb.Image=mb or Lb and p ( Lb.Icon or "" ) or "" ;
ob.Name.Text,ob.Rarity.Text=p ( AK.Name or AK.Category ) ,p ( AK.Rarity or "" ) :upper ( ) ;
Nb ( ob.VC,o ( AK.Value ) and fb ( AK.Value ) or "" ) ;
Nb ( ob.SC,o ( AK.Scale ) and ( "x%.2f" ) :format ( o ( AK.Scale ) ) or "" ) ;
end ;
Nb ( ob.When,x ( AK.At ) ) ;
Hb=true ;
else
bK ( ob,false ) ;
end ;
else
bK ( ob,false ) ;
end ;
end ;
bK ( Ab.E,not Hb ) ;
end ;
local function x ( ) for Ab,Nb in next,Wb,nil do
bK ( Nb,rb[Ab]==trYb,Xb ) then
return true ;
end ;
if r ( Xb ) then
return false ;
end ;
local Nb=m ( Yb,Xb ) ;
if Nb then
local Gb,Hb,Vb=setPlayerCFrame,CFrame.new,Vector3.new ;
Gb ( Hb ( Nb+Vb ( 0,2.5,0 ) ) ) ;
if os.clock ( ) >=Sb then
Sb=os.clock ( ) +0.08 ;
local Gb=fireproximityprompt and tb ( Yb,Nb ) ;
if Gb then
pcall ( function ( ) Gb.HoldDuration=0 ;
fireproximityprompt ( Gb ) ;
end ) ;
else
task.spawn ( callRequiredModuleMethod, "Egg" , "CarryFieldEgg" ,Yb,Xb and Xb.AreaId and Xb.NestId and Xb.AreaId.. ":" ..Xb.NestId ) ;
end ;
else
end ;
else
end ;
Nb=HeartbeatWait ;
Nb ( ) ;
end ;
return a ( Yb,h ( Yb ) ) ;
end ;
local tb=Ib[ "Capture The Egg" ] ;
local function Yb ( Nb ) local Gb=ChilliState ;
Gb.capSt=Nb ;
end ;
local Nb=wb ( {
name= "Capture" ,mover=true,gap=0.25,pri=-1,urgent=true,ev=function ( ) return true ;
end
} ) ;
local Gb=y ( tb, "Auto Capture Event Egg" , "capture" ,false,function ( Sb ) if not ( Sb ) then
bb ( Nb ) ;
end ;
end ) ;
y ( tb, "Take It From The Holder" , "capTake" ,true,nil,nil,Gb ) ;
l ( tb, "Hold Height" , "capH" ,20,120,45, "studs" ,1,nil,nil,Gb ) ;
l ( tb, "Keep Away Distance" , "capAway" ,20,150,45, "studs" ,1,nil,nil,Gb ) ;
local function Gb ( ) local Sb=workspace:GetAttribute ( "Event_CaptureTheEggUid" ) ;
return type ( Sb ) == "string" and Sb~= "" and Sb or nil ;
end ;
local Sb= {
} ;
local Xb=-9 ;
local function Hb ( ) if os.clock ( ) -Xb<5 then
local Vb=Sb ;
return Vb ;
end ;
local Vb ;
Vb,Sb=os.clock ( ) , {
} ;
Xb=Vb ;
Vb=getWorldInstance ;
local Xb,Kb=Vb ( "Areas" , "EggCarryBounds" ) ,ipairs ;
Vb=Xb and Xb:GetChildren ( ) or {
} ;
for _b,Rb in Kb ( Vb ) do
if Rb:IsA ( "BasePart" ) and Rb.Name~= "SafeZone" and Rb.Position.Y>0 and Rb.Size.X>60 and Rb.Size.Z>60 then
_b=Vector3.new ;
local Vb,Kb=_b ( 1000000000,0,1000000000 ) ,Vector3.new ;
local _b,vb,Pb,cb=Kb ( -1000000000,0,-1000000000 ) ,Rb.Size/2,ipairs, {
-1,1
} ;
for Bb,xb in Pb ( cb ) do
Xb,Kb=ipairs, {
-1,1
} ;
for Tb,qb in Xb ( Kb ) do
Tb,Bb=Vector3.new,Rb.CFrame:PointToWorldSpace ( Vector3.new ( vb.X*xb,0,vb.Z*qb ) ) ;
Vb,_b= ( Vb:Min ( Bb ) ) , ( _b:Max ( Bb ) ) ;
end ;
end ;
Kb=Sb ;
Pb,cb=#Kb+1, {
lo=Vb,hi=_b
} ;
cb.y,Kb[Pb]=Rb.Position.Y+vb.Y,cb ;
end ;
end ;
Xb=Sb ;
return Xb ;
end ;
local function Sb ( Xb,Vb ) Vb=Vb or 0 ;
for Kb,Kb in ipairs ( Hb ( ) ) do
if Xb.X>=Kb.lo.X+Vb then
if Xb.X<=Kb.hi.X-Vb then
if Xb.Z>=Kb.lo.Z+Vb then
if Xb.Z<=Kb.hi.Z-Vb then
return Kb ;
end ;
end ;
end ;
end ;
end ;
end ;
local function Xb ( Vb ) local Kb,_b,Rb=math.huge,ipairs,w[76] ( g:GetPlayers ( ) ) ;
for vb,Pb in _b ( w:iI ( Rb ) ) do
vb=LocalPlayer ;
local cb,Bb=Pb~=vb and Pb.Character and Pb.Character:FindFirstChild ( "HumanoidRootPart" ) ,Pb.Character and Pb.Character:FindFirstChildOfClass ( "Humanoid" ) ;
Kb=if cb then
if Bb then
if Bb.Health>0 then
math.min ( Kb, ( cb.Position-Vb ) .Magnitude )
else
Kb
else
Kb
else
Kb ;
end ;
Rb=getWorldInstance ;
local vb,Pb=Rb ( "Areas" , "GuardAreas" ) ,ipairs ;
Rb=vb and vb:GetChildren ( ) or {
} ;
for cb,cb in Pb ( Rb ) do
_b=cb:FindFirstChild ( "Guard" ) and cb.Guard:FindFirstChild ( "HumanoidRootPart" ,true ) ;
if _b then
cb,vb=nil ;
cb,vb,Kb=Vector3.new,Y[26],math.min ( Kb,Vector3.new ( _b.Position.X-Vb.X,0,_b.Position.Z-Vb.Z ) .Magnitude*Y[26].capAway/32 ) ;
else
end ;
end ;
return Kb ;
end ;
local function Vb ( Kb ) local _b,Rb,vb=math.huge,ipairs,w[76] ( Hb ( ) ) ;
local Hb ;
local Pb,cb=-1 ;
for Bb,xb in Rb ( w:iI ( vb ) ) do
local Rb,vb= ( xb.lo.Z+xb.hi.Z ) /2, ( xb.hi.Z-xb.lo.Z ) /2 ;
local Tb,qb,Fb=math.min ( 40,math.max ( 0,vb-14 ) ) ,xb.lo.X+14,xb.hi.X-14 ;
for Db=qb,Fb,50 do
vb,Bb=ipairs, {
Rb-Tb,Rb,Rb+Tb
} ;
for Rb,Tb in vb ( Bb ) do
Rb=Vector3.new ;
local vb,vb=Y[26],Rb ( Db,xb.y+Y[26].capH,Tb ) ;
local Rb,Bb,xb=Xb ( vb ) , ( vb-Kb ) .Magnitude,Y[26] ;
if Rb>=xb.capAway+10 then
if Bb<_b then
_b,Hb=Bb,vb ;
else
end ;
else
end ;
if Rb>Pb then
Pb,cb=Rb,vb ;
else
if Rb==Pb then
if cb then
if Bb< ( cb-Kb ) .Magnitude then
Pb,cb=Rb,vb ;
else
end ;
else
end ;
else
end ;
end ;
end ;
end ;
end ;
return Hb or cb ;
end ;
local Hb ;
local Kb,_b,Rb=0, "" ,NetworkingRemotes ;
tb=Rb:FindFirstChild ( "RE/EggCapture/StandingsRefreshed" ) ;
if tb then
V ( tb.OnClientEvent,function ( Rb ) local vb=type ( Rb ) == "table" and ( Rb.Entries or Rb.Standings or Rb ) ;
if type ( vb ) ~= "table" then
return ;
end ;
_b= "" ;
Rb=ipairs ;
for Pb,cb in Rb ( vb ) do
if type ( cb ) == "table" then
local Rb=LocalPlayer ;
if tonumber ( cb.UserId ) ==Rb.UserId then
_b= ( " %.1fs #%d" ) :format ( tonumber ( cb.Seconds ) or 0,tonumber ( cb.Rank ) or Pb ) ;
break ;
end ;
end ;
end ;
end ) ;
end ;
Nb.on=function ( ) local Rb=Y[26] ;
return Rb.capture and Gb ( ) ~=nil ;
end ;
Nb.want=function ( ) local Rb=Gb ( ) ;
return Rb and h ( Rb ) and Rb ;
end ;
Nb.run=function ( Nb,Rb ) if not ( Y[13] ( Rb ) ) then
return ;
end ;
local vb=ChilliState ;
vb.ready ( Rb,3 ) ;
local Pb,cb=0.016666666666666666,0 ;
while Rb ( ) do
local Bb,xb=h ( Nb ) ,getRootPart ;
vb=xb ( ) ;
if Bb then
if not vb then
break ;
end ;
else
break ;
end ;
local Tb,qb=r ( Bb ) ,ChilliState ;
qb.godHunt=false ;
if a ( Nb,Bb ) then
xb=Hb ;
local Fb,Db=not xb ;
if xb then
qb=os.clock ( ) >=Kb ;
if qb then
local xb=Sb ( Hb,13 ) ;
local Ub=not xb ;
if xb then
local xb ;
xb,Db=Y[26],Xb ( Hb ) <Y[26].capAway ;
else
Db=Ub ;
end ;
else
Db=qb ;
end ;
else
Db=Fb ;
end ;
if Db then
Hb=Vb ( vb.Position ) ;
end ;
Kb=os.clock ( ) +0.25 ;
local Xb,Vb,Kb=Sb ( vb.Position ) ,Hb ;
if Vb then
Kb=Vb ;
else
Db,Fb=Vector3.new ;
Fb,Kb=Y[26],Db ( vb.Position.X, ( Xb and Xb.y or vb.Position.Y ) +Y[26].capH,vb.Position.Z ) ;
end ;
hb ( Kb,220,Pb ) ;
Yb ( "Holding the event egg" .._b ) ;
else
if Tb then
Hb=nil ;
local Xb=g:GetPlayerByUserId ( Tb ) ;
local Vb ;
if Xb then
local Kb=Y[26] ;
Vb=Kb.capTake ;
else
Vb=Xb ;
end ;
local Kb ;
if Vb then
local _b=ChilliState ;
Kb=_b.bat ( ) ;
else
Kb=Vb ;
end ;
Vb=nil ;
if Kb then
local _b=ChilliState ;
Vb=_b.chase ( Xb,true ) ;
else
Vb=Kb ;
end ;
if Vb then
Kb=ChilliState ;
Kb.godHunt=true ;
Yb ( "Taking the event egg from " ..Xb.DisplayName ) ;
else
local Vb=m ( Nb,Bb ) ;
if Vb then
if Sb ( Vb ) then
local Kb=Vector3.new ;
hb ( Vb+Kb ( 0,25,0 ) ,400,Pb ) ;
end ;
end ;
local Vb,Kb=Xb and Xb.DisplayName or "Someone" ,Y[26] ;
local Xb,_b=Kb.capTake ;
if Xb then
Kb=ChilliState ;
_b=not Kb.bat ( ) ;
else
_b=Xb ;
end ;
Yb ( Vb.. " has the event egg" .. ( _b and ", get a bat to take it" or "" ) ) ;
end ;
else
if Bb.State== "Carried" then
Yb ( "Someone has the event egg" ) ;
else
local Xb=m ( Nb,Bb ) ;
if not ( Xb ) then
break ;
end ;
local Vb=Vector3.new ;
local Kb,_b=Vb ( Xb.X-vb.Position.X,0,Xb.Z-vb.Position.Z ) .Magnitude,isInsideSafeZone ;
Vb=_b ( vb.Position ) ;
_b=nil ;
if Vb then
local Bb=isInsideSafeZone ;
_b=not Bb ( Xb ) ;
else
_b=Vb ;
end ;
Vb=nil ;
if _b then
local Bb=callRequiredModuleMethod ;
local xb=Bb ( "Wall" , "IsSealed" ) ;
if xb then
Vb=xb ;
else
Bb=callRequiredModuleMethod ;
Vb=Bb ( "Cycle" , "IsNightPhase" ,P ( ) ) ;
end ;
else
Vb=_b ;
end ;
if Vb then
Yb ( "Field wall is up, waiting to go out" ) ;
else
if Kb>220 and os.clock ( ) >=cb then
Yb ( "Ragdoll jump to the event egg" ) ;
cb=os.clock ( ) +4 ;
if zb ( function ( ) local Vb=m ( Nb,h ( Nb ) ) ;
local m ;
if Vb then
local Bb=Vector3.new ;
m=Vb+Bb ( 0,3,0 ) ;
else
m=Vb ;
end ;
return m ;
end ,Rb ) then
cb=os.clock ( ) +2 ;
Yb ( "Landed, grabbing the event egg" ) ;
local m=os.clock ( ) +8 ;
while os.clock ( ) <m and ( Rb ( ) ) do
local m=h ( Nb ) ;
if m then
if a ( Nb,m ) then
break ;
elseif
r ( m ) then
break ;
end ;
else
break ;
end ;
B ( Nb,Rb ) ;
end ;
else
end ;
else
if _b then
Yb ( "Leaving the base for the event egK,VK);end;end;end;local function nb(SK,XK,OK)for HK,HK in ipairs(bK(SK,XK,OK))do ab(HK);end;end;local bK=next;for SK,XK in bK,Qb,nil do if type(XK)==" table "then if type(XK.Uid)==" string "then if type(XK.AssetCategory)==" string "then ab(XK);end;end;end;if os.clock()-Lb>0.002 then SK=HeartbeatWait;SK();Lb=os.clock();if mb~=AK then return;elseif ib~=YK then return;elseif not(zK)then return;end;else end;end;if zK then if lb then mb=LocalPlayer;nb(mb," Your Base "," base: ");end;end;if zK and Cb then ib,mb=ipairs,w[76](g:GetPlayers());for Qb,Qb in ib(w:iI(mb))do bK=LocalPlayer;if Qb~=bK then nb(Qb,Qb.DisplayName.." Base "," base "..Qb.UserId.." : ");end;end;end;mb=wK;for nb,Qb in next,mb,nil do if not(eb[nb])then wK[nb]=nil;Qb.b:Destroy();end;end;return true;end;local function nb()if zK then if not(tK)then return;end;else return;end;NK=true;if GK then return;end;GK=true;task.defer(function()while true do local Qb=zK and tK and NK;if not Qb then break;end;NK=false;AK+=1;local Qb,mb=pcall(xb,tK,AK,YK);if Qb then if mb~=true then NK=true;end;end;Qb=HeartbeatWait;Qb();end;GK=false;end);end;local function xb(Qb)return type(Qb)==" table "and type(Qb.Records)==" table "and Qb.Records or nil;end;local function Qb()local mb=YK;if tK then if next(wK)==nil then nb();end;end;local ib=callRequiredModuleMethod;local eb=xb(ib(" Egg "," ReadFieldEggs "));if eb then else if ub then if os.clock()>=Wb then Wb=os.clock()+30;local ib,Lb=pcall(ub.InvokeServer,ub);eb=ib and xb(Lb)or nil;else end;else end;end;if mb~=YK then return;elseif not(zK)then return;end;if eb then tK={};for xb,mb in next,eb,nil do tK[xb]=mb;end;end;if tK then nb();end;end;local function xb()if IK then return;end;IK=true;task.delay(0.5,function()IK=false;if zK then task.spawn(pcall,Qb);end;end);end;local function mb()local ib=wK;for eb,eb in next,ib,nil do eb.w=nil;sK(eb);end;end;local function ib()zK=true;local eb,Lb=YK,GameModules;local ab=Lb.Egg or{};local function ub(Wb,bK)task.spawn(function()while true do local tK=YK;if not(eb==tK)then break;end;task.wait(Wb);if eb==YK then bK();end;end;end);end;Lb={" FieldRefreshed "," FieldShifted "," FieldGone "," FieldClaimed "," SnapshotRefreshed "};for eb,Wb in ipairs(Lb)do eb=ab[Wb];if type(eb)==" table "then if eb.Connect then local ab,Wb=pcall(eb.Connect,eb,xb);if ab then if Wb then hK[#hK+1]=Wb;end;end;end;end;end;Lb={" AreaEggSlotsClient "," PlacedEggRenders "};for eb,ab in ipairs(Lb)do eb=workspace:FindFirstChild(ab);if eb then hK[#hK+1]=eb.ChildAdded:Connect(xb);hK[#hK+1]=eb.ChildRemoved:Connect(xb);end;end;ub(10,xb);ub(1,function()if ob.Distance t
or nil;else T(" sign ");end;end;dK.acctF=F;for U,r in next,t8,nil do xK(r);qK(r.b,U==" acct "and F or function()T(U);end);end;if v8 then G8=RK(v8.b:Clone());x=G8.b;uK[88]=(b[16](0.1,0.5));uK[89]=(b[16](0.665,0.5));x.Size=uK[88];x.Position=uK[89];uK[90]=(zb(x,n)or b[10](n,x));uK[90].AspectRatio=1;G8.l.Visible=false;N8=a(" ImageLabel ",y(c,0.5,0.5,0.74,0.74,{bt=1,Image=" rbxasset://textures/ui/Settings/MenuBarIcons/GameSettingsTab.png ",z=G8.l.ZIndex+1}),x);b[10](n,N8);l={{-2,0},{2,0},{0,-2},{0,2},{-1.5,-1.5},{1.5,1.5},{-1.5,1.5},{1.5,-1.5}};for T,T in ipairs(l)do w8,g8=N8:Clone(),{ImageColor3=R,z=N8.ZIndex-1};uK[91]=(b[14](0.5,T[1],0.5,T[2]));g8.p=uK[91];p(w8,g8,x);end;vK(G8,sK);xK(G8);qK(x,F);x.Parent=v8.b.Parent;dK.gear=G8;end;w8=R8(0.1);hb(w8,0.02);dK.rb={};for x=1,5,1 do dK.rb[x]=O8({a=c,o=x,v=false},w8,nil,0.9,0.6,nil,function()ab.askRoom(x);end);end;FK,F,A8=dK,dK,w8.Size.Y.Scale+S8;FK.rs=w8;F.rsH=A8;uK[93]=k;uK[92]={};uK[92].bc=R;uK[92].bt=0.45;uK[92].bs=0;uK[92].a=b[13](0.5,1);uK[92].p=b[16](0.5,1);uK[92].s=b[16](1,1.14);uK[92].Active=true;uK[92].v=false;uK[92].z=50;h8=(uK[93](uK[92],oK));uK[98]=p;uK[99]=R8(0.3);uK[95]=y;uK[96]=c;uK[97]=0.3*I8;uK[94]={};uK[94].v=true;uK[94].bc=b[12](30,28,42);uK[94].bt=0;local x=uK[98](uK[99],uK[95](uK[96],0.5,0.54,0.84,uK[97],uK[94]),h8);local function T(U,r)return p(K8:Clone(),y(B,0.5,U,0.9,r,{TextWrapped=true,t=" "}),x);end;Y8,w8,FK,g8=dK,dK,T(0.1,0.24),T(0.36,0.28);Y8.askT=FK;w8.askB=g8;local function B(U,r,f,d)return O8(y(c,U,0.8,0.42,0.26),x,f,0.88,0.6,r,d);end;F=dK;F.askC=B(0.27," Cancel ",XK,function()ab.ask=nil;end);l=dK;l.askS=B(0.73," Switch ",AK,function()local x=ab.ask;ab.ask=nil;if x then ab.setRoom(x);end;end);tb,S8,T,g8,B,G8,F,N8,w8=dK,dK,dK,dK,dK,dK,dK,dK,dK;dK.ask=h8;tb.B=t8;S8.V=b8;T.ov=Yb;g8.stat=K8;B.scroll=UK;G8.title=s8;F.autoB=v8;N8.pk=z8;w8.sib=V8;l,v8,F=dK,dK,WK.Position;l.panel=oK;v8.home=F;ab.tx={};ab.txOn=nil;ab.sgOk=nil;for x,x in ipairs(oK:GetDescendants())do if x:IsA(" TextLabel ")or x:IsA(" TextButton ")then if x.Text~=" "then ab.tx[x]={x.Text,x.Visible,x.TextTransparency};end;end;end;oK.Position=dK.home;for x,x in ipairs(oK:GetDescendants())do if x:IsA(m)then if not(x:GetAttribute(" own "))then b8,KK=pcall(function()return x.StrokeSizingMode;end);if b8 then if KK~=b[11].StrokeSizingMode.ScaledSize then jK[x]=x.Thickness/kK;end;else jK[x]=x.Thickness/kK;end;end;end;end;if Gb then dK.cS={};N8,T=ipairs,w[76](yK:GetDescendants());for x,x in N8(w:iI(T))do if x:IsA(m)then jK[x]=nil;dK.cS[#dK.cS+1]=x;end;end;end;_K(oK);lK=lK:Clone();pK:Destroy();local x=fK.ActivePets;local T=b[10](" ScreenGui ");T.Name,T.Archivable,T.ResetOnSpawn,T.IgnoreGuiInset,T.ZIndexBehavior,T.DisplayOrder=VK(),false,false,x.IgnoreGuiInset,x.ZIndexBehavior,x.DisplayOrder;T.Enabled=false;pcall(function()T.ScreenInsets=x.ScreenInsets;end);dK.gui=T;oK.Parent=T;T.Parent=ZK;b8=ChilliState;if b8 then B=ChilliState;if B.langRoot then t8=ChilliState;t8.langRoot(T);end;end;Kb(oK:GetPropertyChangedSignal(" AbsoluteSize "),rK);l,v8,S8=ipairs,{},fK.ActivePets;w:XI(v8,0,S8,fK.Growing);for B,B in l(v8)do if B then Kb(B:GetPropertyChangedSignal(" Enabled "),function()if B.Enabled then if mK then nK(true);end;end;end);end;end;return true;end;local function B(x)local T={};if type(x)==" table "then if x.rooms~=nil then T[1]=ab;T[2]=ab;T[3]=ab;T[4]=x.rooms or nil;T[5]=x.room;T[6]=b[19]()+(L(x.roomNext)or 0)/1000;T[1].rooms=T[4];T[2].room=T[5];T[3].roomAt=T[6];ab.dirty=true;end;end;end;ab.setRoom=function(x)if x==ab.room then return;elseif not(ab.sess)then return;end;local T=ab.sess;task.spawn(function()local F,U=pcall(b[1].HttpGet,b[1],Rb.." joiner/room?s= "..T.token.." &r= "..x);local r=F and db(U,T.secret,true);if not(r)then return tK(" Could not change room, try again ");end;B(r);if not(r.ok)then ab.ask=x;return;end;table.clear(ab.eggs);table.clear(ab.seen);ab.roomNew=true;Hb(r.eggs);OK();hK();end);end;ab.askRoom=function(x)if x~=ab.room then ab.ask=x;end;end;local function x(T)local F=dK;for U,U in ipairs(F.cards)do U.f.Size=Ab(U.f.Size.X,T);end;end;local function T(F,U)cK(F,U and" ON "or" OFF ",U and AK or XK);end;ab.fakeG=function()local F=b[19]();if F<(ab.fgAt or 0)then return ab.fgV;end;ab.fgAt=F+5;for F in next,Nb,nil do if type(F)==" string "then if F:find(" ^__ChilliV%d ")then ab.fgV=true;return true;elseif F==" __ChilliOrigQueue "then ab.fgV=true;return true;elseif F==" __ChilliOnTpHooked "then ab.fgV=true;return true;elseif F==" __ChilliBootQueuedSession then
ab.fgV=true ;
return true ;
end ;
end ;
end ;
return ab.fgV ;
end ;
ab.guard=function ( ) local F,U=b[19] ( ) ,dK.gui ;
if U then
if getconnections then
if F< ( ab.gdAt or 0 ) then
return ;
end ;
else
return ;
end ;
else
return ;
end ;
ab.gdAt=F+0.2 ;
local r,f=Xb.own,false ;
local function d ( n ) local o,y=pcall ( getconnections,n ) ;
if o then
for o,o in ipairs ( y ) do
n=o.Function ;
if n then
if not ( r[n] ) then
f=true ;
pcall ( o.Disable,o ) ;
end ;
end ;
end ;
end ;
end ;
local function n ( o ) f=false ;
d ( o.Changed ) ;
d ( o.AncestryChanged ) ;
d ( o.ChildAdded ) ;
for y,y in ipairs ( ab.gdP ) do
local l,hb=pcall ( o.GetPropertyChangedSignal,o,y ) ;
if l then
d ( hb ) ;
end ;
end ;
o=f ;
re 