//=============================================================================
// FM_Turret_AltFire_Shield
//=============================================================================
// Created by Laurent Delayen
// © 2003, Epic Games, Inc.  All Rights Reserved
//=============================================================================

class FM_Turret_AltFire_Shield extends WeaponFire;

var()	float	AmmoRegenTime;
var()	float	ChargeupTime;
var		float	RampTime;
var		Sound	ChargingSound;  

function DoFireEffect()
{
    local WA_Turret Attachment;

    Attachment = WA_Turret(Weapon.ThirdPersonActor);
    Instigator.AmbientSound = ChargingSound;
    
    if ( Attachment != None && Attachment.ShieldEffect3rd != None )
        Attachment.ShieldEffect3rd.bHidden = false;

    SetTimer(AmmoRegenTime, true);
}

function PlayFiring()
{
    SetTimer(AmmoRegenTime, true);
}

function StopFiring()
{
    local WA_Turret Attachment;

    Attachment = WA_Turret(Weapon.ThirdPersonActor);
	Instigator.AmbientSound = None;
    
    if ( Attachment != None && Attachment.ShieldEffect3rd != None )
        Attachment.ShieldEffect3rd.bHidden = true;

    SetTimer(AmmoRegenTime, true);
}

function TakeHit( int Drain )
{
    SetBrightness( true );
}

function SetBrightness(bool bHit)
{
    local WA_Turret		Attachment;
 	local float			Brightness;

	Brightness = Weapon.AmmoAmount(1);
	if ( RampTime < ChargeUpTime )
		Brightness *= RampTime/ChargeUpTime; 

    Attachment = WA_Turret(Weapon.ThirdPersonActor);
    if ( Attachment != None )
        Attachment.SetBrightness(Brightness, bHit);
}

function Timer()
{
    if ( !bIsFiring )
    {
		RampTime = 0;
        if ( !Weapon.AmmoMaxed(1) )
			Weapon.AddAmmo(1,1);
        else
            SetTimer(0, false);
    }
    else
    {
        if ( !Weapon.ConsumeAmmo(1,1) )
        {
            if ( Weapon.ClientState == WS_ReadyToFire )
                Weapon.PlayIdle();
            StopFiring();
        }
        else
			RampTime += AmmoRegenTime;
    }
	
	SetBrightness( false );
}

defaultproperties
{
     AmmoRegenTime=0.200000
     ChargeupTime=3.000000
     ChargingSound=Sound'WeaponSounds.BaseFiringSounds.BShield1'
     bPawnRapidFireAnim=True
     bWaitForRelease=True
     FireSound=SoundGroup'WeaponSounds.Translocator.TranslocatorModuleRegeneration'
     FireForce="TranslocatorModuleRegeneration"
     FireRate=1.000000
     AmmoClass=Class'UT2k4AssaultFull.Ammo_BallTurret'
     AmmoPerFire=15
     BotRefireRate=1.000000
}
