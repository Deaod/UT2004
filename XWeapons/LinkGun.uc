//=============================================================================
// Link Gun
//=============================================================================
class LinkGun extends Weapon
    config(user);

#EXEC OBJ LOAD FILE=InterfaceContent.utx

var() int Links;
var() bool Linking;

replication
{
    unreliable if (Role == ROLE_Authority)
        Linking, Links;
}

simulated function UpdateLinkColor( LinkAttachment.ELinkColor Color )
{
	if ( FireMode[1] != None )
		LinkFire(FireMode[1]).UpdateLinkColor( Color );

	if ( Mesh == OldMesh )	// no support for old mesh
		return;

	switch ( Color )
	{
		case LC_Green	:	Skins[0] = material'LinkgunShader';
							Skins[1] = material'PowerPulseShader';
							break;
		case LC_Red		: 	Skins[0] = material'LinkgunRedShader';
							Skins[1] = material'PowerPulseShaderRed';
							break;
		case LC_Blue	: 	Skins[0] = material'LinkgunBlueShader';
							Skins[1] = material'PowerPulseShaderBlue';
							break;
		case LC_Gold	:	Skins[0] = material'LinkgunYellowShader';
							Skins[1] = material'PowerPulseShaderYellow';
							break;
	}
}

simulated function bool HasAmmo()
{
	return ( AmmoClass[0] != None && FireMode[0] != None && AmmoCharge[0] >= 1 );
}

simulated event RenderOverlays( Canvas Canvas )
{
	if ( (FireMode[1] != None) && !FireMode[1].bIsFiring && (ThirdPersonActor != None) )
	{
		if ( Links > 0 )
			LinkAttachment(ThirdPersonActor).SetLinkColor( LC_Gold );
		else
			LinkAttachment(ThirdPersonActor).SetLinkColor( LC_Green );
	}
	super.RenderOverlays( Canvas );
}

simulated function vector GetEffectStart()
{
    local Vector X,Y,Z, Offset;
	local float Extra;

    // 1st person
    if ( Instigator.IsFirstPerson() )
    {
        if ( WeaponCentered() )
			return CenteredEffectStart();

        GetViewAxes(X, Y, Z);
        if ( class'PlayerController'.Default.bSmallWeapons )
			Offset = SmallEffectOffset;
		else
			Offset = EffectOffset;

		if ( Hand == 0 )
		{
			if ( bUseOldWeaponMesh )
				Offset.Z -= 10;
			else
				Offset.Z -= 14;
			Extra = 3;
		}
		else if ( !bUseOldWeaponMesh )
			Offset.Z -= 10;

		return (Instigator.Location +
				Instigator.CalcDrawOffset(self) +
				Offset.X * X  +
				(Offset.Y * Hand + Extra) * Y +
				Offset.Z * Z);
    }
    // 3rd person
    else
    {
        return (Instigator.Location +
            Instigator.EyeHeight*Vect(0,0,0.5) +
            Vector(Instigator.Rotation) * 40.0);
    }
}

simulated function Destroyed()
{
    if (Role == ROLE_Authority)
    {
		if ( LinkFire(FireMode[1]) != None )
			LinkFire(FireMode[1]).SetLinkTo(None);
    }
    Super.Destroyed();
}

simulated function bool StartFire(int Mode)
{
	local SquadAI S;
	local Bot B;
	local vector AimDir;

	if ( (Role == ROLE_Authority) && (PlayerController(Instigator.Controller) != None) && (UnrealTeamInfo(Instigator.PlayerReplicationInfo.Team) != None))
	{
		S = UnrealTeamInfo(Instigator.PlayerReplicationInfo.Team).AI.GetSquadLedBy(Instigator.Controller);
		if ( S != None )
		{
			AimDir = vector(Instigator.Controller.Rotation);
			for ( B=S.SquadMembers; B!=None; B=B.NextSquadMember )
				if ( (HoldSpot(B.GoalScript) == None)
					&& (B.Pawn != None)
					&& (LinkGun(B.Pawn.Weapon) != None)
					&& B.Pawn.Weapon.FocusOnLeader(true)
					&& ((AimDir dot Normal(B.Pawn.Location - Instigator.Location)) < 0.9) )
				{
					B.Focus = Instigator;
					B.FireWeaponAt(Instigator);
				}
		}
	}
	return Super.StartFire(Mode);
}

