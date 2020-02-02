//=============================================================================
// JumpSpot.
// specifies positions that can be reached with greater than normal jump
// forced paths will check for greater than normal jump capability
//=============================================================================
class JumpSpot extends JumpDest
	placeable;

var() bool bOnlyTranslocator;
var   bool bRealOnlyTranslocator;
var() bool bNeverImpactJump;
var() bool bNoLowGrav;
var() bool bForceAllowDoubleJumping;	// LD promises that bot can really make this double jump (for ones the conservative AI code says would barely fail)
var() bool bDodgeUp;
var() name TranslocTargetTag;			// target to transloc toward
var() float TranslocZOffset;
var Actor TranslocTarget;
var vector CachedSpeed[8];

function PostBeginPlay()
{
	Super.PostBeginPlay();
	bRealOnlyTranslocator = bOnlyTranslocator; // used for JumpSpot testing
}

function bool CanMakeJump(Pawn Other, Float JumpHeight, Float GroundSpeed, Int Num, Actor Start, bool bForceCheck)
{
	local vector V,S;
	
	if ( Other.Physics == PHYS_Flying )
		return true;
	if ( bDodgeUp || (JumpPad(Start) != None) )
		return true;
		
	if ( !bForceCheck && (PhysicsVolume.Gravity.Z >= CalculatedGravityZ[Num]) )
	{
		if ( NeededJump[Num].Z < JumpHeight )
			return true;
		if ( PhysicsVolume.Gravity.Z == CalculatedGravityZ[Num] )
			return false;
	}
 
	if ( bForceDoubleJump )
		GroundSpeed = FMax(GroundSpeed, Other.Default.GroundSpeed);
	if ( (CachedSpeed[Num].X <= JumpHeight) && (CachedSpeed[Num].Y <= GroundSpeed) )
		return ( CachedSpeed[Num].Z < JumpHeight );
	S = Start.Location;
	S.Z = S.Z - Start.CollisionHeight + Other.CollisionHeight;
	V = SuggestFallVelocity(Location, S, 2*JumpHeight, GroundSpeed);
	CachedSpeed[Num].X = JumpHeight;
	CachedSpeed[Num].Y = GroundSpeed;
	CachedSpeed[Num].Z = V.Z;
	//log(self$" jumpZ "$JumpHeight$" groundSpeed "$groundspeed$" suggested Z "$V.Z$" from "$Start);
	return ( V.Z < JumpHeight );	
}	
function bool CanDoubleJump(Pawn Other)
{
	return ( bForceDoubleJump || Other.bCanDoubleJump || (PhysicsVolume.Gravity.Z > PhysicsVolume.Default.Gravity.Z) );
}
	
function float EffectiveDoubleJump(ReachSpec Path)
{
	// if its about distance, then effective is doubled
	if ( Path != None && Path.Start != None && Path.End != None &&  ( Path.Start.Location.Z >= Path.End.Location.Z + 32 ) )
		return 1.9;
	return 1.5;
}
	
event int SpecialCost(Pawn Other, ReachSpec Path)
{
	local int Num;
	local vector DodgeV;
	local float AllowedJumpZ, RealGroundSpeed;

	if ( Vehicle(Other) != None )
		return 10000000;	
	if ( Other.Physics == PHYS_Flying )
		return 100;
	if ( Other.Controller.bAllowedToTranslocate )
		return 200;

	if ( bOnlyTranslocator || (bNoLowGrav && (PhysicsVolume.Gravity.Z > PhysicsVolume.Default.Gravity.Z)) )
		return 10000000;
			
	Num = GetPathIndex(Path);
	
	if ( CanDoubleJump(Other) )
	{
		if ( bDodgeUp || bForceAllowDoubleJumping )
			return 100;
		AllowedJumpZ = Other.JumpZ * EffectiveDoubleJump(Path);
	}
	else
	{
		if ( bDodgeUp )
			return 10000000;
		AllowedJumpZ = Other.JumpZ;
	}
		
	if ( CanMakeJump(Other,AllowedJumpZ,Other.GroundSpeed,Num,Path.Start,false) ) 
		return 100;

	if ( (Path.Distance > 1000)
		&& (PhysicsVolume.Gravity.Z > PhysicsVolume.Default.Gravity.Z)
		&& (UnrealPawn(Other) != None) )
	{
		if ( bForceDoubleJump )
		{
			RealGroundSpeed = Other.GroundSpeed;
			Other.GroundSpeed = Other.Default.GroundSpeed;
			DodgeV = UnrealPawn(Other).BotDodge(vect(1,0,0));
			Other.GroundSpeed = RealGroundSpeed;
		}
		else
			DodgeV = UnrealPawn(Other).BotDodge(vect(1,0,0));
		
		if ( CanMakeJump(Other,DodgeV.Z + (EffectiveDoubleJump(Other.Controller.CurrentPath) - 1)*Other.JumpZ,DodgeV.X,Num,Path.Start,true) )
			return 100;
	}
	if ( !bNeverImpactJump && (NeededJump[Num].Z <= 1100) && (bForceDoubleJump || Other.Controller.bAllowedToImpactJump) )
		return 3500;

	return 10000000;
}

