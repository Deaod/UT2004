//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSPurplePlasmaSmallFireEffect extends Emitter;

simulated function PostNetBeginPlay()
{
	local PlayerController PC;
	
	Super.PostNetBeginPlay();
		
	PC = Level.GetLocalPlayerController();
	if ( (PC.ViewTarget == None) || (VSize(PC.ViewTarget.Location - Location) > 5000) )
		Emitters[2].Disabled = true;
}	

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter34
         UseDirectionAs=PTDU_Scale
         UseColorScale=True
         SpinParticles=True
         UniformSize=True
         ColorScale(0)=(Color=(B=235,G=128,R=185,A=128))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=235,G=128,R=185))
         CoordinateSystem=PTCS_Relative
         MaxParticles=2
         StartLocationOffset=(X=92.500000)
         StartSpinRange=(X=(Max=1.000000))
         StartSizeRange=(X=(Min=35.000000,Max=50.000000))
         InitialParticlesPerSecond=8000.000000
         Texture=Texture'AW-2004Particles.Weapons.PlasmaStar'
         LifetimeRange=(Min=0.200000,Max=0.200000)
         WarmupTicksPerSecond=2.000000
         RelativeWarmupTime=2.000000
     End Object
     Emitters(0)=SpriteEmitter'Onslaught.ONSPurplePlasmaSmallFireEffect.SpriteEmitter34'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter35
         UseDirectionAs=PTDU_Right
         UseColorScale=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=235,G=128,R=185))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=235,G=128,R=185))
         CoordinateSystem=PTCS_Relative
         MaxParticles=1
         StartLocationOffset=(X=50.000000)
         StartSizeRange=(X=(Min=-75.000000,Max=-75.000000),Y=(Min=25.000000,Max=25.000000))
         InitialParticlesPerSecond=500.000000
         Texture=Texture'AW-2004Particles.Weapons.PlasmaHeadDesat'
         LifetimeRange=(Min=0.200000,Max=0.200000)
         StartVelocityRange=(X=(Max=10.000000))
         VelocityLossRange=(X=(Min=1.000000,Max=1.000000))
         WarmupTicksPerSecond=1.000000
         RelativeWarmupTime=2.000000
     End Object
     Emitters(1)=SpriteEmitter'Onslaught.ONSPurplePlasmaSmallFireEffect.SpriteEmitter35'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter36
         UseColorScale=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         BlendBetweenSubdivisions=True
         ColorScale(1)=(RelativeTime=0.100000,Color=(B=254,G=148,R=225))
         ColorScale(2)=(RelativeTime=0.500000,Color=(B=238,G=57,R=143))
         ColorScale(3)=(RelativeTime=1.000000)
         CoordinateSystem=PTCS_Relative
         MaxParticles=20
         DetailMode=DM_High
         StartLocationOffset=(X=90.000000)
         SpinsPerSecondRange=(X=(Max=0.200000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000)
         StartSizeRange=(X=(Min=12.500000,Max=20.000000))
         Texture=Texture'AW-2004Particles.Weapons.SmokePanels1'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=0.400000,Max=0.400000)
         StartVelocityRange=(X=(Min=-500.000000,Max=-500.000000))
         WarmupTicksPerSecond=1.000000
         RelativeWarmupTime=2.000000
     End Object
     Emitters(2)=SpriteEmitter'Onslaught.ONSPurplePlasmaSmallFireEffect.SpriteEmitter36'

     bNoDelete=False
}
