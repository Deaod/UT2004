class ONSPowerCore extends DestroyableObjective
	hidecategories(DestroyableObjective)
	abstract;

#exec OBJ LOAD FILE="..\StaticMeshes\VMStructures.usx"
#exec OBJ LOAD FILE="..\Textures\ONSstructureTextures.utx"


var(Events) name            RedActivationEventName;
var(Events) name            BlueActivationEventName;
var(Events) name            DestroyedEventName;

var()   float               ConstructionTime;
var()   StaticMesh          DeadStaticMesh;
var()   sound               DestroyedSound;
var()	sound				ConstructedSound;
var()	sound				StartConstructionSound;
var()   sound               ActiveSound;
var()   sound               NeutralSound;
var()   sound               HealingSound;
var()   sound               HealedSound;
var()   bool                bStartNeutral;
var()   bool                bPowered;
var()   bool                bFinalCore;

var     bool                bPoweredByRed;
var     bool                bPoweredByBlue;
var     bool                bSevered;
var     bool                bUnderAttack;
var     bool                bOldUnderAttack;

var     globalconfig  bool        bShowNodeBeams;

var array<name> LinkedNodes;
var array<ONSPowerCore> PowerLinks;

// Internal
var array<Material> RedConstructingSkins;
var array<Material> BlueConstructingSkins;
var array<Material> RedActiveSkins;
var array<Material> BlueActiveSkins;
var byte            CoreStage;
var byte            LastCoreStage;
var byte            FinalCoreDistance[2];
var float           ConstructionTimeElapsed;
var float           LastAttackTime;
var float           LastAttackExpirationTime;
var float           LastAttackAnnouncementTime;
var float           LastAttackMessageTime;
var float           SeveredDamagePerSecond;
var float           HealingTime;
var array<Actor>    CloseActors;
var array<ONSTeleportPad> TeleportPads;
var Triggers TeleportTrigger;
var int DestructionMessageIndex; //base switch for ONSOnslaughtMessage
var string DestroyedEvent[4];
var string ConstructedEvent[2];
var Controller Constructor; //player who touched me to start construction
var Controller LastHealedBy;
var ONSNodeHealEffect NodeHealEffect;
var Emitter NodeBeamEffect;
var Emitter ExplosionEffect;

var ONSFreeRoamingEnergyEffect  RoamingEnergy;
var ONSPowerCoreShield          Shield;
var class<ONSPowerCoreShield>   ShieldClass;
var vector			ShieldOffset;

var PlayerReplicationInfo LastDamagedBy;
var Pawn LastAttacker;
var ONSPowerCore NextCore;	// link it :P  -- rjp

var byte LastDefenderTeamIndex;
var(HUD) vector HUDLocation;
var int NodeNum;

replication
{
	reliable if (bNetDirty && Role == ROLE_Authority)
		CoreStage, bUnderAttack, bPoweredByRed, bPoweredByBlue, bSevered;
}

delegate UpdateLinkState(ONSPowerCore Node);
delegate NotifyUpdateLinks();
delegate OnCoreDestroyed( byte DestroyedCoreIndex );

simulated function UpdatePrecacheMaterials()
{
	local int i;

	for ( i=0; i<RedConstructingSkins.Length; i++ )
		Level.AddPrecacheMaterial(RedConstructingSkins[i]);

	for ( i=0; i<BlueConstructingSkins.Length; i++ )
		Level.AddPrecacheMaterial(BlueConstructingSkins[i]);

	for ( i=0; i<RedActiveSkins.Length; i++ )
		Level.AddPrecacheMaterial(RedActiveSkins[i]);

	for ( i=0; i<BlueActiveSkins.Length; i++ )
		Level.AddPrecacheMaterial(BlueActiveSkins[i]);

	Level.AddPrecacheMaterial(Material'AW-2004Particles.Energy.AirBlast');
	Level.AddPrecacheMaterial(Material'AW-2004Particles.Energy.PowerBeam');
	Level.AddPrecacheMaterial(Material'ONSstructureTextures.CoreBreachGroup.exp7_framesBLUE');
	Level.AddPrecacheMaterial(Material'ONSstructureTextures.CoreBreachGroup.coreBreachACCRETIONblue');
	Level.AddPrecacheMaterial(Material'ONSstructureTextures.CoreBreachGroup.CoreBreachShockRingTRANS');
	Level.AddPrecacheMaterial(Material'ONSstructureTextures.CoreBreachGroup.CoreBreachShockRINGedge');
	Level.AddPrecacheMaterial(Material'VMParticleTextures.PowerNodeEXP.powerNodeEXPblueTEX');
	Level.AddPrecacheMaterial(Material'ONSstructureTextures.CoreBreachGroup.coreBreachACCRETIONred');
	Level.AddPrecacheMaterial(Material'VMParticleTextures.PowerNodeEXP.powerNodeEXPredTEX');

    Super.UpdatePrecacheMaterials();
}

simulated function UpdatePrecacheStaticMeshes()
{
    if (DeadStaticMesh != None)
	   Level.AddPrecacheStaticMesh(DeadStaticMesh);

	Super.UpdatePrecacheStaticMeshes();
}

event SetInitialState()
{
    Disable('Tick');

	InitialState = '';

    if (PowerLinks.length == 0)
    {
        CoreStage = 255;
        PowerCoreDisabled();
        InitialState = 'DisabledCore';
    }
    else if (bStartNeutral)
    {
        CoreStage = 4;
        PowerCoreNeutral();
        InitialState = 'NeutralCore';
    }
    else
    {
		CoreStage = 0;
        PowerCoreActive();
    }

    Super.SetInitialState();
}

simulated event BeginPlay()
{
    PowerLinks.Length = 0;
}

