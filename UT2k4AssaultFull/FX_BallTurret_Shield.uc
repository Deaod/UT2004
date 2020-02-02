//=============================================================================
// FX_BallTurret_Shield
//=============================================================================
// Created by Laurent Delayen
// © 2003, Epic Games, Inc.  All Rights Reserved
//=============================================================================

class FX_BallTurret_Shield extends Actor;

#exec OBJ LOAD FILE=XEffectMat.utx

var float			Brightness, DesiredBrightness;
var int				HitCount, OldHitCount;
var ShieldSparks	Sparks;


replication
{
    unreliable if ( Role == ROLE_Authority && !bHidden )
        HitCount; 
}


simulated function Destroyed()
{
    if ( Sparks != None )
        Sparks.Destroy();
}

simulated function Flash(int Drain)
{
    if ( Sparks == None )
	    Sparks = Spawn(class'ShieldSparks');

    if ( Instigator != None && Instigator.IsFirstPerson() )
    {
        Sparks.SetLocation( Location + Vect(0,0,20) + VRand()*12.0 );
        Sparks.SetRotation( Rotation );
        Sparks.mStartParticles = 16;
    }
    else if ( EffectIsRelevant(Location, false) )
    {
        Sparks.SetLocation( Location + VRand()*8.0 );
        Sparks.SetRotation( Rotation );
        Sparks.mStartParticles = 16;
    }

    Brightness	= FMin(Brightness + Drain / 2, 250.0);
    Skins[0]	= Skins[1];

    SetTimer(0.2, false);
}

simulated function Timer()
{
    Skins[0] = default.Skins[0];
}

function SetBrightness(int b, bool bHit)
{
    DesiredBrightness = FMin(50+b*2, 250.0);
    if ( bHit )
    {
        HitCount++;
        Flash( 50 );
    }
}

simulated function PostNetReceive()
{
    if ( OldHitCount == -1 )
        OldHitCount = HitCount;
    else if ( HitCount != OldHitCount )
	{
        Flash( 50 );
        OldHitCount = HitCount;
	}
}

defaultproperties
{
     Brightness=250.000000
     DesiredBrightness=250.000000
     OldHitCount=-1
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'WeaponStaticMesh.Shield'
     bHidden=True
     bTrailerSameRotation=True
     bReplicateInstigator=True
     Physics=PHYS_Trailer
     RemoteRole=ROLE_SimulatedProxy
     DrawScale3D=(X=40.000000,Y=15.000000,Z=15.000000)
     PrePivot=(X=-2.000000)
     Skins(0)=FinalBlend'XEffectMat.Shield.Shield3rdFB'
     Skins(1)=FinalBlend'XEffectMat.Shield.ShieldRip3rdFB'
     AmbientGlow=250
     bUnlit=True
     bNetNotify=True
}
