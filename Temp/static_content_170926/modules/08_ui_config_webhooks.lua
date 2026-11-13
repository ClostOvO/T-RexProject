--[[
    ================================================================================
    MODULE 08: UI CONFIGURATION & WEBHOOKS
    Chilli Hub / Steal An Egg Automation Engine
    ================================================================================
    
    DESCRIPTION:
    Manages custom UI settings, config profiles (auto save, auto load, JSON export
    and import), Discord Webhook notifications for rare egg spawns and steals,
    and system performance optimizers.
    
    KEY FEATURES:
    - Auto Save Config / Auto Load Config
    - Profile Manager (Create, Delete, Set Startup)
    - Discord Webhook Embeds: Rare egg notifications, steal alerts
    - FPS Booster & 3D Rendering Toggle
    ================================================================================
]]

ts ",true);t:Button(" Reset to Defaults "," Reset ",function()Y:Default();end," Reset every feature to its built-in default "," Done! ").Quick=false;t:Button(" Turn Off All Toggles "," Turn Off ",function()for g,g in ipairs(Y.Opts)do if g.Type==" toggle "then if g.Value then if g.Tab~=" Settings "then if g.Tab~=" Config "then if g.Tab~=" Quick "then g:Set(false);end;end;end;end;end;end;end," Switch off every enabled toggle in the feature tabs "," Done! ");local g,P=Y:Tab(" Config "," Right "),Y:List();t=g:Section(" Config ",true);local q=t:Text(" Startup Config "," Startup Config: "..Y.Startup);q.NoSave=true;local d=t:Toggle(" Auto Save Config ",Y.AutoSave,function(Q)if not(Y.ready)then return;end;Y.AutoSave=Q;Y:Mgr(true);if Q then Y:Save();end;end," Auto save: "..Y.Active);local Q=t:Toggle(" Auto Load Config ",Y.AutoLoad,function(u)if not(Y.ready)then return;end;Y.AutoLoad=u;Y:Mgr(true);if u then Y:Load(Y.Startup);end;end," Auto load: "..Y.Startup);d.Skip=true;Q.Skip=true;t=g:Section(" Profiles ",true);local u=t:Input(" New Config Name "," New config name... ");u.Skip=true;local p,o={};local function y()q:Set(" Startup Config: "..Y.Startup);q:Note(Y.Startup:lower()~=Y.Active:lower()and" This config loads next time ;
use Load Config to load now "or" ");d:Note(" Auto save: "..Y.Active);Q:Note(" Auto load: "..Y.Startup);if o then o:Note(" Save: "..Y.Active);end;end;Y.cfgNotes=y;local function q()for d,d in ipairs(p)do d:Refresh(Y:List());end;y();end;local function d(Q)for C=2,#p,1 do p[C]:Set(Q,true);end;end;local function Q(C)C=C:match(" ^%s* ( .- ) %s*$ ");if C==" "then return;elseif#C>48 then return;elseif C:find(" [<>:\ "/\\|%?%*%c]" ) then
return ;
elseif
C:find ( "[%. ]$" ) then
return ;
end ;
local wb=C:upper ( ) :gsub ( "%..*$" , "" ) ;
if wb== "CON" then
return ;
elseif
wb== "PRN" then
return ;
elseif
wb== "AUX" then
return ;
elseif
wb== "NUL" then
return ;
elseif
wb== "CLOCK$" then
return ;
elseif
wb:match ( "^COM%d$" ) then
return ;
elseif
wb:match ( "^LPT%d$" ) then
return ;
end ;
return C ;
end ;
t:Button ( "Create New Config" , "Create New" ,function ( ) local C,wb=u.Value ;
if C:match ( "^%s*$" ) then
local bb=1 ;
wb= "Default " ..bb ;
while Y:Find ( wb ) do
bb+=1 ;
wb= "Default " ..bb ;
end ;
else
wb=Q ( C ) ;
if wb then
if Y:Find ( wb ) then
return ;
end ;
else
return ;
end ;
end ;
C=w[76] ( Y:Collect ( ) ) ;
if Y:Save ( wb,w:iI ( C ) ) then
u:Set ( "" ,true ) ;
q ( ) ;
d ( wb ) ;
end ;
end , "New config copies current settings" , "" ) ;
local u,C=function ( wb ) local bb=false ;
for hb,tb in ipairs ( wb ) do
hb=Y:Find ( tb ) ;
if hb then
if hb:lower ( ) ~= "default" then
pcall ( delfile,Y.dirP.. "/configs/" ..hb.. ".json" ) ;
pcall ( delfile,Y.dirP.. "/configs/" ..hb.. ".json.bak" ) ;
bb=if hb:lower ( ) ==Y.Active:lower ( ) then
true
else
bb ;
if hb:lower ( ) ==Y.Startup:lower ( ) then
Y.Startup= "Default" ;
end ;
else
end ;
else
end ;
end ;
if bb then
if not ( Y:Load ( "Default" ) ) then
Y.Active= "Default" ;
Y:Save ( "Default" ,Y:Collect ( ) ) ;
end ;
end ;
Y:Mgr ( true ) ;
q ( ) ;
p[1]:Set ( {
} ,true ) ;
end , {
"Tick the configs to remove, then press Delete" , "Delete"
} ;
p[2]=t:Dropdown ( "Delete Config" ,P, {
} ,u,true,nil,nil,C ) ;
p[3]=t:Dropdown ( "Set Startup Config" ,P,Y.Startup,function ( C ) local wb=Y:Find ( C ) ;
if not ( wb ) then
return q ( ) ;
end ;
Y.Startup=wb ;
Y:Mgr ( true ) ;
y ( ) ;
end ,false,nil,nil, {
"Pick a config to auto load next time, then press Set" , "Set Startup"
} ) ;
p[4]=t:Dropdown ( "Load Config" ,P,Y.Active,function ( C ) Y:Load ( C ) ;
end ,false,nil,nil, {
"Pick a config, then press Load to apply it now" , "Load"
} ) ;
o=t:Button ( "Save Config" , "Save" ,function ( ) Y:Save ( ) ;
end , "Save: " ..Y.Active, "" ) ;
u=g:Section ( "Import / Export" ,true ) ;
p[5]=u:Dropdown ( "Export Config" ,P,Y:Find ( Y.Active ) or "Default" ,function ( P ) P=Y:Find ( P ) or Y:Find ( Y.Active ) or "Default" ;
local o=Jb ( fb ( L ( Y,P ) ) ) ;
if type ( o ) ~= "table" then
return b.Notify ( "Export Failed" , "Selected config does not exist." ) ;
end ;
o.Profile=P ;
local C=nb ( {
Format= "ChilliLibraryConfig" ,ExportVersion=1,Name=P,Config=o
} ) ;
if C and pcall ( setclipboard,C ) then
b.Notify ( "Config Exported" ,P.. " was copied to the clipboard." ) ;
else
b.Notify ( "Export Failed" , "Clipboard is not available in this executor." ) ;
end ;
end ,false,nil,nil, {
"Pick a config, then press Export to copy its text" , "Export"
} ) ;
local P=u:Input ( "Import Config Text" , "Paste exported config JSON..." ) ;
P.Skip=true ;
u:Button ( "Import Config" , "Import" ,function ( ) local u=P.Value:match ( "^%s*(.-)%s*$" ) ;
local o=#u<1048576 and Jb ( u ) ;
if type ( o ) ~= "table" or o.Format~= "ChilliLibraryConfig" or type ( o.Config ) ~= "table" then
return b.Notify ( "Import Failed" , "Paste exported config JSON first." ) ;
end ;
u=Q ( j ( o.Name or "Imported" ) :sub ( 1,40 ) ) or "Imported" ;
local Q,C=u,1 ;
while Y:Find ( Q ) do
C+=1 ;
Q=u.. " " ..C ;
end ;
o.Config.Profile=Q ;
Y:Save ( Q,o.Config ) ;
P:Set ( "" ,true ) ;
q ( ) ;
d ( Q ) ;
b.Notify ( "Config Imported" , "Imported: " ..Q.. ". Open Load Config to apply, or Set Startup Config for Auto Load." ,5 ) ;
end , "Creates a config only; use Load Config or Set Startup after" , "" ) .Quick=false ;
t=p ;
p= {
} ;
w:XI ( p,0,t[2],t[3],t[4],t[5] ) ;
for w,w in ipairs ( p ) do
w.Skip=true ;
end ;
y ( ) ;
return g ;
end ;
eb.Finish=function ( w ) local t=w ;
t.ready=true ;
cb ( function ( ) if not ( isfile and isfile ( L ( t, "Default" ) ) ) then
t:Save ( "Default" ,t:Collect ( ) ) ;
end ;
local w=t.Startup ;
if not ( t:Find ( w ) ) then
t.Startup= "Default" ;
end ;
t.Active=t.Startup ;
end ) ;
if t.AutoLoad then
cb ( function ( ) for w=1,6,1 do
w=t.Startup ;
if t:Load ( w ) then
break ;
end ;
task.wait ( 0.4 ) ;
end ;
end ) ;
end ;
t.busy=false ;
cb ( t.qSync ) ;
cb ( t.cfgNotes ) ;
cb ( function ( ) if t.sizeOpt.Value~=100 then
t:Scale ( t.sizeOpt.Value/100 ) ;
end ;
end ) ;
cb ( function ( ) t:Select ( t.Tabs[1] ) ;
end ) ;
t.gui.Enabled=true ;
task.spawn ( function ( ) for w=1,5,1 do
A.Heartbeat:Wait ( ) ;
end ;
local w=t.St[ "Open On Launch" ] ;
if w then
if w.Value~=false then
t:Show ( true ) ;
end ;
else
t:Show ( true ) ;
end ;
end ) ;
end ;
eb.Destroy=function ( w ) for t,t in ipairs ( zb ) do
pcall ( t.Disconnect,t ) ;
end ;
table.clear ( zb ) ;
local t,Y=ipairs, {
w.gui,w.qgui,w.fgui,w.dlg
} ;
for w,w in t ( Y ) do
if w then
pcall ( w.Destroy,w ) ;
end ;
end ;
end ;
eb.Dialog=function ( w,t ) local Y=w ;
local g=m ( {
0,G ( 92,94,106 )
} , {
0.057,G ( 70,71,82 )
} , {
1,G ( 38,39,46 )
} ) ;
if Y.dlg then
Y.dlg:Destroy ( ) ;
end ;
local function P ( q,d,Q ) return Gb ( "UIStroke" , {
p=q,ApplyStrokeMode=Q and M or l,Color=K,LineJoinMode=N.LineJoinMode.Round,Thickness=d
} ) ;
end ;
local function q ( d,Q ) return Gb ( "UIGradient" , {
p=d,Color=Q,R=90
} ) ;
end ;
local function d ( Q,L,u,p,o,]]=f[G[Y]]==h[Y] ;
else
f[A[Y]]=f[h[Y]]+f[G[Y]] ;
end ;
else
H=j[h[Y]] ;
f[A[Y]]=H[4][H[6]] ;
end ;
end ;
end ;
end ;
end ;
end ;
end ;
Y=Y+1 ;
end ;
else
end ;
if X==186 then
while true do
local t=G[Y] ;
if t>=91 then
if t<136 then
if t>=113 then
if t>=124 then
if t<130 then
if t<127 then
if t>=125 then
if t~=126 then
f[h[Y]][f[N[Y]]]=b[Y] ;
else
f[N[Y]] ( f[A[Y]] ) ;
end ;
else
Y=if f[h[Y]]~=S[Y]then A[Y]else Y ;
end ;
else
if t<128 then
f[h[Y]]=f[A[Y]]>N[Y] ;
elseif
t~=129 then
f[N[Y]]=#f[h[Y]] ;
else
f[h[Y]]=f[N[Y]+f[A[Y]]] ;
end ;
end ;
else
if t<133 then
if t<131 then
Y=A[Y] ;
else
if t==132 then
f[A[Y]] ( S[Y] ) ;
else
f[N[Y]]=f[A[Y]]<=f[h[Y]] ;
end ;
end ;
else
if t>=134 then
if t==135 then
H=N[Y] ;
f[H],f[H+1]=h[Y],A[Y] ;
else
Y=f[N[Y]] ;
end ;
else
f[N[Y]]=e ( f[h[Y]],A[Y] ) ;
end ;
end ;
end ;
else
if t>=118 then
if t<121 then
if t>=119 then
if t~=120 then
f[N[Y]]=q ;
else
H,B=h[Y],f[N[Y]] ;
f[H+1]=B ;
f[H]=B[b[Y]] ;
end ;
else
f[N[Y]]=j[h[Y]][f[A[Y]]] ;
end ;
else
if t<122 then
f[h[Y]][N[Y]]=A[Y] ;
else
if t==123 then
r=f[h[Y]] ;
else
H=j[N[Y]] ;
f[h[Y]]=H[4][H[6]] ;
end ;
end ;
end ;
else
if t>=115 then
if t<116 then
f[h[Y]]=p[b[Y]] ;
else
if t==117 then
w[h[Y]]=f[A[Y]] ;
else
B,H=N[Y],A[Y]+1 ;
for g=1,h[Y],1 do
B=i ( e ( B, ( W ( B,13 ) ) ) ,536870911 ) ;
B=e ( B, ( m ( B,13 ) ) ) ;
B=i ( e ( B, ( W ( B,14 ) ) ) ,536870911 ) ;
h[H]=e ( h[H], ( i ( m ( B,0 ) ,127 ) ) ) ;
A[H]=e ( A[H], ( i ( m ( B,7 ) ,127 ) ) ) ;
N[H]=e ( N[H], ( i ( m ( B,14 ) ,127 ) ) ) ;
G[H]=e ( G[H], ( i ( m ( B,21 ) ,127 ) ) ) ;
H=H+1 ;
end ;
G[Y]=136 ;
end ;
end ;
else
if t~=114 then
f[A[Y]]=i ( f[N[Y]],h[Y] ) ;
else
f[N[Y]]=f[A[Y]]-h[Y] ;
end ;
end ;
end ;
end ;
else
if t<102 then
if t>=96 then
if t<99 then
if t<97 then
f[h[Y]]=f[N[Y]]%f[A[Y]] ;
elseif
t~=98 then
f[A[Y]]=f[N[Y]]==h[Y] ;
else
f[h[Y]]=i ( b[Y],f[N[Y]] ) ;
end ;
else
if t<100 then
Y=if N[Y]<=f[A[Y]]then Y
else
h[Y] ;
else
if t~=101 then
f[h[Y]] ( S[Y],b[Y] ) ;
else
f[h[Y]]=f[N[Y]]+f[A[Y]] ;
end ;
end ;
end ;
else
if t>=93 then
if t>=94 then
if t==95 then
H,B,Z=N[Y],h[Y],A[Y] ;
U,_=H+Z-1,H+B ;
x=f[_] ;
v=x.n ;
V=B+v-1 ;
x.n=V ;
J ( x,1,v,B,x ) ;
J ( f,H+1,_-1,1,x ) ;
P=n ( f[H] ( Q ( x,1,x.n ) ) ) ;
J ( P,1,Z,H,f ) ;
else
H=h[Y] ;
f[H],f[H+1]=b[Y],N[Y] ;
end ;
else
H,B,Z=A[Y],h[Y],N[Y] ;
U,_,x=H+Z-1,H+B,n ( f[H] ( Q ( f,H+1,H+B ) ) ) ;
J ( x,1,Z,H,f ) ;
end ;
else
if t~=92 then
f[A[Y]]=f[h[Y]][S[Y]] ;
else
f[h[Y]]=f[A[Y]]-f[N[Y]] ;
end ;
end ;
end ;
else
if t<107 then
if t<104 then
if t~=103 then
w[z[Y]]=f[N[Y]] ;
else
H=j[h[Y]] ;
f[N[Y]]=H[4][H[6]][b[Y]] ;
end ;
else
if t<105 then
local g ;
local s=b[Y] ;
if s then
local X=#s/3 ;
if X>0 then
g= {
} ;
local V,P=D,O ;
for l=1,X,1 do
local X= ( l-1 ) *3 ;
local wb,bb=s[X+2],s[X+1] ;
if wb==1 then
V=V or {
} ;
local hb=V[bb] ;
if hb then
else
hb= {
[6]=bb,[4]=f
} ;
V[bb]=hb ;
end ;
g[l]=hb ;
else
if wb==0 then
g[l]=f[bb] ;
else
if wb==2 then
g[l]=j[bb] ;
else
if wb==3 then
P=P or {
} ;
local wb=P[bb] ;
if wb then
else
wb= {
[6]=bb,[5]=s[X+3],[4]=f
} ;
P[bb]=wb ;
end ;
g[l]=wb ;
else
end ;
end ;
end ;
end ;
end ;
D,O=V,P ;
else
end ;
else
end ;
f[h[Y]]=f[N[Y]] ( nil,g,nil ) ;
H=g ;
else
if t~=106 then
local g,s,X=h[Y],e ( A[Y], ( i ( e ( q, ( i ( m ( q,29 ) ,7 ) ) ) ,536870911 ) ) ) ,I[6] ;
local V=e ( X[g],371010975 ) ;
X[g]=V ;
g,X=I[5],V+1 ;
V=L ( g,X ) ;
local P,l ;
if V<128 then
P,l=V,X+1 ;
else
local wb=L ( g,X+1 ) ;
if wb<128 then
P,l=V-128+wb*128,X+2 ;
else
local bb=L ( g,X+2 ) ;
if bb<128 then
P,l= ( V-128 ) *128+ ( wb-128 ) *16384+bb,X+3 ;
else
local hb=L ( g,X+3 ) ;
P,l= ( V-128 ) *2097152+ ( wb-128 ) *16384+ ( bb-128 ) +hb%128*128+ ( hb-hb%128 ) *2097152,X+4 ;
end ;
end ;
end ;
V,X=s*16843009,l+P ;
local wb=X-P%4 ;
for P=l,wb-1,4 do
a ( g,P, ( e ( E ( g,P ) ,V ) ) ) ;
end ;
for V=wb,X-1,1 do
u ( g,V, ( e ( L ( g,V ) ,s ) ) ) ;
end ;
h[Y]=38 ;
A[Y]=130 ;
N[Y]=164 ;
G[Y]=136 ;
else
p[b[Y]]=f[N[Y]] ;
end ;
end ;
end ;
else
if t<110 then
if t>=108 then
if t~=109 then
local g,s,X=h[Y],f[N[Y]],b[Y] ;
local V,P=i ( s,4294967295 ) ,i ( X,4294967295 ) ;
local s,X,l,wb=i ( V,65535 ) ,m ( V,16 ) ,i ( P,65535 ) ,m ( P,16 ) ;
P=i ( s*l+W ( i ( s*wb+X*l,65535 ) ,16 ) ,4294967295 ) ;
l=nil ;
repeat
V=P%4294967296 ;
if V~=V then
l=0 ;
break ;
end ;
l=V-V%1 ;
until true ;
f[g]=l ;
else
local g,s,X=h[Y],S[Y],f[A[Y]] ;
local V,P=i ( s,4294967295 ) ,i ( X,4294967295 ) ;
local s,l,wb,bb=i ( V,65535 ) ,m ( V,16 ) ,i ( P,65535 ) ,m ( P,16 ) ;
X=i ( s*wb+W ( i ( s*bb+l*wb,65535 ) ,16 ) ,4294967295 ) ;
P=nil ;
repeat
bb=X%4294967296 ;
if bb~=bb then
P=0 ;
break ;
end ;
P=bb-bb%1 ;
until true ;
f[g]=P ;
end ;
else
local g,s,X=A[Y],f[N[Y]],h[Y] ;
local V,P=i ( s,4294967295 ) ,i ( X,4294967295 ) ;
local l,wb,bb,hb=i ( V,65535 ) ,m ( V,16 ) ,i ( P,65535 ) ,m ( P,16 ) ;
s=i ( l*bb+W ( i ( l*hb+wb*bb,65535 ) ,16 ) ,4294967295 ) ;
bb=nil ;
repeat
X=s%4294967296 ;
if X~=X then
bb=0 ;
break ;
end ;
bb=X-X%1 ;
until true ;
f[g]=bb ;
end ;
else
if t<111 then
f[h[Y]]=f[A[Y]] ( f[N[Y]] ) ;
else
if t==112 then
H=A[Y] ;
f[H],f[H+1]=f[h[Y]],f[N[Y]] ;
else
f[N[Y]]=z[Y]+f[A[Y]] ;
end ;
end ;
end ;
end ;
end ;
end ;
else
if t<159 then
if t<147 then
if t<141 then
if t>=138 then
if t>=139 then
if t==140 then
f[A[Y]]=p[z[Y]][S[Y]] ;
else
f[h[Y]]=f[N[Y]][A[Y]] ;
end ;
else
f[A[Y]][S[Y]]=f[h[Y]] ;
end ;
elseif
t==137 then
if D then
for g in k,D,nil do
local s=D[g] ;
if s then
s[4]=s ;
s[5]=f[g] ;
s[6]=5 ;
D[g]=nil ;
end ;
end ;
end ;
if O then
for g,s in k,O,nil do
local X=s[5] ;
if O then
s=O[g] ;
if s then
local V=d ( X ) ;
J ( f,g,g+X-1,1,V ) ;
s[4]=V ;
s[6]=1 ;
O[g]=nil ;
end ;
end ;
end ;
end ;
return ;
end ;
else
if t<144 then
if t>=142 then
if t~=143 then
H,B,Z=h[Y],A[Y],N[Y] ;
U=H+B ;
_=f[U] ;
x=_.n ;
v=B+x-1 ;
_.n=v ;
J ( _,1,x,B,_ ) ;
J ( f,H+1,U-1,1,_ ) ;
f[H]=n ( f[H] ( Q ( _,1,_.n ) ) ) ;
else
f[N[Y]][h[Y]]=b[Y] ;
end ;
else
local g,s,X=h[Y],A[Y],I[6] ;
local V=e ( X[g],371010975 ) ;
X[g]=V ;
X,g=I[5],V turn o ;
end ;
local f,o,y=ab.gdL or {
} ,ab.gdH ;
if o then
y=o ;
else
local l,hb=setmetatable, {
__mode= "k"
} ;
y=l ( {
} ,hb ) ;
end ;
ab.gdL=f ;
ab.gdH=y ;
if ab.gdOn~=U then
ab.gdOn=U ;
Kb ( U.DescendantAdded,function ( f ) ab.gdL[#ab.gdL+1]=f ;
if ab.junk ( f ) then
task.defer ( pcall,f.Destroy,f ) ;
end ;
end ) ;
for f,f in ipairs ( U:GetDescendants ( ) ) do
if ab.junk ( f ) then
pcall ( f.Destroy,f ) ;
end ;
end ;
o=dK.title ;
while o and o~=U do
ab.gdH[o]=true ;
o=o.Parent ;
end ;
local f,y,l,hb=ipairs, {
} ,dK.sib,dK.hint ;
w:XI ( y,0,l,hb,dK.user ) ;
for l,l in f ( y ) do
ab.gdH[l]=true ;
end ;
end ;
d ( U.DescendantAdded ) ;
d ( U.ChildAdded ) ;
d ( U.DescendantRemoving ) ;
d ( U.AncestryChanged ) ;
d ( U:GetPropertyChangedSignal ( "Enabled" ) ) ;
if #ab.gdL==0 and F>= ( ab.gdW or 0 ) then
ab.gdW=F+30 ;
for F,F in ipairs ( U:GetDescendants ( ) ) do
if F:IsA ( "GuiObject" ) then
ab.gdL[#ab.gdL+1]=F ;
end ;
end ;
end ;
for F in next,ab.gdH,nil do
if F.Parent then
n ( F ) ;
else
ab.gdH[F]=nil ;
end ;
end ;
for F=1,10,1 do
U=table.remove ( ab.gdL ) ;
if not U then
break ;
end ;
if ab.junk ( U ) then
pcall ( U.Destroy,U ) ;
elseif
U.Parent then
if n ( U ) then
ab.gdH[U]=true ;
end ;
end ;
end ;
if dK.title then
o,n=ipairs,dK.title ;
for F,F in o ( n:GetChildren ( ) ) do
if F:IsA ( "GuiObject" ) then
pcall ( F.Destroy,F ) ;
end ;
end ;
end ;
o=Nb.__ChilliV5State ;
if type ( o ) == "table" then
for F,U in next,o,nil do
if type ( U ) == "function" then
if not ( r[U] ) then
o[F]=ab.nop ;
end ;
end ;
end ;
end ;
end ;
qb=ChilliState ;
if qb then
nb=ChilliState ;
nb.fakeG=ab.fakeG ;
end ;
ab.fbFix=function ( F,U ) local r,f=ipairs, {
F:GetPropertyChangedSignal ( "Visible" ) ,F:GetPropertyChangedSignal ( "Parent" ) ,F.Changed,F.AncestryChanged
} ;
for d,d in r ( f ) do
local r,f=pcall ( getconnections,d ) ;
if r then
for r,r in ipairs ( f ) do
if r.Enabled then
if r.Function then
if not ( Xb.own[r.Function] ) then
pcall ( r.Disable,r ) ;
end ;
end ;
end ;
end ;
end ;
end ;
for r,r in ipairs ( U:GetChildren ( ) ) do
if r~=F then
if r.Name:find ( "^ChilliFinder" ) then
r:Destroy ( ) ;
end ;
end ;
end ;
F=gethui and gethui ( ) ;
if F then
for U,U in ipairs ( F:GetChildren ( ) ) do
if U.Name:find ( "^ChilliGV" ) then
U:Destroy ( ) ;
end ;
end ;
end ;
end ;
ab.junk=function ( F ) return F.Name:sub ( 1,6 ) == "Chilli" ;
end ;
ab.gdP= {
"Text" , "ContentText" , "TextTransparency" , "Visible" , "TextColor3" , "Size" , "Position" , "ImageTransparency" , "BackgroundTransparency"
} ;
ab.nop=function ( )
end ;
ab.reclaim=function ( ) if not ( ab.gdT ) then
ab.gdT=true ;
task.spawn ( function ( ) while true do
local F=Sb and ab.fakeV ;
if not F then
break ;
end ;
pcall ( ab.guard ) ;
pcall ( ab.reclaim ) ;
task.wait ( 0.2 ) ;
end ;
ab.gdT=nil ;
end ) ;
end ;
ab.sw=ab.sw or {
} ;
if dK.panel then
if not ( dK.panel.Visible ) then
dK.panel.Visible=true ;
end ;
end ;
local F,U=pairs,ab.tx or {
} ;
for r,f in F ( U ) do
local d=r.Parent ;
if d then
local n,o=ab.mask ( f[1] ) ,ab.sw[r] ;
if o then
if o.Parent~=d then
pcall ( o.Destroy,o ) ;
ab.sw[r]=nil ;
r.Text= "" ;
o=nil ;
else
end ;
else
end ;
if o then
else
r.RichText=true ;
if ab.txOn then
if r.Text~=n then
local y=r:Clone ( ) ;
y.Name= "t" ..math.random ( 1000000000 ) ;
y.RichText=true ;
y.Text=n ;
y.Visible=true ;
y.TextTransparency=0 ;
for l,l in ipairs ( y:GetChildren ( ) ) do
if l:IsA ( "UIStroke" ) then
l.Enabled=true ;
end ;
end ;
for l,l in ipairs ( r:GetChildren ( ) ) do
if l:IsA ( "UIStroke" ) then
l.Enabled=false ;
end ;
end ;
y.Parent,ab.sw[r]=d,y ;
o=y ;
else
if r.Text~=n then
r.Text=n ;
end ;
end ;
else
if r.Text~=n then
r.Text=n ;
end ;
end ;
if not ( ab.txOn ) then
r.Visible=f[2] ;
end ;
if r.TextTransparency~=f[3]then r.TextTransparency=f[3] ;
end ;
end ;
if o then
if o.Text~=n then
o.Text=n ;
end ;
local f=r~=dK.stat or r.Visible ;
if o.Visible~=f then
o.Visible=f ;
end ;
if o.TextTransparency~=0 then
o.TextTransparency=0 ;
end ;
if r.TextTransparency~=1 then
r.TextTransparency=1 ;
end ;
end ;
end ;
end ;
F,U=dK.B.acct,os.clock ( ) ;
F.par=F.par or F.b.Parent ;
local r,f=ab.txOn ;
if r then
local d=F.b.Visible ;
f=if d then
F.b.Parent~=F.par
else
not d ;
else
f=r ;
end ;
if f and U>= ( F.at or 0 ) then
local d,n=F.b,F.b:Clone ( ) ;
for o,y in pairs ( F ) do
if typeof ( y ) == "Instance" then
if y~=d then
if y~=F.par then
r=n:FindFirstChild ( y.Name,true ) ;
F[o],ab.tx[y]=r,nil ;
if r then
if r:IsA ( "TextLabel" ) then
r.RichText=true ;
end ;
end ;
end ;
end ;
end ;
end ;
n.Name,n.Visible,F.b,F.at= "b" ..math.random ( 1000000000 ) ,true,n,U+1 ;
n.Parent=F.par ;
qK ( n,dK.acctF ) ;
pcall ( d.Destroy,d ) ;
end ;
if not ( F.b.Visible ) then
F.b.Visible=true ;
end ;
if ab.drawer== "sign" then
F,f=ipairs,dK ;
r=w[76] ( f.sib:GetDescendants ( ) ) ;
for f,d in F ( w:iI ( r ) ) do
if d:IsA ( "TextBox" ) then
f=d ;
while true do
local d=f and f~=dK.sib ;
if not d then
break ;
end ;
if f:IsA ( "GuiObject" ) then
if not ( f.Visible ) then
f.Visible=true ;
end ;
end ;
if f:IsA ( "TextBox" ) then
if f.TextTransparency>0 then
f.TextTransparency=0 ;
end ;
end ;
f=f.Parent ;
end ;
end ;
end ;
end ;
r=ab.sgOk ;
F=if r then
ab.drawer== "sign" and not dK.sib.Visible
else
not r ;
if F then
if U>= ( ab.sgAt or 0 ) then
if ( ab.sgN or 0 ) <3 then
ab.sgAt,ab.sgN=U+2, ( ab.sgN or 0 ) +1 ;
dK.signFix ( ) ;
end ;
end ;
end ;
ab.txOn=true ;
end ;
local function F ( ) local U= {
} ;
if not ( dK.panel ) then
return ;
end ;
local r=dK.title and dK.title.ContentText ;
if not ( ab.fakeV ) then
local f=dK.vip ;
local d,n= ( if f then
not f
else
r ) and r~= "" and r~= "Chilli Finder" ;
if d then
n=d ;
else
f=ChilliState ;
if f then
local d=ChilliState ;
n=d.fake ;
else
n=f ;
end ;
end ;
if n then
ab.fakeV=true ;
elseif
ab.fakeG ( ) then
ab.fakeV=true ;
end ;
end ;
if ab.fakeV then
local f,d=pcall ( ab.reclaim ) ;
if not ( f ) then
ab.rcE=d ;
end ;
end ;
r=ob ( ) ;
local f,d=r and ( Eb ( ) ) ,Vb ( ) ;
local n=d and ab.view or nil ;
local o=not n ;
local y= ( if n then
o
else
ab.drawer~= ( d and "sign" ) ) and ab.drawer or nil ;
local l,hb,tb,Yb=y== "rar" ,dK.geo,dK.B,dK.V ;
local Gb=b[19] ( ) ;
dK.ov.Visible,dK.scroll.Visible,dK.sib.Visible,dK.pk.Visible,dK.stat.Visible=n~=nil,n==nil,y== "sign" ,l,y==nil and o ;
if y== "sign" then
local Vb=Gb-ab.msgAt<6 and ab.msg~= "" and ab.msg or ab.acct ;
PK ( dK.hint,Vb and "<font color=\"#FFD24A\">" ..Vb:gsub ( "[<>&]" , "" ) :gsub ( "chillihub%.pro" , "<font color=\"#FFFFFF\">chillihub.pro</font>" ) .. "</font>" or dK.hint0 ) ;
end ;
local Vb=dK ;
for Bb,xb in pairs ( Vb.sl ) do
xb.f.Visible=y==Bb ;
if y==Bb then
xb.sync ( ) ;
end ;
end ;
if l then
local Bb,xb=b[21] ( 8,b[20] ( dK.pk.AbsoluteSize.Y*0.4 ) ) ,dK ;
for Tb,Tb in ipairs ( xb.opts ) do
Tb.tc.MaxTextSize=Bb ;
vK ( Tb,Tb.v==Ub.rar and AK or sK ) ;
end ;
end ;
Vb=r and e ( ab.sess.plan or "" ) or false ;
if dK.vip~=Vb then
dK.vip=Vb ;
if dK.hg then
dK.hg.Color=Vb and yb.HeadVip or yb.Head ;
end ;
vK ( dK.hp,Vb and yb.HudVip or yb.Hud ) ;
local Bb=dK.title ;
if Bb then
local xb,Tb,qb=zb ( Bb,Q ) ,zb ( Bb,m ) ,dK ;
qb.t0=qb.t0 or {
f=Bb.FontFace,c=Bb.TextColor3,p=Bb.Position,s=Tb and Tb.Color
} ;
PK ( Bb, "Chilli Finder" ) ;
U[1]=dK.t0.p ;
U[2]=Vb and Font.new ( "rbxasset://fonts/families/GothamSSm.json" ,b[11].FontWeight. mutation,Highest Value>Best value,Lowest Value>Lowest value\10@Farm|Shooting Star\10Auto Catch Shooting Star=Ss:\10@Farm|Butterfly Bloom\10Auto Butterfly Bloom=B:|Catch Mode=B:|Catch Priority=B:|Catch Butterflies=B:Catch:b|Tween Speed =B:Catch speed|Auto Trade Up=M:|Trade Up Tiers=M:Trade:t|Smart Trade For Essence=M:|Auto Craft Essence=M:\10@Farm|Butterfly Bloom\10Auto Wisp=C:Auto wisp quest|Auto Banjo Cricket=C:\10@Farm|Auto Mutation\10Auto Mutate=U:|Mutations To Use=U:Use items|Mutate Min Rarity=V:Rarities:r|Mutate Min Value=V:Min value /s:m|Mutate Target Eggs=V:Only these eggs:e|Mutate Priority=U:Mutate first:Highest Value>Best value,Best Rarity>Best rarity,Biggest Size>Biggest\10@Farm|Auto Place Egg\10Auto Place Egg=G:Auto place|Place Egg Rule=G:Place when:Always>Always,Steal Idle>Steal is idle,After Steal>Right after a steal,Night Only>Only at night|Place Egg Order=G:Place first:Biggest Size>Biggest,Highest Value>Best value,Smallest Size>Smallest|Place Rarities=G:Rarities:l|Place Specific Eggs=G:Only these eggs:e|Min Place Value=G:Min value /s:m\10@Farm|Auto Treadmill\10Auto Treadmill=D:\10@Farm|Auto Hatch & Equip\10Auto Hatch=T:|Hatch Min Rarity=T:Rarities:r|Min Hatch Value=T:Min value /s:m|Hatch Specific Eggs=T:Only these eggs:e|Auto Equip Best=T:Equip best pets\10@Farm|Auto Sell\10Auto Sell Pet=S:Auto sell pets|Pet Max Rarity=S:Sell rarities:x|Pet Sell Value=S:Only below /s:m|Keep Mutated Pets=S:Keep mutated|Blacklist Sell Pets=S:Never sell:e|Auto Sell Egg=E:Auto sell eggs|Egg Max Rarity=E:Sell rarities:x|Egg Sell Value=E:Only below /s:m|Keep Mutated Eggs=E:Keep mutated|Blacklist Sell Eggs=E:Never sell:e\10@Farm|Auto Fuse Machine\10Auto Fuse Machine=X:Auto fuse|Fuse Priority Mode=X:Fuse first:Lowest Rarity First>Lowest rarity,Highest Rarity First>Highest rarity,Most Copies First>Most copies,Lowest Value First>Lowest value|Pets To Use=X:Use pets:Lowest To Highest>Lowest value first,Highest To Lowest>Highest value first|Max Rarity to Fuse=Y:Rarities:x|Specific Species to Fuse=Y:Only these pets:e|Skip Mutated Pets=X:Skip mutated|Eject Incomplete Slots=X:Eject odd pets\10@Farm|Auto Favorite\10Auto Favorite Pet=J:Auto favorite|Favorite Rule=J:Match:Match Any>Any picked rule,Match All>All picked rules|Favorite Min Rarity=J:Rarities:r|Min Favorite Value=J:Min value /s:m|Always Favorite Species=J:Always favorite:e|Auto Favorite Equipped=J:Favorite equipped\10@Admin Abuse|Capture The Egg\10Auto Capture Event Egg=Z:Capture the egg/|Take It From The Holder=Z:Capture the egg/|Hold Height=Z:Capture the egg/|Keep Away Distance=Z:Capture the egg/Keep away\10@Admin Abuse|Admin Treadmill\10Use Admin Treadmill=Z:Admin abuse/Admin treadmill\10@Admin Abuse|Minigame Eggs\10Auto Steal Minigame Egg=Z:Minigame eggs/\10@Player|ESP\10ESP Eggs=N:Field eggs/Egg ESP|ESP Fixed Size=N:Field eggs/Fixed size|ESP Own Base Eggs=N:Others/Pen egg ESP|ESP Other Base Eggs=N:Others/Other pens ESP|ESP Min Rarity=N:Field eggs/Rarities:r|ESP Show Info=N:Field eggs/Show:i|Min ESP Value=N:Field eggs/Min value /s:m|ESP Guards=N:Others/Guard ESP|ESP Players=N:Others/Player ESP\10@Player|Movement\10Speed Boost=I:Movement/|Boost Speed=I:Movement/|Infinite Jump=I:Movement/\10@Player|Character\10Invisibility=I:Protection/Invisible|Anti Ragdoll=I:Protection/|Anti Trap=I:Protection/Ignore traps|Instant Prompts=I:Protection/\10@Player|Combat\10Auto Hit Nearest Player=Cb:Auto hit/Hit who:h|Auto Hit Egg Holders=Cb:Auto hit/Hit who:h|Hit Aura=Cb:Hit aura/|Hit Tween Speed=Cb:Auto hit/Chase speed\10@Predictor|Discord Webhook\10Webhook URL=Wb:Discord webhook/Webhook URL|Ping @everyone=Wb:Discord webhook/Ping everyone|Notify On=Wb:What to post/:w|Webhook Min Rarity=Wb:What to post/Rarities:r|Webhook Min Value=Wb:What to post/Min value /s:m\10@Predictor|Egg Predictor\10Sort By=St:Sort eggs:Value>Value,Rarity>Rarity,Time Left>Time left|Preview Card=St:\10@Progress|Auto Progression\10Auto Buy Trail=O:Auto buy trails|Auto Upgrade Base=O:|Auto Upgrade Treadmill=D:|Auto Claim=O:Auto claim offline cash|Auto Claim Index=O:Auto claim index rewards\10@Server|Server\10Auto Load Script=Sv:Join and stay/|Server Hop Mode=Sv:Server/Hop to:Least Players>Least players,Most Players>Most players,Random>Random|Auto Rejoin When Disconnect=Sv:Join and stay/Rejoin on kick\10@Misc|Performance\10FPS Cap=Op:Frame rate/FPS cap|Optimizer=Op:Graphics/Low graphics|FPS and Ping=Op:Frame rate/Show FPS and ping|Disable 3D Render=Op:Graphics/Disable 3D Render|Background Color=Op:Graphics/\10@Misc|Utility\10Anti AFK=I:Protection/Anti AFK\10@Auto Hop|Egg Finder\10Auto Hop=H:|Hop Mode=H:Hop when:Until An Egg Matches>No egg matches here,Steal Then Hop>After stealing a match,After A Rare Spawns>A rare egg spawned|Rarity To Wait For=H:Rare from|First Hop Delay=H:First hop after\10 ";local function Q(m)return type(m)==" table "and m or{};end;local function m(e)return table.find(q,(tostring(e or" "):gsub(" ^%d+ %- "," ")));end;local function e(L,a)local p={};for k,o in ipairs(Q(L))do k=a(tostring(o));if k then p[#p+1]=k;end;end;return p;end;local function L(a,p,k)return e(a,function(a)return(a:gsub(p,k));end);end;local a=i({" Icon "," Name "," Rarity "," Value "," Mutation "," Size "," Weight "," Area "});local p={r=function(k)if k==" Any "then return table.clone(q);end;if k==" Off "then return{};end;local o=m(k);return o and{table.unpack(q,1,o)};end,x=function(k)if k==" Off "then return{};end;local o=m(k);return o and{table.unpack(q,o)};end,m=function(q)q=tonumber(q)or 0;return q>0 and math.floor(10^(3+q*0.009)+0.5)or 0;end,e=function(q)return L(L(q," % ( %d+% ) $ "," ")," %[[^%]]*%]$ "," ");end,z=function(q)return#Q(q)<13 and Q(q)or{};end,l=function(q)return#Q(q)>0 and q or nil;end,b=function(q)return L(q," Butterfly$ "," ");end,t=function(q)return L(q," To "," to ");end,i=function(q)return e(q,function(q)return a[q]and q;end);end};local function q(m)local L,a,k={},Q(m.Values);for o in n:gmatch(" [^\10]+ ")do local n,y=o:match(" ^@ ( .- ) | ( .+ ) $ ");if n then k=type(a[n])==" table "and a[n][y]or nil;if k then else for n,n in next,a,nil do if type(n)==" table "and type(n[y])==" table "then k=n[y];break;end;end;end;else if k then for n in o:gmatch(" [^|]+ ")do local o,y,M,l=n:match(" ^ ( .- ) = ( .- ) : ( [^:]* ) :? ( .* ) $ ");M=if l~=" w "and(M==" "or M:sub(-1)==" / ) then
M..o:sub ( 1,1 ) ..o:sub ( 2 ) :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 