simulated event PostBeginPlay()
{
    local bool bWasDisabled;

    bWasDisabled = bDisabled;
    Super.PostBeginPlay();
    bDisabled = bWasDisabled;

    Shield = Spawn(ShieldClass, self,, Location + ShieldOffset);

    SetupPowerLinks();

    if (Role == ROLE_Authority)
    	SpawnNodeTeleportTrigger();
}

function SpawnNodeTeleportTrigger()
{
	TeleportTrigger = spawn(class'ONSPCTeleportTrigger', self);
}

simulated event PostNetBeginPlay()
{
    FindCloseActors();
    CheckShield();
}

simulated function ONSPowerCore ClosestTo(Actor A)
{
    local float Distance, BestDistance;
    local ONSPowerCore C, Best;

	BestDistance = VSize(A.Location - Location);
	Best = Self;

	for ( C = NextCore; C != Self && C != None; C = C.NextCore )
	{
		Distance = VSize(A.Location - C.Location);
		if ( Distance < BestDistance )
		{
			BestDistance = Distance;
			Best = C;
		}
	}

	return Best;
}

simulated function FindCloseActors()
{
	local Actor A;

	CloseActors.Length = 0;

	if (Role == ROLE_Authority)
	{
		foreach AllActors(class 'Actor', A)
			if ( (A.IsA('PlayerStart') || A.IsA('ONSVehicleFactory') || A.IsA('ONSStationaryWeaponPawn') || A.IsA('xTeamBanner') || A.IsA('ONSTeleportPad'))
			     && ClosestTo(A) == self )
			{
				if (A.IsA('ONSTeleportPad'))
				{
					A.SetOwner(self);
					TeleportPads[TeleportPads.length] = ONSTeleportPad(A);
				}
				else
					CloseActors[CloseActors.Length] = A;
			}
	}
	else
	{
		foreach AllActors(class'Actor', A)
			if ((A.IsA('xTeamBanner') || A.IsA('ONSTeleportPad')) && ClosestTo(A) == self)
			{
				if (A.IsA('ONSTeleportPad'))
				{
					A.SetOwner(self);
					TeleportPads[TeleportPads.length] = ONSTeleportPad(A);
				}
				else
					CloseActors[CloseActors.Length] = A;
			}
	}
}

simulated function SetupPowerLinks()
{
    local ONSPowerCore PC;
    local NavigationPoint N;

//	log(Name@"SetupPowerLinks()");
    for ( N = Level.NavigationPointList; N != None; N = N.nextNavigationPoint )
    {
    	PC = ONSPowerCore(N);
    	if ( PC != None )
    	{
    		if ( NextCore == None )
    		{
				if ( PC.NextCore == None )
					NextCore = PC;
				else NextCore = PC.NextCore;
				PC.NextCore = Self;
			}

			if ( ShouldLinkTo(PC) )
				AddPowerLink(PC);
		}
	}
}

simulated function ResetLinks()
{
	local ONSPowerCore Core;

	PowerLinks.Remove(0,PowerLinks.Length);
	Core = NextCore;
	do
	{
		if ( ShouldLinkTo(Core) )
			AddPowerLink(Core);

		Core = Core.NextCore;
	}
	until ( Core == None || Core == Self );

	SetInitialState();
}

function Sever()
{
	if (Level.Game.ResetCountDown <= 0 && !Level.Game.bGameEnded)
	{
		SetTimer(1.0, True);
		if (DefenderTeamIndex == 0)
			BroadcastLocalizedMessage(class'ONSOnslaughtMessage', 27);
		else if (DefenderTeamIndex == 1)
			BroadcastLocalizedMessage(class'ONSOnslaughtMessage', 28);
	}
}

function UnSever()
{
    SetTimer(0, false);
}

simulated function AddPowerLink(ONSPowerCore PC)
{
    if ( PC == self || LinkedTo(PC) )
    	return;

    PowerLinks[PowerLinks.Length] = PC;
	if ( PC.bFinalCore )
		DefensePriority = Max(DefensePriority, 5);

	PC.AddPowerLink(Self);
}

simulated function RemovePowerLink(ONSPowerCore PC)
{
    local int i;

	i = FindNodeLinkIndex(PC);

//	log(Name@"RemovePowerLink "@PC.Name);
	if ( i != -1 )
	{
		PowerLinks.Remove(i,1);
		if ( bFinalCore )
			PC.RemovedCoreLink();
//		PC.RemovePowerLink(self);
	}
}

simulated function RemovedCoreLink()
{
	local int i;

	for ( i = 0; i < PowerLinks.Length; i++ )
		if ( PowerLinks[i].bFinalCore )
			return;

	DefensePriority = default.DefensePriority;
}

simulated function protected bool ShouldLinkTo( ONSPowerCore Node )
{
	local int i;

	if ( Node == None )
		return false;

    for (i=0; i<LinkedNodes.Length; i++)
    	if ( Node.Name == LinkedNodes[i] )
    		return true;

    return false;
}

simulated function bool LinkedTo(ONSPowerCore PC)
{
	return FindNodeLinkIndex(PC) != -1;
}

simulated function int FindNodeLinkIndex( ONSPowerCore Node )
{
	local int i;

	if ( Node == None )
		return -1;

	for ( i = 0; i < PowerLinks.Length; i++ )
		if ( PowerLinks[i] == Node )
			return i;

	return -1;
}

