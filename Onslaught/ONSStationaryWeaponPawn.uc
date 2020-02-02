//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSStationaryWeaponPawn extends ONSWeaponPawn
    abstract
    placeable;

var bool bPowered;
var float RespawnTime;
var class<Emitter> DestructionEffectClass;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	//setup for when dead
	SetDrawType(DT_StaticMesh);

	if (Gun != None)
		Gun.bCallInstigatorPostRender = true;
}

function CheckSuperBerserk()
{
	if (Level.GRI != None && Level.GRI.WeaponBerserk > 1.0 && Gun != None)
		Gun.SetFireRateModifier(Level.GRI.WeaponBerserk);
}

simulated function bool IndependentVehicle()
{
	return true;
}

function bool TryToDrive(Pawn P)
{
    if (bPowered)
        return Super.TryToDrive(P);
    else
    {
        P.ReceiveLocalizedMessage(class'ONSOnslaughtMessage', 13);
        return false;
    }
}

function SetTeamNum(byte T)
{
	local byte Temp;

	Temp = Team;
	PrevTeam = T;
	Team = T;

	if (Temp != T)
		TeamChanged();
}

simulated event TeamChanged()
{
    Super.TeamChanged();

    Health = HealthMax;
}

event VehicleLocked(Pawn P)
{
	super.VehicleLocked( P );
	P.ReceiveLocalizedMessage(class'ONSOnslaughtMessage', 4);
}

function AltFire(optional float F)
{
	local PlayerController PC;

	PC = PlayerController(Controller);
	if (PC == None)
		return;

	bWeaponIsAltFiring = true;
	PC.ToggleZoom();
}

function ClientVehicleCeaseFire(bool bWasAltFire)
{
	local PlayerController PC;

	if (!bWasAltFire)
	{
		Super.ClientVehicleCeaseFire(bWasAltFire);
		return;
	}

	PC = PlayerController(Controller);
	if (PC == None)
		return;

	bWeaponIsAltFiring = false;
	PC.StopZoom();
}

simulated function ClientKDriverLeave(PlayerController PC)
{
	Super.ClientKDriverLeave(PC);

	bWeaponIsAltFiring = false;
	PC.EndZoom();
}

function Reset()
{
}

function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	local PlayerController PC;
	local Controller C;

	if ( bDeleteMe || Level.bLevelChange )
		return; // already destroyed, or level is being cleaned up

	if ( Level.Game.PreventDeath(self, Killer, damageType, HitLocation) )
	{
		Health = max(Health, 1); //mutator should set this higher
		return;
	}
	Health = Min(0, Health);

	if ( Controller != None )
	{
		C = Controller;
		C.WasKilledBy(Killer);
		Level.Game.Killed(Killer, C, self, damageType);
		if( C.bIsPlayer )
		{
			PC = PlayerController(C);
			if ( PC != None )
				ClientKDriverLeave(PC); // Just to reset HUD etc.
			else
                ClientClearController();
			if ( bRemoteControlled && (Driver != None) && (Driver.Health > 0) )
			{
				C.Unpossess();
				C.Possess(Driver);
				Driver = None;
			}
			else
				C.PawnDied(self);
		}
		else
			C.Destroy();

		if ( Driver != None )
    		{
	            if (!bRemoteControlled)
        	    {
				if (!bDrawDriverInTP && PlaceExitingDriver())
				{
					Driver.StopDriving(self);
					Driver.DrivenVehicle = self;
				}
				Driver.TearOffMomentum = Velocity * 0.25;
				Driver.Died(Controller, class'DamRanOver', Driver.Location);
        	    }
	            else
				KDriverLeave(false);
		}
	}
	else
		Level.Game.Killed(Killer, Controller(Owner), self, damageType);

	if ( Killer != None )
		TriggerEvent(Event, self, Killer.Pawn);
	else
		TriggerEvent(Event, self, None);

	if ( IsHumanControlled() )
		PlayerController(Controller).ForceDeathUpdate();

	GotoState('Dead');
}

simulated event ClientTrigger()
{
	bNoTeamBeacon = bClientTrigger;

	if ( bClientTrigger && (Level.NetMode != NM_DedicatedServer) )
		spawn(DestructionEffectClass, self).SetBase(self);
}

simulated function PostNetReceive()
{
}

state Dead
{
	function BeginState()
	{
		if (Level.NetMode != NM_DedicatedServer)
			spawn(DestructionEffectClass, self).SetBase(self);
		bClientTrigger = true;
		bNoTeamBeacon = true;
		bHidden = false;
		Gun.bHidden = true;
		SetCollision(false, false);
		bBlockZeroExtentTraces = false;
		bBlockNonZeroExtentTraces = false;
		SetTimer(RespawnTime, false);
	}

	function SetTeamNum(byte T)
	{
		GotoState('');
		Global.SetTeamNum(T);
	}

	function Timer()
	{
		GotoState('');
	}

	function EndState()
	{
		local Controller NewController;

		bClientTrigger = false;
		bNoTeamBeacon = false;
		bHidden = default.bHidden;
		Gun.bHidden = Gun.default.bHidden;
		SetCollision(default.bCollideActors, default.bBlockActors);
		bBlockZeroExtentTraces = default.bBlockZeroExtentTraces;
		bBlockNonZeroExtentTraces = default.bBlockNonZeroExtentTraces;
		Health = HealthMax;
		SetTimer(0, false);
		if (bAutoTurret && Controller == None && AutoTurretControllerClass != None)
		{
			NewController = spawn(AutoTurretControllerClass);
			if ( NewController != None )
				NewController.Possess(self);
		}
	}
}

simulated function UpdatePrecacheMaterials()
{
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Energy.SparkHead');
    Level.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp2_frames');
    Level.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp1_frames');
    Level.AddPrecacheMaterial(Material'ExplosionTex.Framed.we1_frames');

	Super.UpdatePrecacheMaterials();
}

defaultproperties
{
     RespawnTime=30.000000
     DestructionEffectClass=Class'Onslaught.ONSVehicleExplosionEffect'
     bHasOwnHealth=True
     bHasAltFire=False
     bDefensive=True
     bTeamLocked=True
     bDesiredBehindView=False
     AutoTurretControllerClass=Class'Onslaught.ONSTurretController'
     ExitPositions(0)=(X=-150.000000,Z=50.000000)
     ExitPositions(1)=(X=-100.000000,Y=150.000000,Z=50.000000)
     ExitPositions(2)=(X=-100.000000,Y=-150.000000,Z=50.000000)
     ExitPositions(3)=(X=-50.000000,Y=150.000000,Z=50.000000)
     ExitPositions(4)=(X=-50.000000,Y=-150.000000,Z=50.000000)
     VehiclePositionString="manning a turret"
     VehicleNameString="Energy Turret"
     TeamBeaconTexture=Texture'ONSInterface-TX.HealthBar'
     NoEntryTexture=Texture'HUDContent.Generic.NoEntry'
     TeamBeaconBorderMaterial=Texture'InterfaceContent.Menu.BorderBoxD'
     DrawType=DT_Mesh
     bHidden=True
     bStasis=False
     bCollideActors=True
     bBlockActors=True
     bProjTarget=True
     bBlockZeroExtentTraces=True
     bBlockNonZeroExtentTraces=True
     bBlockKarma=True
     bNetNotify=False
}
