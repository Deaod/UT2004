class LinkBeamEffect extends xEmitter;

#exec OBJ LOAD FILE=XEffectMat.utx

var Vector	StartEffect, EndEffect;
var byte	Links, OldLinks;
var byte	LinkColor, OldLinkColor;
var bool	bLockedOn, bHitSomething;
var Pawn	LinkedPawn;
var Vector	EffectOffset;
var Vector	PrevLoc;
var Rotator PrevRot;
var float	scorchtime;

var LinkSparks			Sparks;
var LinkProtSphere		ProtSphere;
var LinkMuzFlashBeam3rd MuzFlash, OldMuzFlash;

const MAX_CHILDREN = 4;
var int				NumChildren;
var LinkBeamChild	Child[MAX_CHILDREN];

replication
{
    unreliable if (Role == ROLE_Authority)
        Links, LinkColor, LinkedPawn, bLockedOn, bHitSomething;

    unreliable if ( (Role == ROLE_Authority) && (!bNetOwner || bDemoRecording || bRepClientDemo)  )
        StartEffect, EndEffect;
}


simulated function Destroyed()
{
    local int c;

    if ( Sparks != None )
    {
        Sparks.SetTimer(0, false);
        Sparks.mRegen = false;
        Sparks.LightType = LT_None;
    }

    if ( MuzFlash != None )
        MuzFlash.mRegen = false;

    if ( ProtSphere != None )
        ProtSphere.Destroy();

    for (c=0; c<MAX_CHILDREN; c++)
    {
        if (Child[c] != None)
            Child[c].Destroy();
    }

    Super.Destroyed();
}

simulated function SetBeamLocation()
{
	local xWeaponAttachment Attachment;

	if ( Level.NetMode == NM_DedicatedServer )
    {
        StartEffect = Instigator.Location + Instigator.EyeHeight*Vect(0,0,1);
        SetLocation( StartEffect );
        return;
    }

    if ( Instigator == None )
    {
        SetLocation( StartEffect );
    }
    else
    {
		if ( Instigator.IsFirstPerson() )
        {
            if ( (Instigator.Weapon == None) || Instigator.Weapon.WeaponCentered() || (Instigator.Weapon.Instigator == None) )
 		        SetLocation( Instigator.Location );
            else
				SetLocation(Instigator.Weapon.GetEffectStart() - 60 * vector(Instigator.Controller.Rotation));
        }
        else
        {
            Attachment = xPawn(Instigator).WeaponAttachment;
            if ( Attachment != None && (Level.TimeSeconds - Attachment.LastRenderTime) < 1 )
                SetLocation( Attachment.GetTipLocation() );
            else
                SetLocation( Instigator.Location + Normal(EndEffect - Instigator.Location) * 25.0 );
        }
        if ( Role == ROLE_Authority ) // what clients will use if their instigator is not relevant yet
            StartEffect = Location;
    }
}

simulated function Vector SetBeamRotation()
{
    if ( (Instigator != None) && PlayerController(Instigator.Controller) != None )
        SetRotation( Instigator.Controller.GetViewRotation() );
    else
        SetRotation( Rotator(EndEffect - Location) );

	return Normal(EndEffect - Location);
}

simulated function bool CheckMaxEffectDistance(PlayerController P, vector SpawnLocation)
{
	return !P.BeyondViewDistance(SpawnLocation,1000);
}


