//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSOnslaughtMessage extends CriticalEventPlus;

var(Message) localized string RedTeamDominatesString;
var(Message) localized string BlueTeamDominatesString;
var(Message) localized string RedTeamPowerCoreString;
var(Message) localized string BlueTeamPowerCoreString;
var(Message) localized string VehicleLockedString;
var(Message) localized string InvincibleCoreString;
var(Message) localized string UnattainableNodeString;
var(Message) localized string RedPowerCoreAttackedString;
var(Message) localized string BluePowerCoreAttackedString;
var(Message) localized string RedPowerNodeAttackedString;
var(Message) localized string BluePowerNodeAttackedString;
var(Message) localized string InWayOfVehicleSpawnString;
var(Message) localized string MissileLockOnString;
var(Message) localized string UnpoweredString;
var(Message) localized string RedPowerCoreDestroyedString;
var(Message) localized string BluePowerCoreDestroyedString;
var(Message) localized string RedPowerNodeDestroyedString;
var(Message) localized string BluePowerNodeDestroyedString;
var(Message) localized string RedPowerCoreCriticalString;
var(Message) localized string BluePowerCoreCriticalString;
var(Message) localized string PressUseToTeleportString;
var(Message) localized string RedPowerCoreVulnerableString;
var(Message) localized string BluePowerCoreVulnerableString;
var(Message) localized string RedPowerNodeUnderConstructionString;
var(Message) localized string BluePowerNodeUnderConstructionString;
var(Message) localized string RedPowerCoreDamagedString;
var(Message) localized string BluePowerCoreDamagedString;
var(Message) localized string RedPowerNodeSeveredString;
var(Message) localized string BluePowerNodeSeveredString;
var(Message) localized string PowerCoresAreDrainingString;
var(Message) localized string UnhealablePowerCoreString;
var(Message) localized string AvrilLockOnString;
var(Message) localized string CameraDeploy;
var(Message) localized string MoveReticle;
var(Message) localized string SPMAAcquiredString;

var name MessageAnnouncements[35];
var Sound VictorySound;

var color RedColor;
var color YellowColor;

static simulated function ClientReceive(
	PlayerController P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	//yet another tutorial hack
	if (P.bViewingMatineeCinematic)
		return;

	Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);

	//only play "under attack" announcer messages every 10 seconds
	if (ONSPowerCore(OptionalObject) != None)
	{
		if (P.Level.TimeSeconds < ONSPowerCore(OptionalObject).LastAttackAnnouncementTime + 10)
			return;
		else
			ONSPowerCore(OptionalObject).LastAttackAnnouncementTime = P.Level.TimeSeconds;
	}

	if ( default.MessageAnnouncements[Switch] != '' )
		P.PlayStatusAnnouncement(default.MessageAnnouncements[Switch], 2, true);

	if (P.PlayerReplicationInfo != None && P.PlayerReplicationInfo.Team != None && P.PlayerReplicationInfo.Team.TeamIndex == Switch)
		P.ClientPlaySound(default.VictorySound);
}

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	switch (Switch)
	{
		case 0:
			return Default.RedTeamDominatesString;
			break;

		case 1:
			return Default.BlueTeamDominatesString;
			break;

		case 2:
			return Default.RedTeamPowerCoreString;
			break;

		case 3:
			return Default.BlueTeamPowerCoreString;
			break;

		case 4:
            return Default.VehicleLockedString;
            break;

		case 5:
            return Default.InvincibleCoreString;
            break;

		case 6:
            return Default.UnattainableNodeString;
            break;

		case 7:
            return Default.RedPowerCoreAttackedString;
            break;

		case 8:
            return Default.BluePowerCoreAttackedString;
            break;

		case 9:
            return Default.RedPowerNodeAttackedString;
            break;

		case 10:
            return Default.BluePowerNodeAttackedString;
            break;

	case 11:
            return Default.InWayOfVehicleSpawnString;
            break;

        case 12:
            return Default.MissileLockOnString;
            break;

        case 13:
            return Default.UnpoweredString;
            break;

        case 14:
            return Default.RedPowerCoreDestroyedString;
            break;

        case 15:
            return Default.BluePowerCoreDestroyedString;
            break;

        case 16:
            return Default.RedPowerNodeDestroyedString;
            break;

        case 17:
            return Default.BluePowerNodeDestroyedString;
            break;
        case 18:
            return Default.RedPowerCoreCriticalString;
            break;
        case 19:
            return Default.BluePowerCoreCriticalString;
            break;
        case 20:
            return Default.RedPowerCoreVulnerableString;
            break;
        case 21:
            return Default.BluePowerCoreVulnerableString;
            break;
        case 22:
            return Default.PressUseToTeleportString;
            break;
        case 23:
            return Default.RedPowerNodeUnderConstructionString;
            break;
        case 24:
            return Default.BluePowerNodeUnderConstructionString;
            break;
        case 25:
            return Default.RedPowerCoreDamagedString;
            break;
        case 26:
            return Default.BluePowerCoreDamagedString;
            break;
        case 27:
            return Default.RedPowerNodeSeveredString;
            break;
        case 28:
            return Default.BluePowerNodeSeveredString;
            break;
        case 29:
            return Default.PowerCoresAreDrainingString;
            break;
        case 30:
            return Default.UnhealablePowerCoreString;
            break;
        case 31:
        	return default.AvrilLockOnString;
        	break;
        case 32:
        	return default.SPMAAcquiredString;
        	break;
        case 33:
        	return default.MoveReticle;
            break;
	    case 34:
        	return default.CameraDeploy;
        	break;
	}
	return "";
}