function DisableObjective(Pawn Instigator)
{
	local PlayerReplicationInfo	PRI;

	if (CoreStage != 5)
	{
		if ( Instigator != None )
			PRI = Instigator.PlayerReplicationInfo;
		else if ( DelayedDamageInstigatorController != None )
			PRI = DelayedDamageInstigatorController.PlayerReplicationInfo;

		BroadcastLocalizedMessage(class'ONSOnslaughtMessage', DestructionMessageIndex + DefenderTeamIndex, PRI);

		if ( bAccruePoints )
			Level.Game.ScoreObjective( PRI, 0 );
		else
		{
			if (CoreStage == 0)
				ShareScore(Score, DestroyedEvent[DefenderTeamIndex]);
			else
				ShareScore(Score, DestroyedEvent[2+DefenderTeamIndex]);
		}
	}

	CoreStage = 1;
	TriggerEvent(DestroyedEventName, self, None);

	PowerCoreDestroyed();

	UnrealMPGameInfo(Level.Game).ObjectiveDisabled(Self);
	UnrealMPGameInfo(Level.Game).FindNewObjectives(Self);
	TriggerEvent(Event, self, Instigator);
}

function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType)
{
	local Controller InstigatorController;

	//if (instigatedBy != None && ScriptedController(instigatedBy.Controller) != None)
	//	Log("SCRIPTED DAMAGE:"@Damage@"CORESTAGE:"@CoreStage@"HEALTH:"@Health@"POWEREDBYINSTIGATED:"@PoweredBy(instigatedBy.GetTeamNum()));

	if (CoreStage == 4 || CoreStage == 1 || Damage <= 0 || Level.Game.ResetCountdown > 0 || Level.Game.bGameEnded)
		return;

	if (damageType == None || !damageType.default.bDelayedDamage)
		DelayedDamageInstigatorController = None;
	if (instigatedBy != None && instigatedBy.Controller != None)
		InstigatorController = instigatedBy.Controller;
	else
		InstigatorController = DelayedDamageInstigatorController;

	if (InstigatorController == None && damageType != None)
		return;

    if (damageType != None)
		Damage *= damageType.default.VehicleDamageScaling;
    if (instigatedBy != None)
    {
    	if (instigatedBy.HasUDamage())
		Damage *= 2;
		Damage *= instigatedBy.DamageScaling;
    }

    if ( InstigatorController == None || (InstigatorController.GetTeamNum() != DefenderTeamIndex && PoweredBy(InstigatorController.GetTeamNum())) )
    {
		NetUpdateTime = Level.TimeSeconds - 1;
    	AccumulatedDamage += Damage;
    	if ((DamageEventThreshold > 0) && (AccumulatedDamage >= DamageEventThreshold))
    	{
    		TriggerEvent(TakeDamageEvent,self, InstigatedBy);
    		AccumulatedDamage = 0;
    	}
	if (InstigatorController != None)
	{
		LastDamagedBy = InstigatorController.PlayerReplicationInfo;
		LastAttacker = instigatedBy;
		AddScorer(InstigatorController, FMin(Health, Damage) / DamageCapacity);
	}
	if ( bFinalCore )
		NetUpdateTime = Level.TimeSeconds - 1;
    Health -= Damage;
    if ( Health < 0 )
    	DisableObjective(instigatedBy);
	else if (damageType != None)
	{
		//attack notification
		if (LastAttackMessageTime + 1 < Level.TimeSeconds)
		{
			if (bFinalCore)
			{
				if (float(Health) / DamageCapacity > 0.55)
					BroadcastLocalizedMessage(class'ONSOnslaughtMessage', 7 + DefenderTeamIndex,,, self);
				else if (float(Health) / DamageCapacity > 0.45)
					BroadcastLocalizedMessage(class'ONSOnslaughtMessage', 25 + DefenderTeamIndex,,, self);
				else
					BroadcastLocalizedMessage(class'ONSOnslaughtMessage', 18 + DefenderTeamIndex,,, self);
			}
			else
				BroadcastLocalizedMessage(class'ONSOnslaughtMessage', 9 + DefenderTeamIndex,,, self);
			UnrealTeamInfo(Level.GRI.Teams[DefenderTeamIndex]).AI.CriticalObjectiveWarning(self, instigatedBy);
			LastAttackMessageTime = Level.TimeSeconds;
		}
		LastAttackTime = Level.TimeSeconds;
	}
    }
    else if (PlayerController(InstigatorController) != None)
    {
    	if (InstigatorController.GetTeamNum() != DefenderTeamIndex)
	        PlayerController(InstigatorController).ReceiveLocalizedMessage(class'ONSOnslaughtMessage', 5);
		else if (bFinalCore && DamageType == class'DamTypeLinkShaft')
			PlayerController(InstigatorController).ReceiveLocalizedMessage(class'ONSOnslaughtMessage', 30);
    }
}

function bool HealDamage(int Amount, Controller Healer, class<DamageType> DamageType)
{
	if (CoreStage == 4 || CoreStage == 1 || Health <= 0 || Amount <= 0 || Healer == None || !TeamLink(Healer.GetTeamNum()))
		return false;

	if (Health >= DamageCapacity)
	{
        if (Level.TimeSeconds - HealingTime < 0.5)
            PlaySound(HealedSound, SLOT_Misc, 5.0);

        return false;
    }

	Amount = Min(Amount * LinkHealMult, DamageCapacity - Health);
	Health += Amount;
	if (ONSPlayerReplicationInfo(Healer.PlayerReplicationInfo) != None)
		ONSPlayerReplicationInfo(Healer.PlayerReplicationInfo).AddHealBonus(float(Amount) / DamageCapacity * Score);

	NetUpdateTime = Level.TimeSeconds - 1;
    HealingTime = Level.TimeSeconds;
    LastHealedBy = Healer;

    if (NodeHealEffect == None)
    {
        NodeHealEffect = Spawn(class'ONSNodeHealEffect', self,, Location + vect(0,0,363));
        NodeHealEffect.AmbientSound = HealingSound;
		if ( Level.NetMode == NM_DedicatedServer )
			NodeHealEffect.LifeSpan = 5000.0;
    }

    Enable('Tick');

    return true;
}

