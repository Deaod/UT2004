//=============================================================================
// EditorEngine: The UnrealEd subsystem.
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class EditorEngine extends Engine
	native
	noexport
	transient;

#exec Texture Import File=Textures\Bad.pcx
#exec Texture Import File=Textures\BadHighlight.pcx
#exec Texture Import File=Textures\Bkgnd.pcx
#exec Texture Import File=Textures\BkgndHi.pcx
#exec Texture Import File=Textures\MaterialArrow.pcx MASKED=1
#exec Texture Import File=Textures\MaterialBackdrop.pcx

#exec NEW StaticMesh File="models\TexPropCube.Ase" Name="TexPropCube"
#exec NEW StaticMesh File="models\TexPropSphere.Ase" Name="TexPropSphere"

// Objects.
var const level       Level;
var const model       TempModel;
var const texture     CurrentTexture;
var const staticmesh  CurrentStaticMesh;
var const mesh		  CurrentMesh;
var const class       CurrentClass;
var const transbuffer Trans;
var const textbuffer  Results;
var const int         Pad[8];

// Textures.
var const texture Bad, Bkgnd, BkgndHi, BadHighlight, MaterialArrow, MaterialBackdrop;

// Used in UnrealEd for showing materials
var staticmesh	TexPropCube;
var staticmesh	TexPropSphere;

// Toggles.
var const bool bFastRebuild, bBootstrapping;

// Other variables.
var const config int AutoSaveIndex;
var const int AutoSaveCount, Mode, TerrainEditBrush, ClickFlags;
var const float MovementSpeed;
var const package PackageContext;
var const vector AddLocation;
var const plane AddPlane;

// Misc.
var const array<Object> Tools;
var const class BrowseClass;

// Grid.
var const int ConstraintsVtbl;
var(Grid) config bool GridEnabled;
var(Grid) config bool SnapVertices;
var(Grid) config float SnapDistance;
var(Grid) config vector GridSize;

// Rotation grid.
var(RotationGrid) config bool RotGridEnabled;
var(RotationGrid) config rotator RotGridSize;

// Advanced.
var(Advanced) config bool UseSizingBox;
var(Advanced) config bool UseAxisIndicator;
var(Advanced) config float FovAngleDegrees;
var(Advanced) config bool GodMode;
var(Advanced) config bool AutoSave;
var(Advanced) config byte AutosaveTimeMinutes;
var(Advanced) config string GameCommandLine;
var(Advanced) globalconfig array<string> EditPackages;
var(Advanced) globalconfig array<string> CutdownPackages;
var(Advanced) config bool AlwaysShowTerrain;
var(Advanced) config bool UseActorRotationGizmo;
var(Advanced) config bool LoadEntirePackageWhenSaving;
var(Advanced) config bool ShowIntWarnings; // gam

defaultproperties
{
     Bad=Texture'Editor.Bad'
     Bkgnd=Texture'Editor.Bkgnd'
     BkgndHi=Texture'Editor.BkgndHi'
     BadHighlight=Texture'Editor.BadHighlight'
     MaterialArrow=Texture'Editor.MaterialArrow'
     MaterialBackdrop=Texture'Editor.MaterialBackdrop'
     TexPropCube=StaticMesh'Editor.TexPropCube'
     TexPropSphere=StaticMesh'Editor.TexPropSphere'
     AutoSaveIndex=6
     GridEnabled=True
     SnapDistance=1.000000
     GridSize=(X=4.000000,Y=4.000000,Z=4.000000)
     RotGridEnabled=True
     RotGridSize=(Pitch=1024,Yaw=1024,Roll=1024)
     UseSizingBox=True
     UseAxisIndicator=True
     FovAngleDegrees=90.000000
     GodMode=True
     AutoSave=True
     AutosaveTimeMinutes=5
     GameCommandLine="-log"
     EditPackages(0)="Core"
     EditPackages(1)="Engine"
     EditPackages(2)="Fire"
     EditPackages(3)="Editor"
     EditPackages(4)="UnrealEd"
     EditPackages(5)="IpDrv"
     EditPackages(6)="UWeb"
     EditPackages(7)="GamePlay"
     EditPackages(8)="UnrealGame"
     EditPackages(9)="XGame_rc"
     EditPackages(10)="XEffects"
     EditPackages(11)="XWeapons_rc"
     EditPackages(12)="XPickups_rc"
     EditPackages(13)="XPickups"
     EditPackages(14)="XGame"
     EditPackages(15)="XWeapons"
     EditPackages(16)="XInterface"
     EditPackages(17)="XAdmin"
     EditPackages(18)="XWebAdmin"
     EditPackages(19)="Vehicles"
     EditPackages(20)="BonusPack"
     EditPackages(21)="SkaarjPack_rc"
     EditPackages(22)="SkaarjPack"
     EditPackages(23)="UTClassic"
     EditPackages(24)="UT2k4Assault"
     EditPackages(25)="Onslaught"
     EditPackages(26)="GUI2K4"
     EditPackages(27)="UT2k4AssaultFull"
     EditPackages(28)="OnslaughtFull"
     EditPackages(29)="xVoting"
     EditPackages(30)="StreamlineFX"
     EditPackages(31)="UTV2004c"
     EditPackages(32)="UTV2004s"
     CutdownPackages(0)="Core"
     CutdownPackages(1)="Editor"
     CutdownPackages(2)="Engine"
     CutdownPackages(3)="Fire"
     CutdownPackages(4)="GamePlay"
     CutdownPackages(5)="GUI2K4"
     CutdownPackages(6)="IpDrv"
     CutdownPackages(7)="UT2K4Assault"
     CutdownPackages(8)="Onslaught"
     CutdownPackages(9)="UnrealEd"
     CutdownPackages(10)="UnrealGame"
     CutdownPackages(11)="UTClassic"
     CutdownPackages(12)="UWeb"
     CutdownPackages(13)="Vehicles"
     CutdownPackages(14)="XAdmin"
     CutdownPackages(15)="XEffects"
     CutdownPackages(16)="XGame"
     CutdownPackages(17)="XGame_rc"
     CutdownPackages(18)="XInterface"
     CutdownPackages(19)="XPickups"
     CutdownPackages(20)="XPickups_rc"
     CutdownPackages(21)="XWeapons"
     CutdownPackages(22)="XWeapons_rc"
     CutdownPackages(23)="XWebAdmin"
     CutdownPackages(24)="XVoting"
     CacheSizeMegs=32
}
