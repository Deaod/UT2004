class TurretController extends AIController;

function rotator AdjustAim(FireProperties FiredAmmunition, vector projStart, int aimerror)
{
	if ( (FRand() < 0.2) && (Enemy != None) && (Enemy.Controller != None) )
		Enemy.Controller.ReceiveWarning(Pawn, -1, vector(Rotation)); 

    return Rotation;
}

function Possess(Pawn aPawn)
{
	super.Possess( aPawn );

	if ( Level.NetMode != NM_Standalone )
	{
		Skill = 6;
		FocusLead = 0.000042;
	}
	else
	{
		Skill = Level.Game.GameDifficulty;
		
		if ( Skill > 3 )
			FocusLead = (0.07 * FMin(Skill,7))/10000; 
	}
}

simulated function int GetTeamNum()
{
	if ( Vehicle(Pawn) != None )
		return Vehicle(Pawn).Team;
		
	return super.GetTeamNum();
}

function bool IsTargetRelevant( Pawn Target )
{
	if ( (Target != None) && (Target.Controller != None) && !SameTeamAs(Target.Controller) 
		&& (Target.Health > 0) && VSize(Target.Location-Pawn.Location) < Pawn.SightRadius*1.25 )
		return true;

	return false;
}

// FIXME -- Implement this in Pawn to support ONS weapon system.
function bool IsTurretFiring()
{
	if ( (Pawn.Weapon != None) && Pawn.Weapon.IsFiring() )
		return true;

	return false;
}

auto state Searching
{
	event SeePlayer(Pawn SeenPlayer)
	{
		if ( IsTargetRelevant( SeenPlayer ) )
		{
			Enemy = SeenPlayer;
			GotoState('Engaged');
		}	
	}

	function ScanRotation()
	{
		local actor HitActor;
		local vector HitLocation, HitNormal, Dir;
		local float BestDist, Dist;
		local rotator Pick;
		
		DesiredRotation.Yaw = 0;
		DesiredRotation.Pitch = Rotation.Pitch + 16384 + Rand(32768); 
		Dir = vector(DesiredRotation);
		
		// check new pitch not a blocked direction
		HitActor = Trace(HitLocation,HitNormal,Pawn.Location + 2000 * Dir,Pawn.Location,false);
		if ( HitActor == None )
			return;
		BestDist = vsize(HitLocation - Pawn.Location);
		Pick = DesiredRotation;
		
		DesiredRotation.Pitch += 32768;
		Dir = vector(DesiredRotation);
		// check new pitch not a blocked direction
		HitActor = Trace(HitLocation,HitNormal,Pawn.Location + 2000 * Dir,Pawn.Location,false);
		if ( HitActor == None )
			return;
		Dist = vsize(HitLocation - Pawn.Location);
		if ( Dist > BestDist )
		{
			BestDist = Dist;
			Pick = DesiredRotation;
		}
		
		DesiredRotation.Pitch += 16384;
		Dir = vector(DesiredRotation);
		// check new pitch not a blocked direction
		HitActor = Trace(HitLocation,HitNormal,Pawn.Location + 2000 * Dir,Pawn.Location,false);
		if ( HitActor == None )
			return;
		Dist = vsize(HitLocation - Pawn.Location);
		if ( Dist > BestDist )
		{
			BestDist = Dist;
			Pick = DesiredRotation;
		}

		DesiredRotation.Pitch += 32768;
		Dir = vector(DesiredRotation);
		// check new pitch not a blocked direction
		HitActor = Trace(HitLocation,HitNormal,Pawn.Location + 2000 * Dir,Pawn.Location,false);
		if ( HitActor == None )
			return;
		Dist = vsize(HitLocation - Pawn.Location);
		if ( Dist > BestDist )
		{
			BestDist = Dist;
			Pick = DesiredRotation;
		}
		
		DesiredRotation = Pick;
	}	

	function BeginState()
	{
		Enemy = None;
		Focus = None;
		StopFiring();
	}
	
Begin:
	ScanRotation();	
	FocalPoint = Pawn.Location + 1000 * vector(DesiredRotation);
	Sleep(2 + 3*FRand());
	Goto('Begin');
}


state Engaged
{
	function EnemyNotVisible()
	{
		if ( IsTargetRelevant( Enemy ) )
		{
			Focus = None;
			FocalPoint = LastSeenPos;
			GotoState('WaitForTarget');
			return;
		}
		GotoState('Searching');
	}

	function BeginState()
	{
		Focus = Enemy.GetAimTarget();
		Target = Enemy;
		bFire = 1;
		if ( Pawn.Weapon != None )	
			Pawn.Weapon.BotFire(false);
	}
	
Begin:
	Sleep(1.0);
	if ( !IsTargetRelevant( Enemy ) || !IsTurretFiring() )
		GotoState('Searching');
	Goto('Begin');
}

State WaitForTarget
{
	event SeePlayer(Pawn SeenPlayer)
	{
		if ( IsTargetRelevant( SeenPlayer ) )
		{
			Enemy = SeenPlayer;
			GotoState('Engaged');
		}	
	}

	function BeginState()
	{
		Target = Enemy;
		bFire = 1;
		if ( Pawn.Weapon != None )	
			Pawn.Weapon.BotFire(false);
	}

Begin:
	Sleep( GetWaitForTargetTime() );
	GotoState('Searching'); 
}

function float GetWaitForTargetTime()
{
	return (3 + 5 * FRand());
}

defaultproperties
{
     bSlowerZAcquire=False
     RotationRate=(Pitch=32768,Yaw=60000,Roll=0)
}
