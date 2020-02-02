class MasterServerClient extends ServerQueryClient
	native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

enum EClientToMaster
{
	CTM_Query,
	CTM_GetMOTD,
	CTM_QueryUpgrade,
    CTM_GetModMOTD,
    CTM_GetOwnageList
};

enum EQueryType
{
	QT_Equals,
	QT_NotEquals,
	QT_LessThan,
	QT_LessThanEquals,
	QT_GreaterThan,
	QT_GreaterThanEquals,
	QT_Disabled		// if QT_Disabled, query item will not be added
};

struct native export QueryData
{
	var() string Key;
	var() string Value;
	var() EQueryType QueryType;
};

enum EResponseInfo
{
	RI_AuthenticationFailed,
	RI_ConnectionFailed,
	RI_ConnectionTimeout,
	RI_Success,
	RI_MustUpgrade,
    RI_DevClient,
	RI_BadClient,
    RI_BannedClient,
    RI_UTANBan,
};

enum EMOTDResponse
{
	MR_MOTD,
	MR_MandatoryUpgrade,
	MR_OptionalUpgrade,
	MR_NewServer,
	MR_IniSetting,
	MR_Command,
};

// Internal
var native const pointer MSLinkPtr;

var int	OwnageLevel;		// The current revision for ownage maps
var int ModRevLevel;		// The current mod news revision level  -- Both returned by a MS query

var(Query) array<QueryData> Query;
var(Query) const int ResultCount;
var	string	OptionalResult;

native function StartQuery( EClientToMaster Command );
native function Stop();
native function LaunchAutoUpdate();

delegate OnQueryFinished( EResponseInfo ResponseInfo, int Info );
delegate OnReceivedServer( GameInfo.ServerResponseLine s );
delegate OnReceivedMOTDData( EMOTDResponse Command, string Value );
delegate OnReceivedModMOTDData( string Value );
delegate OnReceivedOwnageItem(int Level, string ItemName, string ItemDesc, string ItemURL);

defaultproperties
{
}
