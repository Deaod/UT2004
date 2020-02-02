//=============================================================================
// ONSAttackCraftExhaust.
//=============================================================================
// Placement offsets are:
// X=147.695313,Y=-25.922363,Z=51.000000
// and
// X=147.612320,Y=27.779526,Z=51.000000
//=============================================================================

class ONSAttackCraftExhaust extends Emitter
	placeable;

#exec OBJ LOAD FILE="..\Textures\AW-2004Particles.utx"

simulated function SetThrust(float Amount)
{
	Emitters[0].StartSizeRange.X.Min = -0.1 - (Amount * 0.3);
	Emitters[0].StartSizeRange.X.Max = -0.2 - (Amount * 0.8);

	Emitters[1].StartVelocityRange.X.Min = 150 + (Amount * 250);
	Emitters[1].StartVelocityRange.X.Max = Emitters[1].StartVelocityRange.X.Min;

	Emitters[1].ParticlesPerSecond = 30 + (Amount * 70);
	Emitters[1].InitialParticlesPerSecond = 30 + (Amount * 70);
}

simulated function SetThrustEnabled(bool bDoThrust)
{
	if(bDoThrust)
	{
		Emitters[0].Disabled = false;
		Emitters[1].Disabled = false;
	}
	else
	{
		Emitters[0].Disabled = true;
		Emitters[1].Disabled = true;
	}
}

defaultproperties
{
     Begin Object Class=MeshEmitter Name=MeshEmitter2
         StaticMesh=StaticMesh'AW-2004Particles.Weapons.TurretFlash'
         UseMeshBlendMode=False
         UseParticleColor=True
         UseColorScale=True
         SpinParticles=True
         UniformSize=True
         ColorScale(1)=(RelativeTime=0.330000,Color=(B=32,G=112,R=255))
         ColorScale(2)=(RelativeTime=0.660000,Color=(B=32,G=112,R=255))
         ColorScale(3)=(RelativeTime=1.000000)
         CoordinateSystem=PTCS_Relative
         MaxParticles=3
         StartSpinRange=(Z=(Max=1.000000))
         StartSizeRange=(X=(Min=-0.500000,Max=-0.750000))
         LifetimeRange=(Min=0.100000,Max=0.200000)
     End Object
     Emitters(0)=MeshEmitter'Onslaught.ONSAttackCraftExhaust.MeshEmitter2'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter3
         UseColorScale=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         UseRandomSubdivision=True
         ColorScale(1)=(RelativeTime=0.125000,Color=(B=28,G=192,R=250))
         ColorScale(2)=(RelativeTime=0.400000,Color=(B=26,G=112,R=255))
         ColorScale(3)=(RelativeTime=1.000000)
         CoordinateSystem=PTCS_Relative
         MaxParticles=30
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=0.250000)
         StartSizeRange=(X=(Min=10.000000,Max=10.000000))
         ParticlesPerSecond=100.000000
         InitialParticlesPerSecond=100.000000
         Texture=Texture'AW-2004Particles.Weapons.SmokePanels1'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=0.200000,Max=0.200000)
         StartVelocityRange=(X=(Min=150.000000,Max=150.000000))
     End Object
     Emitters(1)=SpriteEmitter'Onslaught.ONSAttackCraftExhaust.SpriteEmitter3'

     AutoDestroy=True
     CullDistance=12000.000000
     bNoDelete=False
     AmbientGlow=140
     bHardAttach=True
}