simulated function Tick(float dt)
{
    local float LocDiff, RotDiff, WiggleMe,ls;
    local int c, n;
    local Vector BeamDir, HitLocation, HitNormal;
    local actor HitActor;
	local PlayerController P;
    if ( Role == ROLE_Authority && (Instigator == None || Instigator.Controller == None) )
    {
        Destroy();
        return;
    }

	// set beam start location
	SetBeamLocation();
	BeamDir = SetBeamRotation();

	if ( Level.NetMode != NM_DedicatedServer )
	{
		if ( (Instigator != None) && !Instigator.IsFirstPerson() )
		{
			if ( MuzFlash == None )
				MuzFlash = Spawn(class'LinkMuzFlashBeam3rd', self);
		}
		else if ( MuzFlash != None )
			MuzFlash.Destroy();

		if ( Sparks == None && EffectIsRelevant(EndEffect, false) )
		{
			P = Level.GetLocalPlayerController();
			if ( (P == Instigator.Controller) || CheckMaxEffectDistance(P, Location) )
				Sparks = Spawn(class'LinkSparks', self);
		}
	}
    ls = class'LinkFire'.default.LinkScale[Min(Links,5)];

    if ( Links != OldLinks || LinkColor != OldLinkColor || MuzFlash != OldMuzFlash )
    {
        // beam size
        mSizeRange[0] = default.mSizeRange[0] * (ls*0.6 + 1);

        mWaveShift = default.mWaveShift * (ls*0.6 + 1);

        // create/destroy children
        NumChildren = Min(Links+1, MAX_CHILDREN);
		if ( Level.NetMode != NM_DedicatedServer )
		{
			for (c=0; c<MAX_CHILDREN; c++)
			{
				if ( c < NumChildren && !Level.bDropDetail && Level.DetailMode != DM_Low )
				{
					if ( Child[c] == None )
						Child[c] = Spawn(class'LinkBeamChild', self);

					Child[c].mSizeRange[0] = 2.0 + 4.0 * (NumChildren - c);
				}
				else if ( Child[c] != None )
					Child[c].Destroy();
			}
		}

        if ( LinkColor == 0 )
        {
            if ( Links > 0 )
            {
                Skins[0] = FinalBlend'XEffectMat.LinkBeamYellowFB';
                if ( MuzFlash != None )
					MuzFlash.Skins[0] = Texture'XEffectMat.link_muz_yellow';
                LightHue = 40;
            }
            else
            {
                Skins[0] = FinalBlend'XEffectMat.LinkBeamGreenFB';
                if ( MuzFlash != None )
	                MuzFlash.Skins[0] = Texture'XEffectMat.link_muz_green';
                LightHue = 100;
            }
        }
        else if ( LinkColor == 1 )
        {
            Skins[0] = FinalBlend'XEffectMat.LinkBeamRedFB';
            if ( MuzFlash != None )
				MuzFlash.Skins[0] = Texture'XEffectMat.link_muz_red';
            LightHue = 0;
        }
        else
        {
            Skins[0] = FinalBlend'XEffectMat.LinkBeamBlueFB';
            if ( MuzFlash != None )
	            MuzFlash.Skins[0] = Texture'XEffectMat.link_muz_blue';
            LightHue = 160;
        }

		if ( MuzFlash != None )
		{
			MuzFlash.mSizeRange[0] = MuzFlash.default.mSizeRange[0] * (ls*0.5 + 1);
			MuzFlash.mSizeRange[1] = MuzFlash.mSizeRange[0];
		}

        LightBrightness = 180 + 40*ls;
        LightRadius = 6 + 3*ls;

        if ( Sparks != None )
        {
            Sparks.SetLinkStatus(Links, (LinkColor > 0), ls);
            Sparks.bHidden = (LinkColor > 0);
            Sparks.LightHue = LightHue;
            Sparks.LightBrightness = LightBrightness;
            Sparks.LightRadius = LightRadius - 3;
        }

        if ( LinkColor > 0 && LinkedPawn != None )
        {
            if ( (ProtSphere == None) && (Level.NetMode != NM_DedicatedServer) )
            {
                ProtSphere = Spawn(class'LinkProtSphere');
                if (LinkColor == 2)
                    ProtSphere.Skins[0] = Texture'XEffectMat.link_muz_blue';
            }
        }

        OldLinks		= Links;
        OldLinkColor	= LinkColor;
		OldMuzFlash		= MuzFlash;
    }

    if ( Level.bDropDetail || Level.DetailMode == DM_Low )
    {
		bDynamicLight = false;
        LightType = LT_None;
    }
    else if ( bDynamicLight )
        LightType = LT_Steady;

    if ( LinkedPawn != None )
    {
        EndEffect = LinkedPawn.Location + LinkedPawn.EyeHeight*Vect(0,0,0.5) - BeamDir*30.0;
    }

    mSpawnVecA = EndEffect;

    mWaveLockEnd = bLockedOn || (LinkColor > 0);

    // magic wiggle code
    if ( bLockedOn || (LinkColor > 0) )
    {
        mWaveAmplitude = FMax(0.0, mWaveAmplitude - (mWaveAmplitude+5)*4.0*dt);
    }
    else
    {
        LocDiff			= VSize((Location - PrevLoc) * Vect(1,1,5));
        RotDiff			= VSize(Vector(Rotation) - Vector(PrevRot));
        WiggleMe		= FMax(LocDiff*0.02, RotDiff*4.0);
        mWaveAmplitude	= FMax(1.0, mWaveAmplitude - mWaveAmplitude*1.0*dt);
        mWaveAmplitude	= FMin(16.0, mWaveAmplitude + WiggleMe);
    }

    PrevLoc = Location;
    PrevRot = Rotation;

    for (c=0; c<NumChildren; c++)
    {
        if ( Child[c] != None )
        {
            n = c+1;
            Child[c].SetLocation( Location );
            Child[c].SetRotation( Rotation );
            Child[c].mSpawnVecA		= mSpawnVecA;
            Child[c].mWaveShift		= mWaveShift*0.6;
            Child[c].mWaveAmplitude = n*4.0 + mWaveAmplitude*((16.0-n*4.0)/16.0);
            Child[c].mWaveLockEnd	= (LinkColor > 0); //mWaveLockEnd;
            Child[c].Skins[0]		= Skins[0];
        }
    }

    if ( Sparks != None )
    {
        Sparks.SetLocation( EndEffect - BeamDir*10.0 );
        if ( bHitSomething )
            Sparks.SetRotation( Rotation);
        else
            Sparks.SetRotation( Rotator(-BeamDir) );
        Sparks.mRegenRange[0] = Sparks.DesiredRegen;
        Sparks.mRegenRange[1] = Sparks.DesiredRegen;
        Sparks.bDynamicLight = true;
    }

    if ( LinkColor > 0 && LinkedPawn != None )
    {
        if ( ProtSphere != None )
        {
            ProtSphere.SetLocation( EndEffect );
            ProtSphere.SetRotation( Rotation );
            ProtSphere.bHidden = false;
            if ( LinkedPawn.IsFirstPerson() )
                ProtSphere.mSizeRange[0] = 20.0;
            else
                ProtSphere.mSizeRange[0] = 35.0;
            ProtSphere.mSizeRange[1] = ProtSphere.mSizeRange[0];
        }
    }
    else
    {
        if ( ProtSphere != None )
			ProtSphere.bHidden = true;
    }
    if ( bHitSomething && (Level.NetMode != NM_DedicatedServer) && (Level.TimeSeconds - ScorchTime > 0.07) )
    {
		ScorchTime = Level.TimeSeconds;
		HitActor = Trace(HitLocation, HitNormal, EndEffect + 100*BeamDir, EndEffect - 100*BeamDir, true);
		if ( (HitActor != None) && HitActor.bWorldGeometry )
			spawn(class'LinkScorch',,,HitLocation,rotator(-HitNormal));
	}
}

defaultproperties
{
     EffectOffset=(X=22.000000,Y=11.000000,Z=1.400000)
     mParticleType=PT_Beam
     mMaxParticles=3
     mRegenDist=65.000000
     mSpinRange(0)=45000.000000
     mSizeRange(0)=11.000000
     mColorRange(0)=(B=240,G=240,R=240)
     mColorRange(1)=(B=240,G=240,R=240)
     mAttenuate=False
     mAttenKa=0.000000
     mWaveFrequency=0.060000
     mWaveAmplitude=8.000000
     mWaveShift=100000.000000
     mBendStrength=3.000000
     mWaveLockEnd=True
     LightType=LT_Steady
     LightHue=100
     LightSaturation=100
     LightBrightness=255.000000
     LightRadius=4.000000
     bDynamicLight=True
     bNetTemporary=False
     bReplicateInstigator=True
     RemoteRole=ROLE_SimulatedProxy
     Skins(0)=FinalBlend'XEffectMat.Link.LinkBeamGreenFB'
     Style=STY_Additive
}
