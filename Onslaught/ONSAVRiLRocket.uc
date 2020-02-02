class ONSAVRiLRocket extends Projectile;

var Emitter SmokeTrail;
var Effects Corona;
var float AccelerationAddPerSec;
var bool bLockedOn;
var float LeadTargetDelay; //don't lead target until missle has been flying for this many seconds
var float LeadTargetStartTime;
var actor OverrideTarget;
var Vehicle HomingTarget;

replication
{
	reliable if (bNetDirty && Role == ROLE_Authority)
		HomingTarget, OverrideTarget, bLockedOn;
}

simulated function Destroyed()
{
	// Turn of smoke emitters. Emitter should then destroy itself when all particles fade out.
	if ( SmokeTrail != None )
		SmokeTrail.Kill();

	if ( Corona != None )
		Corona.Destroy();

	PlaySound(sound'WeaponSounds.BExplosion3',,2.5*TransientSoundVolume);
	if (!bNoFX && EffectIsRelevant(Location, false))
		spawn(class'ONSAVRiLRocketExplosion',,, Location, rotator(vect(0,0,1)));
	if (Instigator != None && Instigator.IsLocallyControlled() && Instigator.Weapon != None && !Instigator.Weapon.HasAmmo())
		Instigator.Weapon.DoAutoSwitch();
	//hack for crappy weapon firing sound
	if (ONSAVRiL(Owner) != None)
		ONSAVRiL(Owner).PlaySound(sound'WeaponSounds.BExplosion3', SLOT_Interact, 0.01,, TransientSoundRadius);

	Super.Destroyed();
}

simulated function PostBeginPlay()
{
	local vector Dir;

	Dir = vector(Rotation);

	if ( Level.NetMode != NM_DedicatedServer)
	{
		SmokeTrail = Spawn(class'ONSAvrilSmokeTrail',,,Location - 15 * Dir);
		SmokeTrail.Setbase(self);

		Corona = Spawn(class'RocketCorona',self);
	}

	Velocity = speed * Dir;
	Acceleration = Dir;	//really small accel just to give it a direction for use later
	if (PhysicsVolume.bWaterVolume)
		Velocity=0.6*Velocity;
	if ( Level.bDropDetail )
	{
		bDynamicLight = false;
		LightType = LT_None;
	}

	SetTimer(0.1, true);
	LeadTargetStartTime = Level.TimeSeconds + LeadTargetDelay;

	Super.PostBeginPlay();
}

simulated function Landed( vector HitNormal )
{
	Explode(Location,HitNormal);
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	BlowUp(HitLocation);
	Destroy();
}

simulated function Timer()
{
    local vector Dir, ForceDir;
    local float VelMag, LowestDesiredZ;
    local array<Vehicle> TargetPawns;
    local bool bLastLockedOn;
    local int i;
	local actor NewTarget;

    if (Role == ROLE_Authority)
    {
    	if (OverrideTarget == none)
    	{
			if (Instigator != None && Instigator.Controller != None && ONSAVRiL(Owner) != None)
			{
				bLastLockedOn = bLockedOn;
				bLockedOn = ONSAVRiL(Owner).bLockedOn;
				HomingTarget = ONSAVRiL(Owner).HomingTarget;
				if (!bLastLockedOn && bLockedOn)
				{
					if (HomingTarget != None && HomingTarget.Controller != None)
						HomingTarget.Controller.ReceiveProjectileWarning(self);
				}
			}
			else
				bLockedOn = false;
		}
		else
			bLockedOn = true;

		if (HomingTarget != None)
    	{
    		// Check to see if it's lock has changed
    		if ( !HomingTarget.VerifyLock(self,NewTarget) )
    			OverrideTarget = NewTarget;
			else
			{
                OverrideTarget = None;
				HomingTarget.IncomingMissile(self);

	    		//bots with nothing else to shoot at may attempt to shoot down incoming missles
	    		TargetPawns = HomingTarget.GetTurrets();
	    		TargetPawns[TargetPawns.length] = HomingTarget;
	    		for (i = 0; i < TargetPawns.length; i++)
					TargetPawns[i].ShouldTargetMissile(self);
	    	}
    	}
    }

    if (bLockedOn && ( HomingTarget != none || OverrideTarget != none) )
    {
		if (OverrideTarget != none)
		{
			if ( VSize(OverrideTarget.Location - Location ) < 256 )
			{
				OverrideTarget.Destroy();
				TakeDamage(20000,none, Location, Velocity, none);
				return;
			}
			NewTarget = OverrideTarget;
		}

		else
			NewTarget = HomingTarget;

    	// Do normal guidance to target.
		if ( Pawn(NewTarget) != None )
			Dir = Pawn(NewTarget).GetTargetLocation() - Location;
		else
    		Dir = NewTarget.Location - Location;
    	VelMag = VSize(Velocity);

		if (Level.TimeSeconds >= LeadTargetStartTime)
		{
	    	ForceDir = Dir + NewTarget.Velocity * VSize(Dir) / (VelMag * 2);

	    	if (Instigator != None)
				LowestDesiredZ = FMin(Instigator.Location.Z, NewTarget.Location.Z); //missle should avoid going any lower than this
			else
				LowestDesiredZ = NewTarget.Location.Z;

			if (ForceDir.Z + Location.Z < LowestDesiredZ)
	    		ForceDir.Z += LowestDesiredZ - (ForceDir.Z + Location.Z);

	    	ForceDir = Normal(ForceDir);
		}
		else
			ForceDir = Dir;

    	ForceDir = Normal(ForceDir * 0.8 * VelMag + Velocity);
    	Velocity =  VelMag * ForceDir;
    	Acceleration += 5 * ForceDir;

    	// Update rocket so it faces in the direction its going.
    	SetRotation(rotator(Velocity));
    }
}

simulated function Tick(float deltaTime)
{
	if (VSize(Velocity) >= MaxSpeed)
	{
		Acceleration = vect(0,0,0);
		disable('Tick');
	}
	else
		Acceleration += Normal(Velocity) * (AccelerationAddPerSec * deltaTime);
}

function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType)
{
	if (Damage > 0)
		Explode(HitLocation, vect(0,0,0));
}

simulated event PostRender2D(Canvas C, float ScreenLocX, float ScreenLocY)
{
	local PlayerController PC;
	if (bLockedOn)
	{
		PC = Level.GetLocalPlayerController();
		if (PC!=none && PC.Pawn != none && ONSWeaponPawn(PC.Pawn)!=none)
			ONSWeaponPawn(PC.Pawn).ProjectilePostRender2D(self, C, ScreenLocX, ScreenLocY);
	}
}

defaultproperties
{
     AccelerationAddPerSec=750.000000
     LeadTargetDelay=1.000000
     Speed=550.000000
     MaxSpeed=2800.000000
     Damage=125.000000
     DamageRadius=150.000000
     MomentumTransfer=50000.000000
     MyDamageType=Class'Onslaught.DamTypeONSAVRiLRocket'
     ExplosionDecal=Class'Onslaught.ONSRocketScorch'
     bScriptPostRender=True
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'VMWeaponsSM.AVRiLGroup.AVRiLprojectileSM'
     bNetTemporary=False
     bUpdateSimulatedPosition=True
     bIgnoreVehicles=True
     LifeSpan=7.000000
     DrawScale=0.200000
     AmbientGlow=96
     bProjTarget=True
     bUseCylinderCollision=False
     bFixedRotationDir=True
     RotationRate=(Roll=50000)
     DesiredRotation=(Roll=30000)
     ForceType=FT_Constant
     ForceRadius=100.000000
     ForceScale=5.000000
}
