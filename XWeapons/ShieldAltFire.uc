class ShieldAltFire extends WeaponFire;

var ShieldEffect ShieldEffect;
var() float AmmoRegenTime;
var() float ChargeupTime;
var	  float RampTime;
var Sound ChargingSound;                // charging sound
var() byte	ShieldSoundVolume;

simulated function DestroyEffects()
{
    if ( Weapon.Role == ROLE_Authority )
    {
        if ( ShieldEffect != None )
            ShieldEffect.Destroy();
    }
    Super.DestroyEffects();
}

function DoFireEffect()
{
    local ShieldAttachment Attachment;

    Attachment = ShieldAttachment(Weapon.ThirdPersonActor);
    Instigator.AmbientSound = ChargingSound;
    Instigator.SoundVolume = ShieldSoundVolume;
   
    if( Attachment != None && Attachment.ShieldEffect3rd != None )
        Attachment.ShieldEffect3rd.bHidden = false;

    SetTimer(AmmoRegenTime, true);
}

function PlayFiring()
{
    ClientPlayForceFeedback("ShieldNoise");  // jdf
    SetTimer(AmmoRegenTime, true);
    Weapon.LoopAnim('Shield');
}

function StopFiring()
{
    local ShieldAttachment Attachment;

    Attachment = ShieldAttachment(Weapon.ThirdPersonActor);
	Instigator.AmbientSound = None;
    Instigator.SoundVolume = Instigator.Default.SoundVolume;
    
    if( Attachment != None && Attachment.ShieldEffect3rd != None )
    {
        Attachment.ShieldEffect3rd.bHidden = true;
        StopForceFeedback( "ShieldNoise" );  // jdf
    }

    SetTimer(AmmoRegenTime, true);
}

function TakeHit(int Drain)
{
    if (ShieldEffect != None)
    {
        ShieldEffect.Flash(Drain);
    }

    SetBrightness(true);
}

function StartBerserk()
{
}

function StopBerserk()
{
}

function StartSuperBerserk()
{
}

function SetBrightness(bool bHit)
{
    local ShieldAttachment Attachment;
 	local float Brightness;

	Brightness = Weapon.AmmoAmount(1);
	if ( RampTime < ChargeUpTime )
		Brightness *= RampTime/ChargeUpTime; 
    if (ShieldEffect != None)
        ShieldEffect.SetBrightness(Brightness);

    Attachment = ShieldAttachment(Weapon.ThirdPersonActor);
    if( Attachment != None )
        Attachment.SetBrightness(Brightness, bHit);
}

function DrawMuzzleFlash(Canvas Canvas)
{
    Super.DrawMuzzleFlash(Canvas);

    if (ShieldEffect == None)
        ShieldEffect = Weapon.Spawn(class'ShieldEffect', instigator);

    if ( bIsFiring && Weapon.AmmoAmount(1) > 0 )
    {
        ShieldEffect.SetLocation( Weapon.GetEffectStart() );
        ShieldEffect.SetRotation( Instigator.GetViewRotation() );
        Canvas.DrawActor( ShieldEffect, false, false, Weapon.DisplayFOV );
    }
}

function Timer()
{
    if (!bIsFiring)
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
            if (Weapon.ClientState == WS_ReadyToFire)
                Weapon.PlayIdle();
            StopFiring();
        }
        else
			RampTime += AmmoRegenTime;
    }
	
	SetBrightness(false);
}

defaultproperties
{
     AmmoRegenTime=0.200000
     ChargeupTime=3.000000
     ChargingSound=Sound'WeaponSounds.BaseFiringSounds.BShield1'
     ShieldSoundVolume=220
     bPawnRapidFireAnim=True
     bWaitForRelease=True
     FireAnim=
     FireLoopAnim=
     FireEndAnim="Idle"
     FireSound=SoundGroup'WeaponSounds.Translocator.TranslocatorModuleRegeneration'
     FireForce="TranslocatorModuleRegeneration"
     FireRate=1.000000
     AmmoClass=Class'XWeapons.ShieldAmmo'
     AmmoPerFire=15
     BotRefireRate=1.000000
}
