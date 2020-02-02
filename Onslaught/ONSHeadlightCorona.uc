class ONSHeadlightCorona extends Light
	native;

simulated function ChangeTeamTint(byte T)
{
	if(T == 0)
	{
		LightHue = 255;
		LightSaturation=240;
	}
	else
	{
		LightHue = 128;
		LightSaturation=175;
	}
}

defaultproperties
{
     CoronaRotation=10.000000
     LightType=LT_None
     LightHue=255
     LightSaturation=175
     LightBrightness=0.000000
     LightRadius=100.000000
     LightPeriod=0
     LightCone=0
     DrawType=DT_None
     bCorona=True
     bDirectionalCorona=True
     bStatic=False
     bHidden=False
     bNoDelete=False
     bDetailAttachment=True
     bNetInitialRotation=True
     RemoteRole=ROLE_None
     DrawScale=0.400000
     bUnlit=True
     bMovable=True
     bHardAttach=True
}
