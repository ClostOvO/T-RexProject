--[[
    ================================================================================
    MODULE 05: PEN EGG PLACEMENT, HATCHING & SATCHEL
    Chilli Hub / Steal An Egg Automation Engine
    ================================================================================
    
    DESCRIPTION:
    Controls automated egg hatching, smart pen egg placement (e.g. Always vs
    Steal Idle), and bulk pet satchel selling with whitelist and favorite pet
    protections.
    
    KEY REMOTES & MECHANISMS:
    - RF/EggWorld/AskHatch               = Initiates egg incubation
    - RF/EggWorld/AskFinishHatch         = Claims hatched pet
    - RE/PetSatchel/SellSelection        = Bulk sells unneeded pets
    - Place Egg Rules                    = "Always", "Steal Idle", Min/Max Value thresholds
    - Whitelist Protection               = Prevents selling favorited or high-tier pets
    ================================================================================
]]

b=r ( Yb ) ,Sb.rar or Sb.mut or Sb.any or ( Sb.minV or 0 ) >0 or next ( Xb ) ~=nil,ChilliState ;
local Sb,Xb=Kb.favNow,ChilliState ;
Xb.favNow=nil ;
local _b,Rb,vb,Pb,cb,Bb=next,type ( Yb.Inventory ) == "table" and Yb.Inventory or {
} ,0,0,0,0 ;
for xb,Tb in _b,Rb,nil do
if type ( Tb ) == "table" then
if m ( d ( Tb ) ) then
Kb=vb+1 ;
vb,Pb=Kb,if Tb.IsFavorite then
Pb
else
Pb+1 ;
else
end ;
else
end ;
cb=if type ( Tb ) == "table" then
if Tb.IsFavorite then
cb+1
else
cb
else
cb ;
if Bb>=25 then
break ;
end ;
if type ( Tb ) == "table" then
if ( hb.pend[xb]or 0 ) <os.clock ( ) then
a=Y[26] ;
Yb,Xb= ( a.favEq or Sb== "eq" ) and Hb[xb] ;
if Yb then
Xb=Yb ;
else
local a=Y[26] ;
local Yb,Kb=a.fav ;
if Yb then
Kb=Yb ;
else
a=Y[26] ;
Kb=a.unfav ;
end ;
Xb= ( Kb or Sb== "rules" ) and m ( d ( Tb ) ) ;
end ;
local m ;
local a=Tb.IsFavorite ;
local Yb,Kb=not a ;
if a then
Kb=Yb ;
else
local _b=Y[26] ;
local Rb= ( _b.favEq or Sb== "eq" ) and Hb[xb] ;
if Rb then
Kb=Rb ;
else
_b=Y[26] ;
Kb= ( _b.fav or Sb== "rules" ) and Xb ;
end ;
end ;
if Kb then
m=true ;
else
if Tb.IsFavorite then
if Hb[xb]then if Sb== "uneq" then
m=false ;
else
a=Y[26] ;
m=if a.unfav then
if Vb then
if Xb then
m
else
false
else
m
else
m ;
end ;
else
end ;
else
end ;
end ;
if m~=nil then
Yb=Bb+1 ;
hb.pend[xb]=os.clock ( ) +4 ;
R ( "RE/PetSatchel/WriteFavourite" ,xb,m ) ;
task.wait ( 0.12 ) ;
Bb=Yb ;
else
end ;
else
end ;
else
end ;
end ;
Gb ( ( "Favorite matches - %d pets, %d to mark | %d favorited" ) :format ( vb,Pb,cb ) ) ;
end ;
end ) ;
S ( "20_farm#8" ,function ( ) local m= {
} ;
local a=wb ( {
name= "Fuse" ,gap=2,bad= {
} ,info=true
} ) ;
m[66]=a ;
local a=Ib[ "Auto Fuse Machine" ] ;
local hb=p ( "fuseTx" ,a:Text ( "Fuse Preview" , "Fuse status unknown" ) ) ;
m[70]=hb ;
local hb,Yb,Gb,Sb=y ( a, "Auto Fuse Machine" , "fuse" ,false,nil, "Fuse 3 same pets into an egg, nonstop" ) , {
[ "Lowest Rarity First" ]= "Lowest rarity" ,[ "Highest Rarity First" ]= "Highest rarity" ,[ "Most Copies First" ]= "Most copies" ,[ "Lowest Value First" ]= "Lowest value"
} ,Y[26],Y[26] ;
Gb.fuseFirst= "Lowest rarity" ;
Sb.fuseUse= "Lowest value first" ;
a:Dropdown ( "Fuse Priority Mode" , {
"Lowest Rarity First" , "Highest Rarity First" , "Most Copies First" , "Lowest Value First"
} , "Lowest Rarity First" ,function ( Gb ) local Xb=Y[26] ;
Xb.fuseFirst=Yb[Gb]or "Lowest rarity" ;
end ,false,nil,hb ) ;
a:Dropdown ( "Pets To Use" , {
"Lowest To Highest" , "Highest To Lowest"
} , "Lowest To Highest" ,function ( Yb ) local Gb=Y[26] ;
Gb.fuseUse=Yb== "Highest To Lowest" and "Highest value first" or "Lowest value first" ;
end ,false,nil,hb ) ;
local Yb,Gb,Xb= {
} ,ChilliState ;
m[68]=Yb ;
Xb,m[68].rar=ChilliState,Gb.maxRar ( ChilliState.RNUM[6] ) ;
Sb=ChilliState ;
local Yb,Xb,Xb,Hb=Sb.RNUM,ChilliState,ChilliState.RNUM,function ( Sb ) local Vb,Kb=m[68],ChilliState ;
Vb.rar=Kb.maxRar ( Sb ) ;
end ;
a:Dropdown ( "Max Rarity to Fuse" ,Yb,Xb[6],Hb,false,nil,hb ) ;
Gb=ChilliState ;
local function Yb ( Sb ) local Xb,Hb=m[68],ChilliState ;
Xb.sp=Hb.names ( Sb ) ;
end ;
a:Dropdown ( "Specific Species to Fuse" ,Gb.eggList, {
} ,Yb,true, "Only fuse these species (empty = all)" ,hb ) ;
y ( a, "Skip Mutated Pets" , "fuseKeep" ,true,nil,nil,hb ) ;
y ( a, "Eject Incomplete Slots" , "fuseEject" ,true,nil, "Take out pets that can't make a set" ,hb ) ;
local a= {
[ "Lowest rarity" ]=function ( hb ) return -hb.r*1000+#hb ;
end ,[ "Highest rarity" ]=function ( hb ) return hb.r*1000+#hb ;
end ,[ "Most copies" ]=function ( hb ) return #hb ;
end ,[ "Lowest value" ]=function ( hb ) return -hb.v ;
end
} ;
m[69]=a ;
m[66].on=function ( ) local a=Y[26] ;
return a.fuse or L ( "Farm" ) ;
end ;
m[66].fn=w:zI ( 19,20, {
[64]=Y,[26]=Y,[21]=Y,[9]=Y,[65]=Y,[66]=m,[67]=Y,[68]=m,[69]=m,[70]=m,[71]=Y,[23]=Y,[72]=Y
} ,b,h,nil ) ;
end ) ;
S ( "21_eggs#1" ,function ( ) local b=Color3.fromRGB ;
local h=UDim2.fromScale ;
local m=UDim2.fromOffset ;
local a=Vector2.new ;
local hb=UDim2.new ;
local Yb=UDim.new ;
local Gb=ColorSequence.new ;
local Sb=math.max ;
local Xb,Hb,Vb=math.floor,Enum,ChilliState ;
local Kb=Vb.PS ;
local Vb=Color3.new ( 1,1,1 ) ;
local _b ;
local Rb,vb,Pb=true ;
local cb,Bb=Kb.Seq,Kb.FormatRate ;
local xb=Kb.FormatWeight ;
local Tb=Kb.Income ;
local qb=Kb.AssetInfo ;
local Fb=wb ( {
name= "GoTo" ,mover=true,gap=0.5,pri=0,soft=true
} ) ;
Fb.on=function ( ) local Db=_b ;
return Db~=nil ;
end ;
Fb.want=function ( ) local Db=_b ;
return Db ;
end ;
Fb.run=function ( Fb,Db ) local Ub=Vector3.new ;
tb ( Fb+Ub ( 0,3,4 ) ,Db ) ;
_b=nil ;
end ;
local function tb ( Fb ) return type ( Fb ) == "table" and Fb or {
} ;
end ;
local function Fb ( Db,Ub,Zb,rb,fb,jb ) return Gb ( b ( Db,Ub,Zb ) ,b ( rb,fb,jb ) ) ;
end ;
local function Db ( Ub ) return {
TextScale=0.84,LineHeight=1.1,MinLines=16,MaxLines=Ub,BackgroundTransparency=0.5,ScrollBarColor=b ( 170,174,184 ) ,TextColor=Vb,TextStrokeTransparency=0.7
} ;
end ;
do
local Ub=Color3.new ( 0,0,0 ) ;
local Zb=b ( 18,18,26 ) ;
local rb=b ( 214,218,236 ) ;
local fb=b ( 62,64,84 ) ;
local jb=Gb ( Vb ) ;
local db=Fb ( 170,255,140,40,230,90 ) ;
local Jb=Hb.TextXAlignment.Left ;
local nb=Hb.TextTruncate.None ;
local Qb=Hb.AutomaticSize.X ;
local mb=Hb.AutomaticSize.Y ;
local ib,eb,Lb=Hb.SortOrder.LayoutOrder, {
"Value" , "Rarity" , "Time Left"
} , {
} ;
w:XI ( Lb,0, {
"All" , "ALL" ,Fb ( 255,255,255,176,188,220 )
} , {
"Ready" , "READY" ,Fb ( 170,255,150,40,220,90 )
} , {
"Growing" , "GROWING" ,Fb ( 255,232,150,255,150,40 )
} , {
"Inventory" , "IN BAG" ,Fb ( 180,232,255,70,160,255 )
} ) ;
local ab= {
} ;
ab.Ready= {
Fb ( 170,255,150,30,205,85 ) , "HATCH NOW"
} ;
ab.Growing= {
Fb ( 255,225,120,255,130,40 ) , "FLY TO EGG"
} ;
ab.Inventory= {
Fb ( 160,225,255,60,140,255 ) , "HOLD EGG"
} ;
local Eb,ub=cb ( 0,255,110,110,0.2,255,190,90,0.4,255,245,110,0.6,120,255,150,0.8,110,200,255,1,200,120,255 ) , {
} ;
ub.Golden=Fb ( 255,246,170,255,184,0 ) ;
ub.Silver=Fb ( 255,255,255,160,176,200 ) ;
ub.Sakura=Fb ( 255,214,236,255,110,190 ) ;
ub.GreatBloom=Fb ( 205,255,230,60,225,150 ) ;
ub.Boss=Fb ( 255,190,190,255,70,70 ) ;
ub.Monstrous=Fb ( 228,204,255,150,90,255 ) ;
ub.Scrambled=Fb ( 215,255,160,40,215,170 ) ;
ub.Rainbow=Eb ;
ub.Prismatic=Eb ;
local Eb,Wb=Fb ( 215,245,255,80,190,255 ) , {
} ;
Wb.ETERNAL=cb ( 0,196,222,255,0.45,246,242,255,1,214,180,255 ) ;
Wb.SECRET=cb ( 0,240,243,250,0.3,120,128,146,0.52,30,32,42,0.74,110,118,136,1,248,250,255 ) ;
localocusLost,function ( ) z ( hK,0.6,0.16 ) ;
local o=zK and Eb ( hK.Text ) or tonumber ( ( hK.Text:gsub ( "," , "." ) :gsub ( "[^%d%.%-]" , "" ) ) ) ;
if o then
NK:Set ( o ) ;
end ;
AK ( ) ;
end ) ;
NK.Value=D ( tonumber ( ob ) or ub,ub,kb ) ;
AK ( ) ;
Qb.vb=hK ;
Qb.tr=IK ;
Vb:Reg ( Qb,NK, "slider" ) ;
return NK ;
end ;
Wb.Dropdown=function ( o,Vb,db,Qb,mb,ib,Lb,ab,Eb ) local ub=o.W ;
local kb=o:Row ( Vb,ab,true ) ;
local ob=Sb ( {
p=kb.m,n= "Dropdown" ,A=R,P=s ( 0.845,0.5 ) ,S=s ( 0.28,0.62 ) ,B=K,T=0.6,Z=6,sb ( 0.1 )
} ) ;
Bb ( ob,1.025,0.975 ) ;
local Cb=j ( Lb or "" ) ;
g ( kb,0.66,Cb ) ;
Q ( kb,0.65,Cb~= "" ) ;
if Cb~= "" then
ob.Size=s ( 0.28,0.465 ) ;
end ;
local Lb=Kb ( {
p=ob,n= "Value" ,A=R,P=s ( 0.405,0.5 ) ,S=s ( 0.7,0.58 ) ,W=true,Z=7
} ) ;
gb ( {
p=ob,n= "Divider" ,A=R,P=s ( 0.8,0.5 ) ,S=s ( 0.014,0.66 ) ,B=K,T=0.3,Z=7
} ) ;
local wK=qb ( ob,_,s ( 0.888,0.5 ) ,s ( 0.16,0.56 ) ,7 ) ;
local bK,hK,tK,zK,YK,AK,IK,gK,NK,GK,SK=gb ( {
p=kb.r,n= "Menu" ,A=c,P=S ( 0.5,0,0,0 ) ,S=Nb ( 0 ) ,T=1,C=true,V=false,Z=6
} ) , {
Multi=ib,Options=db,Empty= "None"
} ,false, {
} , "" ;
local sK,XK,OK,HK=0,0,0,0 ;
local function VK ( ) local KK= {
} ;
for _K,RK in ipairs ( type ( hK.Options ) == "function" and hK.Options ( ) or hK.Options ) do
KK[_K]=j ( RK ) ;
end ;
return KK ;
end ;
local function KK ( _K ) if ib then
return table.find ( hK.Value,_K ) ~=nil ;
end ;
return hK.Value==_K ;
end ;
local function _K ( ) return ib and#hK.Value or ( hK.Value~=nil and 1 or 0 ) ;
end ;
local function RK ( vK ) if ib then
local PK=#hK.Value ;
Lb.Text=PK==0 and hK.Empty or PK==1 and j ( hK.Value[1] ) or PK.. " selected" ;
else
Lb.Text=j ( hK.Value or "" ) ;
end ;
local Lb=zK ;
for PK,PK in next,Lb,nil do
PK.paint ( vK ) ;
end ;
if NK then
Lb=_K ( ) ;
GK.Text=ib and Lb>0 and Eb[2].. " (" ..Lb.. ")" or Eb[2] ;
vK=Lb>0 and 0 or 0.45 ;
GK.TextTransparency=vK ;
GK:FindFirstChildOfClass ( "UIStroke" ) .Transparency=vK ;
for Lb,Lb in ipairs ( SK ) do
Lb.BackgroundTransparency=vK ;
end ;
end ;
end ;
local function Lb ( ) local vK,PK,cK= {
} ,ipairs,w[76] ( VK ( ) ) ;
for BK,xK in PK ( w:iI ( cK ) ) do
BK=zK[xK] ;
if BK then
BK.b.Visible=YK== "" or xK:lower ( ) :find ( YK,1,true ) ~=nil ;
if BK.b.Visible then
vK[#vK+1]=BK ;
end ;
end ;
end ;
if hK.empty then
hK.empty.Visible=#vK==0 ;
end ;
return vK ;
end ;
local function vK ( PK ) local cK=sK ;
local BK,xK,TK,qK=S ( 1,0,0,cK+ ( tK and OK+XK or 0 ) ) ,HK*2,tK ;
if TK then
cK=XK ;
qK=cK+HK*2 ;
else
qK=TK ;
end ;
TK=S ( 1,xK,0,qK or 0 ) ;
if kb.rt then
kb.rt:Cancel ( ) ;
kb.mt:Cancel ( ) ;
end ;
if tK then
bK.Visible=true ;
end ;
if PK then
kb.rt,kb.mt=_b ( kb.r, {
Size=t ( BK.Y.Offset )
} ,0.26,y ) ,_b ( bK, {
Size=TK
} ,0.26,y ) ;
if not ( tK ) then
kb.mt.Completed:Connect ( function ( PK ) if PK==N.PlaybackState.Completed then
if not ( tK ) then
bK.Visible=false ;
end ;
end ;
end ) ;
end ;
else
qK,cK,xK=kb.r,t ( BK.Y.Offset ) ,tK ;
qK.Size=cK ;
bK.Size=TK ;
bK.Visible=xK ;
end ;
end ;
local function t ( PK ) local cK=kb.r.AbsoluteSize.X ;
if cK<=0 then
return ;
end ;
local BK=cK/pb ;
local xK=BK/10 ;
sK=Cb~= "" and BK/7.5 or xK ;
BK=xK*0.62 ;
local Cb,TK=BK*0.12,xK*0.15 ;
HK,OK=Cb,TK ;
kb.head.Size=Nb ( sK ) ;
TK=sK ;
bK.Position=S ( 0.5,0,0,TK-sK*0.075+OK-HK ) ;
if tK then
elseif
PK then
else
return vK ( false ) ;
end ;
Cb=zK ;
for sK,sK in next,Cb,nil do
sK.aw=BK*0.17 ;
end ;
TK,xK=0,0 ;
if gK then
TK=BK*0.8+OK ;
gK.Position,gK.Size=X ( HK,HK ) ,X ( cK,BK*0.8 ) ;
else
end ;
if AK then
xK=BK+OK ;
local sK,qK,FK,DK=AK,AK,X ( HK,HK+TK ) ,X ( cK,BK ) ;
sK.Position=FK ;
qK.Size=DK ;
else
end ;
local sK,qK=HK+TK+xK,Lb ( ) ;
if #qK==0 then
if hK.empty then
hK.empty.Position,hK.empty.Size=X ( HK,sK ) ,X ( cK,BK ) ;
end ;
XK=TK+xK+BK ;
else
Cb=D ( Z ( 4,F ( ( cK+OK ) / ( BK*2.2+OK ) ) ) ,1,#qK ) ;
local Lb,FK=f ( #qK/Cb ) , ( cK- ( Cb-1 ) *OK ) /Cb ;
XK=TK+xK+Lb*BK+U ( Lb-1,0 ) *OK ;
for TK,DK in ipairs ( qK ) do
local UK,ZK= ( TK-1 ) //Cb, ( TK-1 ) %Cb ;
local rK,fK,jK,dK=Z ( Cb,#qK-UK*Cb ) ,DK.b,DK.b,HK ;
TK,Lb=X ( dK+ ( cK- ( rK*FK+ ( rK-1 ) *OK ) ) /2+ZK* ( FK+OK ) ,sK+UK* ( BK+OK ) ) ,X ( FK,BK ) ;
fK.Position=TK ;
jK.Size=Lb ;
end ;
end ;
if NK then
sK=HK ;
NK.Position,NK.Size=X ( sK+cK/2,HK+XK+OK+BK/2 ) ,X ( Z ( cK,U ( BK*3.6,cK*0.42 ) ) ,BK ) ;
xK=XK ;
XK=xK+ ( OK+BK ) ;
end ;
RK ( false ) ;
vK ( PK ) ;
end ;
kb.dd=function ( ) t ( false ) ;
end ;
local Lb=0 ;
Ab ( kb.r, "AbsoluteSize" ,function ( ) local Cb=kb.r.AbsoluteSize.X ;
if r ( Cb-Lb ) >=0.5 then
Lb=Cb ;
t ( false ) ;
end ;
end ) ;
local function Lb ( ) local Cb=zK ;
for sK,sK in next,Cb,nil do
sK.b:Destroy ( ) ;
end ;
zK= {
} ;
Cb=VK ( ) ;
if #Cb>=5 then
if not ( AK ) then
AK=gb ( {
p=bK,n= "Search" ,B=K,T=0.6,Z=7,sb ( 0.07 )
} ) ;
IK=Hb ( Gb ( "TextBox" , {
p=AK,n= "Input" ,A=R,P=B,S=s ( 0.94,0.56 ) ,PH= "Search..." ,PC3=Ib,Z=9
} ) ) ;
Ab ( IK, "Text" ,function ( ) YK= ( IK.Text:match ( "^%s*(.-)%s*$" ) or "" ) :lower ( ) ;
t ( true ) ;
end ) ;
end ;
end ;
if not ( hK.empty ) then
hK.empty=Kb ( {
p=bK,n= "Empty" ,x= "No match" ,t=0.4,V=false,Z=9
} ) ;
end ;
for AK,sK in ipairs ( Cb ) do
local Cb=Sb ( {
p=bK,n= "Option" ..AK,O=AK,B=K,T=0.45,Z=7,sb ( 0.07 )
} ) ;
local AK,XK,OK,HK= {
b=Cb,aw=0
} ,false ;
if ib then
HK=gb ( {
p=gb ( {
p=Cb,n= "Tick" ,A=v,P=s ( 0.055,0.5 ) ,S=s ( 0.16,0.44 ) ,B=K,T=0.3,Z=8,sb ( 0.12 ) ,Ob ( 1,true )
} ) ,n= "Fill" ,A=R,P=B,S=s ( 0,0 ) ,B=V,Z=9,Xb ( L, "AccentGradient" )
} ) ;
else
OK=gb ( {
p=Cb,n= "Accent" ,A=v,P=s ( 0,0.5 ) ,S=s ( 0,1 ) ,B=V,Z=8,Xb ( L, "AccentGradient" )
} ) ;
end ;
local L=Kb ( {
p=Cb,n= "Label" ,A=R,P=s ( ib and 0.56 or 0.5,0.5 ) ,S=s ( ib and 0.62 or 0.78,0.56 ) ,x=sK,W=true,Z=9
} ) ;
AK.paint=function ( Ob ) local vK=KK ( sK ) ;
local KK,PK=vK and 0.85 or 0,vK and 0.2 or ( XK and 0.3 or 0.45 ) ;
local cK=HK and s ( KK,KK ) or S ( 0,vK and AK.aw or 0,1,0 ) ;
if Ob then
z ( Cb,PK,0.12 ) ;
_b ( OK or HK, {
Size=cK
} ,0.12 ) ;
else
Cb.BackgroundTransparency, ( OK or HK ) .Size=PK,cK ;
end ;
L.TextTransparency=vK and 0 or 0.15 ;
end ;
Yb ( Cb.MouseEnter,function ( ) XK=true ;
AK.paint ( true ) ;
end ) ;
Yb ( Cb.MouseLeave,function ( ) XK=false ;
AK.paint ( true ) ;
end ) ;
Fb ( Cb,function ( ) if ib then
local L=table.clone ( hK.Value ) ;
local Ob=table.find ( L,sK ) ;
if Ob then
table.remove ( L,Ob ) ;
else
L[#L+1]=sK ;
end ;
if Eb then
hK.Value=L ;
RK ( true ) ;
else
hK:Set ( L ) ;
end ;
elseif
Eb then
hK.Value=sK ;
RK ( true ) ;
else
hK:Set ( sK ) ;
ub.closeDD ( ) ;
end ;
end ) ;
zK[sK]=AK ;
end ;
end ;
if Eb then
gK=Kb ( {
p=bK,n= "Hint" ,x=Eb[1],W=true,t=0.28,Z=9
} ) ;
db,Vb,ab=nil ;
NK,db,GK,Vb,ab=Db ( {
p=bK,n= "Apply" ,S=X ( 0,0 ) ,Z=9,full=true,Text=Eb[2],LSize=s ( 0.88,0.56 ) ,wrap=true,h=1.03
} ) ;
SK= {
Vb,ab
} ;
Fb ( NK,function ( ) if _K ( ) ==0 then
if ib then
return ;
end ;
end ;
ub.closeDD ( ) ;
cb ( mb,hK.Value ) ;
end ) ;
else
end ;
local function L ( Ob ) if tK==Ob then
return ;
end ;
if Ob then
lb ( ) ;
Lb ( ) ;
YK= "" ;
if IK then
IK.Text= "" ;
end ;
function ub.closeDD ( ) L ( false ) ;
end ;
else
if IK then
IK:ReleaseFocus ( ) ;
end ;
ub.closeDD=nil ;
end ;
tK=Ob ;
_b ( wK, {
Rotation=Ob and 180 or 0
} ,0.22 ) ;
z ( ob,Ob and 0.42 or 0.6,0.16 ) ;
t ( true ) ;
end ;
kb.close=function ( ) L ( false ) ;
end ;
Fb ( ob,function ( ) L ( not tK ) ;
end ) ;
hK.Set=function ( L,Ob,db ) L=hK.Value ;
if ib then
local ab,ub= {
} , {
} ;
for ob,ob in ipairs ( VK ( ) ) do
ub[ob]=true ;
end ;
for ob,Cb in next,type ( Ob ) == "table" and Ob or Ob~=nil and {
Ob
} or {
} ,nil do
local wK=type ( ob ) == "string" and Cb==true and ob or j ( Cb ) ;
if ub[wK]or type ( hK.Opt nb=ChilliState ;
nb.skip[Ub]=nil ;
end ;
end ;
table.sort ( mb,function ( Ub,Zb ) if Ub.b~=Zb.b then
return Ub.b>Zb.b ;
end ;
if Ub[Eb]~=Zb[Eb]then return Ub[Eb]>Zb[Eb] ;
end ;
return Ub.v>Zb.v ;
end ) ;
return mb ;
end ;
local Ub=ChilliState ;
Ub.sortKey=function ( ) local Ub=Y[26] ;
return Rb[Ub.order]or "v" ;
end ;
local Ub=ChilliState ;
Ub.stealSort=function ( Ub ) local Zb=Y[26] ;
local rb=Rb[Zb.order]or "v" ;
table.sort ( Ub,function ( Zb,fb ) if Zb.b~=fb.b then
return Zb.b>fb.b ;
end ;
if ( Zb[rb]or 0 ) ~= ( fb[rb]or 0 ) then
return ( Zb[rb]or 0 ) > ( fb[rb]or 0 ) ;
end ;
return Zb.v>fb.v ;
end ) ;
return Ub ;
end ;
local Ub ;
local Zb=0 ;
local function rb ( ) if Ub then
if os.clock ( ) -Zb<0.3 then
local fb=Ub ;
return fb ;
end ;
end ;
local fb,db,Jb=xb ( false ) ,os ;
Jb,Ub=db.clock ( ) ,fb ;
Zb=Jb ;
db=Ub ;
return db ;
end ;
local Zb=ChilliState ;
Zb.fresh=function ( ) Ub=nil ;
end ;
local Ub=ChilliState ;
Ub.targetsSoon=function ( ) return xb ( false,true ) ;
end ;
local Ub=ChilliState ;
Ub.allEggs=function ( ) return xb ( true ) ;
end ;
_b=ChilliState ;
_b.reach=Pb ;
local _b=115 ;
pcall ( function ( ) _b=tonumber ( require ( N.Shared.Types.Eggs ) .MAX_INVENTORY ) or _b ;
end ) ;
Hb=ChilliState ;
Hb.bagMax=_b ;
local Hb=0 ;
local function xb ( ) local Ub=0 ;
for Zb in pairs ( Q ( ) ) do
Ub+=1 ;
end ;
local Zb=_b ;
return Ub>=Zb ;
end ;
local function _b ( Ub ) if os.clock ( ) -Hb<1 then
return true ;
end ;
local Zb,fb=pairs,w[76] ( Q ( ) ) ;
local db ;
for Jb,nb in Zb ( w:iI ( fb ) ) do
if type ( nb ) == "table" then
if nb.Placement then
else
local fb=ChilliState ;
if fb.reserved[Jb]then
else
local fb=ChilliState ;
local Qb,mb=fb.protect ;
if Qb then
fb=ChilliState ;
mb=fb.protect ( Jb,nb ) ;
else
mb=Qb ;
end ;
if mb then
else
fb=d ( nb ) ;
if #fb.m==0 then
if fb.v<Ub then
Qb=Y[26] ;
if fb.v< ( Qb.bagMax or math.huge ) then
local nb=fb.v ;
Ub,db=nb,Jb ;
else
end ;
else
end ;
else
end ;
end ;
end ;
end ;
else
end ;
end ;
if not ( db ) then
return false ;
end ;
R ( "RE/PetSatchel/SellSelection" , {
Eggs= {
db
} ,Assets= {
}
} ) ;
Hb=os.clock ( ) ;
Zb=Y[11] ;
Zb ( "Sold a cheap egg to make room" , "ok" ) ;
return true ;
end ;
local Hb ;
local Ub=ChilliState ;
Ub.bagCheck=function ( ) Hb=nil ;
local Ub=Y[26] ;
if Ub.bagSell then
if xb ( ) then
_b ( math.huge ) ;
end ;
end ;
end ;
Vb=GameModules ;
if Vb.Egg then
vb=GameModules ;
if vb.Egg.OwnerRefreshed then
Kb=GameModules ;
V ( Kb.Egg.OwnerRefreshed,function ( Vb ) local Kb=LocalPlayer ;
if Vb==Kb.UserId then
local Vb=Y[26] ;
if Vb.bagSell then
if not ( Hb ) then
Hb=true ;
task.defer ( ChilliState.bagCheck ) ;
end ;
end ;
end ;
end ) ;
end ;
end ;
function Sb.ready ( ) if e ( ) <=0 then
return nil ;
elseif
( Sb.full or 0 ) >os.clock ( ) then
return nil ;
end ;
local Hb=rb ( ) [1] ;
if not ( Hb ) then
return nil ;
end ;
local Vb=ChilliState ;
Vb.stealNext=Hb.kind ;
Vb=ChilliState ;
return Vb.rank[ "Steal:" ..Hb.kind]or 9 ;
end ;
local Hb=ChilliState ;
Hb.stealWants=function ( ) local Hb=Sb.inq==true or Y[4]==Sb ;
return Hb ;
end ;
function Sb.want ( ) local Hb=ChilliState ;
Hb.curUid=nil ;
Hb=e ( ) ;
if Hb<=0 then
rb ( ) ;
local Vb=Y[11] ;
return Vb ( "Waiting for daytime" ) ;
end ;
if os.clock ( ) -hb<1.5 then
return "wait" ;
end ;
if ( Sb.full or 0 ) >os.clock ( ) then
Hb=Y[11] ;
return Hb ( Sb.fullTx or "Bag full, retrying soon" , "warn" ) ;
end ;
Hb=rb ( ) ;
Sb.empty=#Hb==0 and ( Sb.empty or os.clock ( ) ) or nil ;
if #Hb==0 then
local hb=Y[11] ;
return hb ( "No egg matches your targets" ) ;
end ;
local hb,Vb=ipairs ;
for Kb,vb in hb ( Hb ) do
if vb.held then
Kb=ChilliState ;
if Kb.bat ( ) then
Vb=vb ;
break ;
end ;
else
Vb=vb ;
break ;
end ;
end ;
if not ( Vb ) then
hb=Y[11] ;
return hb ( "Matching eggs are in other players' hands" ) ;
end ;
if xb ( ) then
hb=Y[26] ;
if hb.bagSell then
if _b ( Vb.v ) then
return "wait" ;
end ;
end ;
Sb.full=os.clock ( ) +30 ;
local Kb,vb=Y[11],Y[26] ;
return Kb ( vb.bagSell and "Bag is full, no cheaper egg to sell" or "Bag full, place or sell eggs" , "warn" ) ;
end ;
hb,Hb=ChilliState ;
Hb,hb.rank.Steal=ChilliState,ChilliState.rank[ "Steal:" ..Vb.kind]or 9 ;
return Vb ;
end ;
local function hb ( Hb ) local Vb=Y[18] ;
local Kb=Vb ( ) ;
if type ( Kb[Hb] ) == "table" then
return Kb[Hb] ;
end ;
for Vb,Vb in pairs ( Kb ) do
if type ( Vb ) == "table" then
if Vb.Uid==Hb then
return Vb ;
end ;
end ;
end ;
end ;
local function Hb ( Vb ) local Kb=hb ( Vb ) ;
local vb,xb=Kb and Kb.State== "Carried" and g:GetPlayerByUserId ( tonumber ( Kb.CarrierUserId ) or 0 ) ;
if vb then
Kb=LocalPlayer ;
xb=vb~=Kb ;
else
xb=vb ;
end ;
Kb=xb and vb.Character and vb.Character:FindFirstChild ( "HumanoidRootPart" ) ;
if Kb then
return Kb,vb ;
end ;
Kb=workspace:FindFirstChild ( Vb ) ;
if not Kb then
return ;
end ;
xb,Vb=ipairs,w[76] ( Kb:GetDescendants ( ) ) ;
for Ub,Zb in xb ( w:iI ( Vb ) ) do
if Zb:IsA ( "JointInstance" ) or Zb:IsA ( "WeldConstraint" ) or Zb:IsA ( "RigidConstraint" ) then
vb,Ub=ipairs, {
Zb.Part0,Zb.Part1
} ;
for Zb,fb in vb ( Ub ) do
local Ub,db=fb and not fb:IsDescendantOf ( Kb ) and fb:FindFirstAncestorOfClass ( "Model" ) ;
if Ub then
Zb=LocalPlayer ;
db=Ub~=Zb.Character ;
e 295 ) ,i ( tb,4294967295 ) ;
local hb,tb,Ab,Ib=i ( zb,65535 ) ,m ( zb,16 ) ,i ( Yb,65535 ) ,m ( Yb,16 ) ;
zb=i ( hb*Ab+W ( i ( hb*Ib+tb*Ab,65535 ) ,16 ) ,4294967295 ) ;
tb=nil ;
repeat
Ab=zb%4294967296 ;
if Ab~=Ab then
tb=0 ;
break ;
end ;
tb=Ab-Ab%1 ;
until true ;
f[bb]=tb ;
else
f[h[Y]]=f[A[Y]]+G[Y] ;
end ;
else
if wb>=78 then
if wb>=79 then
if wb~=80 then
H=A[Y] ;
f[H],f[H+1]=G[Y],f[h[Y]] ;
else
f[A[Y]]= {
} ;
end ;
else
Y=if f[h[Y]]<A[Y]then Y
else
G[Y] ;
end ;
else
if wb<76 then
f[A[Y]]=h[Y]<f[G[Y]] ;
else
if wb~=77 then
H=f[h[Y]] ;
f[G[Y]]=n ( Q ( H,A[Y],H.n ) ) ;
else
Hace ",false,function(vb)if not(vb)then bb(Vb);end;end);y(Kb," Place And Hatch Missing Index Eggs "," placeIdx ");local vb,Pb,cb,Bb={Always=" Always ",[" Steal Idle "]=" Steal is idle ",[" After Steal "]=" Right after a steal ",[" Night Only "]=" Only at night "},{[" Biggest Size "]=" Biggest ",[" Highest Value "]=" Best value ",[" Smallest Size "]=" Smallest ",[" Lowest Value "]=" Lowest value ",[" Backpack Order "]=" Backpack "},Y[26],Y[26];cb.placeWhen=" Always ";Bb.placeFirst=" Best value ";Kb:Dropdown(" Place Egg Rule ",{" Always "," Steal Idle "," After Steal "," Night Only "}," Always ",function(cb)local xb=Y[26];xb.placeWhen=vb[cb]or" Always ";end,false,nil,Rb);Kb:Dropdown(" Place Egg Order ",{" Biggest Size "," Highest Value "," Smallest Size "," Lowest Value "," Backpack Order "}," Highest Value ",function(vb)local cb=Y[26];cb.placeFirst=Pb[vb]or" Best value ";end,false,nil,Rb);local vb,Pb,cb={},{},ChilliState;Bb=#cb.RANY;for xb=2,Bb,1 do cb=nil;cb,Pb[#Pb+1]=ChilliState,ChilliState.RANY[xb];end;local function cb(Bb)local xb,Tb=ipairs;for qb,Fb in xb(Bb)do Tb=Tb or{};qb=ChilliState;Tb[qb.RIDX[Fb]or 0]=true;end;vb.rar=Tb;end;Kb:Dropdown(" Place Rarities ",Pb,{},cb,true," Only place eggs of the picked rarities ( empty = all ) ",Rb);Pb=ChilliState;local function cb(Bb)local xb=ChilliState;vb.sp=xb.names(Bb);end;Kb:Dropdown(" Place Specific Eggs ",Pb.eggList,{},cb,true," Only place these eggs ( empty = all ) ",Rb);Kb:Slider(" Min Place Value ",0,0,0,function(Pb)vb.minV=Pb>0 and Pb or nil;end," log ",nil," Skip eggs worth less than this ( 0 = off ) ",Rb);Kb:Slider(" Max Place Value ",0,0,1000,function(Kb)vb.maxV=Kb>0 and Kb<1000000000000 and Kb or nil;end," log ",nil," Only place eggs worth less than this, keep the better ones ( far right = no limit ) ",Rb);local Kb,Rb=0,ChilliState;local Pb,Bb=Rb.onSteal,ChilliState;Bb.onSteal=function(Rb)Kb=os.clock();if Pb then Pb(Rb);end;end;local function Rb()local Pb=Y[63];local Bb,xb,Tb,qb,Fb=Pb(),Vector3.zero,next,{},ChilliState;w:XI(qb,0,workspace:FindFirstChild(" PlacedEggRenders "),Fb.hidden);Pb=0;for Db,Ub in Tb,qb,nil do Db,Fb=ipairs,w[76](Ub:GetChildren());for Tb,qb in Db(w:iI(Fb))do if qb:IsA(" Model ")then Tb,Ub=LocalPlayer,qb.Name:find(LocalPlayer.UserId.." _ ",1,true);if Ub==1 then local Tb,Fb=Pb+1,xb+qb:GetPivot().Position;Pb,xb=Tb,Fb;else end;else end;end;end;if Pb>0 then return xb/Pb;end;return Bb and Bb.PetArea and Bb.PetArea.Position;end;local Pb=w:zI(17,18,{[63]=Y,[20]=Y,[28]=Y},b,h,nil);local function Bb(xb)local Tb=callRequiredModuleMethod;if Tb(" Egg "," WearEggTool ",xb)==false then return false;end;Tb=os.clock()+2;while os.clock()<Tb do if hb()==xb then return true;end;if os.clock()>Tb-1.3 then local Tb,qb=ipairs,n()and n():GetChildren()or{};for Fb,Fb in Tb(qb)do if Fb:GetAttribute(" UID ")==xb then local xb,xb=getHumanoid,getHumanoid;pcall(getHumanoid().EquipTool,getHumanoid(),Fb);end;end;end;task.wait(0.1);end;return false;end;cb=ChilliState;cb.wear=Bb;local function cb()local xb=Y[26];local Tb=xb.placeWhen;if Tb==" Steal is idle "then xb=Y[26];local qb=xb.steal;return if qb then Sb.empty~=nil else not qb;end;if Tb==" Right after a steal "then xb=os.clock()-Kb;return xb<12;end;if Tb==" Only at night "then return e()<14;end;return true;end;local function Sb()local Kb,xb,Tb,qb=Q(),{},{},Y[26];local Fb,Db=qb.placeIdx;if Fb then qb=ChilliState;Db=qb.indexMissing();else Db=Fb;end;local Ub,Zb,rb=Db or{},{},0;for fb,fb in pairs(Kb)do if type(fb)==" table "then if fb.Placement then Fb=rb+1;Zb[fb.AssetCategory or fb.Category or" "]=true;rb=Fb;else end;else end;end;qb=pairs;for fb,jb in qb(Kb)do if type(jb)==" table "then if not(jb.Placement)then if(Vb.bad[fb]or 0)<os.clock()then Db=ChilliState;if not(Db.reserved[fb])then Fb=ChilliState;if not(Fb.protect(fb,jb))then local db=d(jb);db.uid=fb;if Ub[db.cat]and not Zb[db.cat]then Zb[db.cat]=true;Tb[#Tb+1]=db;else local Ub=Y[26];if Ub.place then local Ub=Y[67];if Ub(vb,db)then xb[#xb+1]=db;end;end;end;end;end;end;end;end;end;qb=Y[64];local Ub,Zb=qb(),0;for fb in next,Ub and type(Ub.EquippedAssets)==" table "and Ub.EquippedAssets or{},nil do Zb+=1;end;Db=0;for fb,fb in pairs(Kb)do Db=if type(fb)==" table "then if fb.Placement then Db else Db+1 else Db;end;Fb,qb=pcall(function()local fb=GameModules;return fb.Bases.GetAssetEquipCapacity(Ub and tonumber(Ub.BaseUpgradeLevel)or 0);end);_b(vb.maxV and vb.maxV<=(vb.minV or 0)and" Max Place Value must be above Min Place Value, nothing will be placed "or(" Eggs placed %d/%d - %d/%d pets equipped, %d in bag "):format(rb,30,Zb,Fb and tonumber(qb)or 0,Db));return rb,xb,Kb,Tb;end;local Kb=wb({name=" PlaceInfo ",gap=2,info=true});Kb.on=function()return L(" Farm ");end;Kb.fn=Sb;Vb.want=function()local Kb,_b,vb,xb=Sb();if Kb>=30 then return;elseif#_b+#xb==0 then return;elseif#xb==0 then if not(cb())then return;end;end;local Sb=Y[26];if Sb.placeFirst~=" Backpack "then local Sb=Y[26];Hb(_b,Sb.placeFirst);end;for Sb,cb in ipairs(xb)do table.insert(_b,Sb,cb);end;return{list=_b,room=30-Kb,recs=vb};end;Vb.run=function(Sb,Kb)local _b=Rb();if not(_b)then return;end;local Rb=Y[11];Rb(" Walking to your pen ");Rb=Vector3.new;if not(tb(_b+Rb(0,3,0),Kb))then return;end;local vb,cb,xb,Tb=Pb(Sb.recs),math.min(Sb.room,#Sb.list),0,0;for Pb=1,cb,1 do if not(Kb())then break;end;Rb=Sb.list[Pb];if Bb(Rb.uid)then _b=false;for Sb=1,8,1 do xb+=1;Pb=vb[xb];if not Pb then break;end;Sb=invokeServerBoolean;if Sb(" RF/EggWorld/AskPlaceEgg ",{Uid=Rb.uid,LocalCFrame=Pb[1]})then Tb+=1;local Sb=Y[42];Sb.placed=Sb.placed+1;_b=true;break;end;end;if not _b then Vb.bad[Rb.uid]=os.clock()+60;end;task.wait(0.25);else Vb.bad[Rb.uid]=os.clock()+20;end;end;Rb=callRequiredModuleMethod;Rb(" Egg "," DoffEggTool ");if Tb>0 then vb=Y[11];vb(" Placed "..Tb.." egg ( s ) "," ok ");end;end;Vb.on=function()local Sb=Y[26];local Vb,Kb=Sb.place;if Vb then Kb=Vb;else Sb=Y[26];Kb=Sb.placeIdx;end;return Kb;end;end);S(" 20_farm#2 ",function()local Sb=wb({name=" Hatch ",gap=2,bad={},info=true});local Vb=Ib[" Auto Hatch & Equip "];local Kb,_b=y(Vb," Auto Hatch "," hatch ",false),ChilliState;local Rb,vb,Pb=_b.nostat,{},ChilliState;local function cb(Bb)local xb=ChilliState;vb.rar=xb.minRar(Bb);end;Vb:Dropdown(" Hatch Min Rarity ",Pb.RANY," Any ",cb,false," Hatch eggs of the chosen rarity and every rarity above it ",Kb);Vb:Slider(" Min Hatch Value ",0,0,0,function(Pb)vb.minV=Pb>0 and Pb or nil;end," log ",nil," Skip eggs worth less than this ( 0 = off ) ",Kb);Vb:Slider(" Max Hatch Value ",0,0,1000,function(Pb)vb.maxV=Pb>0 and Pb<1000000000000 and Pb or nil;end," log ",nil," Only hatch eggs worth less than this, keep the better ones ( far righ+1]=function ( ) p ( ) ;
g ( ) ;
Ub ( ) ;
end ;
xb.ls[#xb.ls+1]=function ( ) for t,Y in ipairs ( Mb ) do
Y.pn.Position=s ( ob ( t ) ) ;
end ;
end ;
Zb.ls[#Zb.ls+1]=wK ;
hb.qSync=function ( ) wK ( ) ;
p ( ) ;
g ( ) ;
Ub ( ) ;
u ( ) ;
end ;
return ub ;
end ;
eb.ConfigTab=function ( t ) local Y=t ;
t=Y.setTab:Section ( "Defaults" ,true ) ;
t:Button ( "Reset to Defaults" , "Reset" ,function ( ) Y:Default ( ) ;
end , "Reset every feature to its built-in default" , "Done!" ) .Quick=false ;
t:Button ( "Turn Off All Toggles" , "Turn Off" ,function ( ) for g,g in ipairs ( Y.Opts ) do
if g.Type== "toggle" then
if g.Value then
if g.Tab~= "Settings" then
if g.Tab~= "Config" then
if g.Tab~= "Quick" then
g:Set ( false ) ;
end ;
end ;
end ;
end ;
end ;
end ;
end , "Switch off every enabled toggle in the feature tabs" , "Done!" ) ;
local g,P=Y:Tab ( "Config" , "Right" ) ,Y:List ( ) ;
t=g:Section ( "Config" ,true ) ;
local q=t:Text ( "Startup Config" , "Startup Config: " ..Y.Startup ) ;
q.NoSave=true ;
local d=t:Toggle ( "Auto Save Config" ,Y.AutoSave,function ( Q ) if not ( Y.ready ) then
return ;
end ;
Y.AutoSave=Q ;
Y:Mgr ( true ) ;
if Q then
Y:Save ( ) ;
end ;
end , "Auto save: " ..Y.Active ) ;
local Q=t:Toggle ( "Auto Load Config" ,Y.AutoLoad,function ( u ) if not ( Y.ready ) then
return ;
end ;
Y.AutoLoad=u ;
Y:Mgr ( true ) ;
if u then
Y:Load ( Y.Startup ) ;
end ;
end , "Auto load: " ..Y.Startup ) ;
d.Skip=true ;
Q.Skip=true ;
t=g:Section ( "Profiles" ,true ) ;
local u=t:Input ( New Co 