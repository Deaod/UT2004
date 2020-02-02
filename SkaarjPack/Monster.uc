class Monster extends xPawn;

var bool bMeleeFighter;
var bool bShotAnim;
var bool bCanDodge;
var bool bVictoryNext;
var bool bTryToWalk;
var bool bBoss;
var bool bAlwaysStrafe;

var float DodgeSkillAdjust;
var sound HitSound[4];
var sound DeathSound[4];
var sound ChallengeSound[4];
var sound FireSound;
var class<Ammunition> AmmunitionClass;
var Ammunition MyAmmo;
var int ScoringValue;

var FireProperties SavedFireProperties;

// combat interface
function RangedAttack(Actor A);
function bool CanAttack(Actor A);
function StopFiring();
function bool SplashDamage();
function float GetDamageRadius();
function bool RecommendSplashDamage();

simulated function TurnOff()
{
	if ( Health > 0 )
		bVictoryNext = true;
}

simulated function bool ForceDefaultCharacter()
{
	return false;		// never replace monsters w/ default character
}

function bool IsHeadShot(vector loc, vector ray, float AdditionalScale)
{
    local vector HeadLoc, B, M, diff;
    local float t, DotMM, Distance;

    if ( HeadBone != '' )
        return super.IsHeadShot(Loc,Ray,AdditionalScale);

	HeadRadius = 0.25 * CollisionHeight;

    HeadLoc = Location + CollisionHeight * vect(0,0,0.5);

    // Express snipe trace line in terms of B + tM
    B = loc;
    M = ray * (2.0 * CollisionHeight + 2.0 * CollisionRadius);

    // Find Point-Line Squared Distance
    diff = HeadLoc - B;
    t = M Dot diff;
    if (t > 0)
    {
        DotMM = M dot M;
        if (t < DotMM)
        {
            t = t / DotMM;
            diff = diff - (t * M);
        }
        else
        {
            t = 1;
            diff -= M;
        }
    }
    else
        t = 0;

    Distance = Sqrt(diff Dot diff);

    return (Distance < (HeadRadius * HeadScale * AdditionalScale));
}

function Fire( optional float F )
{
	local Actor BestTarget;
    local float bestAim, bestDist;
    local vector FireDir, X,Y,Z;
    
    bestAim = 0.90;
    GetAxes(Controller.Rotation,X,Y,Z);
    FireDir = X;
    BestTarget = Controller.PickTarget(bestAim, bestDist, FireDir, GetFireStart(X,Y,Z), 6000); 
    RangedAttack(BestTarget);
}

function bool PreferMelee()
{
	return bMeleeFighter;
}
function bool HasRangedAttack();
function float RangedAttackTime();

function vector GetFireStart(vector X, vector Y, vector Z)
{
    return Location + 0.5 * CollisionRadius * (X+Y);
}

function FireProjectile()
{	
	local vector FireStart,X,Y,Z;
	
	if ( Controller != None )
	{
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

		Spawn(MyAmmo.ProjectileClass,,,FireStart,Controller.AdjustAim(SavedFireProperties,FireStart,600));
		PlaySound(FireSound,SLOT_Interact);
	}
}

event PostBeginPlay()
{
	Super.PostBeginPlay();
	
	if ( (ControllerClass != None) && (Controller == None) )
		Controller = spawn(ControllerClass);
	if ( Controller != None )
	{
		Controller.Possess(self);
		MyAmmo = spawn(AmmunitionClass);
	}
}

simulated function SpawnGiblet( class<Gib> GibClass, Vector Location, Rotator Rotation, float GibPerterbation )
{
    local Gib Giblet;
    local Vector Direction, Dummy;

    if( (GibClass == None) || class'GameInfo'.static.UseLowGore() )
        return;
	
	Instigator = self;
    Giblet = Spawn( GibClass,,, Location, Rotation );

    if( Giblet == None )
        return;

	Giblet.SetDrawScale(Giblet.DrawScale * (CollisionRadius*CollisionHeight)/1100); // 1100 = 25 * 44
    GibPerterbation *= 32768.0;
    Rotation.Pitch += ( FRand() * 2.0 * GibPerterbation ) - GibPerterbation;
    Rotation.Yaw += ( FRand() * 2.0 * GibPerterbation ) - GibPerterbation;
    Rotation.Roll += ( FRand() * 2.0 * GibPerterbation ) - GibPerterbation;

    GetAxes( Rotation, Dummy, Dummy, Direction );

    Giblet.Velocity = Velocity + Normal(Direction) * 512.0;
}

function LandThump()
{
	// animation notify - play sound if actually landed, and animation also shows it
	if ( Physics == PHYS_None)
		PlaySound(sound'Thump');
}

function bool SameSpeciesAs(Pawn P)
{
	return ( (Monster(P) != None) && (ClassIsChildOf(Class,P.Class) || ClassIsChildOf(P.Class,Class)) );
}

simulated function AssignInitialPose()
{
	TweenAnim(MovementAnims[0],0.0);
}

function PlayChallengeSound()
{
	PlaySound(ChallengeSound[Rand(4)],SLOT_Talk);
}

