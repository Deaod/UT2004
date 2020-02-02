//=============================================================================
// Assault Rifle
//=============================================================================
class AssaultRifle extends Weapon
    config(user);

var float DualPickupTime;
var AssaultAttachment OffhandActor;
var bool bDualMode;
var bool bWasDualMode;
var bool bFireLeft;

#EXEC OBJ LOAD FILE=InterfaceContent.utx
#EXEC OBJ LOAD FILE=UT2004Weapons.utx

replication
{
    reliable if ( Role == ROLE_Authority )
        bDualMode;
}

simulated function Loaded()
{
	bDualMode = true;
}

simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();

	if ( (Role < ROLE_Authority) && (Instigator != None) && (Instigator.Controller != None) && (Instigator.Weapon != self) && (Instigator.PendingWeapon != self) )
		Instigator.Controller.ClientSwitchToBestWeapon();
}


simulated function bool WeaponCentered()
{
	return !bDualMode && Super.WeaponCentered();
}

simulated event RenderOverlays( Canvas Canvas )
{
	local bool bRealHidden;
	local int RealHand;

    if (Instigator == None)
        return;

	if ( Instigator.Controller != None )
		Hand = Instigator.Controller.Handedness;

    if ((Hand < -1.0) || (Hand > 1.0))
        return;

    RealHand = Hand;
    if ( bDualMode && (Hand == 0) )
    {
		Instigator.Controller.Handedness = -1;
		Hand = -1;
	}

    if ( bDualMode && (FireMode[1].FlashEmitter != None) )
    {
		bRealHidden = FireMode[1].FlashEmitter.bHidden;
		if ( bFireLeft )
			FireMode[1].FlashEmitter.bHidden = true;
		Super.RenderOverlays(Canvas);
		FireMode[1].FlashEmitter.bHidden = bRealHidden;
	}
	else
		Super.RenderOverlays(Canvas);

	if ( bDualMode )
		RenderDualOverlay(Canvas);
	if ( Instigator.Controller != None )
		Instigator.Controller.Handedness = RealHand;
}

simulated function RenderDualOverlay(Canvas Canvas)
{
	local vector NewScale3D;
	local rotator WeaponRotation;
	local bool bRealHidden;

	Hand *= -1;
	newScale3D = Default.DrawScale3D;
	newScale3D.Y *= Hand;
	SetDrawScale3D(newScale3D);
	PlayerViewPivot.Roll = Default.PlayerViewPivot.Roll * Hand;
	PlayerViewPivot.Yaw = Default.PlayerViewPivot.Yaw * Hand;
	RenderedHand = Hand;

	if ( class'PlayerController'.Default.bSmallWeapons )
		PlayerViewOffset = SmallViewOffset;
	else
		PlayerViewOffset = Default.PlayerViewOffset;

	PlayerViewOffset.Y *= Hand;

    SetLocation( Instigator.Location + Instigator.CalcDrawOffset(self) );
    WeaponRotation = Instigator.GetViewRotation();

    if ( bDualMode != bWasDualMode )
    {
		bWasDualMode = true;
		DualPickupTime = Level.Timeseconds;
	}
    if ( DualPickupTime > Level.TimeSeconds - 0.5 )
		WeaponRotation.Pitch = WeaponRotation.Pitch - 16384 - 32768 * (DualPickupTime - Level.TimeSeconds);

    SetRotation( WeaponRotation );

    bDrawingFirstPerson = true;
    if ( bDualMode && (FireMode[1].FlashEmitter != None) )
    {
		bRealHidden = FireMode[1].FlashEmitter.bHidden;
		if ( !bFireLeft )
			FireMode[1].FlashEmitter.bHidden = true;
	    Canvas.DrawActor(self, false, false, DisplayFOV);
		FireMode[1].FlashEmitter.bHidden = bRealHidden;
	}
	else
	   Canvas.DrawActor(self, false, false, DisplayFOV);
    bDrawingFirstPerson = false;
    Hand *= -1;
}

simulated function DetachFromPawn(Pawn P)
{
	bFireLeft = false;
    AssaultGrenade(FireMode[1]).ReturnToIdle();
	Super.DetachFromPawn(P);
	if ( OffhandActor != None )
	{
		OffhandActor.Destroy();
		OffhandActor = None;
	}
}

