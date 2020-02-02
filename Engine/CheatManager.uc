//=============================================================================
// CheatManager
// Object within playercontroller that manages "cheat" commands
// only spawned in single player mode
//=============================================================================

class CheatManager extends Object within PlayerController
	native;

var rotator LockedRotation;

var bool bCheatsEnabled;

/* Used for correlating game situation with log file
*/

exec function ReviewJumpSpots(name TestLabel)
{
	if ( TestLabel == 'Transloc' )
		TestLabel = 'Begin';
	else if ( TestLabel == 'Jump' )
		TestLabel = 'Finished';
	else if ( TestLabel == 'Combo' )
		TestLabel = 'FinishedJumping';
	else if ( TestLabel == 'LowGrav' )
		TestLabel = 'FinishedComboJumping';
	log("TestLabel is "$TestLabel);
	Level.Game.ReviewJumpSpots(TestLabel);
}

exec function ListDynamicActors()
{
	local Actor A;
	local int i;

	ForEach DynamicActors(class'Actor',A)
	{
		i++;
		log(i@A);
	}
	log("Num dynamic actors: "$i);
}

exec function FreezeFrame(float delay)
{
	Level.Game.SetPause(true,outer);
	Level.PauseDelay = Level.TimeSeconds + delay;
}

exec function WriteToLog( string Param )
{
	log("NOW!" $ Eval(Param != "", " '" $ Param $ "'", ""));
}

exec function SetFlash(float F)
{
	FlashScale.X = F;
}

exec function SetFogR(float F)
{
	FlashFog.X = F;
}

exec function SetFogG(float F)
{
	FlashFog.Y = F;
}

exec function SetFogB(float F)
{
	FlashFog.Z = F;
}

exec function KillViewedActor()
{
	if ( ViewTarget != None )
	{
		if ( (Pawn(ViewTarget) != None) && (Pawn(ViewTarget).Controller != None) )
			Pawn(ViewTarget).Controller.Destroy();
		ViewTarget.Destroy();
		SetViewTarget(None);
		ReportCheat("KillViewedActor");
	}
}

/* LogScriptedSequences()
Toggles logging of scripted sequences on and off
*/
exec function LogScriptedSequences()
{
	local AIScript S;

	ForEach AllActors(class'AIScript',S)
		S.bLoggingEnabled = !S.bLoggingEnabled;
}

/* Teleport()
Teleport to surface player is looking at
*/
exec function Teleport()
{
	local actor HitActor;
	local vector HitNormal, HitLocation;
	if (!areCheatsEnabled()) return;

	HitActor = Trace(HitLocation, HitNormal, ViewTarget.Location + 10000 * vector(Rotation),ViewTarget.Location, true);
	if ( HitActor == None )
		HitLocation = ViewTarget.Location + 10000 * vector(Rotation);
	else
		HitLocation = HitLocation + ViewTarget.CollisionRadius * HitNormal;

	ViewTarget.SetLocation(HitLocation);
	ReportCheat("Teleport");
}

/*
Scale the player's size to be F * default size
*/
exec function ChangeSize( float F )
{
	if ( Pawn.SetCollisionSize(Pawn.Default.CollisionRadius * F,Pawn.Default.CollisionHeight * F) )
	{
		Pawn.SetDrawScale(F);
		Pawn.SetLocation(Pawn.Location);
	}
}

exec function LockCamera()
{
	local vector LockedLocation;
	local rotator LockedRot;
	local actor LockedActor;

	if ( !bCameraPositionLocked )
	{
		PlayerCalcView(LockedActor,LockedLocation,LockedRot);
		Outer.SetLocation(LockedLocation);
		LockedRotation = LockedRot;
		SetViewTarget(outer);
	}
	else
		SetViewTarget(Pawn);

	bCameraPositionLocked = !bCameraPositionLocked;
	bBehindView = bCameraPositionLocked;
	bFreeCamera = false;
}

exec function SetCameraDist( float F )
{
	CameraDist = FMax(F,2);
}

/* Stop interpolation
*/
exec function EndPath()
{
}

/*
Camera and pawn aren't rotated together in behindview when bFreeCamera is true
*/
exec function FreeCamera( bool B )
{
	bFreeCamera = B;
	bBehindView = B;
}


exec function CauseEvent( name EventName )
{
	TriggerEvent( EventName, Pawn, Pawn);
}


exec function Amphibious()
{
	if (!areCheatsEnabled()) return;
	Pawn.UnderwaterTime = +999999.0;
	ReportCheat("Amphibious");
}

