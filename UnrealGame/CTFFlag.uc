class CTFFlag extends GameObject;

var byte 			TeamNum;
var UnrealTeamInfo 	Team;
var UnrealPawn 		OldHolder;
var GameReplicationInfo GRI;

replication
{
	reliable if ( Role == ROLE_Authority )
		Team;
}

simulated function UpdateForTeam()
{
	if ( (GRI != None) && (TeamNum < 2) && (GRI.TeamSymbols[TeamNum] != None) )
	    TexScaler(Combiner(Shader(FinalBlend(Skins[0]).Material).Diffuse).Material2).Material = GRI.TeamSymbols[TeamNum];
}

simulated function SetGRI(GameReplicationInfo NewGRI)
{
	GRI = NewGRI;
	UpdateForTeam();
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
    if ( Level.Game != None )
		SetGRI(Level.Game.GameReplicationInfo);
}

// State transitions
function SetHolder(Controller C)
{
	local CTFSquadAI S;

	// AI Related
	if ( Bot(C) != None )
		S = CTFSquadAI(Bot(C).Squad);
	else if ( PlayerController(C) != None )
		S = CTFSquadAI(UnrealTeamInfo(C.PlayerReplicationInfo.Team).AI.FindHumanSquad());
	if ( S != None )
		S.EnemyFlagTakenBy(C);

	Super.SetHolder(C);

    C.SendMessage(None, 'OTHER', C.GetMessageIndex('GOTENEMYFLAG'), 10, 'TEAM');
}

function Drop(vector newVel)
{
    OldHolder = Holder;

	RotationRate.Yaw = Rand(200000) - 100000;
	RotationRate.Pitch = Rand(200000 - Abs(RotationRate.Yaw)) - 0.5 * (200000 - Abs(RotationRate.Yaw));

    Velocity = (0.2 + FRand()) * (newVel + 400 * FRand() * VRand());
	if ( PhysicsVolume.bWaterVolume )
		Velocity *= 0.5;

    Super.Drop(Velocity);

	if ( !FastTrace(OldHolder.Location, Location) )
	{
        //log(self$" Drop sent flag home", 'Error');
		UnrealMPGameInfo(Level.Game).GameEvent("flag_returned_timeout",""$Team.TeamIndex,None);
		BroadcastLocalizedMessage( MessageClass, 3, None, None, Team );
		SendHome();
        Disable('Touch');
        bHome = true;
        SetLocation(HomeBase.Location);
        SetRotation(HomeBase.Rotation);
        Enable('Touch');
		return;
	}
}

// Helper funcs
function bool SameTeam(Controller c)
{
    if (c == None || c.PlayerReplicationInfo.Team != Team)
        return false;

    return true;
}

function bool ValidHolder(Actor Other)
{
    local Controller c;

    if (!Super.ValidHolder(Other))
        return false;

    c = Pawn(Other).Controller;
	if (SameTeam(c))
	{
        SameTeamTouch(c);
        return false;
	}

    return true;
}

function SameTeamTouch(Controller c)
{
}

// Events
function Landed(vector HitNormal)
{
	local rotator NewRot;

	NewRot = Rot(16384,0,0);
	NewRot.Yaw = Rotation.Yaw;
	SetRotation(NewRot);
	Super.Landed(HitNormal);
}

// Logging
function LogReturned();

function LogDropped()
{
	if ( bLastSecondSave )
		BroadcastLocalizedMessage( class'LastSecondMessage', 1, Holder.PlayerReplicationInfo, None, Team );
	else
		BroadcastLocalizedMessage( MessageClass, 2, Holder.PlayerReplicationInfo, None, Team );
	bLastSecondSave = false;
	UnrealMPGameInfo(Level.Game).GameEvent("flag_dropped",""$Team.TeamIndex, Holder.PlayerReplicationInfo);
}

function CheckPain(); // stub

event FellOutOfWorld(eKillZType KillType)
{
	BroadcastLocalizedMessage( MessageClass, 3, None, None, Team );
    SendHome();
}

simulated event BaseChange()
{
	Super.BaseChange();

	bAlwaysZeroBoneOffset = default.bAlwaysZeroBoneOffset && (Vehicle(Base) == None);
}

// States
auto state Home
{
    ignores SendHome, Score, Drop;

    function SameTeamTouch(Controller c)
    {
        local CTFFlag flag;

        if (C.PlayerReplicationInfo.HasFlag == None)
            return;

        // Score!
        flag = CTFFlag(C.PlayerReplicationInfo.HasFlag);
        UnrealMPGameInfo(Level.Game).ScoreGameObject(C, flag);
        flag.Score();
		TriggerEvent(HomeBase.Event,HomeBase,C.Pawn);
        if (Bot(C) != None)
            Bot(C).Squad.SetAlternatePath(true);
    }

    function LogTaken(Controller c)
    {
        BroadcastLocalizedMessage( MessageClass, 6, C.PlayerReplicationInfo, None, Team );
        UnrealMPGameInfo(Level.Game).GameEvent("flag_taken",""$Team.TeamIndex,C.PlayerReplicationInfo);
    }

	function Timer()
	{
		if ( VSize(Location - HomeBase.Location) > 10 )
		{
			UnrealMPGameInfo(Level.Game).GameEvent("flag_returned_timeout",""$Team.TeamIndex,None);
			BroadcastLocalizedMessage( MessageClass, 3, None, None, Team );
            log(self$" Home.Timer: had to sendhome", 'Error');
			SendHome();
		}
	}

	function BeginState()
	{
        Super.BeginState();
        Level.Game.GameReplicationInfo.FlagState[TeamNum] = EFlagState.FLAG_Home;
		bHidden = true;
		HomeBase.bHidden = false;
		HomeBase.Timer();
		HomeBase.NetUpdateTime = Level.TimeSeconds - 1;
		SetTimer(1.0, true);
	}

	function EndState()
	{
        Super.EndState();
		bHidden = false;
		HomeBase.bHidden = true;
		HomeBase.PlayAlarm();
		HomeBase.NetUpdateTime = Level.TimeSeconds - 1;
		SetTimer(0.0, false);
	}
}

