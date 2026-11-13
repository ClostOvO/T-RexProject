--[[
    ================================================================================
    MODULE 12: RIG SYNC, CHARACTER DESYNC & RESPAWN
    Chilli Hub / Steal An Egg Automation Engine
    ================================================================================
    
    DESCRIPTION:
    Manages client-server character synchronization, ghost/desync exploit routines,
    and clean state resets:
    - Remotes handled:
      * RE/RigSync/AskRigWipe         = Server request to reset/re-sync client rig
      * RE/RigSync/CorrectionBegan    = Server correction notification
      * RE/RigSync/ProbeSatchel       = Satchel inventory probe
      * RE/RigSync/SeedSatchel        = Satchel synchronization seed
      * RE/RigSync/Refresh            = Full rig refresh
      * RE/GearSatchel/Lost & Gained  = Weapon gear pickup/drop sync
    - Anti-Detection Ghost / Desync Routine:
      * Unequips tools and triggers ServerBreakJoints
      * Sets HipHeight = 999 and anchors HumanoidRootPart while detaching visual joints
      * Evades server hitboxes and velocity checks during high-speed actions
    - Clean Death / Respawn Routine:
      * Changes Humanoid state to Dead and executes AskRigWipe loop until re-spawned
    ================================================================================
]]

id ")then Rb.Died:Once(function()Sb=true;end);end;end;for Rb,Rb in ipairs(Kb:GetChildren())do _b(Rb);end;Kb.ChildAdded:Connect(_b);end;local Kb=LocalPlayer;Vb(Kb.Character);Kb=LocalPlayer;V(Kb.CharacterRemoving,function()Hb=not Sb;end);Kb=LocalPlayer;V(Kb.CharacterAdded,function(Sb)local _b=Y[7];_b();Vb(Sb);local Sb,Vb,_b,Rb=Y[3],Y[3],Y[3],Hb;Sb.gate,Vb.body,_b.at=Rb,os.clock(),os.clock()+1;Hb=false;end);Kb=NetworkingRemotes;local Sb=Kb:FindFirstChild(" RE/RigSync/Refresh ");if Sb then V(Sb.OnClientEvent,function()local Sb=Y[3];Sb.rig=os.clock();end);end;end);local function Sb()local Hb=ChilliState;local Vb,Kb=Hb.invisBusy;if Vb then Kb=Vb;else Hb=Y[26];local _b,Rb=Hb.moveTo==" Teleport ";if _b then local vb=Y[26];Rb=vb.steal;else Rb=_b;end;if Rb then _b=ChilliState;Kb=not _b.tpFT;else Kb=Rb;end;end;Vb=nil;if Kb then Vb=Kb;else Hb=ChilliState;local Kb=Hb.realHum~=nil;if Kb then local Hb=ChilliState;Vb=Hb.realHum();else Vb=Kb;end;end;return Vb;end;ChilliState.ready=function(Hb,Vb)local Kb=os.clock()+(Vb or 1.5);while true do Vb=Y[2];local _b=Vb();if not
b.UnequipTools,Yb);end;for tb,tb in ipairs(hb:GetChildren())do if tb:IsA(" Tool ")then if n()then tb.Parent=n();end;end;end;for hb=1,3,1 do Yb=HeartbeatWait;Yb();end;end;local function hb()local tb=LocalPlayer;local Yb,Nb=tb.Character,getHumanoid;local Gb=Nb();if not(Yb and Gb)then return;end;tb,Nb=ChilliState,ChilliState;tb.invisBusy,Nb.respawnAt=true,os.clock();sb();a(Yb);tb=invokeServerWithTimeout;tb(" RF/Treadmill/AskDoff ");pcall(function()Gb:SetStateEnabled(Enum.HumanoidStateType.Dead,true);Gb.BreakJointsOnDeath=true;Gb.RequiresNeck=true;Gb.Health=0;Gb:ChangeState(Enum.HumanoidStateType.Dead);Yb:BreakJoints();end);Nb=os.clock()+60;while true do tb=LocalPlayer;if not(tb.Character==Yb and os.clock()<Nb)then break;end;R(" RE/RigSync/AskRigWipe ",Yb);local a=os.clock()+8;while true do local tb=LocalPlayer;if not(tb.Character==Yb and os.clock()<a)then break;end;task.wait(0.2);end;end;Nb=ChilliState;Nb.invisBusy=b;end;m=ChilliState;m.respawn=hb;local a=false;local function tb()if a then return;end;a=true;local a,Yb=ipairs,{" RE/GearSatchel/Lost "," RE/GearSatchel/Gained "," RE/RigSync/ProbeSatchel "," RE/RigSync/SeedSatchel "," RE/RigSync/CorrectionBegan "," RE/RigSync/Refresh "," RE/ToolTrigger/Trigger "," RE/BatSwing/Trigger "};for Nb,Gb in a(Yb)do Nb=NetworkingRemotes;local a=Nb:FindFirstChild(Gb);if a then V(a.OnClientEvent,function()end);end;end;Yb=n();if Yb then V(Yb.ChildAdded,function()end);V(Yb.ChildRemoved,function()end);end;end;local function n(a)local Yb=ChilliState;Yb.invisBusy=true;local Nb,Gb=a:WaitForChild(" Humanoid ",10),a:WaitForChild(" HumanoidRootPart ",10);a:WaitForChild(" Head ",10);if Nb then if not(Gb)then Yb=ChilliState;b=false;Yb.invisBusy=false;return;end;else local Sb=ChilliState;b=false;Sb.invisBusy=false;return;end;task.wait(0.05);pcall(Nb.UnequipTools,Nb);pcall(Nb.UnequipTools,Nb);for Sb=1,2,1 do pcall(replicatesignal,Nb.ServerBreakJoints);end;local Sb,Xb=Nb.HipHeight,Gb.CFrame;Gb.Anchored=true;Nb.HipHeight=999;for Hb,Hb in ipairs(a:GetDescendants())do if Hb:IsA(" Accessory ")then Hb.Parent=nil;elseif Hb:IsA(" BasePart ")then if Hb~=Gb then if not(Hb:FindFirstAncestorOfClass(" Accessory "))then Hb.Parent=nil;end;end;end;end;task.wait(0.12);Yb,Nb=Instance.new(" Part "),Vector3.new;Yb.Name,Yb.Size=" RightHand ",Nb(0.2,0.2,0.2);Yb.Transparency=1;Yb.CanCollide=false;Yb.CanTouch=false;Yb.CanQuery=false;Yb.Massless=true;Yb.Parent=a;local Nb,Hb=Instance.new(" Motor6D "),CFrame.new;Nb.Name,Nb.C0=" RightWrist ",Hb(1.2,0,0);Nb.Part0=Gb;Nb.Part1=Yb;Nb.Parent=Gb;Gb.CanCollide=false;task.delay(0.2,function()if Gb.Parent then Gb.CanCollide=true;end;end);for Nb,Nb in ipairs(a:GetChildren())do if Nb:IsA(" Humanoid ")then Nb.AutomaticScalingEnabled=false;Nb.HipHeight=Sb;end;end;a:SetAttribute(" InvisHip ",Sb);if Gb.Position.Y>Xb.Y+5 then Gb.CFrame=Xb;end;Yb=Vector3.zero;Gb.AssemblyLinearVelocity=Yb;Gb.Anchored=false;a:SetAttribute(" InvisApplied ,true ) ;
Sb=ChilliState ;
Sb.invisSettle=os.clock ( ) +1 ;
Xb=ChilliState ;
b=false ;
Xb.invisBusy=false ;
task.delay ( 1,tb ) ;
end ;
local function a ( ) local tb,Yb=Y[4] ;
if tb then
Yb=tb ;
else
local Nb=ChilliState ;
local Gb=Nb.queue ;
if Gb then
Nb=ChilliState ;
Yb=Nb.queue[1] ;
else
Yb=Gb ;
end ;
end ;
local Nb,Gb=Yb~= 