exec function Fly()
{
	if (!areCheatsEnabled()) return;
	if ( (Pawn != None) && Pawn.CheatFly() )
	{
		ClientMessage("You feel much lighter");
		bCheatFlying = true;
		Outer.GotoState('PlayerFlying');
		ReportCheat("Fly");
	}
}

exec function Walk()
{
	bCheatFlying = false;
	if ( (Pawn != None) && Pawn.CheatWalk() )
		ClientReStart(Pawn);
}

exec function Ghost()
{
	if (!areCheatsEnabled()) return;
	if ( (Pawn != None) && Pawn.CheatGhost() )
	{
		ClientMessage("You feel ethereal");
		bCheatFlying = true;
		Outer.GotoState('PlayerFlying');
		ReportCheat("Ghost");
	}
}

exec function AllAmmo()
{
	local Inventory Inv;
	if (!areCheatsEnabled()) return;

	for( Inv=Pawn.Inventory; Inv!=None; Inv=Inv.Inventory )
		if ( Weapon(Inv)!=None )
			Weapon(Inv).SuperMaxOutAmmo();

    AwardAdrenaline( 999 );
	ReportCheat("AllAmmo");
}

exec function Invisible(bool B)
{
	if (!areCheatsEnabled()) return;
	Pawn.bHidden = B;

	if (B)
		Pawn.Visibility = 0;
	else
		Pawn.Visibility = Pawn.Default.Visibility;
	ReportCheat("Invisible");
}

exec function Phil()
{
	if (!areCheatsEnabled()) return;
	if( !bGodMode )
	{
		bGodMode = true;
		ClientMessage("phil == god");
		ReportCheat("God");
	}
	else
	{
		bGodMode = false;
		ClientMessage("you're not phil!");
	}
}

exec function God()
{
	if (!areCheatsEnabled()) return;
	if ( bGodMode )
	{
		bGodMode = false;
		ClientMessage("God mode off");
		return;
	}

	bGodMode = true;
	ClientMessage("God Mode on");
	ReportCheat("God");
}

exec function SloMo( float T )
{
	if (!areCheatsEnabled()) return;
	Level.Game.SetGameSpeed(T);
	Level.Game.SaveConfig();
	Level.Game.GameReplicationInfo.SaveConfig();
	ReportCheat("SloMo");
}

exec function SetJumpZ( float F )
{
	if (!areCheatsEnabled()) return;
	Pawn.JumpZ = F;
	ReportCheat("SetJumpZ");
}

exec function SetGravity( float F )
{
	if (!areCheatsEnabled()) return;
	PhysicsVolume.Gravity.Z = F;
	ReportCheat("SetGravity");
}

exec function SetSpeed( float F )
{
	if (!areCheatsEnabled()) return;
	Pawn.GroundSpeed = Pawn.Default.GroundSpeed * f;
	Pawn.WaterSpeed = Pawn.Default.WaterSpeed * f;
	ReportCheat("SetSpeed");
}

exec function KillPawns()
{
	if (!areCheatsEnabled()) return;
	KillAllPawns(class'Pawn');
	ReportCheat("KillPawns");
}

/* Avatar()
Possess a pawn of the requested class
*/
exec function Avatar( string ClassName )
{
	local class<actor> NewClass;
	local Pawn P;

	NewClass = class<actor>( DynamicLoadObject( ClassName, class'Class' ) );
	if( NewClass!=None )
	{
		Foreach DynamicActors(class'Pawn',P)
		{
			if ( (P.Class == NewClass) && (P != Pawn) )
			{
				if ( Pawn.Controller != None )
					Pawn.Controller.PawnDied(Pawn);
				Possess(P);
				break;
			}
		}
	}
}

exec function Summon( string ClassName )
{
	local class<actor> NewClass;
	local vector SpawnLoc;

	if (!areCheatsEnabled()) return;

	log( "Fabricate " $ ClassName );
	NewClass = class<actor>( DynamicLoadObject( ClassName, class'Class' ) );
	if( NewClass!=None )
	{
		if ( Pawn != None )
			SpawnLoc = Pawn.Location;
		else
			SpawnLoc = Location;
		Spawn( NewClass,,,SpawnLoc + 72 * Vector(Rotation) + vect(0,0,1) * 15 );
	}
	ReportCheat("Summon");
}

exec function PlayersOnly()
{
	if (!areCheatsEnabled()) return;
	Level.bPlayersOnly = !Level.bPlayersOnly;
	ReportCheat("PlayersOnly");
}

exec function FreezeAll()
{
	if (!areCheatsEnabled()) return;
	Level.bPlayersOnly = !Level.bPlayersOnly;
	Level.bFreezeKarma = Level.bPlayersOnly;
	ReportCheat("FreezeAll");
}

