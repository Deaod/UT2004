// ====================================================================
//  Class:  xVoting.MapVoteHistory_INI
//
//	Used to save map stats/history data to an ini file. Subclasses  
//
//  Written by Bruce Bickar
//  (c) 2002, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class MapVoteHistory_INI extends MapVoteHistory DependsOn(VotingHandler) 
	  Config(MapVoteHistory) PerObjectConfig;

var config array<VotingHandler.MapHistoryInfo> H;  // array used to store map data
var config int    LastMapIndex;
var bool bUpdated;
//------------------------------------------------------------------------------------------------
function AddMap(VotingHandler.MapHistoryInfo MapInfo)
{
   local int x;

   if(MapInfo.M == "")
      return;

   bUpdated = true;

   if(LastMapIndex == -1)  // brand new list
   {
      H.Insert(0,1);
      H[0].M = MapInfo.M;    // add new map
      H[0].P = 0;            
      H[0].S = 0;            
      H[0].G = MapInfo.G;
      H[0].U = MapInfo.U;
      LastMapIndex = 0;
      return;
   }

   // search list for map
   for(x=0; x<=LastMapIndex; x++)
   {
      if(MapInfo.M ~= H[x].M)  // found map
      {
         H[x].G = MapInfo.G;
         H[x].U = MapInfo.U;
         return;
      }

      if(Caps(H[x].M) > Caps(MapInfo.M))  // MapName is not in array and should be inserted here
      {
         H.Insert(x,1);
         LastMapIndex++;
         H[x].M = MapInfo.M; 
         H[x].P = 0;         
         H[x].S = 0;         
         H[x].G = MapInfo.G;
         H[x].U = MapInfo.U;
         return;
      }
   }

   // didnt find insertion point so add at end
   LastMapIndex++;
   H.Insert(LastMapIndex,1);
   H[LastMapIndex].M = MapInfo.M; 
   H[LastMapIndex].P = 0;         
   H[LastMapIndex].S = 0;         
   H[LastMapIndex].G = MapInfo.G;
   H[LastMapIndex].U = MapInfo.U;
   return;
}
//------------------------------------------------------------------------------------------------
function VotingHandler.MapHistoryInfo PlayMap(string MapName)
{
   local int x,y;
   local bool bFound;
   local VotingHandler.MapHistoryInfo MapInfo;

   if(MapName == "")
      return MapInfo;

   bUpdated = true;

   if(LastMapIndex > H.Length - 1)
      LastMapIndex = H.Length - 1;

   if(LastMapIndex == -1)  // brand new list
   {
      H.Insert(0,1);
      H[0].M = MapName;    // add new map
      H[0].P = 1;
      H[0].S = 1;
      H[0].G = "";
      H[0].U = "";
      LastMapIndex = 0;
      MapInfo = H[0];
      return MapInfo;
   }

   bFound = false;
   for(x=0; x<=LastMapIndex; x++)
   {
      if(MapName ~= H[x].M)  // found map
      {
         H[x].S=1; // Set sequence (last 1 map played)
         H[x].P++; // increment Play count
         MapInfo = H[x]; // save data to return to caller
         bFound=true;
      }
      else
      {
         if(H[x].S > 0)  // -1 indicates not to every play this map, 0 is a map that has never been played
            H[x].S++;  // increment the sequence of all maps to make room for # 1
      }

      if(Caps(H[x].M) > Caps(MapName) && !bFound)  // MapName is not in array and should be inserted here
      {
         H.Insert(x,1);
         LastMapIndex++;
         for(y=LastMapIndex; y>x; y--)  
         {
            if(H[y].S > 0) 
               H[y].S++;
         }
         H[x].M = MapName;    // add new map
         H[x].P = 1;
         H[x].S = 1;
         H[x].G = "";
         H[x].U = "";
         MapInfo = H[x];
         return MapInfo;
      }
   }

   if(!bFound) // didnt find insertion point so add at end
   {
      LastMapIndex++;
      H.Insert(LastMapIndex,1);
      H[LastMapIndex].M = MapName;
      H[LastMapIndex].P = 1;
      H[LastMapIndex].S = 1;
      H[LastMapIndex].G = "";
      H[LastMapIndex].U = "";
      MapInfo = H[LastMapIndex];
   }
   return MapInfo;
}
//------------------------------------------------------------------------------------------------
function VotingHandler.MapHistoryInfo GetMapHistory(string MapName)
{
   local int Index;
   local VotingHandler.MapHistoryInfo MapInfo;

   Index = FindIndex(MapName);
   if(Index > -1 && Index < H.Length)
   {
      MapInfo = H[Index];
   }
   return MapInfo;
}
//------------------------------------------------------------------------------------------------
function Save()
{
   if(bUpdated)
      SaveConfig();
   bUpdated = false;
}
//------------------------------------------------------------------------------------------------
function RemoveOldestMap()
{
  local int x,Lowest;

  bUpdated = true;

  // scan the list for the oldest played map
  Lowest = 1;
  for(x=2; x<=LastMapIndex; x++)
  {
     if(H[x].S < H[Lowest].S)
        Lowest = x;
  }
  RemoveMapByIndex(Lowest);
}
//------------------------------------------------------------------------------------------------
function RemoveMap(string MapName)
{
   local int Index;

   bUpdated = true;
   
   Index = FindIndex(MapName);
   if(Index > 0)
      RemoveMapByIndex(Index);
}
//------------------------------------------------------------------------------------------------
function RemoveMapByIndex(int Index)
{
  bUpdated = true;

  H.Remove(Index,1);
  LastMapIndex--;
}
//------------------------------------------------------------------------------------------------
function int FindIndex(string MapName)
{
   local int a,b,i;

   // speedy way to find the map if it alread exists
   //a               7                           b
   //12345678901234568901234567890123456789012345
   //|----------|----------|----------|----------|
   //1                     <                       too high
   //2---------------------b                       b = ((b - a)/2) + a
   //3          >                                  too low
   //4          a----------b                       a = ((b - a)/2) + a
   //7               <                             too high
   //8          a----b                             b = ((b - a)/2) + a
   //9            >                                too low
   //10           a--b                             a = ((b - a)/2) + a
   //11            >                               too low
   //12            a-b
   //13             >                              too low
   //14             ab
   //15             >                              too low
   //16             b                              a==b

   if(LastMapIndex == -1)
      return(-1);

   a = 1;
   b = LastMapIndex+1;

   while(true)
   {
      i = ((b-a)/2)+a;
      if(H[i-1].M ~= MapName)  // check for a match
         return(i-1); // found

      if(a == b) // Not found
         return(-1);

      if(Caps(H[i-1].M) > Caps(MapName))  //check mid-way
         b = i;    // too high
      else
      {
         if(a == i)
            a = b;
         else
            a = i;    // too low
      }
   }
}
//------------------------------------------------------------------------------------------------
function Swap(int a,int b)
{
   local VotingHandler.MapHistoryInfo MapInfo;

   MapInfo = H[a];
   H[a]    = H[b];
   H[b]    = MapInfo;
}
//------------------------------------------------------------------------------------------------

defaultproperties
{
     LastMapIndex=-1
}
