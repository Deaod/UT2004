//=============================================================================
// xBomb
// This is the bomb.  Someone set us up the bomb.
//=============================================================================
class xBombFlag extends GameObject;

var() String        BombLauncherClassName;
var() class<Weapon> PrevWeaponClass;
var() Pawn          PassTarget;
var() float         ThrowSpeed;
var() float         Elasticity;
var() sound         ImpactSound;
var() float         ThrowerTouchDelay;
var() float         ThrowerTime;
var() vector        InitialDir;
var() float         SeekInterval;
var() transient float         SeekAccum;
var material TeamShader[2];
var byte TeamHue[2];

var bool	bThrownBomb;
var bool	bBallDrainsTransloc;

var material SecondRepSkin;
var xEmitter TossTrail;
#exec OBJ LOAD FILE=XGameShaders.utx


replication
{
    reliable if (Role == ROLE_Authority)
        SecondRepSkin, bBallDrainsTransloc;
}

function Destroyed()
{
	if ( TossTrail != None )
		TossTrail.Destroy();

	Super.Destroyed();
}

simulated event PostNetReceive()
{
	Skins[2] = SecondRepSkin;
}

function ClearHolder()
{
    if (Holder == None)
        return;

	if ( Holder.PlayerReplicationInfo != None )
	{
		Holder.PlayerReplicationInfo.HasFlag = None;
		Holder.PlayerReplicationInfo.NetUpdateTime = Level.TimeSeconds - 1;
	}
    if ( (Holder.PendingWeapon != None) && Holder.PendingWeapon.IsA('BallLauncher') )
		Holder.PendingWeapon = None;
    if ( (Holder.Weapon != None) && (Holder.Controller != None) && Holder.Weapon.IsA('BallLauncher') )
		Holder.Controller.ClientSwitchToBestWeapon();
    Holder = None;
    HolderPRI = None;
}

// State transitions
function SetHolder(Controller C)
{
    local Class<Weapon> BombLauncherClass;
	local Weapon W;
	local BombingRunSquadAI S;
	local Inventory Inv;
	local Pawn P;

	// update AI before changing states
    if ( Bot(C) != None )
		S = BombingRunSquadAI(Bot(C).Squad);
	else if ( (PlayerController(C) != None) && (UnrealTeamInfo(C.PlayerReplicationInfo.Team).AI != None) )
	{
        S = BombingRunSquadAI(UnrealTeamInfo(C.PlayerReplicationInfo.Team).AI.FindHumanSquad());
        if ( S != None && S.SquadLeader != C )
			S = None;
    }
    if ( S != None )
		S.BombTakenBy(C);

    Super.SetHolder(C);
	Instigator = Holder;
	bThrownBomb = false;
    Level.Game.GameReplicationInfo.FlagTarget = None;

    BombLauncherClass = Class<Weapon>( DynamicLoadObject( BombLauncherClassName , class'Class' ) );
    PrevWeaponClass = C.Pawn.Weapon.Class;

    if( ClassIsChildOf( PrevWeaponClass, BombLauncherClass ) )
        PrevWeaponClass = None;

	// Make sure the new holds has the BombLauncher

	P = C.Pawn;
	if (P==None)
		return;

	for( Inv=P.Inventory; Inv!=None; Inv=Inv.Inventory )
	{
		if ( ClassIsChildOf(Inv.Class, BombLauncherClass) )
			break;
	}

	if (Inv==None)
	{
		//	Give the Ball Launcher to the player
        W = Spawn(BombLauncherClass,,,P.Location);
        if( W == None )
        {
			log(self@"could not spawn a launcher for player"@p);
			return;
        }
        w.GiveTo(P);
	}

    C.ClientSetWeapon( BombLauncherClass );
}

function SetThrow(vector start)
{
	Instigator = Holder;
	ThrowerTime = Level.TimeSeconds;
	bThrownBomb = true;
    SetLocation(start);
}

function Throw(vector start, vector dir)
{
    SetThrow(start);
    Drop(Dir);
    if( PassTarget != None )
    {
        Enable('Tick');
        SetPhysics(PHYS_Projectile);
    }
    else
		Disable('Tick');
	if ( PassTarget == None )
		Level.Game.GameReplicationInfo.FlagTarget = None;
	else
		Level.Game.GameReplicationInfo.FlagTarget = PassTarget.PlayerReplicationInfo;
    if ( TossTrail == None )
		TossTrail = Spawn(class'BombTrail', self);

	TossTrail.SetBase(self);
	TossTrail.SetRelativeLocation(vect(0,0,0));
	if ( (PassTarget != None) && (PassTarget != Instigator) )
	{
		if ( Instigator.PlayerReplicationInfo.Team.TeamIndex == 0 )
		{
			TossTrail.mColorRange[0].G = 0;
			TossTrail.mColorRange[1].B = 0;
			TossTrail.mColorRange[0].B = 0;
			TossTrail.mColorRange[1].G = 0;
		}
		else
		{
			TossTrail.mColorRange[0].G = 0;
			TossTrail.mColorRange[1].R = 0;
			TossTrail.mColorRange[0].R = 0;
			TossTrail.mColorRange[1].G = 0;
		}
	}
}

