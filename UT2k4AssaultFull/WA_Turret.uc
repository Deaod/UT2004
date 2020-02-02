//=============================================================================
// WA_Turret
//=============================================================================

class WA_Turret extends WA_SpaceFighter;

var FX_BallTurret_Shield ShieldEffect3rd;


replication
{
    reliable if ( bNetInitial && Role == ROLE_Authority )
        ShieldEffect3rd;
}

simulated function Destroyed()
{
    if ( ShieldEffect3rd != None )
        ShieldEffect3rd.Destroy();

    super.Destroyed();
}

function InitFor(Inventory I)
{
    super.InitFor(I);

	ShieldEffect3rd = Spawn(class'FX_BallTurret_Shield', I.Instigator);
}

function SetBrightness(int b, bool hit)
{
    if ( ShieldEffect3rd != None )
        ShieldEffect3rd.SetBrightness(b, hit);
}

simulated function PlayFireFX( float fSide );


//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     MuzzleScale=2.000000
}