simulated event Tick(float DT)
{
    if (Level.TimeSeconds - HealingTime > 0.5)
    {
        if (NodeHealEffect != None)
            NodeHealEffect.Destroy();

		Disable('Tick');
    }
}

simulated function bool PoweredBy(byte Team)
{
    if (Team == 0 && bPoweredByRed)
        return True;
    if (Team == 1 && bPoweredByBlue)
        return True;
    return False;
}

function bool LinkedToCoreConstructingFor(byte Team)
{
	local int i;

	for (i = 0; i < PowerLinks.length; i++)
		if ( (PowerLinks[i].DefenderTeamIndex == Team) && ((PowerLinks[i].CoreStage == 2) || (PowerLinks[i].CoreStage == 5)) )
			return true;

	return false;
}

simulated event PostNetReceive()
{
    if (CoreStage != LastCoreStage)
    {
//    	log(Name@"CoreStage changed from "$LastCoreStage@"to"@CoreStage);
	   LastCoreStage = CoreStage;
       switch(CoreStage)
        {
            case 0:
                PowerCoreActive();
                break;
            case 1:
                PowerCoreDestroyed();
                break;
            case 2:
                PowerCoreConstructing();
                break;
            case 3:
                PowerCoreReset();
                break;
            case 4:
                PowerCoreNeutral();
                break;
            case 5:
                PowerCoreReconstitution();
            	break;
            case 255:
            	PowerCoreDisabled();
            	break;
        }
//        UpdateLinkState(Self);
    }

    if (bUnderAttack != bOldUnderAttack)
    {
//    	log(Name@"UnderAttackChanged to"@bUnderAttack);
        UnderAttackChange();
        bOldUnderAttack = bUnderAttack;
    }

    if ( DefenderTeamIndex != LastDefenderTeamIndex )
    {
//    	log(Name@"DefenderTeamIndex changed from "$LastDefenderTeamIndex@"to"@DefenderTeamIndex);
    	LastDefenderTeamIndex = DefenderTeamIndex;
    	UpdateLinkState(Self);
    }

    CheckShield();
}

simulated function NotifyLocalPlayerTeamReceived()
{
	CheckShield();
}

simulated function UnderAttackChange()
{
    if (NodeBeamEffect != None && NodeBeamEffect.Emitters[2] != None)
        NodeBeamEffect.Emitters[2].Disabled = !bUnderAttack;
}

// Hide/UnHide Shield Effect
simulated function CheckShield()
{
	local PlayerController PC;

	UpdateLocationName();

	if ( NodeBeamEffect != None )
	{
		NodeBeamEffect.bHidden = !bShowNodeBeams;

		if ( (CoreStage != 0 || (NodeBeamEffect.IsA('ONSNodeBeamRedEffect') && DefenderTeamIndex == 1) || (NodeBeamEffect.IsA('ONSNodeBeamBlueEffect') && DefenderTeamIndex == 0)))
			NodeBeamEffect.Destroy();
	}
	if (PoweredBy(1 - DefenderTeamIndex))
	{
        Shield.bHidden = true;
		Shield.SetCollision(false);

        if ( (Level.NetMode != NM_DedicatedServer) && bShowNodeBeams && CoreStage == 0 && NodeBeamEffect == None)
        {
            if (DefenderTeamIndex == 0)
                NodeBeamEffect = spawn(class'ONSNodeBeamRedEffect');
            else
                NodeBeamEffect = spawn(class'ONSNodeBeamBlueEffect');
        }
	}
	else if (CoreStage != 0 && CoreStage != 2)
    {
        Shield.bHidden = true;
		Shield.SetCollision(false);
		if (NodeBeamEffect != None)
            NodeBeamEffect.Destroy();
	}
	else
	{
		Shield.bHidden = false;
		Shield.SetCollision(true);
		Shield.SetTeam(DefenderTeamIndex);
		if (NodeBeamEffect != None)
            NodeBeamEffect.Destroy();
	}

	if (Level.NetMode == NM_DedicatedServer || CoreStage != 4)
		return;

	PC = Level.GetLocalPlayerController();
	if (PC == None || PC.PlayerReplicationInfo == None || (!PC.PlayerReplicationInfo.bOnlySpectator && PC.PlayerReplicationInfo.Team == None))
		return;

	if (PoweredBy(PC.GetTeamNum()))
	{
		if (RoamingEnergy == None)
		        RoamingEnergy = spawn(class'ONSFreeRoamingEnergyEffect',self,, Location + vect(0,0,30) + PrePivot * -2);
	}
	else if (RoamingEnergy != None)
	{
		RoamingEnergy.Kill();
		RoamingEnergy = None;
	}
}

simulated function PowerCoreDisabled()
{
//	log(Name@"PowerCoreDisabled");
    bHidden = True;
    bPowered = False;

    if (RoamingEnergy != None)
        RoamingEnergy.Destroy();

    CheckShield();

    UpdateLinkState(Self);
}

simulated function PowerCoreNeutral()
{
    AmbientSound = NeutralSound;

//	log(Name@"PowerCoreNeutral");
    Health = 0;
    bPowered = False;
    DefenderTeamIndex = 2;
	NetUpdateTime = Level.TimeSeconds - 1;

    if (Level.NetMode != NM_DedicatedServer)
        UpdateTeamBanners();

    if (Role == ROLE_Authority)
    {
    	NetUpdateTime = Level.TimeSeconds - 1;
	   	NotifyUpdateLinks();
	}

	UpdateLinkState(Self);
}

