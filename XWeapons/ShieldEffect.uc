class ShieldEffect extends Actor;

#exec OBJ LOAD FILE=XEffectMat.utx

var float Brightness, DesiredBrightness;

function Flash(int Drain)
{
    Brightness = FMin(Brightness + Drain / 2, 250.0);
    Skins[0] = Skins[1];
    SetTimer(0.2, false);
}

function Timer()
{
    Skins[0] = default.Skins[0];
}

function SetBrightness(int b)
{
    DesiredBrightness = FMin(50+b*2, 250.0);
}

defaultproperties
{
     Brightness=250.000000
     DesiredBrightness=250.000000
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'WeaponStaticMesh.Shield'
     bHidden=True
     bOnlyOwnerSee=True
     RemoteRole=ROLE_None
     DrawScale=1.800000
     Skins(0)=FinalBlend'XEffectMat.Shield.Shield3rdFB'
     Skins(1)=FinalBlend'XEffectMat.Shield.ShieldRip3rdFB'
     AmbientGlow=250
     bUnlit=True
}
