class Skaarj extends Monster;

var sound FootStep[2];
var name DeathAnim[4];

function PlayVictory()
{
	Controller.bPreparingMove = true;
	Acceleration = vect(0,0,0);
	bShotAnim = true;
    PlaySound(sound'hairflp2sk',SLOT_Interact);	
	SetAnimAction('HairFlip');
	Controller.Destination = Location;
	Controller.GotoState('TacticalMove','WaitForAnim');
}

function bool SameSpeciesAs(Pawn P)
{
	return ( (Monster(P) != None) && (P.IsA('Skaarj') || P.IsA('WarLord')) );
}

function vector GetFireStart(vector X, vector Y, vector Z)
{
    return Location + 0.9 * CollisionRadius * X + 0.9 * CollisionRadius * Y + 0.4 * CollisionHeight * Z;
}

function SpawnTwoShots()
{
	local vector X,Y,Z, FireStart;
	local rotator FireRotation;
	
	GetAxes(Rotation,X,Y,Z);
	FireStart = GetFireStart(X,Y,Z);
	if ( !SavedFireProperties.bInitialized )
	{
		SavedFireProperties.AmmoClass = MyAmmo.Class;
		SavedFireProperties.ProjectileClass = MyAmmo.ProjectileClass;
		SavedFireProperties.WarnTargetPct = MyAmmo.WarnTargetPct;
		SavedFireProperties.MaxRange = MyAmmo.MaxRange;
		SavedFireProperties.bTossed = MyAmmo.bTossed;
		SavedFireProperties.bTrySplash = MyAmmo.bTrySplash;
		SavedFireProperties.bLeadTarget = MyAmmo.bLeadTarget;
		SavedFireProperties.bInstantHit = MyAmmo.bInstantHit;
		SavedFireProperties.bInitialized = true;
	}
	FireRotation = Controller.AdjustAim(SavedFireProperties,FireStart,600);
	Spawn(MyAmmo.ProjectileClass,,,FireStart,FireRotation);
		
	FireStart = FireStart - 1.8 * CollisionRadius * Y;
	FireRotation.Yaw += 400;
	spawn(MyAmmo.ProjectileClass,,,FireStart, FireRotation);
}

simulated function AnimEnd(int Channel)
{
	local name Anim;
	local float frame,rate;
	
	if ( Channel == 0 )
	{
		GetAnimParams(0, Anim,frame,rate);
		if ( Anim == 'looking' )
			IdleWeaponAnim = 'guncheck';
		else if ( (Anim == 'guncheck') && (FRand() < 0.5) )
			IdleWeaponAnim = 'looking';
	}
	Super.AnimEnd(Channel);
}

function RunStep()
{
	PlaySound(FootStep[Rand(2)], SLOT_Interact);
}

function WalkStep()
{
	PlaySound(FootStep[Rand(2)], SLOT_Interact,0.2);
}

simulated function PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	AmbientSound = None;
    bCanTeleport = false; 
    bReplicateMovement = false;
    bTearOff = true;
    bPlayedDeath = true;
		
	HitDamageType = DamageType; // these are replicated to other clients
    TakeHitLocation = HitLoc;
	LifeSpan = RagdollLifeSpan;

    GotoState('Dying');
		
	Velocity += TearOffMomentum;
    BaseEyeHeight = Default.BaseEyeHeight;
    SetPhysics(PHYS_Falling);
    
    if ( (DamageType == class'DamTypeSniperHeadShot')
		|| ((HitLoc.Z > Location.Z + 0.75 * CollisionHeight) && (FRand() > 0.5) 
			&& (DamageType != class'DamTypeAssaultBullet') && (DamageType != class'DamTypeMinigunBullet') && (DamageType != class'DamTypeFlakChunk')) )
    {
		PlayAnim('Death5',1,0.05);
		CreateGib('head',DamageType,Rotation);
		return;
	}
	if ( Velocity.Z > 300 )
	{
		if ( FRand() < 0.5 )
			PlayAnim('Death',1.2,0.05);
		else
			PlayAnim('Death2',1.2,0.05);
		return;
	}
	PlayAnim(DeathAnim[Rand(4)],1.2,0.05);		
}

function SpinDamageTarget()
{
	if (MeleeDamageTarget(20, (30000 * Normal(Controller.Target.Location - Location))) )
		PlaySound(sound'clawhit1s', SLOT_Interact);		
}