state Held
{
    ignores SetHolder, SendHome;

	function Timer()
	{
		if (Holder == None)
        {
            log(self$" Held.Timer: had to sendhome", 'Error');
			UnrealMPGameInfo(Level.Game).GameEvent("flag_returned_timeout",""$Team.TeamIndex,None);
			BroadcastLocalizedMessage( MessageClass, 3, None, None, Team );

		    CalcSetHome();
		    GotoState('Home');
        }
	}

	function BeginState()
	{
        Level.Game.GameReplicationInfo.FlagState[TeamNum] = EFlagState.FLAG_HeldEnemy;
        Super.BeginState();
		SetTimer(10.0, true);
	}
}


state Dropped
{
   ignores Drop;

   function SameTeamTouch(Controller c)
	{
		// returned flag
		UnrealMPGameInfo(Level.Game).ScoreGameObject(C, self);
		SendHome();
	}

    function LogTaken(Controller c)
    {
        UnrealMPGameInfo(Level.Game).GameEvent("flag_pickup",""$Team.TeamIndex,C.PlayerReplicationInfo);
        BroadcastLocalizedMessage( MessageClass, 4, C.PlayerReplicationInfo, None, Team );
    }

	function CheckFit()
	{
		local vector X,Y,Z;

		GetAxes(OldHolder.Rotation, X,Y,Z);
		SetRotation(rotator(-1 * X));
		if ( !SetLocation(OldHolder.Location - 2 * OldHolder.CollisionRadius * X + OldHolder.CollisionHeight * vect(0,0,0.5))
			&& !SetLocation(OldHolder.Location) )
		{
			SetCollisionSize(0.8 * OldHolder.CollisionRadius, FMin(CollisionHeight, 0.8 * OldHolder.CollisionHeight));
			if ( !SetLocation(OldHolder.Location) || !FastTrace(OldHolder.Location, Location) )
			{
				//log(self$" Drop sent flag home", 'Error');
				UnrealMPGameInfo(Level.Game).GameEvent("flag_returned_timeout",""$Team.TeamIndex,None);
				BroadcastLocalizedMessage( MessageClass, 3, None, None, Team );
				SendHome();
				Disable('Touch');
				bHome = true;
				SetLocation(HomeBase.Location);
				SetRotation(HomeBase.Rotation);
				Enable('Touch');
				return;
			}
		}
	}

    function CheckPain()
    {
        if (IsInPain())
            timer();
    }

	function TakeDamage( int NDamage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType)
	{
        CheckPain();
	}

	singular function PhysicsVolumeChange( PhysicsVolume NewVolume )
	{
		Super.PhysicsVolumeChange(NewVolume);
        CheckPain();
	}

	function BeginState()
	{
        Level.Game.GameReplicationInfo.FlagState[TeamNum] = EFlagState.FLAG_Down;
        Super.BeginState();
	    bCollideWorld = true;
	    SetCollisionSize(0.5 * default.CollisionRadius, CollisionHeight);
        SetCollision(true, false, false);
        CheckFit();
        CheckPain();
		SetTimer(MaxDropTime, false);
	}

    function EndState()
    {
        Super.EndState();
		bCollideWorld = false;
		SetCollisionSize(default.CollisionRadius, default.CollisionHeight);
    }

	function Timer()
	{
		BroadcastLocalizedMessage( MessageClass, 3, None, None, Team );
		UnrealMPGameInfo(Level.Game).GameEvent("flag_returned_timeout",""$Team.TeamIndex,None);
		Super.Timer();
	}
}

defaultproperties
{
     bHome=True
     LightType=LT_Steady
     LightEffect=LE_QuadraticNonIncidence
     LightSaturation=128
     LightBrightness=220.000000
     LightRadius=6.000000
     bStatic=False
     bHidden=True
     bDynamicLight=True
     bStasis=False
     NetPriority=3.000000
     DrawScale=0.600000
     PrePivot=(X=2.000000,Z=0.500000)
     Style=STY_Masked
     bUnlit=True
     CollisionRadius=48.000000
     CollisionHeight=30.000000
     bCollideActors=True
     bCollideWorld=True
     bFixedRotationDir=True
     Mass=30.000000
     Buoyancy=20.000000
     RotationRate=(Pitch=30000,Roll=30000)
     MessageClass=Class'UnrealGame.CTFMessage'
}
