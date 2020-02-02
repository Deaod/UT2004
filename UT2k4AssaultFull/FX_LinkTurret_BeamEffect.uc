//=============================================================================
// FX_LinkTurret_BeamEffect
//=============================================================================
// Created by Laurent Delayen
// © 2003, Epic Games, Inc.  All Rights Reserved
//=============================================================================

class FX_LinkTurret_BeamEffect extends LinkBeamEffect
	notplaceable;


simulated function SetBeamLocation()
{
	if ( Instigator == None || ASVehicle(Instigator) == None )
    {
        super.SetBeamLocation();
		return;
    }

    if ( Instigator != None && Instigator.IsLocallyControlled() )
		StartEffect = ASTurret_LinkTurret(Instigator).FPVAdjustBeamStart();
    else
	    StartEffect = ASVehicle(Instigator).GetFireStart(0);

	SetLocation( StartEffect );
}

simulated function vector SetBeamRotation()
{
	local vector	Start, HL, HN;

    if ( Instigator != None )
	{
		Start = ASVehicle(Instigator).GetFireStart();
		ASVehicle(Instigator).CalcWeaponFire( HL, HN );
		SetRotation( Rotator(HL - Start) );
        //SetRotation( Instigator.Rotation );
	}
    else
        SetRotation( Rotator(EndEffect - StartEffect) );

	return Normal( Vector(Rotation) );
}

defaultproperties
{
     mSizeRange(0)=20.000000
}
