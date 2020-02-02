class ClassicBulletTrail extends xEmitter;

var Vector HitNormal;
var class<ShockMuzFlash> MuzFlashClass;
var class<ShockMuzFlash3rd> MuzFlash3Class;

replication
{
    reliable if (bNetInitial && Role == ROLE_Authority)
        HitNormal;
}

function AimAt(Vector hl, Vector hn)
{
    HitNormal = hn;
    mSpawnVecA = hl;
    if (Level.NetMode != NM_DedicatedServer)
        SpawnEffects();
}

simulated function PostNetBeginPlay()
{
    MakeNoise(0.5);
	
    if (Role < ROLE_Authority)
        SpawnEffects();
}

simulated function SpawnEffects()
{
    local xWeaponAttachment Attachment;
	local PlayerController PC;
	local vector Dir, LineDir, NewLocation, LinePos;
	
    if (Instigator != None)
    {
        if ( Instigator.IsFirstPerson() )
        {
			if ( (Instigator.Weapon != None) && (Instigator.Weapon.Instigator == Instigator) )
				SetLocation(Instigator.Weapon.GetEffectStart());
			else
				SetLocation(Instigator.Location);
        }
        else
        {
            Attachment = xPawn(Instigator).WeaponAttachment;
            if (Attachment != None && (Level.TimeSeconds - Attachment.LastRenderTime) < 1)
                NewLocation = Attachment.GetTipLocation();
            else
                 NewLocation = Instigator.Location + Instigator.EyeHeight*Vect(0,0,1) + Normal(mSpawnVecA - Instigator.Location) * 25.0; 
            
			// see if local player controller near bullet, but missed
			PC = Level.GetLocalPlayerController();
			if ( (PC != None) && (PC.Pawn != None) )
			{
				Dir = Normal(mSpawnVecA - NewLocation);
				LinePos = (NewLocation + (Dir dot (PC.Pawn.Location - NewLocation)) * Dir);
				LineDir = PC.Pawn.Location - LinePos;
				if ( VSize(LineDir) < 150 )
				{
					SetLocation(LinePos);
					if ( FRand() < 0.5 )
						PlaySound(sound'Impact3Snd',,,,80);
					else
						PlaySound(sound'Impact7Snd',,,,80);
				}
			}
			SetLocation(NewLocation);
            Spawn(MuzFlash3Class);
        }
    }

    if ( EffectIsRelevant(mSpawnVecA + HitNormal*2,false) && (HitNormal != Vect(0,0,0)) )
		Spawn(class'SniperWallHitEffect',,, mSpawnVecA, rotator(-1 * HitNormal));
}

defaultproperties
{
     MuzFlashClass=Class'XEffects.ShockMuzFlash'
     mParticleType=PT_Beam
     mMaxParticles=3
     mLifeRange(0)=0.750000
     mRegenDist=150.000000
     mSizeRange(0)=24.000000
     mSizeRange(1)=48.000000
     mAttenKa=0.100000
     bReplicateInstigator=True
     bReplicateMovement=False
     RemoteRole=ROLE_SimulatedProxy
     NetPriority=3.000000
     LifeSpan=0.750000
     Texture=Texture'XWeapons_rc.Effects.ShockBeamTex'
     Skins(0)=Texture'XWeapons_rc.Effects.ShockBeamTex'
     Style=STY_Additive
}
