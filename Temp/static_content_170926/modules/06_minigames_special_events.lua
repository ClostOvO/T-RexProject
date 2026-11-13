--[[
    ================================================================================
    MODULE 06: MINIGAMES & SPECIAL EVENTS
    Chilli Hub / Steal An Egg Automation Engine
    ================================================================================
    
    DESCRIPTION:
    Handles side events and minigames: automated fishing (cast, reel, claim mastery),
    Shooting Star tracking and catching, Alien Lagoon pearl trading & socketing,
    Banjo Cricket minigame, Away Earnings collection, and Codex index redemption.
    
    KEY REMOTES & MECHANISMS:
    - RF/Fishing/Cast & Reel             = Automated fishing cast and reel
    - RF/Fishing/AskClaimMastery         = Claims fishing mastery rewards
    - RE/ShootingStar/Catch & Claimed    = Catches falling stars in world
    - RF/AlienLagoon/Request & Trade     = Trades void pearls for dark matter
    - RF/AlienGate/Socket                = Sockets alien keys
    - RF/BanjoCricket/AskClaim           = Claims cricket rhythm rewards
    - RF/AwayEarnings/AskCollect         = Collects offline earnings
    - RF/Codex/AskRedeemAll              = Redeems all completed codex entries
    ================================================================================
]]