simulated function PowerCoreReconstitution()
{
    if (Level.NetMode != NM_DedicatedServer)
    {
    	if (RoamingEnergy != None)
	    RoamingEnergy.Destroy();

        if (DefenderTeamIndex == 0)
            Spawn(class'ONSRedEnergyEffect',self,, Location + vect(0,0,-20));
        else
            Spawn(class'ONSBlueEnergyEffect',self,, Location + vect(0,0,-20));
    }
}

function bool LegitimateTargetOf(Bot B)
{
	if (DefenderTeamIndex == B.Squad.Team.TeamIndex || CoreStage == 4 || CoreStage == 1 )
		return false;
	return Super.LegitimateTargetOf(B);
}

simulated function PowerCoreDestroyed()
{
    local PlayerController PC;

    AmbientSound = None;
//	log(Name@"PowerCoreDestroyed");
    Health = 0;

    if (Level.NetMode != NM_DedicatedServer)
    {
        PC = Level.GetLocalPlayerController();
        if (PC != None)
            PC.ClientPlaySound(DestroyedSound, False, 2.0);
        else
            PlaySound(DestroyedSound, SLOT_Misc, 5.0);

        ExplosionEffect = spawn(class'ONSPowerCoreBreachEffect', self);
        Skins.length = 0;
    }

    if (Role == ROLE_Authority)
    {
        NetUpdateTime = Level.TimeSeconds - 1;
        Scorers.length = 0;
        UpdateCloseActors();
        OnCoreDestroyed(DefenderTeamIndex);
        NotifyUpdateLinks();
        DefenderTeamIndex = 2;
        GotoState('DestroyedCore');
    }

	UpdateLinkState(Self);
}

function UpdateCloseActors()
{
    local int i;
    local Actor A;
    local ONSVehicle V;

    for (i = 0; i < CloseActors.Length; i++)
    {
        A = CloseActors[i];
        // Disable any playerstarts in the power radius
        if (A.IsA('PlayerStart'))
            PlayerStart(A).bEnabled = False;

        // Disable any vehicle factories in the power radius
        if (A.IsA('ONSVehicleFactory'))
            ONSVehicleFactory(A).Deactivate();

        // Disable any turrets in the power radius
        if (A.IsA('ONSStationaryWeaponPawn') && !bFinalCore)
        {
            ONSStationaryWeaponPawn(A).bPowered = False;
            ONSStationaryWeaponPawn(A).KDriverLeave(True);
            ONSStationaryWeaponPawn(A).Team = 255;
        }
    }
    foreach DynamicActors(class'ONSVehicle', V)
        if (V.bTeamLocked && V.Health > 0 && ClosestTo(V) == self)
            V.Destroy();
}

// Returns a rating based on nearby vehicles
function float RateCore()
{
    local int i;
	local float Result;

    for (i = 0; i < CloseActors.Length; i++)
    {
        if ( ONSVehicleFactory(CloseActors[i]) != None )
		{
			Result += (ONSVehicleFactory(CloseActors[i]).VehicleClass.Default.MaxDesireability * ONSVehicleFactory(CloseActors[i]).VehicleClass.Default.MaxDesireability);
			if ( ONSVehicleFactory(CloseActors[i]).VehicleClass.Default.MaxDesireability > 0.6 )
				Result += 0.5;
		}
	}
	return Result;
}

simulated function PowerCoreConstructing()
{
//	log(Name@"PowerCoreConstructing");
    AmbientSound = HealingSound;
    if (Level.NetMode != NM_DedicatedServer)
    {
        if (DefenderTeamIndex == 0)
            Skins = RedConstructingSkins;
        else
            Skins = BlueConstructingSkins;

    	// Update shield
       	Shield.SetTeam(DefenderTeamIndex);

        UpdateTeamBanners();
    }
    bHidden = False;

    // Update Links
    NotifyUpdateLinks();
	UpdateLinkState(Self);
}

simulated function PowerCoreActive()
{
    local Actor A;
    local int i;

    bHidden = False;
    AmbientSound = ActiveSound;

	//log(Name@"PowerCoreActive");
    // Update Visuals
    if (Level.NetMode != NM_DedicatedServer)
    {
        if (RoamingEnergy != None)
            RoamingEnergy.Destroy();

        if (ExplosionEffect != None)
            ExplosionEffect.Destroy();

        if (DefenderTeamIndex == 0)
            Skins = RedActiveSkins;
        else
            Skins = BlueActiveSkins;

    	// Update shield
    	if (Shield != None)
	        Shield.SetTeam(DefenderTeamIndex);

        UpdateTeamBanners();

		PlaySound(ConstructedSound, SLOT_Misc, 5.0);
    }

    if (Role == ROLE_Authority)
    {
	    NotifyUpdateLinks();
	    Scorers.length = 0;

        // Update Nearby Powered Actors
        for (i = 0; i < CloseActors.Length; i++)
        {
            A = CloseActors[i];

            // Update any vehicle factories in the power radius to be owned by the controlling team
            if (A.IsA('ONSVehicleFactory'))
                ONSVehicleFactory(A).Activate(DefenderTeamIndex);

            // Update any playerstarts in the power radius to the be owned by the controlling team
            if (A.IsA('PlayerStart'))
            {
                PlayerStart(A).TeamNumber = DefenderTeamIndex;
                PlayerStart(A).bEnabled = True;
            }

            // Enable any turrets in the power radius
            If (A.IsA('ONSStationaryWeaponPawn'))
            {
                ONSStationaryWeaponPawn(A).bPowered = True;
                ONSStationaryWeaponPawn(A).SetTeamNum(DefenderTeamIndex);
                ONSStationaryWeaponPawn(A).PrevTeam = DefenderTeamIndex;
            }
        }
    }

	UpdateLinkState(Self);
}

function Reset()
{
	Health = DamageCapacity;
	PowerCoreReset();
}

