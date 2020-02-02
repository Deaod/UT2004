class ShockComboVortex extends MeshEffect;

#exec OBJ LOAD FILE=XEffectMat.utx

var() Rotator InitialRot;

event PostBeginPlay()
{
    Super.PostBeginPlay();
    SetRotation(InitialRot);
}

defaultproperties
{
     InitialRot=(Roll=16384)
     FadeInterp=(OutTime=0.900000)
     ScaleInterp=(Start=0.400000,Mid=1.600000,End=0.200000,InTime=0.400000,OutTime=0.400000,InStyle=IS_InvExp,OutStyle=IS_InvExp)
     DrawType=DT_Mesh
     Mesh=VertMesh'XEffects.ShockVortexMesh'
     Skins(0)=FinalBlend'XEffectMat.Shock.ShockElecRingFB'
     bUnlit=True
     bAlwaysFaceCamera=True
}
