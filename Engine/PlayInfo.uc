class PlayInfo extends object
	native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

enum EPlayInfoType
{
	PIT_Check,
	PIT_Select,
	PIT_Text,
	PIT_Custom
};

struct native init PlayInfoData
{
	var const Property         ThisProp;    // Pointer to property
	var const class<Info>      ClassFrom;   // Which class was this Property from
	var const string           SettingName; // Name of the class member
	var const string           DisplayName; // Display Name of the control (from .INT/.INI File ?)
	var const string           Description; // Description of what the property does
	var const string           Grouping;    // Grouping for this parameter
	var const string           Data;        // Extra Data (like Gore Level Texts)
	var const string           ExtraPriv;   // Extra Privileges Required to set this parameter
	var const string           Value;       // Value of the setting
	var const EPlayInfoType    RenderType;  // Type of rendered control
	var const byte             SecLevel;    // Sec Level Required to set this param. (Read from Ini file afterwards)
	var const byte             Weight;      // Importance of the setting compared to others in its group
	var const bool             bMPOnly;     // This setting should only appear in multi-player context
	var const bool             bAdvanced;   // This setting is an advanced property (only displayed when user sets bExpertMode in GUIController)

	// Internal flags (set natively)
	var const bool             bGlobal;     // globalconfig property
	var const bool             bStruct;		// Property is a struct
	var const int              ArrayDim;    // -1: Not array, 0: dynamic array,  >1: Static array
};

var const array<PlayInfoData>	Settings;
var const array<class<Info> >	InfoClasses;
var const array<int>			ClassStack;
var const array<string>			Groups;
var const string				LastError;

native(700) final function bool Clear();
native(701) final function bool AddClass(class<Info> AddingClass);
native(702) final function bool RemoveClass(class<Info> RemovingClass);
native(703) final function bool PopClass();
native(704) final function bool AddSetting(string Group, string PropertyName, string Description, byte SecLevel, byte Weight, string RenderType, optional string Extras, optional string ExtraPrivs, optional bool bMultiPlayerOnly, optional bool bAdvanced);
native(705) final function bool SaveSettings();	// Saves stored settings to ini file
native(706) final function bool StoreSetting(int index, coerce string NewVal, optional string RangeData);	// Only validates and sets Settins[index].Value to passed value
native(707) final function bool GetSettings(string GroupName, out array<PlayInfoData> GroupSettings);	// rjp
native(708) final function int  FindIndex(string SettingName);

// 0 = Grouping, 1 = Weight, 2 = RenderType, 3 = DisplayName, 4 = SettingName, 5 = SecLevel
// 6 = RevGroup, 1 = RevWeight, etc.
// Equal items will be sorted by the next highest type
native(709) final function Sort(byte SortingMethod);

final function Dump( optional string group )
{
local int i;
	log("** Dumping settings array for PlayInfo object '"$Name$"' **");

	log("** Classes:"@InfoClasses.Length);
	for ( i = 0; i < InfoClasses.Length; i++ )
		log("   "$i$")"@InfoClasses[i].Name);
	log("");

	log("** Groups:"@Groups.Length);
	for (i = 0; i < Groups.Length; i++)
		log("   "$i$")"@Groups[i]);
	log("");

	Log("** Settings:"@Settings.Length);
	for (i = 0; i<Settings.Length; i++)
	{
		if ( group == "" || group ~= Settings[i].Grouping )
		{
			Log(i$")"@Settings[i].SettingName);
			log("            DisplayName:"@Settings[i].DisplayName);
			log("              ClassFrom:"@Settings[i].ClassFrom);
			log("                  Group:"@Settings[i].Grouping);
			log("                  Value:"@Settings[i].Value);
			log("                   Data:"@Settings[i].Data);
			log("                 Weight:"@Settings[i].Weight);
			log("                 Struct:"@Settings[i].bStruct);
			log("                 Global:"@Settings[i].bGlobal);
			log("                 MPOnly:"@Settings[i].bMPOnly);
			log("               SecLevel:"@Settings[i].SecLevel);
			log("               ArrayDim:"@Settings[i].ArrayDim);
			log("              bAdvanced:"@Settings[i].bAdvanced);
			log("              ExtraPriv:"@Settings[i].ExtraPriv);
			log("             RenderType:"@GetEnum(enum'EPlayInfoType',Settings[i].RenderType));
			log("");
		}
	}
}

// Specify bStrict to purge any secondary classes from the Classes stack
final function bool Init(array<class<Info> > Classes, optional bool bStrict)
{
	local int i, j;
	local bool b;

	if (Classes.Length == 0)
		return b;

	b = True;

	Clear();
	for (i = 0; i < Classes.Length; i++)
	{
		if (Classes[i] == None)
		{
			log("Call in PlayInfo.Init() with 'None' value for Class array member.  Index:"$i);
			Classes.Remove(i--, 1);
			continue;
		}
		Classes[i].static.FillPlayInfo(Self);
	}

	if ( bStrict )
	{
		for ( i = InfoClasses.Length - 1; i >= 0; i-- )
		{
			for (j = 0; j < Classes.Length; j++)
				if (InfoClasses[i] == Classes[j])
					break;

			if (j < Classes.Length)
				continue;

			b = b && RemoveClass(InfoClasses[i]);
		}
	}

	return b;
}

final function class<GameInfo> GetGameInfo()
{
	local int i;
	for ( i = 0; i < InfoClasses.Length; i++ )
		if ( class<GameInfo>( InfoClasses[i] ) != None )
			return class<GameInfo>(InfoClasses[i]);

	return None;
}

final function SplitStringToArray(out array<string> Parts, string Source, string Delim)
{
	Split(Source, Delim, Parts);
}

defaultproperties
{
}
