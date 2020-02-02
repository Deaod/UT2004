class ONSBrakelightCorona extends ONSHeadlightCorona;

simulated function UpdateBrakelightState(float Brake, int Gear)
{
	if(Brake > 0.01f)
	{
		bCorona = true;
		LightHue = 255;
		LightSaturation = 48;
	}
	else if(Gear == 0)
	{
		bCorona = true;
		LightHue = 255;
		LightSaturation = 255;
	}
	else
	{
		bCorona = false;
	}
}

defaultproperties
{
     MaxCoronaSize=50.000000
     LightRadius=64.000000
     DrawScale=0.300000
}
