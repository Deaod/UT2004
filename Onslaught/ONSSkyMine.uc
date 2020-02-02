class ONSSkyMine extends ShockProjectile;

var ONSWeapon OwnerGun;
var bool bDoChainReaction;
var float MaxChainReactionDist, ChainReactionDelay;
var class<ShockBeamEffect> BeamEffectClass;
var class<Emitter> ProjectileEffectClass;
var Emitter ProjectileEffect;

simulated function PostBeginPlay()
{
	Super(Projectile).PostBeginPlay();

	if ( Level.NetMode != NM_DedicatedServer )
	{
		ProjectileEffect = spawn(ProjectileEffectClass, self,, Location, Rotation);
    		ProjectileEffect.SetBase(self);
	}

	Velocity = Speed * Vector(Rotation);
}

simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();

	OwnerGun = ONSWeapon(Owner);
	if (OwnerGun != None)
		OwnerGun.Projectiles[OwnerGun.Projectiles.length] = self;
}

simulated function DestroyTrails()
{
	if (ProjectileEffect != None)
		ProjectileEffect.Destroy();
}

simulated function Destroyed()
{
	if (ProjectileEffect != None)
		ProjectileEffect.Destroy();

	Super.Destroyed();
}

function TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType)
{
	if (DamageType == class'DamTypeShockBeam')
	{
		ComboDamageType = DamageType;
		bDoChainReaction = false;
	}

	Super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType);
}

function SuperExplosion()
{
	local actor HitActor;
	local vector HitLocation, HitNormal;
	local Emitter E;

	HurtRadius(ComboDamage, ComboRadius, class'DamTypePRVCombo', ComboMomentumTransfer, Location );

	E = Spawn(class'ONSPRVComboEffect');
	if ( Level.NetMode == NM_DedicatedServer )
	{
		if ( E != None )
			E.LifeSpan = 0.25;
	}
	else if ( EffectIsRelevant(Location,false) )
	{
		HitActor = Trace(HitLocation, HitNormal,Location - Vect(0,0,120), Location,false);
		if ( HitActor != None )
			Spawn(class'ComboDecal',self,,HitLocation, rotator(vect(0,0,-1)));
	}
	PlaySound(ComboSound, SLOT_None,1.0,,800);
	DestroyTrails();

	if (bDoChainReaction)
	{
		SetPhysics(PHYS_None);
		SetCollision(false);
		bHidden = true;
		SetTimer(ChainReactionDelay, false);
	}
	else
		Destroy();
}

State WaitForCombo
{
	function Tick(float DeltaTime)
	{
		if (ComboTarget == None || ComboTarget.bDeleteMe || ONSWeaponPawn(Instigator) == None || ONSWeaponPawn(Instigator).Gun == None)
		{
			GotoState('');
			return;
		}

		if ( (Velocity Dot (ComboTarget.Location - Location)) <= 0 )
		{
			if ( VSize(ComboTarget.Location - Location) <= ComboRadius + ComboTarget.CollisionRadius )
			{
				ONSWeaponPawn(Instigator).Gun.DoCombo();
			}
			GotoState('');
			return;
		}
		else if ( (VSize(ComboTarget.Location - Location) <= 0.5 * ComboRadius + ComboTarget.CollisionRadius) )
		{
			ONSWeaponPawn(Instigator).Gun.DoCombo();
			GotoState('');
			return;
		}
	}
}

function Timer()
{
	local int x;
	local ShockBeamEffect Beam;
	local Projectile ChainTarget;
	local float BestDist;

	if (OwnerGun != None)
	{
		BestDist = MaxChainReactionDist;
		for (x = 0; x < OwnerGun.Projectiles.length; x++)
		{
			if (OwnerGun.Projectiles[x] == None || OwnerGun.Projectiles[x] == self)
			{
				OwnerGun.Projectiles.Remove(x, 1);
				x--;
			}
			else if (VSize(Location - OwnerGun.Projectiles[x].Location) < BestDist)
			{
				ChainTarget = OwnerGun.Projectiles[x];
				BestDist = VSize(Location - OwnerGun.Projectiles[x].Location);
			}
		}

		if (ChainTarget != None)
		{
			Beam = Spawn(BeamEffectClass,,, Location, rotator(ChainTarget.Location - Location));
			Beam.Instigator = None;
			Beam.AimAt(ChainTarget.Location, Normal(ChainTarget.Location - Location));
			ChainTarget.TakeDamage(1, Instigator, ChainTarget.Location, vect(0,0,0), ComboDamageType);
		}
	}

	Destroy();
}

defaultproperties
{
     bDoChainReaction=True
     MaxChainReactionDist=2500.000000
     ChainReactionDelay=0.250000
     BeamEffectClass=Class'XWeapons.ShockBeamEffect'
     ProjectileEffectClass=Class'XEffects.ShockBall'
     ComboRadius=525.000000
     ComboDamageType=Class'Onslaught.DamTypePRVLaser'
     Speed=950.000000
     MaxSpeed=950.000000
     Damage=25.000000
     MomentumTransfer=25000.000000
     MyDamageType=Class'Onslaught.DamTypeSkyMine'
     DrawType=DT_None
     DrawScale=1.050000
     Style=STY_Additive
     CollisionRadius=20.000000
     CollisionHeight=20.000000
}