// AI Interface
function bool FocusOnLeader(bool bLeaderFiring)
{
	local Bot B;
	local Pawn LeaderPawn;
	local Actor Other;
	local vector HitLocation, HitNormal, StartTrace;
	local Vehicle V;

	B = Bot(Instigator.Controller);
	if ( B == None )
		return false;
	if ( PlayerController(B.Squad.SquadLeader) != None )
		LeaderPawn = B.Squad.SquadLeader.Pawn;
	else
	{
		V = B.Squad.GetLinkVehicle(B);
		if ( V != None )
		{
			LeaderPawn = V;
			bLeaderFiring = (LeaderPawn.Health < LeaderPawn.HealthMax) && (V.LinkHealMult > 0)
							&& ((B.Enemy == None) || V.bKeyVehicle);
		}
	}
	if ( LeaderPawn == None )
	{
		LeaderPawn = B.Squad.SquadLeader.Pawn;
		if ( LeaderPawn == None )
			return false;
	}
	if ( !bLeaderFiring && (LeaderPawn.Weapon == None || !LeaderPawn.Weapon.IsFiring()) )
		return false;
	if ( (Vehicle(LeaderPawn) != None)
		|| ((LinkGun(LeaderPawn.Weapon) != None) && ((vector(B.Squad.SquadLeader.Rotation) dot Normal(Instigator.Location - LeaderPawn.Location)) < 0.9)) )
	{
		StartTrace = Instigator.Location + Instigator.EyePosition();
		if ( VSize(LeaderPawn.Location - StartTrace) < LinkFire(FireMode[1]).TraceRange )
		{
			Other = Trace(HitLocation, HitNormal, LeaderPawn.Location, StartTrace, true);
			if ( Other == LeaderPawn )
			{
				B.Focus = Other;
				return true;
			}
		}
	}
	return false;
}

function float GetAIRating()
{
	local Bot B;
	local DestroyableObjective O;
	local Vehicle V;

	B = Bot(Instigator.Controller);
	if ( B == None )
		return AIRating;

	if ( (PlayerController(B.Squad.SquadLeader) != None)
		&& (B.Squad.SquadLeader.Pawn != None)
		&& (LinkGun(B.Squad.SquadLeader.Pawn.Weapon) != None) )
		return 1.2;

	V = B.Squad.GetLinkVehicle(B);
	if ( (V != None)
		&& (VSize(Instigator.Location - V.Location) < 1.5 * LinkFire(FireMode[1]).TraceRange)
		&& (V.Health < V.HealthMax) && (V.LinkHealMult > 0) )
		return 1.2;

	if ( Vehicle(B.RouteGoal) != None && B.Enemy == None && VSize(Instigator.Location - B.RouteGoal.Location) < 1.5 * LinkFire(FireMode[1]).TraceRange
	     && Vehicle(B.RouteGoal).TeamLink(B.GetTeamNum()) )
		return 1.2;

	O = DestroyableObjective(B.Squad.SquadObjective);
	if ( O != None && B.Enemy == None && O.TeamLink(B.GetTeamNum()) && O.Health < O.DamageCapacity
	     && VSize(Instigator.Location - O.Location) < 1.1 * LinkFire(FireMode[1]).TraceRange && B.LineOfSightTo(O) )
		return 1.2;

	return AIRating * FMin(Pawn(Owner).DamageScaling, 1.5);
}

/* BestMode()
choose between regular or alt-fire
*/
function byte BestMode()
{
	local float EnemyDist;
	local bot B;
	local Vehicle V;

	B = Bot(Instigator.Controller);
	if ( B == None )
		return 0;

	if ( ( (DestroyableObjective(B.Squad.SquadObjective) != None && B.Squad.SquadObjective.TeamLink(B.GetTeamNum()))
		|| (B.Squad.SquadObjective == None && DestroyableObjective(B.Target) != None && B.Target.TeamLink(B.GetTeamNum())) )
	     && VSize(B.Squad.SquadObjective.Location - B.Pawn.Location) < FireMode[1].MaxRange() && (B.Enemy == None || !B.EnemyVisible()) )
		return 1;
	if ( FocusOnLeader(B.Focus == B.Squad.SquadLeader.Pawn) )
		return 1;

	V = B.Squad.GetLinkVehicle(B);
	if ( V == None )
		V = Vehicle(B.MoveTarget);
	if ( V == B.Target )
		return 1;
	if ( (V != None) && (VSize(Instigator.Location - V.Location) < LinkFire(FireMode[1]).TraceRange)
		&& (V.Health < V.HealthMax) && (V.LinkHealMult > 0) && B.LineOfSightTo(V) )
		return 1;
	if ( B.Enemy == None )
		return 0;
	EnemyDist = VSize(B.Enemy.Location - Instigator.Location);
	if ( EnemyDist > LinkFire(FireMode[1]).TraceRange )
		return 0;
	return 1;
}

function float SuggestAttackStyle()
{
	return 0.8;
}

function float SuggestDefenseStyle()
{
    return -0.4;
}

function bool CanHeal(Actor Other)
{
	if (DestroyableObjective(Other) != None && DestroyableObjective(Other).LinkHealMult > 0)
		return true;
	if (Vehicle(Other) != None && Vehicle(Other).LinkHealMult > 0)
		return true;

	return false;
}

// End AI Interface

function bool LinkedTo(LinkGun L)
{
	local Pawn Other;
	local LinkGun OtherWeapon, Head;
	local int sanity;

	Head = self;
	while (Head != None && Head.Linking && sanity < 20)
	{
            Other = LinkFire(Head.FireMode[1]).LockedPawn;
            if (Other == None)
                return false;
            else
            {
                OtherWeapon = LinkGun(Other.Weapon);
                if (OtherWeapon == None)
                    return false;
                else
                    Head = OtherWeapon;
            }
            if (Head == L)
            	return true;

            sanity++;
        }

        return false;
}

