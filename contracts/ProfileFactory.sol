// contracts/ProfileFactory.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Profile.sol";

contract ProfileFactory {
    event ProfileCreated(address payable profileAddress);
	//Change name event
	event ProfileRenamed(string oldName, string newName);

	//Registered profiles by name
	mapping (string => address payable) public profiles;
	
	
	
    function deployNewProfile(string memory name) public returns (address profileAddress) {
		require ( profiles[name] == payable(0) );
		
        Profile cp = new Profile(name, msg.sender, address(this));
		profiles[name] = payable(cp);
        emit ProfileCreated(payable(cp));
		return payable(cp);
    }
	
	function getProfile( string memory name )
		public view
		returns (address payable profileAddress)
	{
		return profiles[name];
	}
	
	function changeProfileName ( string memory oldName, string memory newName )
		public
		returns (string memory name)
	{
		require ( profiles[newName] == address(0), "Name already taken" );
		profiles[newName] = profiles[oldName];
		profiles[oldName] = payable(0);
		
		Profile cp = Profile(profiles[newName]);
		cp.setProfileName(newName);
		
		emit ProfileRenamed(oldName, newName);
		
		return newName;
	}
}