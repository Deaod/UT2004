//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSPowerNode extends ONSPowerCore
    abstract;

var ONSPowerNodeEnergySphere    EnergySphere;
var localized string NeutralString, ConstructingString;

simulated event PostBeginPlay()
{
    Super.PostBeginPlay();

    EnergySphere = spawn(class'ONSPowerNodeEnergySphere', self,, Location + vect(0,0,370));

    Skins = default.Skins;
}

function SpawnNodeTeleportTrigger()
{
	//no trigger necessary, players can stand on top of powernodes to use them
}

simulated function string GetHumanReadableName()
{
	if (CoreStage == 0)
		return ObjectiveStringPrefix$class'TeamInfo'.Default.ColorNames[DefenderTeamIndex]$ObjectiveStringSuffix$" "$NodeNum;
	else if (CoreStage == 2)
		return ObjectiveStringPrefix$class'TeamInfo'.Default.ColorNames[DefenderTeamIndex]$ConstructingString$" "$NodeNum;
	else
		return NeutralString$" "$NodeNum;
}

simulated function PowerCoreNeutral()
{
    Super.PowerCoreNeutral();

    Skins = default.Skins;

    bHidden = False;
    if (EnergySphere != None)
    {
        EnergySphere.bHidden = True;
        EnergySphere.SetCollision(false, false);
    }
}

simulated function PowerCoreConstructing()
{
    Super.PowerCoreConstructing();

    if (Level.NetMode != NM_DedicatedServer)
    {
        if (DefenderTeamIndex == 0)
            EnergySphere.Skins = EnergySphere.RedConstructingSkins;
        else
            EnergySphere.Skins = EnergySphere.BlueConstructingSkins;
    }

    EnergySphere.bHidden = False;
    EnergySphere.SetCollision(True, True);

    if (Role == ROLE_Authority)
    {
    	if (DefenderTeamIndex == 0)
	    	BroadcastLocalizedMessage(class'ONSOnslaughtMessage', 23);
	else if (DefenderTeamIndex == 1)
		BroadcastLocalizedMessage(class'ONSOnslaughtMessage', 24);
    }
}

simulated function PowerCoreActive()
{
    Super.PowerCoreActive();

    if (EnergySphere != None)
    {
	    EnergySphere.bHidden = False;
	    EnergySphere.SetCollision(True, True);

	    if (Level.NetMode != NM_DedicatedServer)
	    {
        	if (DefenderTeamIndex == 0)
	            EnergySphere.Skins = EnergySphere.RedActiveSkins;
        	else
	            EnergySphere.Skins = EnergySphere.BlueActiveSkins;
	    }
    }
}

simulated function PowerCoreDestroyed()
{
    Health = 0;

    EnergySphere.bHidden = True;
    EnergySphere.SetCollision(False, False);

    if (Level.NetMode != NM_DedicatedServer)
    {
        PlaySound(DestroyedSound, SLOT_Misc, 5.0);
        spawn(class'ONSSmallVehicleExplosionEffect',self,, Location + vect(0,0,200));
    }

    if (Role == ROLE_Authority)
    {
	NetUpdateTime = Level.TimeSeconds - 1;
        Scorers.length = 0;
        UpdateCloseActors();
        NotifyUpdateLinks();
        DefenderTeamIndex = 2;
        GotoState('DestroyedCore');
    }

    UpdateLinkState(Self);
}

simulated function PowerCoreDisabled()
{
	Super.PowerCoreDisabled();

	if (EnergySphere != None)
	{
		EnergySphere.bHidden = true;
		EnergySphere.SetCollision(false, false);
	}
}

function bool TellBotHowToHeal(Bot B)
{
	local vector AdjustedLoc;

	// if bot is in important vehicle, don't get out
	if ( (Vehicle(B.Pawn) != None) && Vehicle(B.Pawn).ImportantVehicle() )
		return TooClose(B);

	AdjustedLoc = EnergySphere.Location;
	AdjustedLoc.Z = B.Pawn.Location.Z;
	if ( VSize(AdjustedLoc - B.Pawn.Location) < 50 )
	{
		//standing right on top of it, move away a little
		B.GoalString = "Move away from "$self;
		B.RouteGoal = B.FindRandomDest();
		B.MoveTarget = B.RouteCache[0];
		B.SetAttractionState();
		return true;
	}
	else if ( VSize(EnergySphere.Location - B.Pawn.Location) > 1050 )
	{
		//too far to heal
		B.GoalString = "Move closer to "$self;
		if ( B.FindBestPathToward(B.RouteGoal, false, true) )
		{
			B.SetAttractionState();
			return true;
		}
		else
			return false;
	}

	return Super.TellBotHowToHeal(B);
}

defaultproperties
{
     NeutralString="Neutral PowerNode"
     ConstructingString=" Constructing PowerNode"
     ActiveSound=Sound'ONSVehicleSounds-S.PowerNode.PwrNodeActive02'
     bFinalCore=False
     RedConstructingSkins(0)=Texture'ONSstructureTextures.CoreGroup.PowerNodeTEX'
     RedConstructingSkins(1)=FinalBlend'ONSstructureTextures.CoreGroup.powerNodeUpperFLAREredFinal'
     BlueConstructingSkins(0)=Texture'ONSstructureTextures.CoreGroup.PowerNodeTEX'
     BlueConstructingSkins(1)=FinalBlend'ONSstructureTextures.CoreGroup.powerNodeUpperFLAREblueFinal'
     RedActiveSkins(0)=Texture'ONSstructureTextures.CoreGroup.PowerNodeTEX'
     RedActiveSkins(1)=FinalBlend'ONSstructureTextures.CoreGroup.powerNodeUpperFLAREredFinal'
     BlueActiveSkins(0)=Texture'ONSstructureTextures.CoreGroup.PowerNodeTEX'
     BlueActiveSkins(1)=FinalBlend'ONSstructureTextures.CoreGroup.powerNodeUpperFLAREblueFinal'
     CoreStage=4
     DestructionMessageIndex=16
     DestroyedEvent(0)="red_powernode_destroyed"
     DestroyedEvent(1)="blue_powernode_destroyed"
     DestroyedEvent(2)="red_constructing_powernode_destroyed"
     DestroyedEvent(3)="blue_constructing_powernode_destroyed"
     ConstructedEvent(0)="red_powernode_constructed"
     ConstructedEvent(1)="blue_powernode_constructed"
     ShieldClass=Class'Onslaught.ONSPowerNodeShield'
     ShieldOffset=(Z=220.000000)
     DamageCapacity=2000
     LinkHealMult=1.000000
     AIShootOffset=(Z=370.000000)
     DefensePriority=1
     Score=5
     ObjectiveStringSuffix=" PowerNode"
     bDestinationOnly=False
     StaticMesh=StaticMesh'VMStructures.CoreGroup.powerNodeBaseSM'
     DrawScale=2.000000
     PrePivot=(Z=25.000000)
     CollisionRadius=160.000000
     CollisionHeight=30.000000
     bPathColliding=False
}
