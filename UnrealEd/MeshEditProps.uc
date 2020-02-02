//=============================================================================
// Object to facilitate properties editing
//=============================================================================
//  Animation / Mesh editor object to expose/shuttle only selected editable 
//  parameters from UMeshAnim/ UMesh objects back and forth in the editor.
//  
 
class MeshEditProps extends MeshObject
	hidecategories(Object)
	native;	

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

// Static/smooth parts
struct native FSectionDigest
{
	var() EMeshSectionMethod  MeshSectionMethod;
	var() int     MaxRigidParts;
	var() int     MinPartFaces;
	var() float   MeldSize;
};

// LOD 
struct native LODLevel
{
	var() float   DistanceFactor;
	var() float   ReductionFactor;	
	var() float   Hysteresis;
	var() int     MaxInfluences;
	var() bool    RedigestSwitch;
	var() FSectionDigest Rigidize;
};

struct native AttachSocket
{
	var() vector  A_Translation;
	var() rotator A_Rotation;
	var() name AttachAlias;	
	var() name BoneName;		
	var() float      Test_Scale;
	var() mesh       TestMesh;
	var() staticmesh TestStaticMesh;	
};

struct native MEPBonePrimSphere
{
	var() name		BoneName;
	var() vector	Offset;
	var() float		Radius;
	var() int		bBlockKarma;
	var() int		bBlockNonZeroExtent;
	var() int		bBlockZeroExtent;
};

struct native MEPBonePrimBox
{
	var() name		BoneName;
	var() vector	Offset;
	var() vector	Radii;
	var() int		bBlockKarma;
	var() int		bBlockNonZeroExtent;
	var() int		bBlockZeroExtent;
};


var const pointer WBrowserAnimationPtr;
var(Mesh) vector			 Scale;
var(Mesh) vector             Translation;
var(Mesh) rotator            Rotation;
var(Mesh) vector             MinVisBound;
var(Mesh) vector			 MaxVisBound;
var(Mesh) vector             VisSphereCenter;
var(Mesh) float              VisSphereRadius;

var(Redigest) int            LODStyle; //Make drop-down box w. styles...
var(Animation) MeshAnimation DefaultAnimation;

var(Skin) array<Material>					Material;

// To be implemented: - material order specification to re-sort the sections (for multiple translucent materials )
// var(RenderOrder) array<int>					MaterialOrder;
// To be implemented: - originalmaterial names from Maya/Max
// var(OriginalMaterial) array<name>			OrigMat;

var(LOD) float				LOD_Strength;
var(LOD) array<LODLevel>	LODLevels;
var(LOD) float				SkinTesselationFactor;

// Collision cylinder: for testing/preview only, not saved with mesh (Actor property !)
var(Collision) float TestCollisionRadius;	// Radius of collision cyllinder.
var(Collision) float TestCollisionHeight;	// Half-height cyllinder.

var(Collision) array<MEPBonePrimSphere>		CollisionSpheres;		// Array of spheres linked to bones
var(Collision) array<MEPBonePrimBox>		CollisionBoxes;			// Array of boxes linked to bones
var(Collision) StaticMesh					CollisionStaticMesh;	// Optional static mesh used for traces.

var(Attach) array<AttachSocket>   Sockets;  // Sockets, with or without adjustment coordinates / bone aliases.
var(Attach) bool  ApplyNewSockets;			// Explicit switch to apply changes 
var(Attach) bool  ContinuousUpdate;			// Continuous updating (to adjust socket angles interactively)

var(Impostor) bool      bImpostorPresent;
var(Impostor) Material  SpriteMaterial;
var(Impostor) vector    Scale3D;
var(Impostor) rotator   RelativeRotation;
var(Impostor) vector    RelativeLocation;
var(Impostor) color     ImpColor;           // Impostor base coloration.
var(Impostor) EImpSpaceMode  ImpSpaceMode;   
var(Impostor) EImpDrawMode   ImpDrawMode;
var(Impostor) EImpLightMode  ImpLightMode;

defaultproperties
{
     Scale=(X=1.000000,Y=1.000000,Z=1.000000)
     LODStyle=10
     SkinTesselationFactor=1.000000
     Scale3D=(X=1.000000,Y=1.000000,Z=1.000000)
     ImpSpaceMode=ISM_PivotVertical
}