function AttachToPawn(Pawn P)
{
	local name BoneName;

	if ( ThirdPersonActor == None )
	{
		ThirdPersonActor = Spawn(AttachmentClass,Owner);
		InventoryAttachment(ThirdPersonActor).InitFor(self);
	}
	BoneName = P.GetWeaponBoneFor(self);
	if ( BoneName == '' )
	{
		ThirdPersonActor.SetLocation(P.Location);
		ThirdPersonActor.SetBase(P);
	}
	else
		P.AttachToBone(ThirdPersonActor,BoneName);

	if ( bDualMode )
	{
		BoneName = P.GetOffHandBoneFor(self);
		if ( BoneName == '' )
			return;
		if ( OffhandActor == None )
		{
			OffhandActor = AssaultAttachment(Spawn(AttachmentClass,Owner));
			OffhandActor.InitFor(self);
		}
		P.AttachToBone(OffhandActor,BoneName);
		if ( OffhandActor.AttachmentBone == '' )
			OffhandActor.Destroy();
		else
		{
			ThirdPersonActor.SetDrawScale(0.3);
			OffhandActor.SetDrawScale(0.3);
			OffhandActor.bDualGun = true;
			OffhandActor.TwinGun = AssaultAttachment(ThirdPersonActor);
			if ( Mesh == OldMesh )
			{
			    OffhandActor.SetRelativeRotation(rot(0,32768,0));
			    OffhandActor.SetRelativeLocation(vect(20,-10,-5));
			}
			else
			{
			    OffhandActor.SetRelativeRotation(rot(0,0,32768));
			    OffhandActor.SetRelativeLocation(vect(40,-3,-7));
			}
			AssaultAttachment(ThirdPersonActor).TwinGun = OffhandActor;
		}
	}
}

simulated function DrawWeaponInfo(Canvas Canvas)
{
	NewDrawWeaponInfo(Canvas, 0.705*Canvas.ClipY);
}

simulated function NewDrawWeaponInfo(Canvas Canvas, float YPos)
{
	local int i,Count;
	local float ScaleFactor;

	ScaleFactor = 99 * Canvas.ClipX/3200;
	Canvas.Style = ERenderStyle.STY_Alpha;
	Canvas.DrawColor = class'HUD'.Default.WhiteColor;
	Count = Min(8,AmmoAmount(1));
    for( i=0; i<Count; i++ )
    {
		Canvas.SetPos(Canvas.ClipX - (0.5*i+1) * ScaleFactor, YPos);
		Canvas.DrawTile( Material'HudContent.Generic.HUD', ScaleFactor, ScaleFactor, 174, 259, 46, 45);
	}
	if ( AmmoAmount(1) > 8 )
	{
		Count = Min(16,AmmoAmount(1));
		for( i=8; i<Count; i++ )
		{
			Canvas.SetPos(Canvas.ClipX - (0.5*(i-8)+1) * ScaleFactor, YPos - ScaleFactor);
			Canvas.DrawTile( Material'HudContent.Generic.HUD', ScaleFactor, ScaleFactor, 174, 259, 46, 45);
		}
	}
}

function byte BestMode()
{
	local Bot B;

	B = Bot(Instigator.Controller);
	if ( (B != None) && (B.Enemy != None) )
	{
	    if ( ((FRand() < 0.1) || !B.EnemyVisible()) && (AmmoAmount(1) >= FireMode[1].AmmoPerFire) )
		    return 1;
	}
    if ( AmmoAmount(0) >= FireMode[0].AmmoPerFire )
		return 0;
	return 1;
}

simulated function float ChargeBar()
{
	return FMin(1,FireMode[1].HoldTime/AssaultGrenade(FireMode[1]).mHoldClampMax);
}

