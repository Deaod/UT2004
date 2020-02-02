class HUDInvasion extends HudCTeamDeathMatch
	config(user);

var float RadarPulse,RadarScale;
var config float RadarPosX, RadarPosY;
var float LastDrawRadar;
var float MinEnemyDist;

var config bool bNoRadarSound;

#EXEC OBJ LOAD FILE=InterfaceContent.utx
#EXEC OBJ LOAD FILE=AS_FX_TX.utx

simulated function UpdatePrecacheMaterials()
{
	Level.AddPrecacheMaterial(Material'InterfaceContent.HUD.SkinA');
	Level.AddPrecacheMaterial(Material'AS_FX_TX.AssaultRadar');
	Super.UpdatePrecacheMaterials();
}

simulated function ShowTeamScorePassA(Canvas C)
{
	local float RadarWidth, PulseWidth, PulseBrightness;

	RadarScale = Default.RadarScale * HUDScale;
	RadarWidth = 0.5 * RadarScale * C.ClipX;
	PulseWidth = RadarScale * C.ClipX;
	C.DrawColor = RedColor;
	C.Style = ERenderStyle.STY_Translucent;

	PulseBrightness = FMax(0,(1 - 2*RadarPulse) * 255.0);
	C.DrawColor.R = PulseBrightness;
	C.SetPos(RadarPosX*C.ClipX - 0.5*PulseWidth,RadarPosY*C.ClipY+RadarWidth-0.5*PulseWidth);
	C.DrawTile( Material'InterfaceContent.SkinA', PulseWidth, PulseWidth, 0, 880, 142, 142);

	PulseWidth = RadarPulse * RadarScale * C.ClipX;
	C.DrawColor = RedColor;
	C.SetPos(RadarPosX*C.ClipX - 0.5*PulseWidth,RadarPosY*C.ClipY+RadarWidth-0.5*PulseWidth);
	C.DrawTile( Material'InterfaceContent.SkinA', PulseWidth, PulseWidth, 0, 880, 142, 142);

	C.Style = ERenderStyle.STY_Alpha;
	C.DrawColor = GetTeamColor( PawnOwner.GetTeamNum() );
	C.SetPos(RadarPosX*C.ClipX - RadarWidth,RadarPosY*C.ClipY+RadarWidth);
	C.DrawTile( Material'AS_FX_TX.AssaultRadar', RadarWidth, RadarWidth, 0, 512, 512, -512);
	C.SetPos(RadarPosX*C.ClipX,RadarPosY*C.ClipY+RadarWidth);
	C.DrawTile( Material'AS_FX_TX.AssaultRadar', RadarWidth, RadarWidth, 512, 512, -512, -512);
	C.SetPos(RadarPosX*C.ClipX - RadarWidth,RadarPosY*C.ClipY);
	C.DrawTile( Material'AS_FX_TX.AssaultRadar', RadarWidth, RadarWidth, 0, 0, 512, 512);
	C.SetPos(RadarPosX*C.ClipX,RadarPosY*C.ClipY);
	C.DrawTile( Material'AS_FX_TX.AssaultRadar', RadarWidth, RadarWidth, 512, 0, -512, 512);
}

simulated function ShowTeamScorePassC(Canvas C)
{
	local Pawn P;
	local float Dist, MaxDist, RadarWidth, PulseBrightness,Angle,DotSize,OffsetY,OffsetScale;
	local rotator Dir;
	local vector Start;
	
	LastDrawRadar = Level.TimeSeconds;
	RadarWidth = 0.5 * RadarScale * C.ClipX;
	DotSize = 24*C.ClipX*HUDScale/1600;
	if ( PawnOwner == None )
		Start = PlayerOwner.Location;
	else
		Start = PawnOwner.Location;
	
	MaxDist = 3000 * RadarPulse;
	C.Style = ERenderStyle.STY_Translucent;
	OffsetY = RadarPosY + RadarWidth/C.ClipY;
	MinEnemyDist = 3000;
	ForEach DynamicActors(class'Pawn',P)
		if ( P.Health > 0 )
		{
			Dist = VSize(Start - P.Location);
			if ( Dist < 3000 )
			{
				if ( Dist < MaxDist )
					PulseBrightness = 255 - 255*Abs(Dist*0.00033 - RadarPulse);
				else
					PulseBrightness = 255 - 255*Abs(Dist*0.00033 - RadarPulse - 1);
				if ( Monster(P) != None )
				{
					MinEnemyDist = FMin(MinEnemyDist, Dist);
					C.DrawColor.R = PulseBrightness;
					C.DrawColor.G = PulseBrightness;
					C.DrawColor.B = 0;
				}
				else
				{
					C.DrawColor.R = 0;
					C.DrawColor.G = 0;
					C.DrawColor.B = PulseBrightness;
				}
				Dir = rotator(P.Location - Start);
				OffsetScale = RadarScale*Dist*0.000167;
				if ( PawnOwner == None )
					Angle = ((Dir.Yaw - PlayerOwner.Rotation.Yaw) & 65535) * 6.2832/65536;
				else
					Angle = ((Dir.Yaw - PawnOwner.Rotation.Yaw) & 65535) * 6.2832/65536;
				C.SetPos(RadarPosX * C.ClipX + OffsetScale * C.ClipX * sin(Angle) - 0.5*DotSize,
						OffsetY * C.ClipY - OffsetScale * C.ClipX * cos(Angle) - 0.5*DotSize);
				C.DrawTile(Material'InterfaceContent.Hud.SkinA',DotSize,DotSize,838,238,144,144);
			}
		}			
}

simulated function Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);
	RadarPulse = RadarPulse + 0.5 * DeltaTime;
	if ( RadarPulse >= 1 )
	{
		if ( !bNoRadarSound && (Level.TimeSeconds - LastDrawRadar < 0.2) )
			PlayerOwner.ClientPlaySound(Sound'RadarPulseSound',true,FMin(1.0,300/MinEnemyDist));
		RadarPulse = RadarPulse - 1;
	}
}

defaultproperties
{
     RadarScale=0.200000
     RadarPosX=0.900000
     RadarPosY=0.250000
     YouveLostTheMatch="The Invasion Continues"
}