simulated function PowerCoreReset()
{
//	log(Name@"PowerCoreReset");
	if (RoamingEnergy != None && bScriptInitialized)
		RoamingEnergy.Destroy();

	if (Role == ROLE_Authority)
	{
		SetStaticMesh(default.StaticMesh);
		UpdateCloseActors();
		NetUpdateTime = Level.TimeSeconds - 1;
		if (!bFinalCore)
            DefenderTeamIndex = default.DefenderTeamIndex;

		if ( bScriptInitialized )
			SetInitialState();
	}

	UpdateLinkState(Self);
}

simulated function UpdateTeamBanners()
{
	local int i;

	for (i = 0; i < CloseActors.length; i++)
        	if (xTeamBanner(CloseActors[i]) != None)
        	{
        		if (CoreStage == 0)
	        		xTeamBanner(CloseActors[i]).Team = DefenderTeamIndex;
	        	else
	        		xTeamBanner(CloseActors[i]).Team = 255;
        		xTeamBanner(CloseActors[i]).UpdateForTeam();
        	}
        for (i = 0; i < TeleportPads.length; i++)
	{
        	if (CoreStage == 0)
        		TeleportPads[i].SetTeam(DefenderTeamIndex);
        	else
        		TeleportPads[i].SetTeam(255);
        }
}

function float TeleportRating(Controller Asker, byte AskerTeam, byte SourceDist)
{
	local int i;
	local ONSVehicleFactory F;
	local Bot B;
	local float Rating;

	B = Bot(Asker);

	for (i = 0; i < CloseActors.length; i++)
	{
		F = ONSVehicleFactory(CloseActors[i]);
		if (F != None && F.LastSpawned != None && F.LastSpawned.bTeamLocked && !F.LastSpawned.SpokenFor(Asker))
		{
			if (B == None)
				Rating = FMax(Rating, F.LastSpawned.MaxDesireability);
			else
				Rating = FMax(Rating, B.Squad.VehicleDesireability(F.LastSpawned, B));
		}
	}

	return (Rating - (FinalCoreDistance[Abs(1 - AskerTeam)] - SourceDist) * 0.1);
}

function bool HasUsefulVehicles(Controller Asker)
{
	local int i;
	local ONSVehicleFactory F;
	local Bot B;

	B = Bot(Asker);

	for (i = 0; i < CloseActors.length; i++)
	{
		F = ONSVehicleFactory(CloseActors[i]);
		if ( F != None && F.LastSpawned != None && F.LastSpawned.bTeamLocked
		     && (B == None || B.Squad.VehicleDesireability(F.LastSpawned, B) > 0) )
			return true;
	}

	return false;
}

simulated function string GetHumanReadableName()
{
	if ( DefenderTeamIndex > 1 )
		return ObjectiveStringPrefix$class'TeamInfo'.Default.ColorNames[Default.DefenderTeamIndex]$ObjectiveStringSuffix;
	else
		return ObjectiveStringPrefix$class'TeamInfo'.Default.ColorNames[DefenderTeamIndex]$ObjectiveStringSuffix;
}

function UsedBy(Pawn User)
{
	if (Vehicle(User) == None && PlayerController(User.Controller) != None && User.GetTeamNum() == DefenderTeamIndex)
	{
		PlayerController(User.Controller).ClientOpenMenu(Level.Game.GameUMenuType,,"TL");
	}
}

// if bot is in important vehicle, and other bots can do the dirty work,
// return false if within get out distance
function bool StandGuard(Bot B)
{
	local bot SquadMate;
	local float Dist;
	local int i;

	if ( (DefenderTeamIndex != B.PlayerReplicationInfo.Team.TeamIndex) && (DefenderTeamIndex < 2) )
	{
		return false;
	}

	if ( (ONSVehicle(B.Pawn) != None) && Vehicle(B.Pawn).ImportantVehicle() )
	{
		Dist = VSize(B.Pawn.Location - Location);
		if ( (Dist < Vehicle(B.Pawn).ObjectiveGetOutDist) && B.LineOfSightTo(self) )
		{
			if ( (ONSVehicle(B.Pawn) != None) && ONSVehicle(B.Pawn).bKeyVehicle && B.Pawn.CanAttack(self) )
			{
				ONSVehicle(B.Pawn).Deploy();
				return true;
			}
			if ( (DefenderTeamIndex == B.PlayerReplicationInfo.Team.TeamIndex) || ((B.Enemy != None) && (Level.TimeSeconds - B.LastSeenTime < 2)) )
				return true;

			// check if there's a passenger
			if ( ONSVehicle(B.Pawn).WeaponPawns.Length > 0 )
			{
				for ( i=0; i<ONSVehicle(B.Pawn).WeaponPawns.Length; i++ )
				{
					SquadMate = Bot(ONSVehicle(B.Pawn).WeaponPawns[i].Controller);
					if ( SquadMate != None )
					{
						ONSVehicle(B.Pawn).WeaponPawns[i].TeamUseTime = Level.TimeSeconds + 8;
						ONSVehicle(B.Pawn).WeaponPawns[i].KDriverLeave(false);
						return true;
					}
				}
			}

			// check if there's another bot around to do it
			for ( SquadMate=B.Squad.SquadMembers; SquadMate!=None; SquadMate=SquadMate.NextSquadMember )
			{
				if ( (SquadMate.Pawn != None) && ((Vehicle(SquadMate.Pawn) == None) || !Vehicle(SquadMate.Pawn).ImportantVehicle())
					&& (VSize(SquadMate.Pawn.Location - Location) < Dist + 2000) && (SquadMate.RouteGoal == self) )
					return true;
			}
		}
	}
	return false;
}

