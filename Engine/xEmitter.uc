//=============================================================================
// xEmitter - particle emission! renamed to avoid conflict with Emitter
// Copyright 2001 Digital Extremes - All Rights Reserved.
// Confidential.
//=============================================================================
class xEmitter extends Actor native placeable;

#exec Texture Import File=Textures\S_Emitter.tga Name=S_Emitter Mips=Off

replication
{
    unreliable if (Role == ROLE_Authority)
        mSpawnVecA, blockOnNet;
}

// particle system config...
var(PclEmitter) enum ExParticleTypes
{
	PT_Sprite,
	PT_Stream,
	PT_Line,
	PT_Disc,
	PT_Mesh,
	PT_Branch,
    PT_Beam,
} mParticleType;

// particle system config...
var(PclEmitter) enum ExSpawningTypes
{
	ST_Sphere,
	ST_Line,
	ST_Disc,
	ST_Cylinder,
    ST_AimedSphere,
    ST_StaticMesh,
    ST_Explode,
    ST_ExplodeRing,
    ST_OwnerSkeleton,
    ST_Test,
} mSpawningType;

var(PclEmitter) bool	mRegen;
var(PclEmitter) bool	mRegenPause;
var(PclEmitter) float	mRegenOnTime[2];
var(PclEmitter) float	mRegenOffTime[2];
var(PclEmitter) int		mStartParticles;	// at runtime also, you can set this > 0 to spawn this many next tick
var(PclEmitter) private int		mMaxParticles;
var(PclEmitter) float	mDelayRange[2];
var(PclEmitter) float	mLifeRange[2];
var(PclEmitter) float	mRegenRange[2];
var(PclEmitter) float	mRegenDist;
var(PclEmitter) Name	mSourceActor;
var(PclEmitter) Name	mChildName;
var			   xEmitter mChildEmitter;
var(PclEmitter) StaticMeshActor SourceStaticMesh;
var(PclEmitter) bool    bSuspendWhenNotVisible;
var(PclVisuals) bool    mDistanceAtten;

var(PclMovement) vector	mDirDev;
var(PclMovement) vector	mPosDev;
var(PclMovement) vector mSpawnVecA;
var(PclMovement) vector	mSpawnVecB;

var(PclMovement) float	mSpeedRange[2];
var(PclMovement) bool	mPosRelative;
var(PclMovement) float	mMassRange[2];
var(PclMovement) float	mAirResistance;
var(PclMovement) bool	mCollision;
var(PclMovement) float  mOwnerVelocityFactor;

var(PclVisuals) bool	mRandOrient;

var(PclMovement) float	mSpinRange[2];

var(PclVisuals) float	mSizeRange[2];
var(PclVisuals) float	mGrowthRate;
var(PclVisuals) color	mColorRange[2];

// attenuation
var(PclVisuals) bool	mAttenuate;
var(PclVisuals) float	mAttenKa;
var(PclVisuals) float	mAttenKb;
var(PclVisuals) enum	EAttenFunc
{
	ATF_LerpInOut,
	ATF_ExpInOut,
	ATF_SmoothStep,
	ATF_Pulse,
	ATF_Random,
	ATF_None,
} mAttenFunc;
var				int		mpAttenFunc;

var(PclVisuals) bool	mRandTextures;	// choose a random texture for each instance of this emitter
var(PclVisuals) bool	mTileAnimation;	// animate the particle from the set of tiles throughout life
var(PclVisuals) int		mNumTileColumns;
var(PclVisuals) int		mNumTileRows;
var(PclVisuals) bool	mUseMeshNodes;
var(PclVisuals) bool	mRandMeshes;
var(PclVisuals) StaticMesh	mMeshNodes[8]; // if using meshes as particle nodes
var(PclVisuals) Texture	mPosColorMapXY;
var(PclVisuals) Texture	mPosColorMapXZ;
var(PclVisuals) Texture	mLifeColorMap;

var(PclSoftBody) float	springK;
var(PclSoftBody) float	springD;
var(PclSoftBody) float	springMaxStretch;
var(PclSoftBody) float	springMaxCompress;

// ver 1.1
var(PclMovement) float	mColElasticity; // bounciness of particle collision 0-1
var(PclMovement) float	mAttraction;	// attractive force between particles
var(PclMovement) bool	mColMakeSound;