event bool SuggestMovePreparation(Pawn Other)
{
	local int Num;
	local bot B;
	local float RealJumpZ, RealGroundSpeed;
	local vector DodgeV, Dir;
	
	if ( Other.Controller == None )
		return false;

	if ( bDodgeUp )
	{
		B = Bot(Other.Controller);
		if ( B == None )
			return false;
			
		// only here if can double jump
		DodgeV = UnrealPawn(Other).BotDodge(vect(1,0,0));
		UnrealPawn(Other).CurrentDir = DCLICK_Forward;
		Other.bWantsToCrouch = false;
		B.MoveTarget = self;
		B.Destination = Location;
		B.bPlannedJump = true;
		if ( (Other.Anchor != None) && Other.ReachedDestination(Other.Anchor) )
			Dir = Location - Other.Anchor.Location;
		else
			Dir = Location - Other.Location;
		Dir.Z = 0;
		Dir = Normal(Dir);
		Other.Velocity = DodgeV.X * Dir;
		Other.Velocity.Z = DodgeV.Z;
		Other.Acceleration = Other.AccelRate * Dir;
		Other.SetPhysics(PHYS_Falling);
		Other.DestinationOffset = CollisionRadius;
		B.bNotifyApex = true;
		B.bPendingDoubleJump = true;
		return false;
	}

	Num = GetPathIndex(Other.Controller.CurrentPath);
	// try translocator if landing would hurt
	if ( (Other.MaxFallSpeed < Other.Controller.CurrentPath.MaxLandingVelocity) && TryTranslocator(Other) )
		return true;
	
	if ( bNoLowGrav && (PhysicsVolume.Gravity.Z > PhysicsVolume.Default.Gravity.Z) )
		return TryTranslocator(Other);
	
	if ( !bOnlyTranslocator && CanMakeJump(Other,Other.JumpZ,Other.GroundSpeed,Num,Other.Controller.CurrentPath.Start,false) )
	{
		//log("regular jump");
		DoJump(Other);
		return false;
	}

	B = Bot(Other.Controller);
	if ( B == None )
		return false;

	if ( bOnlyTranslocator )
		return TryTranslocator(Other);
		
	if ( CanDoubleJump(Other) 
		&& (bForceAllowDoubleJumping || CanMakeJump(Other,Other.JumpZ * EffectiveDoubleJump(Other.Controller.CurrentPath),Other.GroundSpeed,Num,Other.Controller.CurrentPath.Start,false)) ) 
	{
		// log("double jump");
		RealJumpZ = Other.JumpZ;
		Other.JumpZ = Other.JumpZ * EffectiveDoubleJump(Other.Controller.CurrentPath);
		DoJump(Other);
		Other.JumpZ = RealJumpZ;
		Other.Velocity.Z = FClamp(Other.Velocity.Z - 0.5 * Other.JumpZ,0.7*Other.JumpZ,Other.JumpZ);
		B.bNotifyApex = true;
		B.bPendingDoubleJump = true;
		return false;
	}
	
	if ( (Other.Controller.CurrentPath.Distance > 1000)
		&& (PhysicsVolume.Gravity.Z > PhysicsVolume.Default.Gravity.Z)
		&& (UnrealPawn(Other) != None) )
	{
		//log("TRY DODGE JUMP");
		if ( bForceDoubleJump )
		{
			RealGroundSpeed = Other.GroundSpeed;
			Other.GroundSpeed = Other.Default.GroundSpeed;
			DodgeV = UnrealPawn(Other).BotDodge(vect(1,0,0));
			Other.GroundSpeed = RealGroundSpeed;
		}
		else
			DodgeV = UnrealPawn(Other).BotDodge(vect(1,0,0));
		
		if ( CanMakeJump(Other,DodgeV.Z + (EffectiveDoubleJump(Other.Controller.CurrentPath) - 1) * Other.JumpZ,DodgeV.X,Num,Other.Controller.CurrentPath.Start,true) )
		{
			//log("dodge jump");
			RealJumpZ = Other.JumpZ;
			RealGroundSpeed = Other.GroundSpeed;
			Other.GroundSpeed = DodgeV.X;
			Other.JumpZ = DodgeV.Z + (EffectiveDoubleJump(Other.Controller.CurrentPath) - 1) * RealJumpZ;
			UnrealPawn(Other).CurrentDir = DCLICK_Forward;
			DoJump(Other);
			Other.GroundSpeed = RealGroundSpeed;
			Other.JumpZ = RealJumpZ;
			Other.Velocity.Z = FMax(0.7*Other.JumpZ, Other.Velocity.Z - 0.5 * Other.JumpZ);
			B.bNotifyApex = true;
			B.bPendingDoubleJump = true;
			return false;
		}
	}

	if ( TryTranslocator(Other) )
		return true;

	if ( !bNeverImpactJump && (NeededJump[Num].Z < 1100) && B.CanImpactJump() )
	{
		Other.Acceleration = vect(0,0,0);
		B.bPreparingMove = true;
		B.ImpactTarget = self;
		B.Focus = None;
		B.FocalPoint = B.Location - vect(0,0,100);
		if ( Other.Weapon.IsA('ShieldGun') )
			B.ImpactJump();	
		else
			B.SwitchToBestWeapon();
		return true;
	}
	
	// try double jumping anyway
	if ( CanDoubleJump(Other) ) 
	{
		// log("fallback double jump");
		RealJumpZ = Other.JumpZ;
		Other.JumpZ = Other.JumpZ * EffectiveDoubleJump(Other.Controller.CurrentPath);
		DoJump(Other);
		Other.JumpZ = RealJumpZ;
		Other.Velocity.Z = FClamp(Other.Velocity.Z - 0.5 * Other.JumpZ,0.7*Other.JumpZ,Other.JumpZ);
		B.bNotifyApex = true;
		B.bPendingDoubleJump = true;
		return false;
	}
	
	return false;
}

