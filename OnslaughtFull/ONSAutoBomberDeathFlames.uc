class ONSAutoBomberDeathFlames extends Emitter;

#exec OBJ LOAD FILE=AW-2004Explosions.utx

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter2
         FadeOut=True
         FadeIn=True
         ResetAfterChange=True
         AutoReset=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         UseRandomSubdivision=True
         FadeOutStartTime=2.700000
         FadeInEndTime=2.700000
         MaxParticles=25
         SizeScale(0)=(RelativeTime=3.000000,RelativeSize=8.000000)
         StartSizeRange=(X=(Min=250.000000,Max=250.000000))
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'VMParticleTextures.VehicleExplosions.smokeCloudTEX'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         StartVelocityRange=(Z=(Min=250.000000,Max=250.000000))
     End Object
     Emitters(0)=SpriteEmitter'OnslaughtFull.ONSAutoBomberDeathFlames.SpriteEmitter2'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter1
         FadeOut=True
         FadeIn=True
         AutoReset=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         BlendBetweenSubdivisions=True
         UseRandomSubdivision=True
         Acceleration=(Z=150.000000)
         FadeOutStartTime=1.500000
         FadeInEndTime=0.500000
         MaxParticles=30
         SpinsPerSecondRange=(X=(Min=0.050000,Max=0.100000))
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=8.000000)
         StartSizeRange=(X=(Min=50.000000,Max=75.000000))
         Texture=Texture'AW-2004Explosions.Fire.Fireball4'
         LifetimeRange=(Min=2.000000,Max=2.000000)
     End Object
     Emitters(1)=SpriteEmitter'OnslaughtFull.ONSAutoBomberDeathFlames.SpriteEmitter1'

     bNoDelete=False
}
