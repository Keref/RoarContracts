// contracts/CloutTypedMessages.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * Netclout can accept arbitrary message types
 */
contract TypedMessages {
	//Owner
	address private _owner;
	
	//Type name 
	string private _name;
	
	//Type description
	string private _description;
	

    constructor(string memory name, string memory description, address owner) 
	{
		_owner = owner;
		_name = name;
		_description = description;
    }
	
	
	/////////////////////
	
	
	
	
	//////////////////////
	/**
     * @dev Returns the type information as JSON.
     */
    function getInfo() 
		public view 
		returns (string memory) 
	{
        return string(abi.encodePacked("{\"name\":\"", _name, "\",\"description\":\"", _description, "\"}") );
    }
		
		
	/**
     * @dev Set the profile information.
     */
    function setDescription(string memory description) 
		public 
	{
		_description = description;
    }
	

}