function ClawDamageTarget()
{
	if ( MeleeDamageTarget(25, (25000 * Normal(Controller.Target.Location - Location))) )
		PlaySound(sound'clawhit1s', SLOT_Interact);			
}

function RangedAttack(Actor A)
{
	local name Anim;
	local float frame,rate;
	
	if ( bShotAnim )
		return;
	bShotAnim = true;
	if ( Physics == PHYS_Swimming )
		SetAnimAction('SwimFire');
	else if ( VSize(A.Location - Location) < MeleeRange + CollisionRadius + A.CollisionRadius )
	{
		if ( FRand() < 0.7 )
		{
			SetAnimAction('Spin');
			PlaySound(sound'Spin1s', SLOT_Interact);
			Acceleration = AccelRate * Normal(A.Location - Location);
			return;
		}
		SetAnimAction('Claw');	
		PlaySound(sound'Claw2s', SLOT_Interact);
		Controller.bPreparingMove = true;
		Acceleration = vect(0,0,0);
	}	
	else if ( Velocity == vect(0,0,0) )
	{
		SetAnimAction('Firing');
		Controller.bPreparingMove = true;
		Acceleration = vect(0,0,0);
	}
	else
	{
		GetAnimParams(0,Anim,frame,rate);
		if ( Anim == 'RunL' )
			SetAnimAction('StrafeLeftFr');
		else if ( Anim == 'RunR' )
			SetAnimAction('StrafeRightFr');
		else
			SetAnimAction('JogFire');
	}
}

defaultproperties
{
     Footstep(0)=Sound'SkaarjPack_rc.Cow.walkC'
     Footstep(1)=Sound'SkaarjPack_rc.Cow.walkC'
     DeathAnim(0)="Death"
     DeathAnim(1)="Death2"
     DeathAnim(2)="Death3"
     DeathAnim(3)="Death4"
     HitSound(0)=Sound'SkaarjPack_rc.Skaarj.injur1sk'
     HitSound(1)=Sound'SkaarjPack_rc.Skaarj.injur2sk'
     HitSound(2)=Sound'SkaarjPack_rc.Skaarj.injur3sk'
     HitSound(3)=Sound'SkaarjPack_rc.Skaarj.injur3sk'
     DeathSound(0)=Sound'SkaarjPack_rc.Skaarj.death1sk'
     DeathSound(1)=Sound'SkaarjPack_rc.Skaarj.death2sk'
     ChallengeSound(0)=Sound'SkaarjPack_rc.Skaarj.chalnge1s'
     ChallengeSound(1)=Sound'SkaarjPack_rc.Skaarj.chalnge3s'
     ChallengeSound(2)=Sound'SkaarjPack_rc.Skaarj.roam11s'
     ChallengeSound(3)=Sound'SkaarjPack_rc.Skaarj.roam11s'
     AmmunitionClass=Class'SkaarjPack.SkaarjAmmo'
     ScoringValue=6
     IdleHeavyAnim="Idle_Biggun"
     IdleRifleAnim="Idle_Rifle"
     MeleeRange=60.000000
     JumpZ=550.000000
     Health=150
     MovementAnims(1)="RunR"
     MovementAnims(2)="RunR"
     MovementAnims(3)="RunL"
     SwimAnims(0)="Swim"
     SwimAnims(1)="Swim"
     SwimAnims(2)="Swim"
     SwimAnims(3)="Swim"
     WalkAnims(1)="WalkF"
     WalkAnims(2)="WalkF"
     WalkAnims(3)="WalkF"
     AirAnims(0)="InAir"
     AirAnims(1)="InAir"
     AirAnims(2)="InAir"
     AirAnims(3)="InAir"
     LandAnims(0)="Landed"
     LandAnims(1)="Landed"
     LandAnims(2)="Landed"
     LandAnims(3)="Landed"
     DodgeAnims(0)="DodgeF"
     DodgeAnims(1)="DodgeB"
     DodgeAnims(2)="DodgeL"
     DodgeAnims(3)="DodgeR"
     AirStillAnim="Jump2"
     TakeoffStillAnim="Jump2"
     IdleSwimAnim="Swim"
     IdleWeaponAnim="Looking"
     IdleRestAnim="Breath"
     Mesh=VertMesh'SkaarjPack_rc.Skaarjw'
     Skins(0)=FinalBlend'SkaarjPackSkins.Skins.Skaarjw1'
     Mass=150.000000
     Buoyancy=150.000000
     RotationRate=(Yaw=60000)
}
