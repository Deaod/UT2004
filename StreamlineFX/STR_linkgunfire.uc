class STR_linkgunfire extends Emitter;

simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp7_frames');
	Level.AddPrecacheMaterial(Material'EpicParticles.Flares.SoftFlare');
	Level.AddPrecacheMaterial(Material'AW-2004Particles.Fire.MuchSmoke2t');
	Level.AddPrecacheMaterial(Material'AS_FX_TX.Trails.Trail_red');
	Level.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp1_frames');
	Level.AddPrecacheMaterial(Material'EmitterTextures.MultiFrame.rockchunks02');
	Level.AddPrecacheMaterial(Material'XGameShadersB.Blood.BloodJetc');
	Level.AddPrecacheMaterial(Material'XEffects.Skins.Rexpt');
	Level.AddPrecacheMaterial(Material'XEffects.SmokeAlphab_t');
	Level.AddPrecacheMaterial(Material'WeaponSkins.Skins.RocketShellTex');
	Level.AddPrecacheMaterial(Material'XEffects.RocketFlare');
	Level.AddPrecacheMaterial(Material'XEffects.rocketblastmark');
	Level.AddPrecacheMaterial(Material'ExplosionTex.Framed.SmokeReOrdered');
	Level.AddPrecacheMaterial(Material'ExplosionTex.Framed.we1_frames');
	Level.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp2_frames');
	Level.AddPrecacheMaterial(Material'XEffectMat.Link.link_muz_green');
	Level.AddPrecacheMaterial(Material'XEffects.Effects.LinkMuzFlashTex');
	Level.AddPrecacheMaterial(Material'XEffects.ShellCasingTex');
	Level.AddPrecacheMaterial(Material'XGameShadersB.Blood.AlienBloodJet');
	Level.AddPrecacheMaterial(Material'XGameShaders.WeaponShaders.minigunflash');
	Level.AddPrecacheMaterial(Material'XGameShaders.WeaponShaders.Minigun_burst');
	Level.AddPrecacheMaterial(Material'XEffects.Skins.BotSpark');
	Level.AddPrecacheMaterial(Material'XWeapons_rc.Effects.ShockBeamTex');
	Level.AddPrecacheMaterial(Material'XEffectMat.Shock.purple_line');
	Level.AddPrecacheMaterial(Material'XEffectMat.Shock.shock_flash');
	Level.AddPrecacheMaterial(Material'XEffectMat.Shock.shock_Energy_green_faded');
	Level.AddPrecacheMaterial(Material'EpicParticles.Smoke.Smokepuff2');
	Level.AddPrecacheMaterial(Material'EpicParticles.Smoke.FlameGradient');
	Level.AddPrecacheMaterial(Material'EpicParticles.Shaders.Grad_Falloff');
	Level.AddPrecacheMaterial(Material'EpicParticles.Fire.IonBurn');
	Level.AddPrecacheMaterial(Material'EpicParticles.Flares.BurnFlare1');
	Level.AddPrecacheMaterial(Material'EpicParticles.Beams.WhiteStreak01aw');
	Level.AddPrecacheMaterial(Material'EpicParticles.Smoke.Smokepuff');

	Super.UpdatePrecacheStaticMeshes();
}

simulated function UpdatePrecacheMaterials()
{
	Level.AddPrecacheStaticMesh(StaticMesh'WeaponStaticMesh.RocketProj');

	Super.UpdatePrecacheMaterials();
}

defaultproperties
{
     Begin Object Class=MeshEmitter Name=linkgunbolt
         StaticMesh=StaticMesh'WeaponStaticMesh.LinkProjectile'
         RespawnDeadParticles=False
         UseColorFromMesh=True
         SpinParticles=True
         UseRegularSizeScale=False
         DetermineVelocityByLocationDifference=True
         AutomaticInitialSpawning=False
         Opacity=0.750000
         MaxParticles=1
         UseRotationFrom=PTRS_Actor
         SpinCCWorCW=(X=0.000000,Y=0.000000,Z=0.000000)
         SpinsPerSecondRange=(Z=(Min=-2.000000,Max=2.000000))
         StartSpinRange=(Z=(Min=-50.000000,Max=50.000000))
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=2.000000)
         SizeScaleRepeats=2.000000
         ScaleSizeByVelocityMax=1.000000
         InitialParticlesPerSecond=1.000000
         LifetimeRange=(Min=1.000000,Max=1.000000)
         StartVelocityRange=(X=(Min=750.000000,Max=750.000000))
         RelativeWarmupTime=5.000000
     End Object
     Emitters(0)=MeshEmitter'StreamlineFX.STR_linkgunfire.linkgunbolt'

     Begin Object Class=SpriteEmitter Name=linkgunflash
         UseColorScale=True
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=255,G=255,R=255))
         FadeOutFactor=(W=3.000000,X=3.000000,Y=3.000000,Z=3.000000)
         FadeOutStartTime=0.100000
         MaxParticles=1
         StartSpinRange=(X=(Max=5000.000000))
         SizeScale(0)=(RelativeTime=0.500000)
         StartSizeRange=(X=(Min=35.000000,Max=40.000000),Y=(Min=35.000000,Max=40.000000),Z=(Min=35.000000,Max=40.000000))
         InitialParticlesPerSecond=1.000000
         DrawStyle=PTDS_Brighten
         Texture=Texture'XEffects.Effects.LinkMuzFlashTex'
         LifetimeRange=(Min=1.000000,Max=1.000000)
     End Object
     Emitters(1)=SpriteEmitter'StreamlineFX.STR_linkgunfire.linkgunflash'

     Begin Object Class=SpriteEmitter Name=linkgunsecflash
         UseColorScale=True
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(G=202,R=26))
         Opacity=0.750000
         FadeOutFactor=(W=3.000000,X=3.000000,Y=3.000000,Z=3.000000)
         MaxParticles=1
         StartSpinRange=(X=(Max=-8000.000000))
         SizeScale(0)=(RelativeTime=1.000000)
         StartSizeRange=(X=(Min=60.000000,Max=80.000000),Y=(Min=60.000000,Max=80.000000),Z=(Min=60.000000,Max=80.000000))
         InitialParticlesPerSecond=1.000000
         DrawStyle=PTDS_Brighten
         Texture=Texture'XEffects.Effects.LinkMuzFlashTex'
         LifetimeRange=(Min=1.000000,Max=1.000000)
     End Object
     Emitters(2)=SpriteEmitter'StreamlineFX.STR_linkgunfire.linkgunsecflash'

     bLightChanged=True
     bNoDelete=False
     AmbientGlow=255
     bHardAttach=True
     bFixedRotationDir=True
     bDirectional=True
}