static function color GetColor(
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1,
    optional PlayerReplicationInfo RelatedPRI_2
    )
{
	if ((Switch > 6 && Switch < 11) || Switch == 12 || (Switch > 17 && Switch < 22) || Switch > 24)
		return Default.RedColor;
	else if (Switch == 11)
		return Default.YellowColor;
	else
		return Default.DrawColor;
}

static function GetPos(int Switch, out EDrawPivot OutDrawPivot, out EStackMode OutStackMode, out float OutPosX, out float OutPosY)
{
	Super.GetPos(Switch, OutDrawPivot, OutStackMode, OutPosX, OutPosY);
	if (Switch == 12 || switch == 31 || switch == 32)
		OutPosY = 0.75;
	else if (Switch == 29)
		OutPosY = 0.90;
	else if (Switch == 30)
		OutPosY = 0.30;
}

static function float GetLifeTime(int Switch)
{
	if (Switch == 29)
		return 4.0;

	return default.LifeTime;
}

static function bool IsConsoleMessage(int Switch)
{
 	if (Switch < 5 || (Switch > 12 && Switch < 18) || (Switch > 19 && Switch < 24 && Switch != 22) || Switch > 25)
 		return true;

 	return false;
}

defaultproperties
{
     RedTeamDominatesString="Red Team Achieves Victory!"
     BlueTeamDominatesString="Blue Team Achieves Victory!"
     RedTeamPowerCoreString="Red Team PowerNode Constructed!"
     BlueTeamPowerCoreString="Blue Team PowerNode Constructed!"
     VehicleLockedString="Vehicle is Locked!"
     InvincibleCoreString="You Are Unable To Damage Unlinked PowerNodes!"
     UnattainableNodeString="You Are Unable To Obtain Unlinked PowerNodes!"
     RedPowerCoreAttackedString="Red Team PowerCore is under Attack!"
     BluePowerCoreAttackedString="Blue Team PowerCore is under Attack!"
     RedPowerNodeAttackedString="Red Team PowerNode is under Attack!"
     BluePowerNodeAttackedString="Blue Team PowerNode is under Attack!"
     InWayOfVehicleSpawnString="You are in the way of a vehicle spawning!"
     MissileLockOnString="Missile Lock-On!"
     UnpoweredString="Turret is Unpowered!"
     RedPowerCoreDestroyedString="Red PowerCore Destroyed"
     BluePowerCoreDestroyedString="Blue PowerCore Destroyed"
     RedPowerNodeDestroyedString="Red PowerNode Destroyed"
     BluePowerNodeDestroyedString="Blue PowerNode Destroyed"
     RedPowerCoreCriticalString="Red PowerCore is Critical!"
     BluePowerCoreCriticalString="Blue PowerCore is Critical!"
     PressUseToTeleportString="Press Use to teleport to another node"
     RedPowerCoreVulnerableString="Red PowerCore is Vulnerable!"
     BluePowerCoreVulnerableString="Blue PowerCore is Vulnerable!"
     RedPowerNodeUnderConstructionString="Red PowerNode under Construction!"
     BluePowerNodeUnderConstructionString="Blue PowerNode under Construction!"
     RedPowerCoreDamagedString="Red PowerCore is at 50%!"
     BluePowerCoreDamagedString="Blue PowerCore is at 50%!"
     RedPowerNodeSeveredString="Red PowerNode Isolated!"
     BluePowerNodeSeveredString="Blue PowerNode Isolated!"
     PowerCoresAreDrainingString="PowerCores are draining!"
     UnhealablePowerCoreString="You can't heal your PowerCore!"
     AvrilLockOnString="Incoming Heat-Seeking Missile!"
     CameraDeploy="Press Alt-Fire to deploy camera!"
     MoveReticle="Use Forward and Strafe to Aim Reticle"
     SPMAAcquiredString="SPMA Acquired"
     MessageAnnouncements(7)="Red_Powercore_under_attack"
     MessageAnnouncements(8)="Blue_Powercore_under_attack"
     MessageAnnouncements(14)="Red_Powercore_destroyed"
     MessageAnnouncements(15)="Blue_Powercore_destroyed"
     MessageAnnouncements(16)="Red_powernode_destroyed"
     MessageAnnouncements(17)="Blue_powernode_destroyed"
     MessageAnnouncements(18)="Red_Powercore_critical"
     MessageAnnouncements(19)="Blue_Powercore_critical"
     MessageAnnouncements(20)="Red_PowerCore_vulnerable"
     MessageAnnouncements(21)="Blue_Powercore_vulnerable"
     MessageAnnouncements(23)="Red_powernode_under_construction"
     MessageAnnouncements(24)="Blue_powernode_under_construction"
     MessageAnnouncements(25)="Red_Powercore_damaged"
     MessageAnnouncements(26)="Blue_Powercore_damaged"
     MessageAnnouncements(27)="Red_powernode_isolated"
     MessageAnnouncements(28)="Blue_powernode_isolated"
     VictorySound=Sound'GameSounds.Fanfares.UT2K3Fanfare04'
     RedColor=(R=255,A=255)
     YellowColor=(G=255,R=255,A=255)
     bIsUnique=False
     bIsPartiallyUnique=True
     Lifetime=2
     StackMode=SM_Down
     PosY=0.100000
}
