class GUIMultiColumnList extends GUIVertList
	native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

struct native init MultiColumnSortData
{
	var() editconst const string SortString;	// Set by GetSortString()
	var() editconst const int    SortItem;		// Should be the index into your array for the corresponding SortString

cppstruct
{
	FMultiColumnSortData( INT InSortItem = INDEX_NONE, const TCHAR* InString = TEXT("") );
}
};

// There should always be the same number of ColumnHeadings as InitColumnPerc
var() localized array<string> ColumnHeadings;
var()           array<float>  InitColumnPerc;
var() localized array<string> ColumnHeadingHints;


// Set natively, for speed
var const array<MultiColumnSortData> SortData;      // Filled with results of GetSortString()
var const array<int>                 InvSortData;	// Used for keeping same item selected after sorting
var() const editconst array<float>             ColumnWidths;


// sorting stuff
var()          float CellSpacing;
var()          int   SortColumn; 	        // Column that is currently used for sorting ( -1 for no sorting )
var()          bool  NeedsSorting;          // Will automatically sort when this is true
var()          bool  SortDescending;        // Used by native sorting to determine which direction to sort
var()          bool  ExpandLastColumn;      // If true & columns widths do not add up to 100%, last column will be stretched


// notification
delegate OnColumnSized(int column);
native final function int GetListIndex( int YourArrayIndex );
native final function ChangeSortOrder();
native final function SortList();
native final function UpdatedItem( int YourArrayIndex );	        // should be called when we update an item's data
native final function RemovedItem( int YourArrayIndex );

// must be called when we add an item to the list.
// If your data is contained in a single array, but is represented as multiple multicolumn lists,
// pass in your array index (see UT2K4Tab_PlayerLoginControls for an example of this)
native final function AddedItem(optional int YourArrayIndex);
delegate string GetSortString( int YourArrayIndex );

function int CurrentListId()
{
	if (Index < 0)
		return -1;

	return SortData[Index].SortItem;
}

event OnSortChanged()
{
	if (SortData.Length <= 0)
		return;

	ChangeSortOrder();

	// resort list
	SortList();

	// remap the selection item back again to keep the same item selected
	if ( IsValid() )
		Index = InvSortData[Index];
}

function Clear()
{
	SortData.Remove(0,SortData.Length);
	InvSortData.Remove(0,InvSortData.Length);
	Super.Clear();
}

function RemovedCurrent()
{
	if ( IsValid() )
	{
		RemovedItem(CurrentListId());
		SetIndex(Index);
	}
}

function ResolutionChanged( int ResX, int ResY )
{
	if ( !bInit )
		bInit = True;

	Super.ResolutionChanged(ResX,ResY);
}

event InitializeColumns(Canvas C)
{
	local int i;
	local float AW;

	if ( bDebugging )
	  	log(Name@"#### InitializeColumns ActualWidth() = "@ActualWidth()@"WinWidth:"$WinWidth);

	AW = ActualWidth();
	for(i=0; i<InitColumnPerc.Length; i++)
	{
		if ( bDebugging )
			log(Name@"#### InitColumnPerc["$i$"]:"$InitColumnPerc[i]);

		ColumnWidths[i] = AW * InitColumnPerc[i];
	}
	bInit = false;
}

function bool InternalOnPreDraw(Canvas C)
{
	local float x;
	local int i;

    if (bInit)
    	return false;

	if( NeedsSorting )
	{
		SortList();
		if ( IsValid() )
			Index = InvSortData[Index];
	}

	if( ExpandLastColumn )
	{
		for( i=0;i<ColumnWidths.Length-1;i++ )
			x += ColumnWidths[i];
        ColumnWidths[i] = ActualWidth() - x;
	}

	return false;
}

function GetCellLeftWidth( int Column, out float Left, out float Width )
{
	local int i;

	Left = ClientBounds[0];

	for( i=0;i<Column && i<ColumnWidths.Length;i++ )
		Left += ColumnWidths[i];
	if( i<ColumnWidths.Length )
		Width = ColumnWidths[i];
	else
		Width = 0;

	Left += CellSpacing;
	Width -= 2*CellSpacing;

	if ( Left >= Bounds[2] )
		Width = 0;

	if (Left + Width >= Bounds[2])
		Width = Bounds[2] - Left;

	if ( Width < 0 )
		Width = 0;
}

function Sort()
{
	SortList();
}

function Dump()
{
	local int i;

	log("Dumping multicolumn list contents  '"$Name$"'");

	for ( i = 0; i < SortData.Length; i++ )
	{
		if ( i < InvSortData.Length )
			log(" " $ i $ ")" @ "'" $ SortData[i].SortString $ "'" @ SortData[i].SortItem @ "InvSortData:"$InvSortData[i]);
		else log(" " $ i $ ")" @ "'" $ SortData[i].SortString $ "'" @ SortData[i].SortItem @ "InvSortData: Invalid");
	}
}

defaultproperties
{
     CellSpacing=1.000000
     OnPreDraw=GUIMultiColumnList.InternalOnPreDraw
}
