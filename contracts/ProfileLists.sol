// contracts/ProfileLists.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


/**
 * Lists allow a user to add a profile to some personal list
 */
contract ProfileLists {
	event AddedToList(address profileAddress, uint256 listId, address follower);
	event RemovedFromList(address profileAddress, uint256 listId, address follower);
	event CreatedList(string name, uint256 listId);
	
	address private _owner;
	address private _profileFactory;
	

	
	mapping (address => uint256) public followers;
	mapping (address => uint256) public following;
	
	ProfileList[] public profileLists;
	address[] public listOwner;
	
	
	
	struct ProfileList {
		string name;
		address[] profiles;
		mapping ( address => uint256 ) profileIndex;
	}

	constructor ( ) {
		_owner = msg.sender;
		//push dummy first element
		profileLists.push().name = "First List";
		listOwner.push(msg.sender);
	}
	
	
	/**
	 * @dev Create a new list
	 */
	function createList (string memory name)
		public
		returns (uint256)
	{
		profileLists.push().name = name;
		listOwner.push(msg.sender);
		
		emit CreatedList (name, profileLists.length - 1 );
		
		return profileLists.length - 1;
	}
	
	
	/**
	 * @dev Get list real id based on given Id, creating the list if necessary
	 */
	function getListIndex(uint256 id)
		private
		returns (uint256 listId)
	{
		require ( id < profileLists.length, "Out of bound list ID.");
		if ( id > 0 ) return id;
		
		uint256 folListIndex = following[msg.sender];
		if ( folListIndex > 0 ){
			return folListIndex;
		}
		else {
			//create new personal following list
			uint256 myListIndex = createList("");
			following[msg.sender] = myListIndex;
			return myListIndex;
		}
	}
	
	
	///Getter for the struct
	function getList ( uint256 id )
		public view
		returns (string memory name, address[] memory profileAddresses )
	{
		return ( profileLists[id].name, profileLists[id].profiles );
	}
	
	
	
	
	/**
	 * @dev Add follower to a list
	 * @param profileAddress - address of profile followed 
	 * @param listId - list to which follower is added, adds to personal following list if 0
	 */ 
	function addFollower (address profileAddress, uint256 listId )
		public
	{
		uint256 listIndex = getListIndex(listId);
		
		ProfileList storage pl = profileLists[listIndex];

		require ( pl.profileIndex[profileAddress] == 0, "Already following");
		//edge case where address would be the first one and therefore index would be 0 despite being already in list
		if ( pl.profiles.length > 0 ) require ( pl.profiles[0] != profileAddress, "Already following.");

		pl.profiles.push(profileAddress);
		pl.profileIndex[profileAddress] = pl.profiles.length - 1;
		
		//keep follower count if personal list otherwise can cheat by adding user to many lists
		if ( listId == 0 ) followers[profileAddress] = followers[profileAddress] + 1;
		
		emit AddedToList(profileAddress, listIndex, msg.sender);
	}
	
	
	
	/**
	 * @dev Remove follower from a list
	 * @param profileAddress - address of profile  
	 * @param listId - list to which follower is removed, personal following list if 0
	 */ 
	function removeFollower ( address profileAddress, uint256 listId )
		public
	{
		require ( listId < profileLists.length, "List id doesn't exist (too big).");

		uint256 listIndex = listId;
		if ( listId == 0 ) listIndex = following[msg.sender];
		require ( listIndex > 0, "List id doesn't exist." );
		require ( msg.sender == listOwner[listIndex], "Unauthorized to remove from list");
		
		ProfileList storage pl = profileLists[listIndex];
		

		uint256 followingIndex = pl.profileIndex[profileAddress];
		if ( followingIndex > 0 || pl.profiles[0] == profileAddress ){
			pl.profileIndex[profileAddress] = 0;
			
			//removing from array: if last element just pop(), otherwise put last element in place
			if ( followingIndex == pl.profiles.length - 1 ){
				pl.profiles.pop();
			}
			else {
				address lastProfile = pl.profiles[ pl.profiles.length - 1 ];
				pl.profiles[followingIndex] = lastProfile;
				pl.profiles.pop();
				pl.profileIndex[lastProfile] = followingIndex;
			}
		}
	}
	
	

}