exec function ClearAllDebugLines()
{
    local actor A;

    foreach AllActors(class'Actor', A)
        A.ClearStayingDebugLines();
}

exec function CheatView( class<actor> aClass, optional bool bQuiet )
{
	ViewClass(aClass,bQuiet, true);
}

// ***********************************************************
// Navigation Aids (for testing)

// remember spot for path testing (display path using ShowDebug)
exec function RememberSpot()
{
	if ( Pawn != None )
		Destination = Pawn.Location;
	else
		Destination = Location;
}

// ***********************************************************
// Changing viewtarget

exec function ViewSelf(optional bool bQuiet)
{
	bBehindView = false;
	bViewBot = false;
	if ( Pawn != None )
		SetViewTarget(Pawn);
	else
		SetViewtarget(outer);
	if (!bQuiet )
		ClientMessage(OwnCamera, 'Event');
	FixFOV();
}

exec function ViewPlayer( string S )
{
	local Controller P;

	for ( P=Level.ControllerList; P!=None; P= P.NextController )
		if ( P.bIsPlayer && (P.PlayerReplicationInfo.PlayerName ~= S) )
			break;

	if ( P.Pawn != None )
	{
		ClientMessage(ViewingFrom@P.PlayerReplicationInfo.PlayerName, 'Event');
		SetViewTarget(P.Pawn);
	}

	bBehindView = ( ViewTarget != Pawn );
	if ( bBehindView )
		ViewTarget.BecomeViewTarget();
}

exec function ViewActor( name ActorName)
{
	local Actor A;

	ForEach AllActors(class'Actor', A)
		if ( A.Name == ActorName )
		{
			SetViewTarget(A);
			bBehindView = true;
			return;
		}
}

exec function ViewFlag()
{
	local Controller C;

	For ( C=Level.ControllerList; C!=None; C=C.NextController )
		if ( C.IsA('AIController') && (C.PlayerReplicationInfo != None) && (C.PlayerReplicationInfo.HasFlag != None) )
		{
			SetViewTarget(C.Pawn);
			return;
		}
}

exec function ViewBot()
{
	local actor first;
	local bool bFound;
	local Controller C;

	bViewBot = true;
	For ( C=Level.ControllerList; C!=None; C=C.NextController )
		if ( C.IsA('Bot') && (C.Pawn != None) )
	{
		if ( bFound || (first == None) )
		{
			first = C;
			if ( bFound )
				break;
		}
		if ( C == RealViewTarget )
			bFound = true;
	}

	if ( first != None )
	{
		SetViewTarget(first);
		bBehindView = true;
		ViewTarget.BecomeViewTarget();
		FixFOV();
	}
	else
		ViewSelf(true);
}

exec function ViewTurret()
{
	local actor first;
	local bool bFound;
	local Controller C;

	bViewBot = true;
	For ( C=Level.ControllerList; C!=None; C=C.NextController )
		if ( C.IsA('AIController') && (C.Pawn != None) && !C.IsA('Bot') )
	{
		if ( bFound || (first == None) )
		{
			first = C.Pawn;
			if ( bFound )
				break;
		}
		if ( C.Pawn == ViewTarget )
			bFound = true;
	}

	if ( first != None )
	{
		SetViewTarget(first);
		bBehindView = true;
		ViewTarget.BecomeViewTarget();
		FixFOV();
	}
	else
		ViewSelf(true);
}

exec function ViewClass( class<actor> aClass, optional bool bQuiet, optional bool bCheat )
{
	local actor other, first;
	local bool bFound;

	if ( !bCheat && (Level.Game != None) && !Level.Game.bCanViewOthers )
		return;

	first = None;

	ForEach AllActors( aClass, other )
	{
		if ( bFound || (first == None) )
		{
			first = other;
			if ( bFound )
				break;
		}
		if ( other == ViewTarget )
			bFound = true;
	}

	if ( first != None )
	{
		if ( !bQuiet )
		{
			if ( Pawn(first) != None )
				ClientMessage(ViewingFrom@First.GetHumanReadableName(), 'Event');
			else
				ClientMessage(ViewingFrom@first, 'Event');
		}
		SetViewTarget(first);
		bBehindView = ( ViewTarget != outer );

		if ( bBehindView )
			ViewTarget.BecomeViewTarget();

		FixFOV();
	}
	else
		ViewSelf(bQuiet);
}