function bool TryTranslocator(Pawn Other)
{
	local bot B;
	
	B = Bot(Other.Controller);
	B.TranslocationTarget = None;
	B.RealTranslocationTarget = None;
	if ( B.CanUseTranslocator() )
	{
		Other.Acceleration = vect(0,0,0);
		B.bPreparingMove = true;
		B.TranslocationTarget = self;
		B.RealTranslocationTarget = self;
		if ( TranslocTargetTag != '' )
		{
			if ( TranslocTarget == None )
				ForEach AllActors(class'Actor',TranslocTarget,TranslocTargetTag)
					break;
			if ( TranslocTarget != None )
				B.TranslocationTarget = TranslocTarget;
		}
		B.ImpactTarget = self;
		B.Focus = self;
		if ( Other.Weapon.IsA('TransLauncher') )
		{
			Other.PendingWeapon = None;
			Other.Weapon.SetTimer(0.2,false);
		}
		else
			B.SwitchToBestWeapon();
		return true;
	}
	return false;
}

defaultproperties
{
     CachedSpeed(0)=(X=1000000.000000,Y=1000000.000000,Z=1000000.000000)
     CachedSpeed(1)=(X=1000000.000000,Y=1000000.000000,Z=1000000.000000)
     CachedSpeed(2)=(X=1000000.000000,Y=1000000.000000,Z=1000000.000000)
     CachedSpeed(3)=(X=1000000.000000,Y=1000000.000000,Z=1000000.000000)
     CachedSpeed(4)=(X=1000000.000000,Y=1000000.000000,Z=1000000.000000)
     CachedSpeed(5)=(X=1000000.000000,Y=1000000.000000,Z=1000000.000000)
     CachedSpeed(6)=(X=1000000.000000,Y=1000000.000000,Z=1000000.000000)
     CachedSpeed(7)=(X=1000000.000000,Y=1000000.000000,Z=1000000.000000)
}