function bool CanBePickedUpBy(Pawn P)
{
	return ( (P != Instigator) || (Level.TimeSeconds - ThrowerTime >= ThrowerTouchDelay - VSize(Location - P.Location)/440) );
}

function bool ValidHolder(Actor Other)
{
    local Pawn P;
    local Vector RefNormal;

    if ( (Other == Instigator) && (Level.TimeSeconds - ThrowerTime < ThrowerTouchDelay) )
        return false;

    P = Pawn(Other);
    if( P != None && P.Weapon != None )
    {
        // bounce the ball off the shield
        if( P.Weapon.CheckReflect( Location, RefNormal, 0 ) )
        {
            P.Weapon.DoReflectEffect(10);
            Velocity = (Elasticity * 2.5) * (( Velocity dot RefNormal ) * RefNormal * (-2.0) + Velocity);
	        RandSpin(30000);
            return false;
        }
    }
    return Super.ValidHolder(Other);
}

function RandSpin(float spinRate)
{
	DesiredRotation = RotRand();
	RotationRate.Yaw = spinRate * 2 *FRand() - spinRate;
	RotationRate.Pitch = spinRate * 2 *FRand() - spinRate;
	RotationRate.Roll = spinRate * 2 *FRand() - spinRate;
    bFixedRotationDir = true;
}

// Events
function HitWall( vector HitNormal, actor Wall )
{
	Velocity = Elasticity*(( Velocity dot HitNormal ) * HitNormal * (-2.0) + Velocity);
	RandSpin(30000);

    PlaySound(ImpactSound, SLOT_Misc );

	if ( (VSize(Velocity) < 20) && (HitNormal.Z >= 0.7) && Wall.bWorldGeometry )
        Landed(HitNormal);
    else if (VSize(Velocity) < 300 )
    {
		if ( TossTrail != None )
			TossTrail.Destroy();
	}
}

function Landed(vector hitNormal)
{
	if ( TossTrail != None )
		TossTrail.Destroy();
    Velocity = vect(0,0,0);
    if ( Holder == None )
		SetPhysics(PHYS_Rotating);
}

function TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType)
{
    if (Momentum != Vect(0,0,0) && !bHome && (Holder == None) )
    {
        SetPhysics(PHYS_Falling);
        Velocity += Momentum/Mass;
    }
}

// Logging
function LogDropped()
{
	local TeamInfo T;

	if ( Holder == None )
		return;

	if ( Holder.Health <= 0 )
	{
		if ( Holder.PlayerReplicationInfo != None )
		{
			if ( bLastSecondSave )
			{
				if ( Holder.PlayerReplicationInfo.Team.TeamIndex == 0 )
					T = TeamGame(Level.Game).Teams[1];
				else
					T = TeamGame(Level.Game).Teams[0];
			}
			else
				T = TeamGame(Level.Game).Teams[Holder.PlayerReplicationInfo.Team.TeamIndex];
		}
		if ( bLastSecondSave )
			BroadcastLocalizedMessage( class'LastSecondMessage', 0, Holder.PlayerReplicationInfo, None, T );
		else
			BroadcastLocalizedMessage( MessageClass, 2, Holder.PlayerReplicationInfo, None, T );
	}
    UnrealMPGameInfo(Level.Game).GameEvent("bomb_dropped","255",Holder.PlayerReplicationInfo);
}

function LogReturned()
{
	if ( Level.Game.ResetCountDown == 0 )
		BroadcastLocalizedMessage( MessageClass, 3, None, None, None );
}

function SendHomeDisabled(float TimeOut)
{
	if ( TossTrail != None )
		TossTrail.Destroy();
    CalcSetHome();
    GotoState('HomeDisabled');
}


function bool CanBeThrownBy(Pawn P)
{
//	assert(bBallDrainsTransloc == xBombingRun(Level.Game).bBallDrainsTransloc);

//	return !xBombingRun(Level.Game).bBallDrainsTransloc || (P.Health < 45);
	return !bBallDrainsTransloc || P.Health < 45;
}