function bool HandlePickupQuery( pickup Item )
{
	if ( class == Item.InventoryType )
    {
		if ( bDualMode )
			return super.HandlePickupQuery(Item);
		bDualMode = true;
		if ( Instigator.Weapon == self )
		{
			PlayOwnedSound(SelectSound, SLOT_Interact,,,,, false);
			AttachToPawn(Instigator);
		}
		if (Level.GRI.WeaponBerserk > 1.0)
			CheckSuperBerserk();
		else
			FireMode[0].FireRate = FireMode[0].Default.FireRate *  0.55;

		FireMode[0].Spread = FireMode[0].Default.Spread * 1.5;
		if (xPawn(Instigator) != None && xPawn(Instigator).bBerserk)
			StartBerserk();

		return false;
    }
	if ( item.inventorytype == AmmoClass[1] )
	{
		if ( (AmmoCharge[1] >= MaxAmmo(1)) && (AmmoCharge[0] >= MaxAmmo(0)) )
			return true;
		item.AnnouncePickup(Pawn(Owner));
		AddAmmo(50, 0);
		AddAmmo(Ammo(item).AmmoAmount, 1);
		item.SetRespawn();
		return true;
	}

    if ( Inventory == None )
		return false;

	return Inventory.HandlePickupQuery(Item);
}

simulated function int MaxAmmo(int mode)
{
	if ( bDualMode )
		return 2 * FireMode[mode].AmmoClass.Default.MaxAmmo;
	else
		return FireMode[mode].AmmoClass.Default.MaxAmmo;
}

function float GetAIRating()
{
	local Bot B;

	if ( !bDualMode )
		return AIRating;

	B = Bot(Instigator.Controller);
	if ( B == None )
		return AIRating;

	if ( B.Enemy == None )
	{
		if ( (B.Target != None) && VSize(B.Target.Location - B.Pawn.Location) > 8000 )
			return 0.78;
		return AIRating;
	}

	return (AIRating + 0.0003 * FClamp(1500 - VSize(B.Enemy.Location - Instigator.Location),0,1000));
}

defaultproperties
{
     FireModeClass(0)=Class'XWeapons.AssaultFire'
     FireModeClass(1)=Class'XWeapons.AssaultGrenade'
     PutDownAnim="PutDown"
     SelectSound=Sound'WeaponSounds.AssaultRifle.SwitchToAssaultRifle'
     SelectForce="SwitchToAssaultRifle"
     AIRating=0.400000
     CurrentRating=0.400000
     bShowChargingBar=True
     OldMesh=SkeletalMesh'Weapons.AssaultRifle_1st'
     OldPickup="WeaponStaticMesh.AssaultRiflePickup"
     OldCenteredOffsetY=0.000000
     OldPlayerViewOffset=(X=-8.000000,Y=5.000000,Z=-6.000000)
     OldSmallViewOffset=(X=4.000000,Y=11.000000,Z=-12.000000)
     OldPlayerViewPivot=(Pitch=400)
     OldCenteredRoll=3000
     Description="Inexpensive and easily produced, the AR770 provides a lightweight 5.56mm combat solution that is most effective against unarmored foes. With low-to-moderate armor penetration capabilities, this rifle is best suited to a role as a light support weapon.|The optional M355 Grenade Launcher provides the punch that makes this weapon effective against heavily armored enemies.  Pick up a second assault rifle to double your fire power."
     EffectOffset=(X=100.000000,Y=25.000000,Z=-10.000000)
     DisplayFOV=70.000000
     Priority=4
     HudColor=(B=192,G=128)
     SmallViewOffset=(X=13.000000,Y=12.000000,Z=-10.000000)
     CenteredOffsetY=-5.000000
     CenteredRoll=3000
     CenteredYaw=-1500
     CustomCrosshair=11
     CustomCrossHairScale=0.666700
     CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross5"
     InventoryGroup=2
     PickupClass=Class'XWeapons.AssaultRiflePickup'
     PlayerViewOffset=(X=4.000000,Y=5.500000,Z=-6.000000)
     PlayerViewPivot=(Pitch=400)
     BobDamping=1.700000
     AttachmentClass=Class'XWeapons.AssaultAttachment'
     IconMaterial=Texture'HUDContent.Generic.HUD'
     IconCoords=(X1=245,Y1=39,X2=329,Y2=79)
     ItemName="Assault Rifle"
     LightType=LT_Pulse
     LightEffect=LE_NonIncidence
     LightHue=30
     LightSaturation=150
     LightBrightness=255.000000
     LightRadius=4.000000
     LightPeriod=3
     Mesh=SkeletalMesh'NewWeapons2004.AssaultRifle'
     DrawScale=0.800000
     HighDetailOverlay=Combiner'UT2004Weapons.WeaponSpecMap2'
}