function bool TooClose(Bot B)
{
	local bot SquadMate;
	local int R;

	if ( (VSize(Location - B.Pawn.Location) < 2*B.Pawn.CollisionRadius) && (PathList.Length > 1) )
	{
		//standing right on top of it, move away a little
		B.GoalString = "Move away from "$self;
		R = Rand(PathList.Length-1);
		B.MoveTarget = PathList[R].End;
		for ( SquadMate=B.Squad.SquadMembers; SquadMate!=None; SquadMate=SquadMate.NextSquadMember )
		{
			if ( (SquadMate.Pawn != None) && (VSize(SquadMate.Pawn.Location - B.MoveTarget.Location) < B.CollisionRadius) )
			{
				B.MoveTarget = PathList[R+1].End;
				break;
			}
		}
		B.SetAttractionState();
		return true;
	}
	return false;
}

function bool TellBotHowToDisable(Bot B)
{
	if (CoreStage == 4 || CoreStage == 1)
	{
		if ( StandGuard(B) )
			return TooClose(B);

		return B.Squad.FindPathToObjective(B, self);
	}

	if (DefenderTeamIndex == B.Squad.Team.TeamIndex)
		return false;
	if (!PoweredBy(B.Squad.Team.TeamIndex))
	{
		if (B.CanAttack(self))
			return false;
		else
			return B.Squad.FindPathToObjective(B, self);
	}

	//take out defensive turrets first
	if (B.Enemy != None && B.Enemy.bStationary && B.EnemyVisible() && Vehicle(B.Enemy) != None && Vehicle(B.Enemy).bDefensive)
		return false;

	if ( StandGuard(B) )
		return TooClose(B);

	return Super.TellBotHowToDisable(B);
}

function bool KillEnemyFirst(Bot B)
{
	if ( bFinalCore || !bUnderAttack || Health < DamageCapacity * 0.25
	     || (Vehicle(B.Pawn) != None && Vehicle(B.Pawn).IndependentVehicle() && Vehicle(B.Pawn).HasOccupiedTurret()) )
		return false;

	if (B.Enemy != None && B.Enemy.Controller != None && B.Enemy.CanAttack(B.Pawn) )
	{
		if ( (B.Aggressiveness > 0.4) || (B.Pawn.IsA('ONSHoverBike') && (Vehicle(B.Enemy) == None) && (VSize(B.Enemy.Location - B.Pawn.Location) < 1500)) )
			return true;

		return (B.LastUnderFire > Level.TimeSeconds - 1);
	}

	if (Level.TimeSeconds - HealingTime < 1 && LastHealedBy != None && LastHealedBy.Pawn != None && LastHealedBy.Pawn.Health > 0)
	{
		//attack enemy healing me
		if ( B.Squad.SetEnemy(B,LastHealedBy.Pawn) && (B.Enemy == LastHealedBy.Pawn) )
			return true;
	}

	return false;
}

function bool NearObjective(Pawn P)
{
	if (P.CanAttack(GetShootTarget()))
		return true;

	return (VSize(Location - P.Location) < BaseRadius && P.LineOfSightTo(self));
}

function CheckTouching()
{
    	local Pawn P;

    	foreach BasedActors(class'Pawn', P)
    	{
    		Bump(P);
    		return;
    	}
}

state NeutralCore
{
    function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType)
	{
	}

    function Bump(Actor Other)
    {
        if ( (Pawn(Other) == None) || !Pawn(Other).IsPlayerPawn() || Vehicle(Other) != None )
    		return;

        if (PoweredBy(Pawn(Other).GetTeamNum()))
        {
		    NetUpdateTime = Level.TimeSeconds - 1;
            DefenderTeamIndex = Pawn(Other).GetTeamNum();
            Constructor = Pawn(Other).Controller;
            GotoState('Reconstruction');

            // Update Links
            NotifyUpdateLinks();
        }
        else
            Pawn(Other).ReceiveLocalizedMessage(class'ONSOnslaughtMessage', 6);
    }

    function UsedBy(Pawn User) {}

    event BeginState()
    {
        CheckTouching();
    }

Begin:
	UpdateLinkState(Self);
}

state DestroyedCore
{
Begin:
    sleep(2.0);
    if (bFinalCore)
        SetStaticMesh(DeadStaticMesh);
    else
    {
    	CoreStage = 4;
    	PowerCoreNeutral();
    	GotoState('NeutralCore');
    }

   	UpdateLinkState(Self);
}


event Timer()
{
	if (!bSevered || CoreStage == 4)
	{
		UnSever();
		return;
	}

        TakeDamage(SeveredDamagePerSecond, None, vect(0,0,0), vect(0,0,0), None);
}

state Reconstruction
{
    event Timer()
    {
        if (bSevered)
        {
            Global.Timer();
            return;
        }
    	if (Level.TimeSeconds < LastAttackTime + 1.0)
    		return;

        NetUpdateTime = Level.TimeSeconds - 1;

        ConstructionTimeElapsed += 1.0;
        Health += (1.0 / ConstructionTime) * DamageCapacity;

        if (Health > DamageCapacity)
        {
            SetTimer(0.0, False);
            Health = DamageCapacity;
            CoreStage = 0;
            if (DefenderTeamIndex == 1)
                TriggerEvent(BlueActivationEventName, self, None);
            else
                TriggerEvent(RedActivationEventName, self, None);
            PowerCoreActive();
            if (DefenderTeamIndex == 0)
                BroadcastLocalizedMessage( class'ONSOnslaughtMessage', 2);
            else
                BroadcastLocalizedMessage( class'ONSOnslaughtMessage', 3);
            if (Constructor != None && Constructor.PlayerReplicationInfo != None)
            {
	            Constructor.AwardAdrenaline(Score);
		    Level.Game.ScoreObjective(Constructor.PlayerReplicationInfo, float(Score) / 2.0);
        	    Level.Game.ScoreEvent(Constructor.PlayerReplicationInfo, float(Score) / 2.0, ConstructedEvent[DefenderTeamIndex]);
            }
            UnrealMPGameInfo(Level.Game).FindNewObjectives(self);
            GotoState('');
        }
    }

    function BeginState()
    {
    	Scorers.length = 0;
	PlaySound(StartConstructionSound, SLOT_Misc, 5.0);
	CoreStage = 5;
	PowerCoreReconstitution();
    }

    function Bump(Actor Other) {}
    function UsedBy(Pawn User) {}
    function UnSever() {}

Begin:
    sleep(2.0);
    CoreStage = 2;
    PowerCoreConstructing();
    ConstructionTimeElapsed = 0.0;
    SetTimer(1.0, True);
}