// States
auto state Home
{
    ignores SendHome, Score, Drop;

    function LogTaken(Controller c)
    {
		OldTeam = C.PlayerReplicationInfo.Team;
        BroadcastLocalizedMessage( MessageClass, 6, C.PlayerReplicationInfo, None, C.PlayerReplicationInfo.Team );
        UnrealMPGameInfo(Level.Game).GameEvent("bomb_taken","255",C.PlayerReplicationInfo);
    }

    function BeginState()
    {
		if ( TossTrail != None )
			TossTrail.Destroy();
        Skins[2] = Default.Skins[2];
        SecondRepSkin = Skins[2];
		Super.BeginState();
		SetPhysics(PHYS_Rotating);
        Level.Game.GameReplicationInfo.FlagState[0] = EFlagState.FLAG_Home;
        Level.Game.GameReplicationInfo.FlagState[1] = EFlagState.FLAG_Home;
	}
}


state HomeDisabled
{
    ignores Score, Drop;

    function bool IsHome()
    {
        return true;
    }

    function BeginState()
    {
 		if ( TossTrail != None )
			TossTrail.Destroy();
		Skins[2] = Default.Skins[2];
        SecondRepSkin = Skins[2];
        SetDisable(true);
        Level.Game.GameReplicationInfo.FlagState[0] = EFlagState.FLAG_Home;
        Level.Game.GameReplicationInfo.FlagState[1] = EFlagState.FLAG_Home;
        bHome = true;
        SetLocation(HomeBase.Location);
        SetRotation(HomeBase.Rotation);
        SetCollision(false, false, false);
        bHidden = true;
    }

    function EndState()
    {
        SetDisable(false);
        bHome = false;
        SetCollision(true, false, false);
        bHidden = false;
    }
}

state Held
{
    ignores SetHolder, SendHome;

	function BeginState()
    {
		if ( TossTrail != None )
			TossTrail.Destroy();
        Level.Game.GameReplicationInfo.FlagState[Holder.PlayerReplicationInfo.Team.TeamIndex] = EFlagState.FLAG_HeldFriendly;
        if ( Holder.PlayerReplicationInfo.Team.TeamIndex == 0 )
	        Level.Game.GameReplicationInfo.FlagState[1] = EFlagState.FLAG_HeldEnemy;
        else
	        Level.Game.GameReplicationInfo.FlagState[0] = EFlagState.FLAG_HeldEnemy;
        Super.BeginState();
		bDynamicLight = false;
		LightType = LT_None;
        Skins[0] = TeamShader[Holder.PlayerReplicationInfo.Team.TeamIndex];
        RepSkin = Skins[0];
		Skins[2] = RepSkin;
		SecondRepSkin = Skins[2];
        SetStaticMesh(StaticMesh'XGame_RC.BombEffectMesh');
        SetDrawScale(1.0);
    }

    function EndState()
    {
        Super.EndState();
		bDynamicLight = true;
		LightType = LT_Steady;
        Skins[0] = Default.Skins[0];
        RepSkin = Skins[0];
        SetStaticMesh(Default.StaticMesh);
        SetDrawScale(Default.DrawScale);
    }
}

