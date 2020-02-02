class MaterialFactory extends Object
	abstract
	native;

var string Description;

event Material CreateMaterial( Object InOuter, string InPackage, string InGroup, string InName );
native function ConsoleCommand(string Cmd);

defaultproperties
{
}
