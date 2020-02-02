//=============================================================================
// FM_LinkTurret_AltFire
//=============================================================================
// Created by Laurent Delayen
// © 2003, Epic Games, Inc.  All Rights Reserved
//=============================================================================

class FX_LinkTurretShield_Red extends FX_LinkTurretShield;

simulated function UpdateShieldColor()
{
	ColorModifier(Skins[0]).Color.R = int(Flash);
	ColorModifier(Skins[0]).Color.G = 255 - int(Flash);
	ColorModifier(Skins[0]).Color.B = 0;
}

defaultproperties
{
}