var(pclBeam)     float  mWaveFrequency;
var(pclBeam)     float  mWaveAmplitude;
var(pclBeam)     float  mWaveShift;
var(pclBeam)     float  mBendStrength;
var(pclBeam)     bool   mWaveLockEnd;

var(Force) bool bForceAffected;

// native stuff.
var transient int	SystemHandle;
var transient int	Expire;

var transient pointer mpParticles; // ptr to tarray
var transient int	mNumActivePcl;
var transient pointer  mpIterator;
var transient int	mbSpinningNodes;
var transient vector mLastPos;
var transient vector mLastVector;
var transient float	mTime;
var transient float	mT; // delta
var transient float  mRegenBias;
var transient float  mRegenTimer;
var transient float  mPauseTimer;
var transient Box	mBounds;
var transient plane	mSphere;
var transient vector mDir;
var transient int	mNumUpdates;
var transient int	mAtLeastOneFrame;
var transient int	mRenderableVerts;
var transient float	mTexU;
var transient float	mTexV;
var transient float  mTotalTiles;
var transient float  mInvTileCols;
var transient pointer	mpSprings; // ptr to Spring class
var transient int	mNumSprings;
var transient float mWavePhaseA;
var transient float mWavePhaseB;

var bool blockOnNet;
var bool bCallPreSpawn;
// v 1.4
var transient int	mHeadIndex;

event CollisionSound(); //amb
event PreSpawned()
{
	if ( !Level.bStartup )
	{
		bSuspendWhenNotVisible = false;
		if ( Level.bDropDetail && (mMaxParticles > 5) 
			&& ((mParticleType == PT_Sprite) || (mParticleType == PT_Mesh) || (mParticleType == PT_Line)) )
		{
			mMaxParticles = mMaxParticles * 0.65;
			mRegenRange[0] *= 0.8;
			mRegenRange[1] *= 0.8;
			mStartParticles = 0.65 * mStartParticles;
		}
	}
}

simulated final function float ClampToMaxParticles(float InPart)
{
	return FMin(InPart, mStartParticles);
}

event Trigger( Actor Other, Pawn EventInstigator )
{
	mRegenPause = !mRegenPause;
}

simulated function UpdatePrecacheMaterials()
{
	if ( mPosColorMapXY != None )
		Level.AddPrecacheMaterial(mPosColorMapXY);
	if ( mPosColorMapXZ != None )
	    Level.AddPrecacheMaterial(mPosColorMapXZ);
	if ( mLifeColorMap != None )
		Level.AddPrecacheMaterial(mLifeColorMap);

	super.UpdatePrecacheMaterials();
}

static function PrecacheContent(LevelInfo Level)
{
	if ( Default.mPosColorMapXY != None )
		Level.AddPrecacheMaterial(Default.mPosColorMapXY);
	if ( Default.mPosColorMapXZ != None )
	    Level.AddPrecacheMaterial(Default.mPosColorMapXZ);
	if ( Default.mLifeColorMap != None )
		Level.AddPrecacheMaterial(Default.mLifeColorMap);
	if ( Default.Skins.Length > 0 )
		Level.AddPrecacheMaterial(Default.Skins[0]);
}

defaultproperties
{
     mRegen=True
     mStartParticles=1
     mMaxParticles=50
     mLifeRange(0)=4.000000
     mLifeRange(1)=4.000000
     mRegenRange(0)=1.000000
     mRegenRange(1)=1.000000
     bSuspendWhenNotVisible=True
     mSpawnVecB=(Z=0.050000)
     mSpeedRange(0)=40.000000
     mSpeedRange(1)=40.000000
     mAirResistance=0.400000
     mSizeRange(0)=10.000000
     mSizeRange(1)=10.000000
     mColorRange(0)=(B=255,G=255,R=255,A=255)
     mColorRange(1)=(B=255,G=255,R=255,A=255)
     mAttenuate=True
     mAttenKa=0.200000
     mAttenKb=1.000000
     mNumTileColumns=1
     mNumTileRows=1
     mColElasticity=0.500000
     bCallPreSpawn=True
     LightEffect=LE_QuadraticNonIncidence
     DrawType=DT_Particle
     bAcceptsProjectors=False
     bNetTemporary=True
     RemoteRole=ROLE_None
     Texture=Texture'Engine.S_Emitter'
     Skins(0)=Texture'Engine.S_Emitter'
     bUnlit=True
     bGameRelevant=True
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     bNotOnDedServer=True
     bDirectional=True
}