function Destroyed()
{
	if ( MyAmmo != None )
		MyAmmo.Destroy();
	Super.Destroyed();
}

function PlayVictory();

simulated function AnimEnd(int Channel)
{
	AnimAction = '';
	if ( bVictoryNext && (Physics != PHYS_Falling) )
	{
		bVictoryNext = false;
		PlayVictory();
	}
	else if ( bShotAnim )
	{	
		bShotAnim = false;
		Controller.bPreparingMove = false;
	}
	Super.AnimEnd(Channel);
}

function SetMovementPhysics()
{
	SetPhysics(PHYS_Falling);
}

function bool IsPlayerPawn()
{
	return true; // so can use movers
}

function PlayTakeHit(vector HitLocation, int Damage, class<DamageType> DamageType)
{
    PlayDirectionalHit(HitLocation);

    if( Level.TimeSeconds - LastPainSound < MinTimeBetweenPainSounds )
        return;

    LastPainSound = Level.TimeSeconds;
    PlaySound(HitSound[Rand(4)], SLOT_Pain,2*TransientSoundVolume,,400); 
}


simulated function PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	AmbientSound = None;
    bCanTeleport = false; 
    bReplicateMovement = false;
    bTearOff = true;
    bPlayedDeath = true;

	LifeSpan = RagdollLifeSpan;
    GotoState('Dying');
		
	Velocity += TearOffMomentum;
    BaseEyeHeight = Default.BaseEyeHeight;
    SetInvisibility(0.0);
    PlayDirectionalDeath(HitLoc);
    SetPhysics(PHYS_Falling);
}

function PlayDyingSound()
{
	if ( bGibbed )
	{
        PlaySound(GibGroupClass.static.GibSound(), SLOT_Pain,2.5*TransientSoundVolume,true,500);
		return;
	}

	PlaySound(DeathSound[Rand(4)], SLOT_Pain,2.5*TransientSoundVolume, true,500);
}

function bool MeleeDamageTarget(int hitdamage, vector pushdir)
{
	local vector HitLocation, HitNormal;
	local actor HitActor;
	
	// check if still in melee range
	If ( (Controller.target != None) && (VSize(Controller.Target.Location - Location) <= MeleeRange * 1.4 + Controller.Target.CollisionRadius + CollisionRadius)
		&& ((Physics == PHYS_Flying) || (Physics == PHYS_Swimming) || (Abs(Location.Z - Controller.Target.Location.Z) 
			<= FMax(CollisionHeight, Controller.Target.CollisionHeight) + 0.5 * FMin(CollisionHeight, Controller.Target.CollisionHeight))) )
	{	
		HitActor = Trace(HitLocation, HitNormal, Controller.Target.Location, Location, false);
		if ( HitActor != None )
			return false;
		Controller.Target.TakeDamage(hitdamage, self,HitLocation, pushdir, class'MeleeDamage');
		return true;
	}
	return false;
}

function PlayVictoryAnimation()
{
	bVictoryNext = true;
}	
	
simulated event SetAnimAction(name NewAction)
{
    if ( !bWaitForAnim || (Level.NetMode == NM_Client) )
    {
		AnimAction = NewAction;
		if ( PlayAnim(AnimAction,,0.1) )
		{
			if ( Physics != PHYS_None )
				bWaitForAnim = true;
		}
    }
}

function CreateGib( Name boneName, class<DamageType> DamageType, Rotator r )
{
    if ( class'GameInfo'.static.UseLowGore() )
		return;
		
	HitFX[HitFxTicker].bone = boneName;
	HitFX[HitFxTicker].damtype = DamageType;
	HitFX[HitFxTicker].bSever = true;
    HitFX[HitFxTicker].rotDir = r;
    HitFxTicker = HitFxTicker + 1;
    if( HitFxTicker > ArrayCount(HitFX)-1 )
        HitFxTicker = 0;
}

