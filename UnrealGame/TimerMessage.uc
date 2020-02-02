class TimerMessage extends CriticalEventPlus;

var() Sound CountDownSounds[10]; // OBSOLETE
var name CountDown[10];
var() localized string CountDownTrailer;

static function string GetString(
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1,
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject
    )
{
    return Switch$default.CountDownTrailer;
}

static function ClientReceive(
    PlayerController P,
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1,
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject
    )
{
    super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);

    if ( (Switch > 0) && (Switch < 11) && (P.GameReplicationInfo != None) && (P.GameReplicationInfo.Winner == None)
		&& ((P.GameReplicationInfo.RemainingTime > 10) || (P.GameReplicationInfo.RemainingTime == 0)) )
	{
		P.QueueAnnouncement( default.CountDown[Switch-1], 1, AP_InstantOrQueueSwitch, 1 );
	}
}

defaultproperties
{
     CountDown(0)="one"
     CountDown(1)="two"
     CountDown(2)="three"
     CountDown(3)="four"
     CountDown(4)="five"
     CountDown(5)="six"
     CountDown(6)="seven"
     CountDown(7)="eight"
     CountDown(8)="nine"
     CountDown(9)="ten"
     CountDownTrailer="..."
     bIsConsoleMessage=False
     Lifetime=1
     DrawColor=(B=0,G=255,R=255)
     StackMode=SM_Down
     PosY=0.100000
     FontSize=0
}
