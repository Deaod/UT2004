//=============================================================================
// FX_LinkTurret_BeamEffect
//=============================================================================
// Created by Laurent Delayen
// © 2003, Epic Games, Inc.  All Rights Reserved
//=============================================================================

class WA_LinkTurret extends LinkAttachment;

var ELinkColor	OldLinkColor;
var int			OldLinks;

simulated function UpdateLinkColor()
{
	super.UpdateLinkColor();
	if ( Instigator != None )
		ASTurret_LinkTurret(Instigator).UpdateLinkColor( LinkColor );
}


simulated function PostNetReceive()
{
	super.PostNetReceive();
	if ( LinkColor != OldLinkColor && Instigator != None)
	{
		ASTurret_LinkTurret(Instigator).UpdateLinkColor( LinkColor );
		OldLinkColor = LinkColor;
	}
	else if ( Links != OldLinks )
	{
		if ( Links > 0 )
			SetLinkColor( LC_Gold );
		else
			SetLinkColor( LC_Green );
		OldLinks = Links;
	}
}

simulated event ThirdPersonEffects()
{
    local Rotator	R;
	local vector	Start;

	if ( Instigator == None  )
		return;

    if ( Level.NetMode != NM_DedicatedServer && FlashCount > 0 )
	{
        if ( FiringMode == 0 )
        {
            if ( MuzFlash == None )
            {
				Start = ASVehicle(Instigator).GetFireStart();

                MuzFlash = Spawn(class'LinkMuzFlashProj3rd',,, Start, Instigator.Rotation );

				if ( MuzFlash != None )
				{
					MuzFlash.bHardAttach = true;
					MuzFlash.SetBase( Instigator );
				}
            }

            if ( MuzFlash != None )
            {
                MuzFlash.mSizeRange[0] = MuzFlash.default.mSizeRange[0] * (class'LinkFire'.default.LinkScale[Clamp(Links,0,5)]+1); // (1.0 + 0.3*float(Links));
                MuzFlash.mSizeRange[1] = MuzFlash.mSizeRange[0];

				if ( Links > 0 )
					SetLinkColor( LC_Gold );
				else
					SetLinkColor( LC_Green );
				UpdateLinkColor();

				MuzFlash.Trigger(Self, None);
                R.Roll = Rand(65536);
                MuzFlash.SetRelativeRotation( R );
            }

			// have pawn play firing anim
			Instigator.PlayFiring(1.0, '0');
        }
    }

    super(xWeaponAttachment).ThirdPersonEffects();
}

defaultproperties
{
     bReplicateLinkColor=True
     Mesh=None
     bNetNotify=True
}
