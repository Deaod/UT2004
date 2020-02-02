// ====================================================================
//  Class:  XWeapons.HitScanBlockingVolume
//  Parent: Engine.BlockingVolume
//
//  Used to limit where hit-scan weapons
// ====================================================================

class HitScanBlockingVolume extends BlockingVolume;

defaultproperties
{
     bWorldGeometry=False
     bBlockZeroExtentTraces=True
}