exec function Loaded()
{
	local Inventory Inv;
	if (!areCheatsEnabled()) return;

	if( Level.Netmode!=NM_Standalone )
		return;

    AllWeapons();
    AllAmmo();

    if ( Pawn != None )
		For ( Inv=Pawn.Inventory; Inv!=None; Inv=Inv.Inventory )
			if ( Weapon(Inv) != None )
				Weapon(Inv).Loaded();
	ReportCheat("Loaded");
}

exec function AllWeapons()
{
	if (!areCheatsEnabled()) return;
	if( (Level.Netmode!=NM_Standalone) || (Pawn == None) || (Vehicle(Pawn) != None) )
		return;

	Pawn.GiveWeapon("XWeapons.AssaultRifle");
	Pawn.GiveWeapon("XWeapons.RocketLauncher");
	Pawn.GiveWeapon("XWeapons.ShockRifle");
	Pawn.GiveWeapon("XWeapons.ShieldGun");
	Pawn.GiveWeapon("XWeapons.LinkGun");
	Pawn.GiveWeapon("XWeapons.SniperRifle");
	Pawn.GiveWeapon("XWeapons.FlakCannon");
	Pawn.GiveWeapon("XWeapons.MiniGun");
	Pawn.GiveWeapon("XWeapons.TransLauncher");
	Pawn.GiveWeapon("XWeapons.Painter");
	Pawn.GiveWeapon("XWeapons.BioRifle");
	Pawn.GiveWeapon("XWeapons.Redeemer");
	Pawn.GiveWeapon("UTClassic.ClassicSniperRifle");
	Pawn.GiveWeapon("Onslaught.ONSGrenadeLauncher");
	Pawn.GiveWeapon("Onslaught.ONSAVRiL");
	Pawn.GiveWeapon("Onslaught.ONSMineLayer");
	Pawn.GiveWeapon("OnslaughtFull.ONSPainter");

	ReportCheat("AllWeapons");
}

// Win and skip the current ladder match, if in single-player mode
exec function SkipMatch()
{
	if (!areCheatsEnabled()) return;
	if( (Level.Netmode!=NM_Standalone) || (Pawn == None) )
		return;

	ReportCheat("SkipMatch");
	if ( Level.Game.CurrentGameProfile != none ) {
		Level.Game.CurrentGameProfile.CheatSkipMatch(Level.Game);
	}
}

// jump to a specific match in the ladders
// combine the ladder/rung into one number, i.e., 54 = ladder 5, rung 4
exec function JumpMatch(int ladderrung)
{
	if (!areCheatsEnabled()) return;
	if( (Level.Netmode!=NM_Standalone) || (Pawn == None) )
		return;

	if (ladderrung < 0) {
		return;
	}

	ReportCheat("JumpMatch");
	if ( Level.Game.CurrentGameProfile != none ) {
		Level.Game.CurrentGameProfile.CheatJumpMatch(Level.Game, ladderrung);
	}
}

exec function WinMatch()
{
	if (!areCheatsEnabled()) return;
	ReportCheat("WinMatch");
	if (PlayerReplicationInfo.Team != none)
	{
		PlayerReplicationInfo.Team.Score = Level.Game.GoalScore;
	}
	else {
		PlayerReplicationInfo.Score = Level.Game.GoalScore;
	}
	Level.Game.CheckScore(PlayerReplicationInfo);
}

exec function EnableCheats()
{
	bCheatsEnabled=true;
	ClientMessage("Cheats enabled");
}

/** check if cheats are enabled, if not playing a SP game always return true */
function bool areCheatsEnabled()
{
	if ( Level.Game.CurrentGameProfile != none )
	{
		if (!bCheatsEnabled)
		{
			ClientMessage("Cheats are NOT enabled, to enable cheats type: EnableCheats");
			ClientMessage("Enabling cheats prevents you from unlocking the bonus characters");
		}
		return bCheatsEnabled;
	}
	return true;
}

// report the cheat used
function ReportCheat(optional string cheat)
{
	if ( Level.Game.CurrentGameProfile != none ) {
		Level.Game.CurrentGameProfile.ReportCheat(outer, cheat);
	}
}

exec function WeakObjectives()
{
	if (!areCheatsEnabled()) return;
	ReportCheat("WeakObjectives");
	Level.Game.WeakObjectives();
}

exec function DisableNextObjective()
{
	if (!areCheatsEnabled()) return;
	ReportCheat("DisableNextObjective");
	Level.Game.DisableNextObjective();
}
exec function ruler()
{
	local NavigationPoint N;

	ForEach AllActors(class'NavigationPoint',N)
		if ( N.IsA('ONSPowerCore') )
			N.Bump(Pawn);
}

defaultproperties
{
}