.CosmicEclipse ");local function B()local qb=Y[26];if qb.alEclipse then if not(Tb)then return;end;else return;end;local Fb,Db=pcall(Tb.Current);if Fb then if type(Db)==" table "then if Db.Active then local Ub,Zb=pcall(Tb.StockLeft);if Ub then if Zb==0 then return nil;end;end;return Db;end;end;end;qb,Db=pcall(Tb.ScheduledWindow,P());Fb=qb and type(Db)==" table "and tonumber(Db.StartsAt);Fb=Fb and(if P()>=(tonumber(Db.EndsAt)or 0)then Fb+1800 else Fb);return Fb and Fb>P()and Fb-P()<=30 and Db or nil;end;local function qb()local Fb=xb[Bb():match(" %d ")or" "];return Bb()==" Alien Lagoon "or type(Fb)==" table "and(tonumber(Fb[1])or 0)<=-10000 or B()~=nil;end;b.save=function()local Fb=getRootPart;local Db,Ub=Fb(),Bb():match(" %d ");if Ub then else Ub=" 1 ";for Fb=3,1,-1 do Ub=if xb[tostring(Fb)]then Ub else tostring(Fb);end;end;if not(Db and r and Yb(Db.Position))then return u(" Fishing "," No water in reach here "," warn ");end;xb[Ub]={Db.Position.X,Db.Position.Y,Db.Position.Z};pcall(writefile,cb,X:JSONEncode(xb));Db=Y[26];Db.alSpot=" Spot "..Ub;b.sp=nil;pcall(b.dd.Set,b.dd,Y[26].alSpot);u(" Fishing "," Spot "..Ub.." saved "..(_b()and" in the Alien Lagoon "or" ")," ok ");end;local function cb(Fb)local Db;for Ub,Ub in ipairs(Fb and Fb:GetDescendants()or{})do Db=if Ub:IsA(" BasePart ")then if Db then if Ub.Size.X*Ub.Size.Z>Db.Size.X*Db.Size.Z then Ub else Db else Ub else Db;end;return Db;end;local Fb=RaycastParams.new();Fb.FilterType=Enum.RaycastFilterType.Exclude;Fb.RespectCanCollide=true;local function Db()local Ub,Zb=_b(),getRootPart;local rb=Zb();local fb,jb=B()~=nil,Y[26];local db=jb.alLuck..Bb()..tostring(Ub)..tostring(fb);jb=(if fb then not fb else xb[Bb():match(" %d ")or" "])or nil;if b.sp then if b.sp.k==db then if b.sp.pad then if b.deck then if b.deck.Parent then return b.sp;end;end;else return b.sp;end;end;end;Zb=type(jb)==" table "and tonumber(jb[3])and(jb[1]>-10000 or Ub);if Zb then fb=Vector3.new;local xb=fb(jb[1],jb[2],jb[3]);local Jb=r and(Yb(xb));b.sp=Jb and{at=xb,aim=Jb,k=db}or nil;return b.sp;end;if qb()then if not(Ub)then return;end;local function xb()local Jb=r and rb and Yb(rb.Position);if Jb then b.sp={at=rb.Position,aim=Jb,k=db};return b.sp;end;end;Zb=workspace:FindFirstChild(" AlienLagoon ");jb,fb=Zb and(Zb:FindFirstChild(" Water ",true)),Vector3.new;local rb,Jb,nb,Qb=fb(-14000,0,16000),ipairs,jb and jb:GetDescendants()or{};for mb,mb in Jb(nb)do if mb:IsA(" BasePart ")then if Qb then local ib,eb=Vector3.new;eb,Qb=Vector3.new,if ib(mb.Position.X-rb.X,0,mb.Position.Z-rb.Z).Magnitude<Vector3.new(Qb.Position.X-rb.X,0,Qb.Position.Z-rb.Z).Magnitude then mb else Qb;else Qb=mb;end;else end;end;if r then if not(Qb)then return xb();end;else return xb();end;rb,nb={},LocalPlayer;w:XI(rb,0,nb.Character,jb);Fb.FilterDescendantsInstances=rb;rb,Jb,nb=math.max(Qb.Size.X,Qb.Size.Z)/2,ipairs,{5,10,16};for mb,ib in Jb(nb)do for Jb=0,345,15 do mb=CFrame.Angles(0,math.rad(Jb),0).LookVector;local nb,nb,nb=Vector3.new,Vector3.new,workspace:Raycast(Vector3.new(Qb.Position.X,Qb.Position.Y+80,Qb.Position.Z)+mb*(rb+ib),Vector3.new(0,-160,0),Fb);Jb=nil;if nb then local Fb;Fb,Jb=Vector3.new,Yb(nb.Position+Vector3.new(0,3,0));else Jb=nb;end;if Jb then local Fb,rb={};rb,Fb.at=Vector3.new,nb.Position+Vector3.new(0,3,0);Fb.aim=Jb;Fb.k=db;b.sp=Fb;return b.sp;end;end;end;return xb();end;fb=workspace.World.Build:FindFirstChild(" AlienBiomeZone ");Ub=cb(fb and fb:FindFirstChild(" Dock ",true));if r then if not Ub then return;end;else return;end;if b.deck~=Ub then b.deck,b.dc0=Ub,Ub.CanCollide;end;local cb,xb,Fb,rb,fb=math.max(Ub.Size.X,Ub.Size.Z),Ub.Position.Y+Ub.Size.Y/2+3,Ub.Size.X>Ub.Size.Z and Ub.CFrame.RightVector or Ub.CFrame.LookVector,ipairs,{0.4,-0.4,0,0.2,-0.2};for Jb,nb in rb(fb)do Jb=Vector3.new;Zb,jb=Vector3.new,Jb(Ub.Position.X,xb,Ub.Position.Z)+Vector3.new(Fb.X,0,Fb.Z)*cb*nb;Jb=Yb(jb);if Jb then b.sp={at=jb,aim=Jb,k=db,pad=true};return b.sp;end;end;end;table.insert(ChilliState.cleanup,function()if b.deck then pcall(function()b.deck.CanCollide=b.dc0;end);end;end);local function Yb(cb,xb)local Fb=getHumanoid;local Ub,Zb=Fb(),getRootPart;local rb,fb,jb=Zb(),-1;for db,db in ipairs(Hb(r.IsRod))do Zb=n and n.TierOf(db:GetAttribute(" GearName "))or 0;if Zb>fb then fb,jb=Zb,db;else end;end;if Ub then if rb then if not(jb)then return;end;else return;end;else return;end;Fb=LocalPlayer;if jb.Parent~=Fb.Character then pcall(Ub.EquipTool,Ub,jb);if not(Vb(0.3,xb))then return;end;end;if cb.pad then if b.deck then b.deck.CanCollide=true;end;end;Fb,Zb=setPlayerCFrame,CFrame.new;Fb(Zb(cb.at,Vector3.new(cb.aim.X,cb.at.Y,cb.aim.Z)));local n,fb,db=Ab(),zb(" Ui "),zb(" Line ");local zb=vb(fb);rb,Ub=pcall(require,N.Shared.Flags.FishingFlags);R(" RE/Fishing/Hold ");Zb,Fb=os.clock(),false;while os.clock()-Zb<n do if not(xb())then if fb then pcall(fb.ShowCharge,false);end;zb();R(" RE/Fishing/Cancel ");return;end;local Ab,vb=(os.clock()-Zb-n+0.25)/0.2,LocalPlayer;local Jb,nb=vb.Character;if Jb then vb=LocalPlayer;nb=vb.Character:FindFirstChild(" Head ");else nb=Jb;end;if fb then if Ab>=0 then if nb then if Fb then else pcall(fb.ShowCharge,true,rb and Ub.PerfectMin:Get()or 0.8,rb and Ub.PerfectMax:Get()or 0.95);Fb=true;end;Jb=r.ChargeAt(n)*math.min(Ab,1);pcall(fb.SetCharge,Jb,r.LuckText(r.LuckFor(Jb)),r.IsPerfect(Jb),Pb(nb.Position));else end;else end;else end;Ab=HeartbeatWait;Ab();end;rb=LocalPlayer;Ub,Zb=rb.Character;if Ub then Fb=LocalPlayer;Zb=Fb.Character:FindFirstChild(" Head ");else Zb=Ub;end;if fb then pcall(fb.ShowCharge,false);if Zb then if r.IsPerfect(r.ChargeAt(n))then pcall(fb.Perfect,Pb(Zb.Position+Vector3.new(0,2.6,0)));end;end;end;rb=invokeServerWithTimeout;Ub,Fb,Zb=rb(" RF/Fishing/Cast ",n,cb.aim);if type(Fb)~=" table "then zb();b.fail=(b.fail or 0)+1;b.sp=nil;rb=Y[11];rb(" Fishing: "..tostring(Zb or" no answer ")," warn ");return;end;b.fail=0;local r=jb:FindFirstChild(" RodTip ",true);local Ab,vb=r and r:IsA(" Attachment ")and r.WorldPosition;if Ab then vb=Ab;else Zb=nil;Zb,vb=Vector3.new,cb.at+Vector3.new(0,4,0);end;local Pb,Ub=false;if db then Pb,Ub=pcall(db.Spawn,r,vb);else end;Ub=Pb and Ub;local Pb,jb,Jb=Ub or nil,true,false;if Pb then task.spawn(function()pcall(db.Fly,Pb,vb,cb.aim,0.75,function()local vb=jb;return vb;end);local vb=os.clock();while true do local Ub=jb and Pb.Parent;if not Ub then break;end;pcall(Jb and db.Thrash or db.Float,Pb,cb.aim,Jb and 1 or os.clock()-vb,0);task.wait(Jb and 0.06 or nil);end;end);end;local function vb(cb)jb=false;if Pb then task.spawn(function()pcall(db.Return,Pb,r,0.3);Pb:Destroy();end);end;task.delay(cb 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;end;local b,t=pcall(h);if not(b)then Nb.ChilliFinderErr=e(t);end;task.wait((#ab.inbox>0 or ab.gate)and 0 or 0.2);end;end);Nb.ChilliFinderPanelCleanup=function()Nb.ChilliFinderHidden=nil;pcall(Gb);Sb=false;bK();if Nb.ChilliFinderOwner==ab.me then Nb.ChilliFinderOwner=nil;end;if Nb.ChilliFinderPanelClose==nK then Nb.ChilliFinderPanelClose=nil;end;for b,b in ipairs(Xb)do pcall(b.Disconnect,b);end;QK();if Qb then ib();end;Nb.ChilliFinderPanelCleanup=nil;end;end);H.ChilliFinderBeforeTeleport=function()local b=ChilliState;if b.beforeTeleport then pcall(ChilliState.beforeTeleport);end;end;table.insert(ChilliState.cleanup,function()if H.ChilliFinderPanelCleanup then H.ChilliFinderPanelCleanup();end;end);S(" 53_promo#1 ",function()local b,h,t=Color3.fromRGB," https://discord.gg/CJK4bs2mgT ",{{" #FF6A55 "," New Scripts &amp ;
Updates "," Patch notes and new game scripts are posted there first. "},{" #FFB054 "," Giveaways "," Member giveaways and events are announced in the server. "},{" #9AA3FF "," Support "," Ask for help, report bugs and get answers from the team. "},{" #6EE49C "," Suggestions "," Request features and vote on what gets added next. "}};local R,c,B=11.4+#t*3.35+2.4+0.4,{Perks={}},0;local function x()local T=pcall(setclipboard or toclipboard,h);u(T and" Discord Link Copied "or" Discord Link ",h);if not(c.Copy)then return;end;B+=1;local F=B;c.Copy.Set({Text=T and" <b>Copied!</b> "or" <b>See Notice</b> ",Background=T and" #2EB070 "or" #5865F2 "});task.delay(1.8,function()if F==B then c.Copy.Set({Text=" <b>Copy Link</b> ",Background=" #5865F2 "});end;end);end;local function B(T,...)local F={...};for U,U in ipairs(F)do U.Set({Width=T});end;end;local function T(F,U,r)U=math.max(U/math.max(r,1),14)-0.4;B(U,c.Hero,c.Invite,c.Header,c.Tip);B(math.max(1,U-5.2-0.5),c.Title,c.Subtitle,c.Members);B(math.max(1,U-6.4-1.5),c.Label,c.Link);r,F=c.Copy.Set,{};F.X=U-6.4-0.5;r(F);for F,F in ipairs(c.Perks)do B(U,F[1]);B(math.max(1,U-1.2),F[2],F[3]);end;end;local function B(F)local U=ColorSequenceKeypoint.new;local function r(f,d,n,Q,m,e,L,a)a=a or{};a.Parent,a.X,a.Y,a.Height,a.Scale,a.Text,a.Color,a.Wrap=f,d,n,Q,m,e,L,a.Wrap or false;return F:Text(a);end;c.Hero=F:Frame({Name=" Hero ",X=0.2,Y=0.2,Height=5.4,Background=" #FFFFFF ",Gradient=ColorSequence.new(b(74,24,18),b(14,11,15)),GradientRotation=0,Corner=0.35,StrokeColor=" #FF6A40 ",StrokeThickness=0.0909,StrokeTransparency=0.55});F:Image({Parent=c.Hero,X=0.5,Y=0.6000000000000001,Width=4.2,Height=4.2,Image=z(" logo ")});c.Title=r(c.Hero,5.2,0.45,1.6,1.45," <b>Chilli Hub</b> ",nil,{Gradient=ColorSequence.new({U(0,b(255,218,96)),U(0.5,b(255,152,60)),U(1,b(255,82,64))}),GradientRotation=0,TextStrokeTransparency=1});c.Subtitle=r(c.Hero,5.2,2.1,1,nil," Official Discord Community "," #DCDCE8 ");c.Members=r(c.Hero,5.2,3.3,1.2,nil,(" <font color=\ "#6EE49C\">%s</font> <b>%s</b> <font color=\"#B8B8CC\">Members</font>" ) :format ( utf8.char ( 9679 ) , "180K+" ) ) ;
c.Invite=F:Frame ( {
Name= "Invite" ,X=0.2,Y=6.2,Height=3.6,BackgroundTransparency=0.5,Corner=0.35,StrokeColor= "#5865F2" ,StrokeThickness=0.0909,StrokeTransparency=0.35
} ) ;
c.Label=r ( c.Invite,0.6,0.35,0.9,0.78, "<b>INVITE LINK</b>" , "#9C9CB4" ) ;
c.Link=r ( c.Invite,0.6,1.35,1.6,1.05,h:sub ( 9 ) ,nil, {
Font= "code"
} ) ;
c.Copy=F:Button ( {
Parent=c.Invite,Y=0.8,Width=6.4,Height=2,Text= "<b>Copy Link</b>" ,Background= "#5865F2" ,BackgroundTransparency=0,HoverTransparency=0.15,PressTransparency=0.3,StrokeColor= "#9AA3FF" ,StrokeThickness=0.0909,Callback=x
} ) ;
c.Header=r ( nil,0.30000000000000004,10.45,1,0.8, "<b>WHAT YOU GET</b>" , "#9C9CB4" ) ;
for h,f in ipairs ( t ) do
U=F:Frame ( {
Name= "Perk" ,X=0.2,Y=11.4+ ( h-1 ) *3.35+0.2,Height=3,BackgroundTransparency=0.68,Corner=0.35
} ) ;
F:Frame ( {
Parent=U,X=0.3,Y=0.45,Width=0.22,Height=2.1,Background=f[1],Corner=0.11
} ) ;
c.Perks[h]= {
U,r ( U,0.85,0.3,1.1,nil, "<b>" ..f[2].. "</b>" ,f[1] ) ,r ( U,0.85,1.35,1.5,0.86,f[3], "#C8C8D8" , {
Wrap=true
} )
} ;
end ;
c.Tip=r ( nil,0.30000000000000004,R-2.2-0.2,2,0.8, "Paste the copied link into your browser or the Discord app to join." , "#8A8AA2" , {
Wrap=true
} ) ;
F:SetContentLines ( R ) ;
F:OnResize ( T ) ;
end ;
local h,t=Ib.Community, {
Name= "Discord" ,ShowTitle=false,Layout= "free"
} ;
t.Style,t.Build= {
TextScale=0.84,LineHeight=1.1,MinLines=math.ceil ( R ) ,MaxLines=math.ceil ( R ) ,BackgroundTransparency=0.5,ScrollBarColor=b ( 170,174,184 ) ,TextColor=b ( 255,255,255 ) ,TextStrokeTransparency=0.7
} ,B ;
h:Surface ( t ) ;
Ib.Community:Button ( "Copy Discord Link" ,nil,x ) ;
end ) ;
S ( "53_promo#2" ,function ( ) local b,h,t,R,c,B,x,T,F,U,r,f= "#E4E6EC" ,3.05,1.2999999999999998,6.949999999999999,5.8999999999999995,13.999999999999998,17.65, {
{
"Smoother & faster" , "Less lag, quick to load."
} , {
"More steal methods" , "Teleport, Fast tween and more."
} , {
"Steal from players" , "Hits whoever takes your egg."
} , {
"Easy setup" , "Bring your Chilli config over."
}
} , {
} , {
} ,false,0 ;
local function d ( ) local n=pcall ( setclipboard or toclipboard, "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/tienkhanh1/Venyx/main/VenyxHub\"))()" ) ;
u ( n and "Venyx Loader Copied" or "Venyx Loader" ,n and "Paste it into your executor to run Venyx." or "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/tienkhanh1/Venyx/main/VenyxHub\"))()" ) ;
f+=1 ;
local Q=f ;
local m,e=F.Copy.Set, {
} ;
e.Text=n and "Copied" or "See notice" ;
m ( e ) ;
task.delay ( 1.8,function ( ) if Q==f then
F.Copy.Set ( {
Text= "Copy"
} ) ;
end ;
end ) ;
end ;
local f,n= {
A= "Steal / Auto Steal/Auto steal/" ,F= "Steal / Auto Steal/Filter/" ,H= "Steal / Auto Steal/Auto hop server/" ,B= "Event / Butterfly/Butterfly bloom/" ,M= "Event / Butterfly/Butterfly machine/" ,C= "Event / Butterfly/Wisp companion/" ,U= "Farm / Mutate/Auto mutate/" ,V= "Farm / Mutate/Mutate filter/" ,G= "Farm / Pen/Auto place/" ,T= "Farm / Pen/Auto hatch/" ,D= "Farm / Treadmill/Treadmill/" ,O= "Farm / Treadmill/Progress/" ,S= "Farm / Sell/Pets/" ,E= "Farm / Sell/Eggs/" ,J= "Farm / Sell/Favorite/" ,X= "Farm / Fuse/Fuse machine/" ,Y= "Farm / Fuse/Fuse filter/" ,Z= "Event / AA/" ,N= "Player / ESP/" ,I= "Player / Move/" ,Cb= "Player / Combat/" ,Wb= "System / Webhook/" ,Sv= "System / Server/" ,Op= "System / Optimizer/" ,St= "Steal / Egg Predictor/Egg showcase/" ,Ss= "Event / Star/Shooting Star/"
} , "@Farm|Auto Steal\10Target Areas=F:Zones:z|Min Rarity=F:Rarities:r|Min Steal Value=F:Min value /s:m|Target Specific Eggs=F:Only these eggs:e|Steal Missing Index Eggs=A:|Drop Eggs At Safe Zone=A:|Steal Priority=F:Steal first:Best Rarity>Best rarity,Biggest Weight>Biggest,Best Mutation>Bestb.Frame,X=0,Y=0,Width=Db,Height=Db,Corner=0.35,Background=" #000000 ",BackgroundTransparency=0.45,StrokeThickness=fb,StrokeTransparency=0,Visible=false}),Name=Lb:Text({Parent=nb.Frame,X=0,Y=0,Width=1,Height=1.1,Scale=1.05,Wrap=false,Font=Tb,TextStrokeTransparency=1,Visible=false}),Chip=Lb:Frame({Parent=nb.Frame,X=0,Y=0,Width=Zb,Height=rb,Corner=0.3,Background=" #000000 ",BackgroundTransparency=0.35,StrokeThickness=fb,StrokeTransparency=0,Visible=false})};ab.ChipText=Lb:Text({Parent=ab.Chip,X=0,Y=0,Width=Zb,Height=rb,Scale=0.78,Wrap=false,Align=" Center ",VAlign=" center ",Font=qb,TextStrokeTransparency=1});ab.Detail=Lb:Text({Parent=nb.Frame,X=0,Y=0,Width=1,Height=1,Scale=0.92,Wrap=false,Visible=false});mb(ab.Name);mb(ab.Detail);return ab;end;local function fb(mb,Lb,ab,Eb,ub)mb.Icon.Set({Visible=ub,X=Fb,Y=Lb+0.25,Width=Db,Height=Db});local Wb,pb=mb.Name.Set,{Visible=ub,X=ab,Y=Lb+0.3};pb.Width,pb.Height=math.max(1,Eb-Zb-0.3),1.1;Wb(pb);mb.Chip.Set({Visible=ub,X=ab+Eb-Zb,Y=Lb+0.35,Width=Zb,Height=rb});mb.ChipText.Set({X=0,Y=0,Width=Zb,Height=rb});mb.Detail.Set({Visible=ub,X=ab,Y=Lb+1.4,Width=Eb,Height=1});end;local function Zb()if nb.S then if nb.U<=0 then return;end;else return;end;local rb=math.max(4,nb.U-Fb*2);local mb=rb/4;for Lb,ab in ipairs(nb.Stats)do local Eb=Fb+(Lb-1)*mb;ab.Icon.Set({X=Eb,Y=0.35,Width=1.7,Height=1.7});local ub,Wb=ab.Val.Set,{X=Eb+2,Y=0.25};Wb.Width,Wb.Height=math.max(1,mb-2.1),1.1;ub(Wb);Lb,Wb=ab.Lab.Set,{X=Eb+2,Y=1.3};Wb.Width,Wb.Height=math.max(1,mb-2.1),0.9;Lb(Wb);end;mb=Fb+Db+0.5;local Db,Lb=math.max(1,nb.U-mb-0.5),2.6;nb.Div1.Set({X=Fb,Y=2.45,Width=rb,Height=0.06});nb.BestTag.Set({Visible=nb.HasBest,X=Fb,Y=2.7,Width=rb,Height=1});nb.BestBg.Set({Visible=nb.HasBest,X=Fb-0.25,Y=3.6500000000000004,Width=rb+0.5,Height=Ub+0.15});if nb.HasBest then fb(nb.Best,3.7,mb,Db,true);Lb+=1.1+Ub+0.75;else fb(nb.Best,Lb,mb,Db,false);end;nb.Div2.Set({Visible=nb.HasBest and nb.N>0,X=Fb,Y=Lb-0.35,Width=rb,Height=0.06});nb.EggTag.Set({Visible=nb.N>0,X=Fb,Y=Lb-0.1,Width=rb,Height=1});Lb=if nb.N>0 then Lb+1 else Lb;for ab,Eb in ipairs(nb.Rows)do fb(Eb,Lb+(ab-1)*Ub,mb,Db,ab<=nb.N);end;Db=Lb+math.max(nb.N,nb.HasBest and 0 or 1)*Ub+0.15;nb.Empty.Set({Visible=nb.N==0 and not nb.HasBest,X=Fb,Y=Lb+0.6,Width=rb,Height=1});nb.Frame.Set({X=0,Y=0,Width=nb.U,Height=Db});if math.abs(Db-(nb.H or-1))>0.01 then nb.H=Db;nb.S:SetContentLines(Db);end;end;local function Fb(Db)local Ub,rb={},0;for fb,fb in next,Db.muts,nil do rb+=fb;end;local fb=0;for mb,mb in next,Db.eggs,nil do fb+=mb;end;local mb,Lb=Vb();local Vb,ab=ipairs,{Db.n,mb or Db.pearls,fb,Lb or rb};for rb,fb in Vb(ab)do Lb,mb=nb.Stats[rb].Val.Set,{};mb.Text=" <font color=\ "#" ..Jb[rb][3].. "\"><b>" .._b ( fb ) .. "</b></font>" ;
Lb ( mb ) ;
end ;
mb,Vb=ipairs, {
Db.eggs,Db.pets
} ;
for rb,fb in mb ( Vb ) do
for Eb,ub in next,fb,nil do
rb,ab,Lb=vb ( Eb ) ;
Ub[#Ub+1]= {
n=Eb,k=ub,img=rb,rar=ab,col=ib ( Lb )
} ;
end ;
end ;
table.sort ( Ub,function ( vb,rb ) return vb.k>rb.k or vb.k==rb.k and vb.n<rb.n ;
end ) ;
local vb,rb,fb,Eb,ub=h ( Db ) ;
nb.HasBest=vb~=nil ;
if vb then
Lb,mb,ab=ib ( ub ) ,nb.Best.Icon.Set, {
} ;
ab.Image,ab.StrokeColor=Eb or "" ,Lb ;
mb ( ab ) ;
Db,Vb=nb.Best.Name.Set, {
} ;
Vb.Text= "<b>" ..Qb ( vb ) .. "</b>" ;
Db ( Vb ) ;
nb.Best.Chip.Set ( {
StrokeColor=Lb
} ) ;
nb.Best.ChipText.Set ( {
Text=Qb ( rb or "" ) ,Color=Color3.fromHex ( Lb )
} ) ;
local h,Vb=nb.Best.Detail.Set, {
} ;
Vb.Text=fb and "<font color=\"#3CFF5A\"><b>" ..Pb ( fb.v ) .. "</b></font>" .. ( fb.s and " <font color=\"" ..jb.. "\">" ..cb ( fb ) .. "</font>" or "" ) or "" ;
h ( Vb ) ;
end ;
nb.N=math.min ( #Ub,db ) ;
for h=1,nb.N,1 do
vb,rb=Ub[h],nb.Rows[h] ;
rb.Icon.Set ( {
Image=vb.img or "" ,StrokeColor=vb.col
} ) ;
Lb,ab=rb.Name.Set, {
} ;
ab.Text= "<b>" ..Qb ( vb.n ) .. "</b>" ;
Lb ( ab ) ;
rb.Chip.Set ( {
StrokeColor=vb.col
} ) ;
ub,h=rb.ChipText.Set, {
Text= "x" .._b ( vb.k )
} ;
h.Color=Color3.fromHex ( vb.col ) ;
ub ( h ) ;
mb,h=rb.Detail.Set, {
} ;
h.Text= "<font color=\"" ..vb.col.. "\"><b>" ..Qb ( vb.rar or "" ) .. "</b></font>" ;
mb ( h ) ;
end ;
nb.Want=true ;
end ;
nb.Canvas=xb:Surface ( {
Name= "Fishing History" ,Layout= "free" ,Style= {
TextScale=1,LineHeight=1.1,MinLines=2,MaxLines=40,AutoHeight=true,BackgroundTransparency=0.5,TextColor=Color3.fromRGB ( 255,255,255 ) ,TextStrokeTransparency=0.7
} ,Build=function ( h ) nb.S=h ;
nb.Frame=h:Frame ( {
X=0,Y=0,Width=1,Height=2,Background= "#000000" ,BackgroundTransparency=1
} ) ;
for Vb,_b in ipairs ( Jb ) do
local vb,Pb,cb=nb.Stats, {
} , {
Parent=nb.Frame,X=0,Y=0,Width=1.7,Height=1.7,Image= "rbxassetid://" .._b[1],Background= "#000000" ,BackgroundTransparency=1
} ;
Pb.Icon=h:Image ( cb ) ;
cb= {
Parent=nb.Frame,X=0,Y=0,Width=1,Height=1.1,Scale=1.1,Wrap=false,Font=Tb,TextStrokeTransparency=1
} ;
Pb.Val=h:Text ( cb ) ;
cb= {
Parent=nb.Frame,X=0,Y=0,Width=1,Height=0.9,Scale=0.78,Wrap=false,Text= "<font color=\"" ..jb.. "\">" .._b[2].. "</font>" ,TextStrokeTransparency=1
} ;
Pb.Lab=h:Text ( cb ) ;
vb[Vb]=Pb ;
end ;
nb.Div1=h:Frame ( {
Parent=nb.Frame,X=0,Y=0,Width=1,Height=0.06,Background= "#FFFFFF" ,BackgroundTransparency=0.85
} ) ;
nb.BestTag=h:Text ( {
Parent=nb.Frame,X=0,Y=0,Width=1,Height=1,Scale=0.82,Wrap=false,Font=qb,Text= "<font color=\"#FFD27A\">BEST EGG</font>" ,TextStrokeTransparency=1,Visible=false
} ) ;
nb.BestBg=h:Frame ( {
Parent=nb.Frame,X=0,Y=0,Width=1,Height=1,Corner=0.4,Background= "#FFD27A" ,BackgroundTransparency=0.88,StrokeColor= "#FFD27A" ,StrokeThickness=0.0909,StrokeTransparency=0.35,Visible=false
} ) ;
nb.Best=eb ( h ) ;
nb.EggTag=h:Text ( {
Parent=nb.Frame,X=0,Y=0,Width=1,Height=1,Scale=0.82,Wrap=false,Font=qb,Text= "<font color=\"#8CE8FF\">EGGS CAUGHT</font>" ,TextStrokeTransparency=1,Visible=false
} ) ;
nb.Div2=h:Frame ( {
Parent=nb.Frame,X=0,Y=0,Width=1,Height=0.06,Background= "#FFFFFF" ,BackgroundTransparency=0.85,Visible=false
} ) ;
for Vb=1,db,1 do
nb.Rows[Vb]=eb ( h ) ;
end ;
nb.Empty=h:Text ( {
Parent=nb.Frame,X=0,Y=0,Width=1,Height=1,Scale=0.92,Wrap=false,Align= "Center" ,Text= "<font color=\"" ..jb.. "\">No eggs caught yet</font>" ,Visible=false
} ) ;
h:OnResize ( function ( h,h,Vb ) if h~=nb.W then
nb.W,nb.U=h,h/math.max ( Vb,1 ) ;
nb.Want=true ;
end ;
end ) ;
nb.Dirty=nb.L~=nil ;
end
} ) ;
xb=RunService ;
V ( xb.Heartbeat,function ( ) if nb.Dirty then
if nb.S then
if nb.L then
nb.Dirty=false ;
pcall ( Fb,nb.L ) ;
end ;
end ;
end ;
if nb.Want then
if nb.S then
nb.Want=false ;
pcall ( Zb ) ;
end ;
end ;
end ) ;
return function ( h ) nb.L=h ;
nb.Dirty=true ;
end ;
end ;
b.onLog=Bb ( Ib[ "Alien Biome" ] ) ;
b.onLog ( ( Rb ( ) ) ) ;
local function h ( ) local Vb=Y[26] ;
local _b,vb=Vb.rot ;
if _b then
Vb=Y[26] ;
vb=Vb.fish ;
else
vb=_b ;
end ;
Vb=nil ;
if vb then
_b=ChilliState ;
Vb=_b.treadOn ;
else
Vb=vb ;
end ;
vb=nilon.X ) ;
end ;
end ) ;
Kb ( b[7].InputEnded,function ( P8 ) local B8=U8 and ( P8==U8 or P8.UserInputType==FK.MouseButton1 ) ;
if B8 then
U8=nil ;
j8 ( x8 ( Ub[c8] ) ) ;
mb ( ) ;
hK ( ) ;
end ;
end ) ;
Kb ( f8.FocusLost,function ( ) local FK=F8 ( f8.Text ) ;
if FK then
Ub[c8]=FK ;
mb ( ) ;
else
tK ( D8 ) ;
end ;
f8.Text=q8 ( Ub[c8] ) ;
hK ( ) ;
end ) ;
r8= {
f=Z8,sync=function ( ) if not ( U8 ) then
j8 ( x8 ( Ub[c8] ) ) ;
end ;
if not ( f8:IsFocused ( ) ) then
PK ( f8,q8 ( Ub[c8] ) ) ;
end ;
end
} ;
return r8 ;
end ;
G8=dK ;
G8.sl= {
force=v8 ( AK, "gap" ,t8.force,function ( FK ) return FK/60 ;
end ,function ( FK ) return b[20] ( FK*60+0.5 ) ;
end ,rb,function ( FK ) FK=FK:lower ( ) :gsub ( "[%ss]" , "" ) ;
local P8=FK== "off" and 0 or L ( FK ) ;
return P8 and h ( b[20] ( P8+0.5 ) ,0,60 ) ;
end , "Type seconds from 0 to 60, like 5" ) ,min=v8 ( sK, "min" ,t8.min,function ( FK ) return h ( math.log ( FK/5000000000 ) /5.298317366548036,0,1 ) ;
end ,function ( FK ) local P8=5000000000*200^FK ;
FK=10^b[20] ( math.log10 ( P8 ) -1 ) ;
return h ( b[20] ( P8/FK+0.5 ) *FK,5000000000,1000000000000 ) ;
end ,fb,function ( FK ) local P8=Jb ( FK ) ;
return P8 and ( b[21] ( 5000000000,P8 ) ) ;
end , "Type a value like 50B or 1.5T (5B/s or more)" )
} ;
v8=zb ( KK,Q ) ;
if v8 then
v8.Color=yb.Head ;
v8.Rotation=0 ;
end ;
dK.hg=v8 ;
s8=U ( KK, "Title" ) ;
PK ( s8, "Chilli Finder" ) ;
if s8 then
g8= {
edge=l ( KK,2,nil,t )
} ;
g8.edge.Enabled=false ;
uK[14]=a ;
uK[15]=Q ;
uK[13]= {
} ;
uK[13].r=-11 ;
uK[13].Color=Mb ( 0,b[12] ( 225,170,255 ) ,0.5,b[12] ( 250,225,255 ) ,1,b[12] ( 190,120,255 ) ) ;
uK[16]= ( uK[14] ( uK[15],uK[13],g8.edge ) ) ;
g8.eg=uK[16] ;
uK[18]=a ;
uK[17]= {
} ;
uK[17].bt=1 ;
uK[17].Image= "rbxassetid://100155632293857" ;
uK[17].ImageColor3=R ;
uK[17].ScaleType=b[11].ScaleType.Stretch ;
uK[17].a=c ;
uK[17].z=b[21] ( 1,s8.ZIndex-1 ) ;
uK[17].v=false ;
uK[19]= ( uK[18] ( "ImageLabel" ,uK[17],s8.Parent ) ) ;
g8.ink=uK[19] ;
dK.glx=g8 ;
end ;
local function Jb ( Mb ) if ob ( ) then
return false ;
end ;
if ab.who then
tK ( "No active booking. Book hours at chillihub.pro" ) ;
else
ab.drawer= "sign" ;
tK ( Mb ) ;
end ;
return true ;
end ;
v8=RK ( U ( KK, "PlusEquip" ) ) ;
if v8 then
Y8=v8.b ;
p ( Y8,y ( c,0.85,0.5,0.24,0.5 ) ) ;
uK[20]=v8.l ;
uK[21]= ( b[16] ( 0.84,0.62 ) ) ;
uK[20].Size=uK[21] ;
xK ( v8 ) ;
local Mb,FK,P8=KK.AnchorPoint,KK.Size,KK.Position ;
uK[25]=RK ;
uK[23]=p ;
uK[24]=Y8:Clone ( ) ;
uK[22]= {
} ;
uK[22].a=b[13] ( 1,1 ) ;
uK[22].v=false ;
uK[22].z=KK.ZIndex-1 ;
uK[22].p=b[16] ( P8.X.Scale+FK.X.Scale* ( 1-Mb.X ) -FK.X.Scale*0.03,P8.Y.Scale-FK.Y.Scale*Mb.Y+FK.Y.Scale*0.24 ) ;
uK[22].s=b[16] ( FK.X.Scale*0.29,FK.Y.Scale*0.8 ) ;
g8= ( uK[25] ( uK[23] ( uK[24],uK[22],oK ) ) ) ;
p ( g8.l,y ( c,0.5,0.35,0.88,0.4, {
rt=true
} ) ) ;
vK ( g8,HK ) ;
xK ( g8 ) ;
qK ( g8.b,function ( ) if ob ( ) then
Ub.list= ( Ub.list+1 ) %3 ;
mb ( ) ;
OK ( ) ;
end ;
end ) ;
aK ( g8.b ) ;
dK.lb=g8 ;
aK ( Y8 ) ;
local Mb=0 ;
local function FK ( ) local aK= {
} ;
if b[19] ( ) -Mb<0.25 then
return ;
end ;
aK[1]= ( b[19] ( ) ) ;
Mb=aK[1] ;
BK ( ) ;
if Jb ( "Sign in with your chillihub.pro account to use Auto Join" ) then
if not ( ab.who ) then
ab.view=nil ;
end ;
return ;
end ;
ab.auto=not ab.auto ;
ab.autoAt=_b ( ) *1000 ;
OK ( ) ;
if not ( ab.auto ) then
pcall ( function ( ) b[5]:SetTeleportSetting ( "__ChilliFinderAuto" ,false ) ;
end ) ;
end ;
hK ( ) ;
end ;
Kb ( Y8.Activated,FK ) ;
Kb ( Y8.InputBegan,function ( Mb ) if DK ( Mb ) then
FK ( ) ;
end ;
end ) ;
end ;
for Mb,Mb in ipairs ( yK:GetDescendants ( ) ) do
if Mb:IsA ( "ImageLabel" ) then
Mb:Destroy ( ) ;
elseif
Mb:IsA ( "ImageButton" ) then
Mb:Destroy ( ) ;
end ;
end ;
Y8=RK ( yK ) ;
if Y8.l then
if Y8.l:IsA ( "TextLabel" ) then
p ( Y8.l, {
v=true,rt=false,t= ">"
} ) ;
end ;
end ;
xK ( Y8 ) ;
qK ( yK,nK ) ;
Y8=U ( MK, "Icon" ) ;
if Y8 then
p ( Y8,y ( c,0.09,0.5,0.15,1.3 ) ) ;
end ;
uK[27]=p ;
uK[28]=CK ;
uK[26]= {
} ;
uK[26].a=T ;
uK[26].xa=d ;
uK[26].s=b[16] ( 0.5,0.4 ) ;
uK[26].p=b[16] ( 0.18,0.3 ) ;
uK[27] ( uK[28],uK[26] ) ;
if not ( zb ( CK,Q ) ) then
b[10] ( Q,CK ) ;
end ;
uK[30]=p ;
uK[31]=CK:Clone ( ) ;
uK[29]= {
} ;
uK[29].Name= "Value" ;
uK[29].s=b[16] ( 0.5,0.36 ) ;
uK[29].p=b[16] ( 0.18,0.72 ) ;
Y8= ( uK[30] ( uK[31],uK[29],MK ) ) ;
zb ( Y8,Q ) :Destroy ( ) ;
Y8.RichText=true ;
p ( lK,y ( x,0.975,0.5,0.2,0.7 ) ) ;
uK[32]=RK ( lK ) .l ;
uK[33]= ( b[16] ( 0.8,0.56 ) ) ;
uK[32].Size=uK[33] ;
Yb ( U ( MK, "Btns" ) ) ;
pK.Size=w8 ( pK.Size,0.48 ) ;
pK.Visible=false ;
pK.Parent=nil ;
dK.cards= {
} ;
for Yb=1,30,1 do
g8=p ( pK:Clone ( ) , {
v=false,o=Yb
} ,UK ) ;
local Mb,BK=U ( g8, "Spacer" ) , {
f=g8
} ;
BK.icon=U ( Mb, "Icon" ) ;
BK.name=U ( Mb, "TextLabel" ) ;
BK.val=U ( Mb, "Value" ) ;
BK.b=RK ( U ( Mb, "Unequip" ) ) ;
if BK.icon then
uK[37]=a ;
uK[35]=y ;
uK[36]=c ;
uK[34]= {
} ;
uK[34].bt=1 ;
uK[34].t= "GONE" ;
uK[34].tc=b[12] ( 255,62,62 ) ;
uK[34].ts=true ;
uK[34].z=BK.icon.ZIndex+1 ;
uK[34].v=false ;
uK[34].ff=BK.name.FontFace ;
G8= ( uK[37] ( "TextLabel" ,uK[35] ( uK[36],0.5,0.5,0.92,0.22,uK[34] ) ,BK.icon ) ) ;
KK= ( zb ( BK.name,m ) ) ;
KK=KK and KK:Clone ( ) or b[10] ( m ) ;
uK[38]= ( b[12] ( 45,8,12 ) ) ;
KK.Color=uK[38] ;
KK.Parent=G8 ;
BK.gone=G8 ;
end ;
BK.ng=zb ( BK.name,Q ) ;
uK[40]=p ;
uK[41]=BK.name ;
uK[39]= {
} ;
uK[39].ts=false ;
uK[39].tt=b[11].TextTruncate.AtEnd ;
uK[39].s=b[16] ( 0.585,0.4 ) ;
uK[40] ( uK[41],uK[39] ) ;
uK[43]=p ;
uK[44]=BK.val:Clone ( ) ;
uK[42]= {
} ;
uK[42].rt=false ;
uK[42].ts=false ;
uK[42].a=b[13] ( 0.5,1 ) ;
uK[42].p=b[16] ( 0.09,0.97 ) ;
uK[42].s=b[16] ( 0,0.3 ) ;
uK[42].AutomaticSize=b[11].AutomaticSize.X ;
uK[42].xa=f ;
uK[42].z=BK.icon and BK.icon.ZIndex+1 or BK.val.ZIndex ;
uK[42].v=false ;
uK[45]= ( uK[43] ( uK[44],uK[42],Mb ) ) ;
BK.mh=uK[45] ;
uK[46]= ( b[10] ( Q,BK.mh ) ) ;
BK.mg=uK[46] ;
xK ( BK.b ) ;
qK ( BK.b.b,function ( ) local U=BK.e ;
if not ( U ) then
return ;
end ;
if Jb ( "Sign in with your chillihub.pro account to join" ) then
return ;
end ;
if zK and zK.e==U then
YK ( "Stopped" ) ;
elseif
U.gone==true then
tK ( "This egg is gone" ) ;
elseif
SK ( U ) then
tK ( "This egg is gone" ) ;
else
GK ( U ) ;
end ;
end ) ;
dK.cards[Yb]=BK ;
end ;
Y8,KK=dK.cards[1],A8.bottom-A8.top ;
g8=pK.Size.Y.Scale*KK*0.72 ;
uK[48]=p ;
uK[49]=R8 ( g8/I8 ) ;
uK[47]= {
} ;
uK[47].a=b[13] ( 0.5,1 ) ;
uK[47].p=b[16] ( 0.5,A8.bottom ) ;
uK[47].v=true ;
G8= ( uK[48] ( uK[49],uK[47] ) ) ;
A8.bottom=A8.bottom-g8-S8 ;
w8=A8.bottom-A8.top ;
UK.Size,UK.Position=Ab ( A8.sx,w8 ) ,Ab ( A8.px,A8.top+w8*h8 ) ;
pK.Size=Ab ( pK.Size.X,0.2 ) ;
h8=dK ;
for U,U in ipairs ( h8.cards ) do
U.f.Size=pK.Size ;
end ;
h8=dK ;
h8.foot,A8.bFull,A8.bFoot,A8.cFull=G8,A8.bottom+g8+S8,A8.bottom,0.2*w8/KK ;
uK[55]=p ;
uK[53]=p ;
uK[54]=Y8.name:Clone ( ) ;
uK[51]=y ;
uK[52]=T ;
uK[50]= {
} ;
uK[50].t= "https://chillihub.pro" ;
uK[50].ts=true ;
uK[50].tt=b[11].TextTruncate.None ;
uK[57]=uK[53] ( uK[54],uK[51] ( uK[52],0.05,0.32,0.62,0.4,uK[50] ) ,G8 ) :FindFirstChildOfClass ( Q ) ;
uK[56]= {
} ;
uK[56].Color=b[18] ( t,b[12] ( 225,225,235 ) ) ;
uK[56].r=90 ;
uK[55] ( uK[57],uK[56] ) ;
p ( Y8.val:Clone ( ) ,y ( T,0.05,0.72,0.62,0.32, {
rt=true,ts=true,t= "<font color=\"#C8C2DC\">Create your account and get Chilli Finder</font>"
} ) ,G8 ) ;
local function U ( Yb,Jb,Mb,GK ) qK ( Yb.b,function ( ) local BK=pcall ( setclipboard, "https://chillihub.pro" ) ;
PK ( Yb.l,BK and "Copied!" or "chillihub.pro" ) ;
tK ( BK and Mb or GK ) ;
task.delay ( 2,function ( ) PK ( Yb.l,Jb ) ;
end ) ;
end ) ;
end ;
U ( O8 ( y ( x,0.97,0.5,0.27,0.62 ) ,G8,HK,0.82,0.56, "Copy Linue);end;for Ab,Nb in ipairs(ub)do if Nb.Group then local Hb,xb,fb=ipairs,Nb.Group.Items,false;for mb,mb in Hb(xb)do Ab=rb;fb=if Ab[mb.Id]then true else fb;end;bK(Nb,fb);end;end;Xb();end;local function Ab()local Nb=tK(yb,h(20,18,24),0.12,{Active=true,AnchorPoint=r(0.5,0),Size=B(470,62)});local r,Hb=h(255,196,60),h(255,60,40);zK(Nb,16);Ub(YK(Nb,hb,2.4,Vb),r,Hb,0);IK(Nb,0.9,40);Eb[#Eb+1]=_(" UIScale ",{Parent=Nb});local Vb=tK(Nb,h(30,24,30),nil,{Position=B(9,8),Size=B(46,46)});zK(Vb,12);Ub(YK(Vb,hb,2),r,Hb,45);zK(hK(" ImageLabel ",Vb,{Image=zb,ScaleType=b.ScaleType.Crop,Size=c(1,1)}),12);Ub(NK(Nb,24,{Text=" CHILLI HUB ",Position=B(64,8),Size=B(200,26)}),h(255,226,120),h(255,80,40));NK(Nb,12,{Text=" FARM STATS | STEAL AN EGG ",TextColor3=Bb,Position=B(65,36),Size=B(200,16)},true);_(" UICorner ",{Parent=tK(Nb,hb,0.82,{Position=B(282,12),Size=B(2,38)}),CornerRadius=n(1,0)});local function h(c,r,hb)local zb=NK(Nb,26,{Position=B(c,6),Size=B(r,30),TextXAlignment=Sb,TextColor3=vb});NK(Nb,12,{Text=hb,TextColor3=Bb,Position=B(c,38),Size=B(r,14),TextXAlignment=Sb},true);return zb;end;ub[1]={F=Nb,Order=0};return h(296,78," FPS "),(h(380,80," PING MS "));end;local function h(c,r,hb)local zb=Tb(c):Get();if Zb(zb)then if type(zb.XOffset)==" number "then if type(zb.YOffset)==" number "then c=o(zb.Unit);local Nb=c and c>0 and r/c or 1;return R(o(zb.XScale)or 0,a(zb.XOffset*Nb+0.5),0,a(16+((o(zb.YScale)or 0)*hb+zb.YOffset-(o(zb.Top)or 16))*Nb+0.5));end;end;end;end;local function c()local r,o=Db(),0;for hb,hb in ipairs(ub)do o=if hb.Col==" Center "then if hb.F.Visible then math.max(o,hb.F.AbsoluteSize.X)else o else o;end;local hb,zb=a(o/2+26*r),ub[1].F;zb.Position=R(0.5,0,0,16);local o=16+zb.AbsoluteSize.Y+a(46*r);local Nb,Sb={Left=o,Right=o,Center=o},Gb().Y;for Gb=2,#ub,1 do zb=ub[Gb];Gb,o=zb.Col,zb.F;local Hb=Nb[Gb];o.Position=h(zb.Id,r,Sb)or R(0.5,Gb==" Left "and-hb or Gb==" Right "and hb or 0,0,Hb);if o.Visible then Nb[Gb]=Hb+o.AbsoluteSize.Y+a(42*r);end;end;end;local h=0;local function r()if not(yb)then return;end;h+=1;local o=h;local hb=Db();for zb,zb in ipairs(Eb)do zb.Scale=hb;end;task.defer(function()local hb=HeartbeatWait;hb();hb=HeartbeatWait;hb();if o~=h then return;elseif not(yb)then return;end;c();hb=HeartbeatWait;hb();if o~=h then return;elseif not(yb)then return;end;for h,h in ipairs(ub)do SK(h.F,h.Id);end;end);end;local function h()for c,c in ipairs(ab)do c:Disconnect();end;if yb then yb:Destroy();end;yb,Cb=nil,nil;local c={ab,Eb,ub,Wb,pb,kb};for o,o in ipairs(c)do table.clear(o);end;end;local function c()h();yb=_(" ScreenGui ",{Archivable=false,DisplayOrder=-101,IgnoreGuiInset=true,ResetOnSpawn=false,ZIndexBehavior=b.ZIndexBehavior.Sibling});local b,o=Ab();for hb,zb in ipairs(eb)do local Ab=m(zb,hb);Ab.Group=zb;gK(Ab.Body,4);for hb,Nb in ipairs(zb.Items)do local zb,Gb=hK(" Frame ",Ab.Body,{LayoutOrder=hb,Size=B(Nb.Wide and 380 or 250,46)}),Nb.Id:upper();local hb,Ab,Sb=hK(" ImageLabel ",zb,{Image=Nb.Icon,Position=B(0,2),ScaleType=Kb,Size=B(42,42)}),NK(zb,13,{RichText=true,Text=Gb,TextColor3=Bb,Position=B(50,3),Size=R(1,-50,0,14)},true),NK(zb,Nb.Wide and 18 or 24,{Position=B(50,18),Size=R(1,-50,0,26)});Ub(Sb,Nb.A,Nb.B);Wb[Nb.Id]={F=zb,Icon=hb,Value=Sb,Cap=Ab,Title=Gb,Item=Nb};end;end;for R,hb in ipairs(f)do local f,zb=m(hb,100+R),{};_(" UIListLayout ",{Parent=f.Body,FillDirection=Rb,SortOrder=_b,Padding=n(0,10)});for R=1,6,1 do zb[R]=HK(f.Body,R);end;pb[#pb+1]={Panel=f,Show=hb,Cards=zb};end;Cb=m(nb(" Steal History "," Left ",255,60,90,255,140,160),2.5);gK(Cb.Body,6);for R=1,7,1 do kb[R]=tb(Cb.Body,R);end;local R,f=Cb,{};f.F,R.E=NK(R.Body,16,{LayoutOrder=99,Text=" No steals yet ",TextColor3=Bb,Size=B(330,30)}),f;table.sort(ub,function(B,n)return B.Order<n.Order;end);x();yb.Parent=Yb;r();R=workspace.CurrentCamera;if R then wK(R:GetPropertyChangedSignal(" ViewportSize "),r);end;local R,B,n,m,hb,tb=0,0,0,0;f=RunService;wK(f.RenderStepped,function(f)f=math.clamp(f,0.001,1);local zb,Yb=R<=0 and 1/f;if zb then Yb=zb;else local Ab=R;Yb=Ab+(1/f-R)*(1-math.exp(-f*8));end;R=Yb;Yb=L();if Yb<B then return;end;B=Yb+0.25;Yb=a(R+0.5);if Yb~=hb then hb=Yb;b.Text,b.TextColor3=p(Yb),Yb>=100 and vb or Yb>=50 and Pb or cb;end;zb,Yb=pcall(function()return e.Network.ServerStatsItem[" Data Ping "]:GetValue();end);Yb=a((zb and Yb or 0)+0.5);if Yb~=tb then tb=Yb;o.Text,o.TextColor3=p(Yb),Yb<=90 and vb or Yb<=180 and Pb or cb;end;end);wK(O,function()local b=L();if b<n then return;end;n=b+0.5;for R,B in next,Wb,nil do if rb[R]then local R,f,n,e=pcall(B.Item.Read);if R then f,n,e=p(f or" - "),p(n or" "),e or B.Item.Icon;if f~=B.LV then B.LV=f;B.Value.Text=f;end;if n~=B.LQ then B.LQ=n;B.Cap.Text=B.Title..(n~=" "and Fb..n.." </font> "or" ");end;if e~=B.LI then B.LI=e;B.Icon.Image=e;end;end;end;end;if b>=m or Mb then m,Mb=b+1,false;pcall(Xb);end;end);end;local function b()local R=ChilliState;R.hideUI(db and jb);end;local R=ChilliState;R.hudUI=function(R)local B=y(R," Farm HUD "," farmHud ",false,function(f)jb=f;local n,m=pcall,ChilliState;local e,L,a=m.fpsShow,not f;if f then a=L;else m=Y[26];a=m.fpsHud~=false;end;n(e,a);if f then c();else h();end;b();end," Drag any panel to place it where you like ");R:Toggle(" Hide Game UI ",true,function(c)db=c;b();end,nil,B):When(B);R:Dropdown(" HUD Items ",qb,qb,function(c)rb=i(c)or i(qb);x();r();end,true,nil,B):When(B);R:Slider(" Showcase Cards ",1,6,4,function(c)ib=c;pcall(Xb);end,nil,1,nil,B):When(B);R:Slider(" HUD Size ",50,120,Jb,function(c)Qb=c/100;r();end," % ",1,nil,B):When(B);R:Dropdown(" Egg Card Image ",{" Egg Image "," Pet Image "}," Egg Image ",function(R)lb=R==" Pet Image ";for R,R in ipairs(pb)do for c,c in ipairs(R.Cards)do c.Key=nil;end;end;pcall(Xb);end,false," Picture used for Top Eggs and Steal History ",B):When(B);end;table.insert(ChilliState.cleanup,function()jb=false;h();b();end);end);S(" 49_lang#1 ",function()local b,h,R={c={},n=0},setmetatable,{__mode=" k "};b.src=h({},R);h,R=setmetatable,{__mode=" k "};b.out=h({},R);h,R=setmetatable,{__mode=" k "};b.ph=h({},R);b.roots={};local R,c,B,x,r=" https://chillihub.pro/lang/ ",{" English "," Ti\225\186\191ng Vi\225\187\135t "," Bahasa Indonesia "," Filipino "," \224\184\160\224\184\178\224\184\169\224\184\178\224\185\132\224\184\151\224\184\162 "," Portugu\195\170s "," Fran\195\167ais "," \208\160\209\131\209\129\209\129\208\186\208\184\208\185 "," \224\164\185\224\164\191\224\164\168\224\165\141\224\164\166\224\165unction hb ( ) local Xb=getRootPart ;
local Vb=Xb ( ) ;
return Vb~=nil and ( Vb.Position- ( a ( "Passages" , "SecretRoomSpawn" ) or a ( "SecretRoomSpawn" ) or Yb ) ) .Magnitude<120 ;
end ;
local function Yb ( Xb ) local Vb,Kb,_b=RaycastParams.new ( ) , {
} ,LocalPlayer ;
w:XI ( Kb,0,_b.Character ) ;
Vb.FilterDescendantsInstances,Vb.FilterType=Kb,Enum.RaycastFilterType.Exclude ;
local Rb,Rb,Rb=Vector3.new,Vector3.new,workspace:Raycast ( Xb+Vector3.new ( 0,20,0 ) ,Vector3.new ( 0,-80,0 ) ,Vb ) ;
_b=nil ;
if Rb then
Kb=nil ;
Kb,_b=Vector3.new,Rb.Position+Vector3.new ( 0,3,0 ) ;
else
_b=Rb ;
end ;
return _b or Xb ;
end ;
local function Xb ( Vb ) local Kb=getRootPart ;
local _b=Kb ( ) ;
if _b then
Kb=setPlayerCFrame ;
Kb ( CFrame.lookAt ( _b.Position,Vector3.new ( Vb.X,_b.Position.Y,Vb.Z ) ) ) ;
end ;
end ;
local function Vb ( Kb,_b ) local Rb,vb=m ( Kb ) ,Vector3.new ;
local m=vb ( Rb.X-r.X,0,Rb.Z-r.Z ) ;
vb=m.Magnitude>0.1 and m.Unit ;
if vb then
m=vb ;
else
local r=Vector3.new ;
m= ( r ( 0,0,1 ) ) ;
end ;
vb=Y[50] ;
if not ( vb ( Yb ( Rb+m*6.5 ) ,_b,60 ) ) then
return false ;
end ;
Xb ( Rb ) ;
_b=ChilliState ;
Rb,vb=_b.bat ( ) ,getHumanoid ;
_b=vb ( ) ;
if Rb then
if not _b then
return false ;
end ;
else
return false ;
end ;
vb=LocalPlayer ;
if Rb.Parent~=vb.Character then
pcall ( _b.EquipTool,_b,Rb ) ;
task.wait ( 0.25 ) ;
end ;
R ( "RE/BanjoCricket/Aim" ,Kb ) ;
Kb=os.clock ( ) +2 ;
while os.clock ( ) <Kb and Rb:GetAttribute ( "CooldownActive" ) ==true and P ( ) < ( tonumber ( Rb:GetAttribute ( "CooldownEndTime" ) ) or 0 ) do
task.wait ( 0.05 ) ;
end ;
pcall ( Rb.Activate,Rb ) ;
return true ;
end ;
local function r ( m,Kb,_b ) local Rb=os.clock ( ) +_b ;
while os.clock ( ) <Rb do
if h.wrong>Kb then
return "wrong" ;
end ;
for _b,_b in ipairs ( h.acks ) do
if _b[1]==m then
if _b[2]>Kb then
return "ok" ;
end ;
end ;
end ;
task.wait ( 0.05 ) ;
end ;
end ;
local function m ( Kb ) local _b=os.clock ( ) +300 ;
h.notes=nil ;
local Rb,vb=0,0 ;
while Kb ( ) and os.clock ( ) <_b do
local _b=LocalPlayer ;
if _b:GetAttribute ( "InEnchantedTree" ) then
if not ( hb ( ) ) then
return false ;
end ;
else
return false ;
end ;
if h.solved then
return true ;
elseif
Hb ( ) .Solved==true then
return true ;
end ;
_b=h.notes ;
if _b then
if os.clock ( ) <h.listen then
task.wait ( 0.05 ) ;
else
vb=0 ;
h.notes=nil ;
local Pb=Y[11] ;
Pb ( ( "Playing back %d notes" ) :format ( #_b ) ) ;
Pb=ipairs ;
for cb,Bb in Pb ( _b ) do
cb=nil ;
for _b=1,2,1 do
_b=os.clock ( ) ;
if not ( Vb ( Bb,Kb ) ) then
break ;
end ;
cb=r ( Bb,_b,1.6 ) ;
if cb then
break ;
end ;
end ;
if cb~= "ok" then
Bb=Y[11] ;
Bb ( "Missed a note, starting over" , "warn" ) ;
break ;
end ;
end ;
Rb=os.clock ( ) ;
end ;
else
if os.clock ( ) -Rb>4 then
vb+=1 ;
if vb>12 then
local r=Y[11] ;
r ( "The mushrooms do not answer" , "warn" ) ;
return false ;
end ;
local r=Y[11] ;
r ( "Waking the mushrooms" ) ;
Vb ( 4,Kb ) ;
Rb=os.clock ( ) ;
else
end ;
task.wait ( 0.1 ) ;
end ;
end ;
return false ;
end ;
local function r ( Vb ) if hb ( ) then
return true ;
end ;
for Kb=1,2,1 do
Kb=getWorldInstance ;
local _b=Kb ( "Build" , "EnchantedTreeInterior" , "SecretLeapHint" , "Streaks" ) ;
local Rb,vb=_b and _b:IsA ( "BasePart" ) and _b.Position or Nb,getRootPart ;
_b=vb ( ) ;
if not _b then
return false ;
end ;
vb=Y[11] ;
vb ( "Flying to the Secret Leap" ) ;
vb,Kb=Y[50],Vector3.new ;
if vb ( Kb ( _b.Position.X,Rb.Y+18,_b.Position.Z ) ,Vb,120 ) then
local Nb,Kb=Y[50],Vector3.new ;
if not ( Nb ( Rb+Kb ( 0,18,0 ) ,Vb,120 ) ) then
return false ;
end ;
else
return false ;
end ;
vb=Y[11] ;
vb ( "Taking the Secret Leap" ) ;
Rb=os.clock ( ) +8 ;
while os.clock ( ) <Rb and ( Vb ( ) ) and not hb ( ) do
task.wait ( 0.1 ) ;
end ;
if hb ( ) then
task.wait ( 1 ) ;
return true ;
end ;
end ;
return false ;
end ;
local function Nb ( Vb ) task.wait ( 5 ) ;
for Kb=1,3,1 do
local _b,Rb=B ( ) ,getRootPart ;
Kb=Rb ( ) ;
if Kb and ( Kb.Position-_b ) .Magnitude>9 then
Rb=Y[11] ;
Rb ( "Going to Jitterbug" ) ;
local B=Vector3.new ;
local vb=B ( Sb.X-_b.X,0,Sb.Z-_b.Z ) ;
B=vb.Magnitude>0.1 and vb.Unit ;
if B then
vb=B ;
else
local B=Vector3.new ;
vb= ( B ( 0,0,-1 ) ) ;
end ;
local B,Pb=ipairs, {
Yb ( Gb ) ,Yb ( Sb ) ,Yb ( _b+vb*6 )
} ;
for Yb,Gb in B ( Pb ) do
Yb=Y[50] ;
if not ( Yb ( Gb,Vb,60 ) ) then
return false ;
end ;
end ;
Xb ( _b ) ;
end ;
Kb=Y[11] ;
Kb ( "Claiming Cricket's Banjo" ) ;
Kb=invokeServerWithTimeout ;
Rb,_b=Kb ( "RF/BanjoCricket/AskClaim" ) ;
if _b==true then
return true ;
elseif
Hb ( ) .Claimed==true then
return true ;
end ;
task.wait ( 1 ) ;
end ;
return Hb ( ) .Claimed==true ;
end ;
local function B ( ) local Yb=getHumanoid ;
local Gb=Yb ( ) ;
local function Sb ( ) return true ;
end ;
if Gb then
pcall ( Gb.UnequipTools,Gb ) ;
end ;
if hb ( ) then
Gb,Yb=a ( "Passages" , "SecretRoomExit" ) or tb,Y[50] ;
Yb ( Gb,Sb,60 ) ;
local a=os.clock ( ) +5 ;
while os.clock ( ) <a and ( hb ( ) ) do
local a,hb=setPlayerCFrame,CFrame.new ;
a ( hb ( Gb ) ) ;
task.wait ( 0.1 ) ;
end ;
end ;
Sb=ChilliState ;
Sb.leaveTree ( ) ;
end ;
local a=wb ( {
name= "Banjo" ,mover=true,gap=3,pri=6,soft=true
} ) ;
a.on=function ( ) local hb=Y[26] ;
return hb.banjo and not h.done ;
end ;
local function hb ( tb ) local Yb=ChilliState ;
if Yb.wispSay then
local Yb=ChilliState ;
Yb.wispSay ( "Banjo cricket: " ..tb ) ;
end ;
end ;
a.want=function ( ) if Hb ( ) .Claimed==true then
h.done=true ;
return hb ( "done, Cricket's Banjo is yours" ) ;
end ;
local tb=LocalPlayer ;
if tb:GetAttribute ( "EnchantedTreeUnlocked" ) ~=true then
return hb ( "needs the Enchanted Tree open (finish the wisp quest)" ) ;
end ;
tb=ChilliState ;
if not ( tb.bat ( ) ) then
return hb ( "needs a bat in your bag" ) ;
end ;
if os.clock ( ) <h.next then
return ;
end ;
return true ;
end ;
a.run=function ( a,tb ) a=ChilliState ;
if not ( a.needBody ( ) ) then
return hb ( "leaving invisibility first" ) ;
end ;
h.next=os.clock ( ) +15 ;
if Y[13] ( tb ) then
a=ChilliState ;
if not ( a.enterTree ( tb ) ) then
return hb ( "could not get into the Enchanted Tree" ) ;
end ;
else
return hb ( "could not get into the Enchanted Tree" ) ;
end ;
if not ( r ( tb ) ) then
B ( ) ;
return hb ( "could not take the Secret Leap" ) ;
end ;
if Hb ( ) .Solved~=true then
if not ( h.solved ) then
if not ( m ( tb ) ) then
B ( ) ;
return hb ( "puzzle not solved, trying again" ) ;
end ;
end ;
end ;
if Nb ( tb ) then
h.done=true ;
u ( "Banjo" , "Cricket's Banjo claimed" , "ok" ) ;
hb ( "done, Cricket's Banjo is yours" ) ;
end ;
B ( ) ;
end ;
end ) ;
S ( "38_world#1" ,function ( ) local h,B,r,m,a= {
cd= {
} ,shot=0,at=0
} , {
Prep=true,Match=true,SuddenDeath=true
} , {
Intro=true,Reveal=true,Prep=true,Match=true,SuddenDeath=true,Win=true,Outro=true
} ;
local hb=wb ( {
name= "Dawn" ,gap=1
} ) ;
hb.on=function ( ) local hb=e ( ) >0 ;
if hb then
if m==false then
a=os.clock ( ) ;
end ;
end ;
m=hb ;
return false ;
end ;
local m=ChilliState ;
m.dawnNow=function ( ) local m=os.clock ( ) - ( a or-99 ) ;
return m<20 ;
end ;
local m=ChilliState ;
m.stealDawn=function ( m,hb ) local tb,Yb=os.clock ( ) - ( a or-99 ) ,Y[26] ;
local a,Nb=Yb.steal ;
if a then
Yb=hb and e ( ) <=0 ;
if Yb then
Nb=Yb ;
else
local hb=tb<20 ;
if hb then
local Gb=tb<10 ;
if Gb then
Nb=Gb ;
else
local Gb=ChilliState ;
Nb=Gb.stealWants ( ) ;
end ;
else
Nb=hb ;
end ;
end ;
else
Nb=a ;
end ;
Yb=nil ;
if Nb then
tb=ChilliState ;
Yb= ( tb.rank[ "Steal:filter" ]or 9 ) <m ;
else
Yb=Nb ;
end ;
return Yb ;
end ;
local function m ( a ) local hb=Vector3.new ;
return hb ( a.X,0,a.Z ) ;
end ;
local function a ( hb ) if typeof ( hb ) ~= "Instance" then
return nil ;
end ;
if hb:IsA ( "BasePart" ) then
return hb.Position ;
elseif
hb:IsA ( "Attachment" ) then
return hb.WorldPosition ;
elseif
hb:IsA ( "Model" ) then
reHeavy ) or dK.t0.f ;
U[3]=Vb and t or dK.t0.c ;
Bb.Position=U[1] ;
Bb.FontFace=U[2] ;
Bb.TextColor3=U[3] ;
if xb then
xb.Enabled=not Vb ;
end ;
if Tb then
Tb.Color=Vb and R or dK.t0.s ;
end ;
end ;
end ;
if dK.foot.Visible==d then
dK.foot.Visible,hb.bottom=not d,d and hb.bFull or hb.bFoot ;
x ( d and hb.cFull or 0.2 ) ;
end ;
Vb=r and ab.rooms~=nil ;
local R=Vb and dK.rsH or 0 ;
if dK.hr~=Vb then
dK.hr=Vb ;
local Bb=b[16] ( 0.5,hb.st+R ) ;
dK.stat.Position,dK.sib.Position,dK.pk.Position=Bb,Bb,Bb ;
local xb=dK ;
for Tb,Tb in pairs ( xb.sl ) do
Tb.f.Position=Bb ;
end ;
if d then
x ( hb.cFull* ( hb.bottom-hb.top ) / ( hb.bottom-hb.top-R ) ) ;
end ;
end ;
dK.rs.Visible=Vb and o ;
if Vb then
local x,Bb=#ab.rooms,dK ;
for xb,Tb in ipairs ( Bb.rb ) do
o=ab.rooms[xb] ;
Tb.b.Visible=o~=nil ;
if o then
U[4]=Tb.b ;
U[5]= ( b[16] ( ( 0.94-0.02* ( x-1 ) ) /x,0.72 ) ) ;
U[4].Size=U[5] ;
cK ( Tb, ( "Room %d: %d %s" ) :format ( xb,o,o==1 and "user" or "users" ) ,xb==ab.room and AK or sK ) ;
end ;
end ;
else
ab.ask=nil ;
end ;
dK.ask.Visible=ab.ask~=nil ;
if ab.ask then
o=math.ceil ( ( ab.roomAt or 0 ) -Gb ) ;
PK ( dK.askT,o>0 and "Switch cooldown" or ( "Switch to Room %d?" ) :format ( ab.ask ) ) ;
PK ( dK.askB,o>0 and ( "You can switch again in %d:%02d." ) :format ( o//60,o%60 ) or "You can only join new eggs after switching.\10Switch cooldown: 2 min." ) ;
PK ( dK.askC.l,o>0 and "OK" or "Cancel" ) ;
U[6]=dK.askC.b ;
b ;
y ( b, "Invisibility" , "invis" ,false,function ( a ) local hb=ChilliState ;
if hb.invPin then
local hb=ChilliState ;
hb.invPin ( a ) ;
end ;
end , "Makes you invisible to other players" ) ;
y ( b, "Anti Ragdoll" , "antiRag" ,true,function ( a ) local hb ;
if a then
local tb=LocalPlayer ;
hb= ( tb:GetAttributeChangedSignal ( "RagdollEndTime" ) ) ;
else
hb=a ;
end ;
gb ( "ragAttr" ,hb,function ( ) local hb=isRagdolled ;
if hb ( ) then
r ( ) ;
end ;
end ) ;
gb ( "ragRemote" ,a and h and B.ClientRagdollRemote and B.ClientRagdollRemote.OnClientEvent,r ) ;
end ) ;
local h= {
} ;
local function B ( r ) local a=LocalPlayer ;
if r:GetAttribute ( "Owner" ) ==a.Name then
return ;
end ;
local a,hb=ipairs, {
r,table.unpack ( r:GetDescendants ( ) )
} ;
for r,r in a ( hb ) do
if r:IsA ( "BasePart" ) then
if r.CanTouch then
h[r]=true ;
r.CanTouch=false ;
end ;
end ;
end ;
end ;
local r=I ( "CollectionService" ) ;
y ( b, "Anti Trap" , "traps" ,true,function ( a ) gb ( "trap" ,a and r:GetInstanceAddedSignal ( "PlacedTrap" ) ,function ( hb ) task.defer ( pcall,B,hb ) ;
end ) ;
if a then
for a,a in ipairs ( r:GetTagged ( "PlacedTrap" ) ) do
pcall ( B,a ) ;
end ;
else
local B=h ;
for r in next,B,nil do
if r.Parent then
r.CanTouch=true ;
end ;
end ;
h= {
} ;
end ;
end , "Traps from other players cannot catch you" ) ;
local h,B,r,a= {
} , {
ClaimLostPart=true,CatchPrompt=true
} , {
} ,false ;
local function hb ( tb ) if not ( tb:IsA ( "ProximityPrompt" ) ) then
return ;
end ;
if tb.Name== "CatchPrompt" then
local Yb,Nb=ipairs,getconnections and getconnections ( tb.PromptButtonHoldEnded ) or {
} ;
for Gb,Gb in Yb ( Nb ) do
if not ( r[Gb] ) then
r[Gb]=true ;
pcall ( Gb.Disable,Gb ) ;
end ;
end ;
elseif
tb.HoldDuration>0 then
if not ( B[tb.Name] ) then
local B=h ;
B[tb]=B[tb]or tb.HoldDuration ;
tb.HoldDuration=0 ;
end ;
end ;
end ;
local function B ( tb ) if tb.Name~= "CatchPrompt" then
return ;
elseif
a then
return ;
end ;
hb ( tb ) ;
a=true ;
task.spawn ( function ( ) local Yb=invokeServerWithTimeout ;
local Nb,Gb=Yb ( "RF/ShootingStar/AskState" ) ;
if Nb and type ( Gb ) == "table" and Gb.Id then
local Nb,Sb=os.clock ( ) ,true ;
while true do
local Xb,Hb=os.clock ( ) -Nb,tonumber ;
if not ( Xb< ( Hb ( Gb.HoldSeconds ) or 1.6 ) +0.3 ) then
break ;
end ;
Yb=getRootPart ;
Xb,Hb=Yb ( ) ,tb.Parent ;
local Yb=Xb and Hb and Hb:IsA ( "BasePart" ) ;
if if Yb then
( Xb.Position-Hb.Position ) .Magnitude>tb.MaxActivationDistance+2
else
not Yb then
Sb=false ;
break ;
end ;
task.wait ( 0.1 ) ;
end ;
if Sb then
R ( "RE/ShootingStar/Catch" ,Gb.Id ) ;
else
R ( "RE/ShootingStar/Hold" ,Gb.Id,false ) ;
end ;
end ;
a=false ;
end ) ;
end ;
y ( b, "Instant Prompts" , "prompts" ,true,function ( b ) local a=I ( "ProximityPromptService" ) ;
gb ( "prompt" ,b and a.PromptShown,hb ) ;
gb ( "starTap" ,b and a.PromptButtonHoldBegan,B ) ;
if not ( b ) then
a=h ;
for b,B in next,a,nil do
if b.Parent then
b.HoldDuration=B ;
end ;
end ;
local b=r ;
for B in next,b,nil do
pcall ( B.Enable,B ) ;
end ;
h,r= {
} , {
} ;
end ;
end ) ;
local b= {
idle= {
}
} ;
local function h ( ) b.act= {
} ;
local B,B,r=LocalPlayer,pcall ( getconnections,LocalPlayer.Idled ) ;
for a,a in ipairs ( B and r or {
} ) do
local hb,tb=pcall ( debug.getupvalues,a.Function ) ;
for a,a in next,hb and tb or {
} ,nil do
if typeof ( a ) == "Instance" then
if a.ClassName== "TeleportService" then
return ;
end ;
end ;
end ;
end ;
r,B=pcall ( getgc,false ) ;
for a,hb in ipairs ( r and B or {
} ) do
if a%120==0 then
task.wait ( ) ;
end ;
if type ( hb ) == "function" then
if islclosure ( hb ) then
local B,r=pcall ( debug.info,hb, "s" ) ;
if B then
if type ( r ) == "string" then
if r:find ( "AntiAFK" ,1,true ) then
local B,B=pcall ( debug.info,hb, "n" ) ;
if B== "markActive" or B== "reportActiveFromInput" then
b.act[#b.act+1]=hb ;
end ;
end ;
end ;
end ;
end ;
end ;
end ;
end ;
local function B ( r ) if r then
local r,a,hb=ipairs,getconnections ;
if a then
local tb ;
tb,hb=LocalPlayer,getconnections ( LocalPlayer.Idled ) ;
else
hb=a ;
end ;
for a,a in r ( hb or {
} ) do
if pcall ( a.Disable,a ) then
b.idle[#b.idle+1]=a ;
end ;
end ;
return ;
end ;
for r,r in ipairs ( b.idle ) do
pcall ( r.Enable,r ) ;
end ;
b.idle= {
} ;
b.act=nil ;
end ;
y ( Ib.Utility, "Anti AFK" , "afk" ,true,B ) ;
table.insert ( ChilliState.cleanup,function ( ) B ( false ) ;
end ) ;
local r=wb ( {
name= "Afk" ,gap=120,at=os.clock ( ) +60
} ) ;
r.on=function ( ) local a=Y[26] ;
return a.afk ;
end ;
r.fn=function ( ) B ( true ) ;
if not ( b.act ) then
h ( ) ;
end ;
fower ( )
else
M ;
local hb,tb=k[o], ( f[y]or y ) ..M ;
y=type ( hb ) == "table" and hb.Value ;
if type ( hb ) == "table" and y~=nil then
if l== "h" then
if y==true then
L[f.Cb.. "Auto hit/Auto hit" ],L[tb]=true,o:find ( "Holders" ) and "Egg holders" or "Nearest player" ;
end ;
elseif
l== "w" then
n=i ( Q ( y ) ) or {
} ;
L[tb.. "Post stolen eggs" ],L[tb.. "Post fused eggs" ],L[tb.. "Post when bag is full" ]=n[ "Egg Stolen" ]==true,n[ "Egg Fused" ]==true,n[ "Inventory Full" ]==true ;
else
if p[l]then y=p[l] ( y ) ;
else
if l~= "" then
local n= {
} ;
for Q,i in l:gmatch ( "([^,>]+)>([^,]+)" ) do
n[Q]=i ;
end ;
y=type ( y ) == "table" and e ( y,function ( Q ) return n[Q]or Q ;
end ) or n[y] ;
else
end ;
end ;
if y~=nil then
L[tb]=y ;
end ;
end ;
end ;
end ;
end ;
end ;
end ;
a=type ( m.States ) == "table" and m.States[ "Anti Guard Enabled" ] ;
if type ( a ) == "table" then
if type ( a.Value ) == "boolean" then
L[f.A.. "Anti guard" ]=a.Value ;
end ;
end ;
return L ;
end ;
local f ;
f=V ( O,function ( ) if not ( r ) then
return ;
end ;
r=false ;
f:Disconnect ( ) ;
pcall ( function ( ) local f,n= "ChilliLibrary/Games/" ..tostring ( A.GameId~=0 and A.GameId or A.PlaceId ) , "Default" ;
pcall ( function ( ) local Q=X:JSONDecode ( readfile ( f.. "/config_state.json" ) ) ;
local m=type ( Q ) == "table" and type ( Q.StartupConfig or Q.SelectedConfig ) == "string" and ( Q.StartupConfig or Q.SelectedConfig ) ;
n=m or n ;
end ) ;
local Q=f.. "/configs/" ..n.. ".json" ;
local f=isfile ( Q ) and readfile ( Q ) or isfile ( Q.. ".bak" ) and readfile ( Q.. ".bak" ) ;
Q=type ( f ) == "string" and X:JSONDecode ( f ) ;
f=type ( Q ) == "table" and q ( Q ) ;
if f then
if next ( f ) then
if not ( isfolder ( "Venyx" ) ) then
makefolder ( "Venyx" ) ;
end ;
writefile ( "Venyx/FromChilli.json" ,X:JSONEncode ( f ) ) ;
end ;
end ;
end ) ;
pcall ( s.SetTeleportSetting,s, "__ChilliAutoLoadScriptEnabled" ,false ) ;
_G.__ChilliAutoLoadQueued=nil ;
if H.ChilliHubSaeCleanup then
pcall ( H.ChilliHubSaeCleanup ) ;
end ;
local q,f=pcall ( A.HttpGet,A, "https://raw.githubusercontent.com/tienkhanh1/Venyx/main/VenyxHub" ) ;
local n=q and type ( f ) == "string" and loadstring ( f ) ;
if n then
pcall ( n ) ;
end ;
end ) ;
local function q ( f,n,Q ) n=math.max ( n/math.max ( Q,1 ) ,8 ) ;
f,Q= ( n-0.5 ) /2,math.max ( 1,n-c-5-1.6 ) ;
F.Hero.Set ( {
Width=n
} ) ;
F.Name.Set ( {
Width=Q
} ) ;
F.About.Set ( {
Width=Q
} ) ;
local m,i=F.Switch.Set, {
} ;
i.X=n-5-t ;
m ( i ) ;
F.Card.Set ( {
Width=n
} ) ;
for m,i in ipairs ( U ) do
Q=0.3+ ( m-1 ) %2* ( f+0.5 ) ;
i[1].Set ( {
X=Q+0.25,Width=0.8
} ) ;
i[2].Set ( {
X=Q+1.05,Width=f-1.4
} ) ;
i[3].Set ( {
X=Q+1.05,Width=f-1.4
} ) ;
end ;
F.Loader.Set ( {
Width=n
} ) ;
F.Code.Set ( {
Width=n-5
} ) ;
F.Copy.Set ( {
X=n-3.9
} ) ;
end ;
local function f ( n ) local Q,m,i,e=Font.new ( "rbxasset://fonts/families/Montserrat.json" ,Enum.FontWeight.ExtraBold ) ,Font.new ( "rbxasset://fonts/families/Montserrat.json" ,Enum.FontWeight.Bold ) ,Font.new ( "rbxasset://fonts/families/Montserrat.json" ,Enum.FontWeight.SemiBold ) ,Font.new ( "rbxasset://fonts/families/RobotoMono.json" ,Enum.FontWeight.Medium ) ;
local function L ( a,p,k ) return n:Frame ( {
Name=a,Y=p,Height=k,Background= "#14151A" ,Corner=0.4,StrokeColor= "#FFFFFF" ,StrokeThickness=0.0909,StrokeTransparency=0.82
} ) ;
end ;
local function a ( p,k,o,y,M,l,hb,tb,zb ) return n:Text ( {
Parent=p,X=k,Y=o,Height=y,Scale=M,Wrap=zb==true,Font=l,Text=hb,Color=tb
} ) ;
end ;
F.Hero=L ( "Hero" ,0,6.6 ) ;
local p=n:Image ( {
Parent=n:Frame ( {
Parent=F.Hero,X=t,Y=t,Width=4,Height=4,Background= "#0D0E12" ,Corner=0.8,StrokeColor= "#FFFFFF" ,StrokeThickness=0.0909,StrokeTransparency=0.7
} ) ,X=0.65,Y=0.65,Width=2.7,Height=2.7
} ) ;
task.spawn ( function ( ) local t= "Venyx/mark1.png" ;
local k,o=pcall ( isfile,t ) ;
if k and o then
else
t= "Chilli Hub/VenyxMark1.png" ;
local y,M=pcall ( isfile,t ) ;
if not ( y and M ) then
local y,M=pcall,crypt and ( crypt.base64decode or crypt.base64 and crypt.base64.decode ) ;
local l,hb=y ( M or base64_decode, iVBORw0KGgoAAAANSUhEUgAAAIYAAACACAYAAADOIBGMAAAPWklEQVR4nOydedRd0xnGn8/qH6VKQtIEFVESJTGFGKrRIk1Lo9RUZZWlWLS0S9qaaQ1VStAGCdpGzFMQjURVUkPNpVTFGErNbRUd1Oo/PI+7b9Z1c+6Z9rvvOefe81trr/199557hr3f8+7pfd+9DGpqIlgGNTUR1IJRE8kSwXjvvfdWYLqOaRxq+grW+eZMVzMt2/xsiWAMDAz8i9kzTA/xgCNQ0xewrk9idh/TE5SB/zU/H2g76BPMXmb6CNPNTHvw4P+gpudgXQ9hNpvpc0z/ZxrGun6r+f2H+hj84m/MrnD/bs+0iCfYCjU9BetUdfsYGkIhLmoVChHV+Ty/5e8RTHfxRMegpidgXZ7FbD7TsJaPz28/binBoOTcy+yqto9P4QmvZFoONZWEdbcS0wL+OaXtK2mLR9qP7zRcPS/isz2ZHuXJx6OmUrDOvshsEdN2EV9Pj/pNpGBQgu5idm/EV2sxPcAL7Y2aSsC6+g6z3zANj/j6Ntb1g1G/i5vgOj3mu8t4we+jptSwjo5lNi3mkFM7fTGA+BO/xGy1mENOo8QdjZrSwbqbyizu5X2BdTey05dJU+KnJ3x/FG/gUtSUBg0QmG5EvFCI2LpN0hgrMnuVaVnEs5Bpx9aZs5ruw/r6OBr9ic8kHKpZ7lVYX+90OiBWY/CHb6NDr7UN9Xbn88Y+hppCYNkPQuMFTRIKcW6cUIhYjeEuqGny15GOu5m250X/jZquwTpamdltTOunOPxdptVZR/+IOyhx2d1Nk09DOjR9fqtTaTVdwL24v0c6oRBnJgmFSNQY7uJj0JhbT4tW6ybyBv6LmmCwXoYyu4Np3Qw/G816eSbpoFSGOjyRZs1uQXq2YJqDmmC4gYGmuLMIxdw0QiGyWHCdjWxM5M3/GjXmsFyXR2P0sQGycVbaA1M1JS03pOnTTZCN6ymlu6LGBGdl9VumzyIb97AeUptQZLX5nIXs7MKHqZsVO65BdqEQs7IcnFVjaNld0+SDkZ3zKLGHoiY3LP8LmR2I7GhkOTLLBGQmjeEmRc5EPg7hg30XNblg2R2OfEIhzsg6K51JYwg3uym70BWRj0m8yVtRkxqW+WRmc5EPzVloQuvdLD/K7Ffi5iauQH5m80HXQU0qWFZjmV2J/MzMKhQir8PR+cjPCmgIx6dQEwvLaCQanc3lkZ9fIAe5BIMS+Ciz3yE/eguuQk1H3FzFPGSbwGpnHutqMXLg46LoozXEeD58kr1HP3MJ03rwI+0a11Jk7ny2worV+skY+LEXpdqnDe05WK4nMvsh/Lif5boFcuLr1OzTCV1yDhbEhqj5AJbFV+AvFGI2PPDVGJro0tA1ycIrib8wbeT8Z/sW1yFX/83X4EleZav7uJd6aQxe+E1mF8GfNZkuRs1l8BcKcZGvz7FFfIxzYMPOzgeiL+GzH8lsS9hwLjzxakqauEWynWDD+pT2LEZBlYfltxGzh2HDNSy/r8ETq4g6vkPXVmaij3DzFVfDjhkwwEQwKKEyGklrMJyE5jdORv+gfsVo2PAc6+J2GGAZg+tU2HEchSOrQVDl4DN+AXZNsDCbMDTpYwg3dP0n7FA/Y3yeBaAq4JqQB+A35d3O8lYG2GYaww1dLSa8mmg95UfoXU6DrVBcbmmVb6YxBN+CbeC3uBbFBBeWoWdgOclzbwFs2dAtbppgKhiCD30/s81gxxNM43qlSXHGvHLHWBN2PMTy2RSGhAgAewlskbr9MXoHNSGWQiFy2VzEEUJjaEr3r0wrwZa1+VY8iwrDstEy+iLY8nemEdYa1VxjuA6QySRLGz9B9Unt8JOBs0M0s+YaQ/DNWB0NrWGN/GEXooKwTOR05bUU3oGhaZyUsxIkyDxv9EU0vKWs+Rmqy1TYMzeEUIiQuw+EUJtj+ebthorhohyOhD0hyvgDgjQlTVggMsAZCVue4lvyaVQIlsNzsB+JLGY5jEIgQu9XYrnq2mQdFnRlXB3dTg7WQiGs7GAiCa0xPsnsRdgjX8xRZTcFdIFNNMQOEWFoaKj+hQiqMXjjcoD+FexReKEjUX5OQBihODekUIigGkPwrVF/4AmEYZiLEVY6nGFvqAm5UXkdidISfE80PsCTzEI5MZdZa5yEMMwLLRQiuMYQfHt2R8MHMwRDWFBvoETweWWR9RTCsBOfN3gIq67sosgHuRZhZkLFQSgfUxCGxd0QCtHN7TVDaYzDnDVUKeC9rMLsYIQhVBkuRTcFI8ToRGhIaOHSZ8VRCIeFc1cqutLHaMK36ZfM9oc98rpareh5DW0vhUaMMl+XzShm8Pm+jS7RTY0hzkMY1JTsgeLRmkgIoRChyi6SrmoMwbdKIY63hj2P843yDcngBZ9NUXfXhj3z+WxfRhfptsYQeaP+JbGe89MoBF57R4QRCtH1ADNd1xiChagxvpX3VSsL+GYVIhx8pjuZTYA9hWjCIjSGCGWmN9Et3HUVXlO7S4YQClGIu2ZRgiEn3lCzld9C9wk1WniF2qKQIHaFCIYzXs0dOCyBvNFzc+H8RL6JMPwUBVGUxhASjBBbZA1lZXnHh8iAhsmDYI9cPs39RdJSmGBQayhOVCibxa5NBCHcWs3UInelLGRU0sTt/KeZwhC7L45w1urBCGhzISeiNQcK3DqsyKakqTV+jjB0Y9U11GLZmQMF7ydXqMYQzi4yhBXWoyzcoPFDA83H6GUZUfQWpYVqDMECkNoMsQ6wQcg5DZ5bztYhJummFS 