simulated function ProcessHitFX()
{
    local float GibPerterbation;

    if( (Level.NetMode == NM_DedicatedServer) || class'GameInfo'.static.UseLowGore() )
        return;

    for ( SimHitFxTicker = SimHitFxTicker; SimHitFxTicker != HitFxTicker; SimHitFxTicker = (SimHitFxTicker + 1) % ArrayCount(HitFX) )
    {
        if( HitFX[SimHitFxTicker].damtype == None )
            continue;
			
        if( HitFX[SimHitFxTicker].bSever )
        {
            GibPerterbation = HitFX[SimHitFxTicker].damtype.default.GibPerterbation;

            switch( HitFX[SimHitFxTicker].bone )
            {
                case 'lthigh':
                case 'rthigh':
                    SpawnGiblet( GetGibClass(EGT_Calf), Location - CollisionHeight * vect(0,0,0.5), HitFX[SimHitFxTicker].rotDir, GibPerterbation );
                    SpawnGiblet( GetGibClass(EGT_Calf), Location - CollisionHeight * vect(0,0,0.5), HitFX[SimHitFxTicker].rotDir, GibPerterbation );
                    GibCountCalf -= 2;
                    break;
                
                case 'rfarm':
                case 'lfarm':
                    SpawnGiblet( GetGibClass(EGT_UpperArm), Location + CollisionHeight * vect(0,0,0.5), HitFX[SimHitFxTicker].rotDir, GibPerterbation );
                    SpawnGiblet( GetGibClass(EGT_Forearm), Location + CollisionHeight * vect(0,0,0.5), HitFX[SimHitFxTicker].rotDir, GibPerterbation );
                    GibCountForearm--;
                    GibCountUpperArm--;
                    break;
                
                case 'head':
                    SpawnGiblet( GetGibClass(EGT_Head), Location + CollisionHeight * vect(0,0,0.8), HitFX[SimHitFxTicker].rotDir, GibPerterbation );
                    GibCountTorso--;
                    break;
                
                case 'spine':
                case 'none':
                    SpawnGiblet( GetGibClass(EGT_Torso), Location, HitFX[SimHitFxTicker].rotDir, GibPerterbation );
                    GibCountTorso--;
					bGibbed = true;
                    while( GibCountHead-- > 0 )
                        SpawnGiblet( GetGibClass(EGT_Head), Location + CollisionHeight * vect(0,0,0.8), HitFX[SimHitFxTicker].rotDir, GibPerterbation );
                    while( GibCountForearm-- > 0 )
                        SpawnGiblet( GetGibClass(EGT_UpperArm), Location + CollisionHeight * vect(0,0,0.5), HitFX[SimHitFxTicker].rotDir, GibPerterbation );
                    while( GibCountUpperArm-- > 0 )
                        SpawnGiblet( GetGibClass(EGT_Forearm), Location + CollisionHeight * vect(0,0,0.5), HitFX[SimHitFxTicker].rotDir, GibPerterbation );
                    bHidden = true;
                    break;
            }
        }
    }
}

State Dying
{
ignores AnimEnd, Trigger, Bump, HitWall, HeadVolumeChange, PhysicsVolumeChange, Falling, BreathTimer;

	function Landed(vector HitNormal)
	{
		SetPhysics(PHYS_None);
		if ( !IsAnimating(0) )
			LandThump();
		Super.Landed(HitNormal);
	}

    simulated function Timer()
	{
		if ( !PlayerCanSeeMe() )
			Destroy();
        else if ( LifeSpan <= DeResTime && bDeRes == false )
            StartDeRes();
 		else
 			SetTimer(1.0, false);
 	}
}

simulated function StartDeRes()
{
    if( Level.NetMode == NM_DedicatedServer )
        return;

	AmbientGlow=254;
	MaxLights=0;

	Skins[0]=DeResMat0;
	Skins[1]=DeResMat1;

	// Turn off collision when we de-res (avoids rockets etc. hitting corpse!)
	SetCollision(false, false, false);

	// Remove/disallow projectors
	Projectors.Remove(0, Projectors.Length);
	bAcceptsProjectors = false;

	// Remove shadow
	if(PlayerShadow != None)
		PlayerShadow.bShadowActive = false;

	// Remove flames
	RemoveFlamingEffects();

	// Turn off any overlays
	SetOverlayMaterial(None, 0.0f, true);

    bDeRes = true;
}

defaultproperties
{
     bMeleeFighter=True
     bCanDodge=True
     ScoringValue=1
     IdleHeavyAnim="Idle_Rest"
     IdleRifleAnim="Idle_Rest"
     bCanCrouch=False
     bCanPickupInventory=False
     MeleeRange=90.000000
     WalkingPct=0.300000
     CrouchedPct=0.300000
     ControllerClass=Class'SkaarjPack.MonsterController'
     TurnLeftAnim="Turn"
     TurnRightAnim="Turn"
     CrouchAnims(0)="Crouch"
     CrouchAnims(1)="Crouch"
     CrouchAnims(2)="Crouch"
     CrouchAnims(3)="Crouch"
     AirAnims(0)="Jump"
     AirAnims(1)="Jump"
     AirAnims(2)="Jump"
     AirAnims(3)="Jump"
     TakeoffAnims(0)="Jump"
     TakeoffAnims(1)="Jump"
     TakeoffAnims(2)="Jump"
     TakeoffAnims(3)="Jump"
     LandAnims(0)="Land"
     LandAnims(1)="Land"
     LandAnims(2)="Land"
     LandAnims(3)="Land"
     DoubleJumpAnims(0)="Jump"
     DoubleJumpAnims(1)="Jump"
     DoubleJumpAnims(2)="Jump"
     DoubleJumpAnims(3)="Jump"
     DodgeAnims(0)="Jump"
     DodgeAnims(1)="Jump"
     DodgeAnims(2)="Jump"
     DodgeAnims(3)="Jump"
     AirStillAnim="Jump"
     TakeoffStillAnim="Jump"
     CrouchTurnRightAnim="Crouch"
     CrouchTurnLeftAnim="Crouch"
     IdleWeaponAnim="Idle_Rest"
     AmbientGlow=60
     TransientSoundVolume=0.600000
     TransientSoundRadius=500.000000
}
