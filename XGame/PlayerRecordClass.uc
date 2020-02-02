class PlayerRecordClass extends Object
	abstract
	dependsOn(xUtil);

/* 
PLAYERRECORDCLASS
Use PlayerRecordClass to push down player skins and meshes from the server.
For example, if the Reaper clan was running a server, and had their own clan skin, in ReaperSkin.utx, here's what they'd need to do:

Create a new ReaperMod.u file, with the class Reaper in it.  The package name must be the class name with "mod" appended.  Reaper is a subclass of PlayerRecordClass, with
all the default properties set appropriately to setup up the character. Clan members will have to edit their user.ini file,
to change their character in the [DefaultPlayer] section, or have a .upl file with the same character definition.

The server will need to have both ReaperSkin and ReaperMod in its serverpackages.
*/

var() class<SpeciesType>        Species;                // Species
var() String                    MeshName;               // Mesh type
var() String                    BodySkinName;           // Body texture name
var() String                    FaceSkinName;           // Face texture name
var() Material                  Portrait;               // Menu picture
var() String                    TextName;               // Decotext reference
var() String                    VoiceClassName;         // voice pack class name - overrides species default
var() string					Sex;
var() string					Menu;					// info for menu displaying characters	
var() string					Skeleton;				// skeleton mesh, if it differs from the species default		
var() string				    Ragdoll;

simulated static function xUtil.PlayerRecord FillPlayerRecord()
{
	local xUtil.PlayerRecord PRE;
	
	PRE.Species = Default.Species;
	PRE.MeshName = Default.MeshName;
	PRE.BodySkinName = Default.BodySkinName;
	PRE.FaceSkinName = Default.FaceSkinName;
	PRE.Portrait = Default.Portrait;
	PRE.TextName = Default.TextName;
	PRE.VoiceClassName = Default.VoiceClassName;
	PRE.Sex = Default.Sex;
	PRE.Menu = Default.Menu;
	PRE.Skeleton = Default.Skeleton;
	PRE.Ragdoll = Default.Ragdoll;
	return PRE;
}

defaultproperties
{
}
