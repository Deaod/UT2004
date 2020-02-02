//=============================================================================
// Emitter: An Unreal Trail Particle Emitter.
//	Revision history:
//		* Created by Daniel Vogel
//		* Updated by Laurent Delayen
//=============================================================================

class TrailEmitter extends ParticleEmitter
	native;

struct ParticleTrailData
{
	var vector	Location;
	var color	Color;
	var float	Size;
	var int		DoubleDummy1;
	var int		DoubleDummy2;
};

struct ParticleTrailInfo
{
	var int		TrailIndex;
	var int		NumPoints;
	var vector	LastLocation;					// last point location (to compute new points)
	var vector	LastEmitterLocation;			// Laurent -- Last Emitter Location, to process point interpolation
};

enum ETrailShadeType
{
	PTTST_None,				// Full particle color
	PTTST_RandomStatic,		// particle color * random opacity set once
	PTTST_RandomDynamic,	// particle color * random opacity, updated every tick
	PTTST_Linear,			// smooth linear fade out (begining = 100%, end = 0%)
	PTTST_PointLife			// linear fade relative to point's life
};

enum ETrailLocation
{
	PTTL_AttachedToParticle,	// Attached to Particle
	PTTL_FollowEmitter			// Attached to Particle, with added emitter's velocity
};

var (Trail)			ETrailShadeType				TrailShadeType;			// Shading effect on trail
var (Trail)			ETrailLocation				TrailLocation;			// Trail Attachment

var (Trail)			int							MaxPointsPerTrail;
var (Trail)			float						DistanceThreshold;
var (Trail)			bool						UseCrossedSheets;
var (Trail)			int							MaxTrailTwistAngle;
var (Trail)			float						PointLifeTime;			// 0.f for unlimited

var transient		array<ParticleTrailData>	TrailData;
var transient		array<ParticleTrailInfo>	TrailInfo;
var transient		vertexbuffer				VertexBuffer;
var transient		indexbuffer					IndexBuffer;
var transient		int							VerticesPerParticle;
var transient		int							IndicesPerParticle;
var transient		int							PrimitivesPerParticle;

native final function ResetTrail();

defaultproperties
{
     MaxPointsPerTrail=30
     DistanceThreshold=2.000000
     MaxTrailTwistAngle=16384
}
