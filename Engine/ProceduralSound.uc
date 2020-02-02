// gam ---
class ProceduralSound extends Sound
    native
	hidecategories(Object)
    noexport;

var(Sound) Sound BaseSound;

var(Sound) float PitchModification;
var(Sound) float VolumeModification;

var(Sound) float PitchVariance; 
var(Sound) float VolumeVariance;

var transient float RenderedPitchModification;
var transient float RenderedVolumeModification;

defaultproperties
{
}
