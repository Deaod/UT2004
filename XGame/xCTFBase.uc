//=============================================================================
// xCTFBase.
// For decoration only, this actor serves no game-related purpose!
//=============================================================================
class xCTFBase extends Decoration
	notplaceable;

defaultproperties
{
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'XGame_rc.FlagBaseMesh'
     bStatic=False
     RemoteRole=ROLE_None
     DrawScale=0.400000
     PrePivot=(X=-5.000000)
     bObsolete=True
}
