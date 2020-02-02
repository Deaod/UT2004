class ONSDaredevilMessage extends LocalMessage;

#exec OBJ LOAD FILE="..\Sounds\announcermale2k4.uax"
#exec OBJ LOAD FILE="..\Sounds\ONSVehicleSounds-S.uax"

var		localized String	StuntInfoString1;
var		localized String	StuntInfoString2;
var		localized String	StuntInfoString3;
var		localized String	StuntInfoString4;
var		localized String	StuntInfoString5;
var		localized String	StuntInfoString6;
var		localized String	StuntInfoString7;
var		localized String	StuntInfoString8;
var		localized String	StuntDegrees;

var		sound				CheerSound;
var		int					CheerPointThresh;

static function string GetString(
								 optional int SwitchNum,
								 optional PlayerReplicationInfo RelatedPRI_1,
								 optional PlayerReplicationInfo RelatedPRI_2,
								 optional Object OptionalObject
								 )
{
	local ONSWheeledCraft Car;
	local string ResultString;

	Car = ONSWheeledCraft(OptionalObject);

	if(SwitchNum == 0)
		return Default.StuntInfoString1$Car.DaredevilPoints$Default.StuntInfoString2$Car.InAirDistance$Default.StuntInfoString3;
	else if(SwitchNum == 1)
	{
		if ( Car.InAirSpin >= Car.DaredevilThreshInAirSpin )
			ResultString = Default.StuntInfoString4$Car.InAirSpin$Default.StuntDegrees;
		if ( Car.InAirPitch >= Car.DaredevilThreshInAirPitch )
		{
			if ( ResultString != "" )
				ResultString = ResultString$Default.StuntInfoString7;
			ResultString = ResultString$Default.StuntInfoString5$Car.InAirPitch$Default.StuntDegrees;
		}
		if ( Car.InAirRoll >= Car.DaredevilThreshInAirRoll )
		{
			if ( ResultString != "" )
				ResultString = ResultString$Default.StuntInfoString7;
			ResultString = ResultString$Default.StuntInfoString6$Car.InAirRoll$Default.StuntDegrees;
		}
		if ( Car.InAirTime >= Car.DaredevilThreshInAirTime )
		{
			if ( ResultString != "" )
				ResultString = ResultString$Default.StuntInfoString7;
			ResultString = ResultString$Car.InAirTime$Default.StuntInfoString8;
		}
		return ResultString;
	}
}

static simulated function ClientReceive(
										PlayerController P,
										optional int SwitchNum,
										optional PlayerReplicationInfo RelatedPRI_1,
										optional PlayerReplicationInfo RelatedPRI_2,
										optional Object OptionalObject
										)
{
	local ONSWheeledCraft Car;

	Super.ClientReceive(P, SwitchNum, RelatedPRI_1, RelatedPRI_2, OptionalObject);

	if(SwitchNum == 0)
	{
		P.PlayRewardAnnouncement('DareDevil', 1, true);

		// If we got enough points - add a cheer as well!
		Car = ONSWheeledCraft(OptionalObject);

		if(Car.DaredevilPoints >= Default.CheerPointThresh)
			P.ClientPlaySound(Default.CheerSound);
	}
}

defaultproperties
{
     StuntInfoString1="Daredevil!  Level "
     StuntInfoString2=", "
     StuntInfoString3="m"
     StuntInfoString4="Spin: "
     StuntInfoString5="Flip: "
     StuntInfoString6="Roll: "
     StuntInfoString7=", "
     StuntInfoString8=" secs"
     StuntDegrees="°"
     CheerSound=Sound'ONSVehicleSounds-S.Misc.crowd_cheer'
     CheerPointThresh=20
     bFadeMessage=True
     Lifetime=9
     DrawColor=(B=128,G=0)
     StackMode=SM_Down
     PosY=0.700000
}