state Dropped
{
    ignores Drop;

	function HitWall( vector HitNormal, actor Wall )
	{
		if ( (PassTarget != None) 
			&& (((Acceleration Dot HitNormal) < 0) || ((Velocity Dot (PassTarget.Location - Location)) < 0)) )
		{
			Disable('Tick');
			if ( Physics == PHYS_Projectile )
				SetPhysics(PHYS_Falling);
		}
		Global.HitWall(HitNormal, Wall);
	}

	// pass seeking
	function Tick(float delta)
	{
		local vector Dir;
		local float Z;

		SeekAccum += delta;

		if( SeekAccum >= SeekInterval )
		{
			SeekAccum -= SeekInterval;

			if ( (PassTarget != None) && (PassTarget != Instigator) )
			{
				Dir = Normal((PassTarget.Location + (vect(0,0,1)*PassTarget.CollisionHeight*0.5)) - Location);
				Acceleration = 1.25 * ThrowSpeed * Dir;
				if ( VSize(Location - PassTarget.Location) < 250 )
				{
					Velocity = Velocity + 10 * Acceleration * delta;
					if ( (Dir Dot Normal(Velocity)) < 0.9 )
						Acceleration *= 0.4;
				}
				SetRotation(rotator(Acceleration));
				if ( Level.TimeSeconds - ThrowerTime > 4 )
				{
					Disable('Tick');
					if ( Physics == PHYS_Projectile )
						SetPhysics(PHYS_Falling);
				}
			}
			else
			{
				Disable('Tick');
				if ( Physics == PHYS_Projectile )
					SetPhysics(PHYS_Falling);
			}
		}
		if ( Physics == PHYS_Projectile )
			Velocity = Velocity + 10 * Acceleration * delta;
		else
		{
			Disable('Tick');
			Acceleration = vect(0,0,0);
			Z = Velocity.Z;
			Velocity.Z = 0;
			if ( VSize(Velocity) > 800 )
			{
				Velocity = 800 * Normal(Velocity);
				Velocity.Z = FMin(100,Z);
			}
		}
	}

	function Landed(vector hitNormal)
	{
		if ( Skins[2] != Default.Skins[2] )
		{
			Skins[2] = Default.Skins[2];
			SecondRepSkin = Skins[2];
		}
		Velocity = vect(0,0,0);
		Acceleration = vect(0,0,0);
		SetPhysics(PHYS_Rotating);
		if ( (Location.Z < Region.Zone.KillZ) || IsInPain() )
			Timer();
	}

    function LogTaken(Controller c)
    {
		if ( C.PlayerReplicationInfo.Team != OldTeam )
			BroadcastLocalizedMessage( MessageClass, 4, C.PlayerReplicationInfo, None, C.PlayerReplicationInfo.Team );
		OldTeam = C.PlayerReplicationInfo.Team;
        UnrealMPGameInfo(Level.Game).GameEvent("bomb_pickup","255",C.PlayerReplicationInfo);
    }

	function Timer()
	{
        UnrealMPGameInfo(Level.Game).GameEvent("bomb_returned_timeout","255",None);
		Super.Timer();
	}

	function BeginState()
	{
		if ( ((PassTarget == None) || (PassTarget == Instigator)) && (Skins[2] != Default.Skins[2]) )
		{
			Skins[2] = Default.Skins[2];
			SecondRepSkin = Skins[2];
 	       SetPhysics(PHYS_Falling);
		}
		else if ( Physics != PHYS_Projectile )
			SetPhysics(PHYS_Falling);
		SetTimer(MaxDropTime, false);
        SetPhysics(PHYS_Falling);
		Level.Game.GameReplicationInfo.FlagState[0] = EFlagState.FLAG_Down;
        Level.Game.GameReplicationInfo.FlagState[1] = EFlagState.FLAG_Down;
    }

    function EndState()
    {
		PassTarget = None;
		if ( Skins[2] != Default.Skins[2] )
		{
			Skins[2] = Default.Skins[2];
			SecondRepSkin = Skins[2];
		}
		Super.EndState();
	}
}

defaultproperties
{
     BombLauncherClassName="XWeapons.BallLauncher"
     ThrowSpeed=1300.000000
     Elasticity=0.400000
     ImpactSound=Sound'WeaponSounds.Misc.ball_bounce_v3a'
     ThrowerTouchDelay=1.000000
     SeekInterval=0.050000
     TeamShader(0)=Shader'XGameShaders.BRShaders.BombIconRS'
     TeamShader(1)=Shader'XGameShaders.BRShaders.BombIconBS'
     TeamHue(1)=170
     SecondRepSkin=Shader'XGameShaders.BRShaders.BombIconYS'
     bHome=True
     GameObjBone="spine"
     LightType=LT_Steady
     LightEffect=LE_QuadraticNonIncidence
     LightHue=40
     LightBrightness=255.000000
     LightRadius=6.000000
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'E_Pickups.BombBall.FullBomb'
     bStatic=False
     bDynamicLight=True
     bStasis=False
     Physics=PHYS_Rotating
     NetUpdateFrequency=100.000000
     NetPriority=3.000000
     DrawScale=1.500000
     PrePivot=(X=2.000000,Z=0.500000)
     Skins(1)=Shader'XGameShaders.BRShaders.BombIconYS'
     Skins(2)=Shader'XGameShaders.BRShaders.BombIconYS'
     Style=STY_Masked
     bUnlit=True
     SoundRadius=250.000000
     CollisionRadius=24.000000
     CollisionHeight=20.000000
     bCollideActors=True
     bCollideWorld=True
     bProjTarget=True
     bBounce=True
     bFixedRotationDir=True
     Buoyancy=20.000000
     RotationRate=(Yaw=30000)
     DesiredRotation=(Yaw=30000)
     MessageClass=Class'XGame.xBombMessage'
}