function bool ConsumeAmmo(int Mode, float load, optional bool bAmountNeededIsMax)
{
	local Controller C;

	if (Linking && LinkFire(FireMode[1]).LockedPawn != None && Vehicle(LinkFire(FireMode[1]).LockedPawn) == None)
		return true;

	if ( mode == 0 )
		bAmountNeededIsMax = true;

	//use ammo from linking teammates
	if (Instigator != None && Instigator.PlayerReplicationInfo != None && Instigator.PlayerReplicationInfo.Team != None)
	{
		for (C = Level.ControllerList; C != None; C = C.NextController)
			if (C.Pawn != None && LinkGun(C.Pawn.Weapon) != None && LinkGun(C.Pawn.Weapon).LinkedTo(self))
				LinkGun(C.Pawn.Weapon).LinkedConsumeAmmo(Mode, load, bAmountNeededIsMax);
	}

	return Super.ConsumeAmmo(Mode, load, bAmountNeededIsMax);
}

function bool LinkedConsumeAmmo(int Mode, float load, optional bool bAmountNeededIsMax)
{
	if ( mode == 0 )
		bAmountNeededIsMax = true;

	return Super.ConsumeAmmo(Mode, load, bAmountNeededIsMax);
}

simulated function IncrementFlashCount(int mode)
{
    Super.IncrementFlashCount(mode);
	if ( LinkAttachment(ThirdPersonActor) != None )
        LinkAttachment(ThirdPersonActor).Links = Links;
}

simulated function bool PutDown()
{
    LinkFire(FireMode[1]).SetLinkTo(None);
    Links = 0;
    return Super.PutDown();
}

simulated function BringUp(optional Weapon PrevWeapon)
{
    Links = 0;
    Super.BringUp(PrevWeapon);
}

// jdf ---
simulated event WeaponTick(float dt)
{
	local PlayerController PC;
	local LinkFire LF;

	PC = PlayerController(Instigator.Controller);
	LF = LinkFire(FireMode[1]);

	if (PC != None && LF != None)
	{
		if (Links > 0 && !LF.bLinkFeedbackPlaying)
		{
			LF.bLinkFeedbackPlaying = true;
			PC.ClientPlayForceFeedback(LF.MakeLinkForce);
			if (!LF.bIsFiring)
				PC.ClientPlayForceFeedback("BLinkGunBeam1");
		}
		else if (Links <= 0 && LF.bLinkFeedbackPlaying)
		{
			LF.bLinkFeedbackPlaying = false;
			PC.StopForceFeedback("BLinkGunBeam1");
		}
	}
}
// --- jdf

defaultproperties
{
     FireModeClass(0)=Class'XWeapons.LinkAltFire'
     FireModeClass(1)=Class'XWeapons.LinkFire'
     PutDownAnim="PutDown"
     IdleAnimRate=0.030000
     SelectSound=Sound'NewWeaponSounds.NewLinkSelect'
     SelectForce="SwitchToLinkGun"
     AIRating=0.680000
     CurrentRating=0.680000
     bMatchWeapons=True
     OldMesh=SkeletalMesh'Weapons.LinkGun_1st'
     OldPickup="WeaponStaticMesh.LinkGunPickup"
     OldCenteredOffsetY=-12.000000
     OldPlayerViewOffset=(X=-2.000000,Y=-2.000000,Z=-3.000000)
     OldSmallViewOffset=(X=10.000000,Y=4.000000,Z=-9.000000)
     OldPlayerViewPivot=(Yaw=500)
     OldCenteredRoll=3000
     OldCenteredYaw=-300
     Description="Riordan Dynamic Weapon Systems combines the best of weapon design in the Advanced Plasma Rifle v23, commonly known as the Link Gun.|While the primary firing mode of the Link remains the same as its plasma-firing predecessor, the secondary cutting torch has been replaced with a switchable energy matrix. Upon contacting a teammate, it converts to a harmless carrier stream, offloading energy from the onboard cells to boost the output of any targeted player also using the Link.|It should be noted that while players are boosting a teammate, they are unable to defend themselves from attack."
     EffectOffset=(X=100.000000,Y=25.000000,Z=-3.000000)
     DisplayFOV=60.000000
     Priority=13
     HudColor=(B=128,R=128)
     SmallViewOffset=(X=2.000000,Z=-1.500000)
     CenteredOffsetY=-5.000000
     CenteredRoll=3000
     CenteredYaw=-1000
     CustomCrossHairColor=(B=128,R=128)
     CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Bracket1"
     InventoryGroup=5
     PickupClass=Class'XWeapons.LinkGunPickup'
     PlayerViewOffset=(X=-5.000000,Y=-3.000000)
     PlayerViewPivot=(Yaw=500)
     BobDamping=1.575000
     AttachmentClass=Class'XWeapons.LinkAttachment'
     IconMaterial=Texture'HUDContent.Generic.HUD'
     IconCoords=(X1=169,Y1=78,X2=244,Y2=124)
     ItemName="Link Gun"
     Mesh=SkeletalMesh'NewWeapons2004.FatLinkGun'
}