state DisabledCore
{
	event BeginState()
	{
		NetUpdateTime = Level.TimeSeconds - 1;
		SetCollision(false, false);
		bDisabled = true;
		SetTimer(0, false);
		NetUpdateFrequency = 0.1;
	}

	event EndState()
	{
		NetUpdateTime = Level.TimeSeconds - 1;
		SetCollision(default.bCollideActors, default.bBlockActors);
		bDisabled = false;
		NetUpdateFrequency = default.NetUpdateFrequency;
		UnrealMPGameInfo(Level.Game).FindNewObjectives(self);
	}

Begin:
   	UpdateLinkState(Self);
}

simulated function bool HasHealthBar()
{
	return CoreStage == 0 || CoreStage == 2 || CoreStage == 5;
}

simulated singular function UpdateHUDLocation( float ScreenX, float ScreenY, float RadarWidth, float Range, vector Center )
{
	local vector ScreenLocation;
	local float Dist;

    ScreenLocation = Location - Center;
    ScreenLocation.Z = 0;
	Dist = VSize(ScreenLocation);

    HUDLocation.X = ScreenX + ScreenLocation.X * (RadarWidth/Range);
    HUDLocation.Y = ScreenY + ScreenLocation.Y * (RadarWidth/Range);

    if ( NextCore != None )
    	NextCore.UpdateHUDLocation(ScreenX, ScreenY, RadarWidth, Range, Center);
}

function SetTeam(byte TeamIndex)
{
	Super.SetTeam(TeamIndex);

	if (CoreStage == 0)
		PowerCoreActive();
}

defaultproperties
{
     ConstructionTime=30.000000
     DeadStaticMesh=StaticMesh'VMStructures.CoreGroup.coreDead'
     DestroyedSound=Sound'ONSVehicleSounds-S.PowerCore.PowerCoreExplosion01'
     ConstructedSound=Sound'ONSVehicleSounds-S.PowerNode.whooshthunk'
     StartConstructionSound=Sound'ONSVehicleSounds-S.PowerNode.PwrNodeBuild02'
     ActiveSound=Sound'ONSVehicleSounds-S.PowerNode.PwrNodeActive01'
     NeutralSound=Sound'ONSVehicleSounds-S.PowerNode.PwrNodeNOTActive01'
     HealingSound=Sound'ONSVehicleSounds-S.PowerNode.PwrNodeStartBuild03'
     HealedSound=Sound'ONSVehicleSounds-S.PowerNode.PwrNodeBuilt01'
     bPowered=True
     bFinalCore=True
     bShowNodeBeams=True
     RedConstructingSkins(0)=FinalBlend'ONSstructureTextures.CoreConstructionRed'
     RedConstructingSkins(1)=FinalBlend'ONSstructureTextures.CoreGroup.InvisibleFinal'
     BlueConstructingSkins(0)=FinalBlend'ONSstructureTextures.CoreConstructionBlue'
     BlueConstructingSkins(1)=FinalBlend'ONSstructureTextures.CoreGroup.InvisibleFinal'
     RedActiveSkins(0)=Texture'ONSstructureTextures.CoreGroup.CoreDiffTEX'
     RedActiveSkins(1)=Shader'ONSstructureTextures.CoreGroup.CoreLightShader'
     BlueActiveSkins(0)=Texture'ONSstructureTextures.CoreGroup.CoreDiffTEX'
     BlueActiveSkins(1)=Shader'ONSstructureTextures.CoreGroup.CoreLightShader'
     LastCoreStage=250
     FinalCoreDistance(0)=255
     FinalCoreDistance(1)=255
     LastAttackExpirationTime=5.000000
     SeveredDamagePerSecond=30.000000
     DestructionMessageIndex=14
     DestroyedEvent(0)="red_powercore_destroyed"
     DestroyedEvent(1)="blue_powercore_destroyed"
     DestroyedEvent(2)="red_constructing_powercore_destroyed"
     DestroyedEvent(3)="blue_constructing_powercore_destroyed"
     ConstructedEvent(0)="red_powercore_constructed"
     ConstructedEvent(1)="blue_powercore_constructed"
     ShieldClass=Class'Onslaught.ONSPowerCoreShield'
     LastDefenderTeamIndex=2
     DamageCapacity=4500
     bMonitorUnderAttack=False
     bPlayCriticalAssaultAlarm=False
     DefensePriority=10
     Score=10
     DestructionMessage=
     ObjectiveStringSuffix=" PowerCore"
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'VMStructures.CoreGroup.CoreDivided'
     bHidden=False
     bIgnoreEncroachers=True
     bNotifyLocalPlayerTeamReceived=True
     SoundVolume=128
     SoundRadius=255.000000
     CollisionRadius=120.000000
     CollisionHeight=150.000000
     bCollideWorld=True
     bBlockActors=True
     bBlockKarma=True
     bBlocksTeleport=True
     bNetNotify=True
     bPathColliding=True
}
