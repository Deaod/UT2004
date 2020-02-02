//=============================================================================
// Weapon_LinkTurret
//=============================================================================
// Created by Laurent Delayen
// © 2003, Epic Games, Inc.  All Rights Reserved
//=============================================================================

class Weapon_LinkTurret extends LinkGun
    config(user)
    HideDropDown
	CacheExempt;

#exec OBJ LOAD FILE=..\Animations\AS_VehiclesFull_M.ukx

simulated function UpdateLinkColor( LinkAttachment.ELinkColor Color )
{
	if ( FireMode[1] != None )
		LinkFire(FireMode[1]).UpdateLinkColor( Color );

	switch ( Color )
	{
		case LC_Gold	:	Skins[2] = material'PowerPulseShaderYellow';	break;
		case LC_Green	:	Skins[2] = material'PowerPulseShader';			break;
		case LC_Red		: 	Skins[2] = material'PowerPulseShaderRed';		break;
		case LC_Blue	: 	Skins[2] = material'PowerPulseShaderBlue';		break;
	}
	Skins[0] = Combiner'AS_Weapons_TX.LinkTurret.LinkTurret_Skin1_C';
}

simulated function vector GetEffectStart()
{
	return ASVehicle(Instigator).GetFireStart();
}

simulated function IncrementFlashCount(int mode)
{
    super(Weapon).IncrementFlashCount( mode );

	if ( ThirdPersonActor != None && LinkAttachment(ThirdPersonActor) != None )
        LinkAttachment(ThirdPersonActor).Links = Links;
}

simulated function PawnUnpossessed()
{
	if ( Instigator != None && PlayerController(Instigator.Controller) != None )
		PlayerController(Instigator.Controller).DesiredFOV = PlayerController(Instigator.Controller).DefaultFOV;

	// If was linking to somebody, unlink...
	if ( ThirdPersonActor != None && LinkAttachment(ThirdPersonActor).LinkColor != LC_Gold )
		LinkAttachment(ThirdPersonActor).SetLinkColor( LC_Green );

	super.PawnUnpossessed();
}

/* BestMode()
choose between regular or alt-fire
*/
function byte BestMode()
{
	local float			EnemyDist;
	local bot			B;
	//local Controller	C;

	B = Bot(Instigator.Controller);
	if ( B == None )
	{
		return 0;
		/*
		C = Instigator.Controller;
		if ( C.Enemy == None || C.Enemy.IsA('Vehicle')
			|| VSize(C.Enemy.Location - C.Pawn.Location) > LinkFire(FireMode[1]).TraceRange )
			return 0;

		return 1;
		*/
	}

	if ( DestroyableObjective(B.Squad.SquadObjective) != None && DestroyableObjective(B.Squad.SquadObjective).TeamLink(B.GetTeamNum())
	     && VSize(B.Squad.SquadObjective.Location - B.Pawn.Location) < FireMode[1].MaxRange() && (B.Enemy == None || !B.CanSee(B.Enemy)) )
		return 1;

	if ( FocusOnLeader(B.Focus == B.Squad.SquadLeader.Pawn) )
	{
		B.Focus = B.Squad.SquadLeader.Pawn;
		return 1;
	}

	if ( B.Enemy == None )
		return 0;

	EnemyDist = VSize(B.Enemy.Location - Instigator.Location);
	if ( EnemyDist > LinkFire(FireMode[1]).TraceRange )
		return 0;
	return 1;
}

simulated event WeaponTick(float dt)
{
	if ( (FireMode[1] != None) && !FireMode[1].bIsFiring && (ThirdPersonActor != None) )
	{
		if ( Links > 0 )
			LinkAttachment(ThirdPersonActor).SetLinkColor( LC_Gold );
		else
			LinkAttachment(ThirdPersonActor).SetLinkColor( LC_Green );
	}
	else if ( Level.NetMode != NM_DedicatedServer && ThirdPersonActor != None )
		LinkAttachment(ThirdPersonActor).UpdateLinkColor();

	super.WeaponTick( dt );
}

//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     FireModeClass(0)=Class'UT2k4AssaultFull.FM_LinkTurret_Fire'
     FireModeClass(1)=Class'UT2k4AssaultFull.FM_LinkTurret_AltFire'
     SelectSound=None
     bCanThrow=False
     bNoInstagibReplace=True
     OldMesh=None
     OldPickup=
     EffectOffset=(X=0.000000,Y=0.000000,Z=0.000000)
     DisplayFOV=90.000000
     Priority=1
     SmallViewOffset=(X=-25.000000,Z=-160.000000)
     CenteredRoll=0
     InventoryGroup=1
     PickupClass=None
     PlayerViewOffset=(X=-25.000000,Y=0.000000,Z=-160.000000)
     PlayerViewPivot=(Yaw=0)
     AttachmentClass=Class'UT2k4AssaultFull.WA_LinkTurret'
     IconMaterial=None
     ItemName="Turret weapon"
     Mesh=SkeletalMesh'AS_VehiclesFull_M.LinkTurret_FP'
     DrawScale=0.750000
     AmbientGlow=64
}
