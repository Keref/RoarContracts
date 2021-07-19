// contracts/CloutProfileFactory.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./CloutProfile.sol";

contract CloutProfileFactory {
    event ProfileCreated(address payable profileAddress);

	//Registered profiles by name
	mapping (string => address payable) public profiles;
	
	
    function deployNewProfile(string memory name) public returns (address profileAddress) {
		require ( profiles[name] == payable(0) );
		
        CloutProfile cp = new CloutProfile(name, msg.sender);
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
		
		CloutProfile cp = CloutProfile(profiles[newName]);
		cp.setProfileName(newName);
		
		return newName;
	}
}