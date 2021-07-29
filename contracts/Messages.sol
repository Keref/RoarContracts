// contracts/Messages.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
//import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./Profile.sol";

//import "./TypedMessage.sol";

contract Messages is ERC721 {

	// Mapping from token ID to message Struct
	mapping (string => address ) public _messageTypes;
	// Mapping from token ID to owner address
    mapping (uint256 => address payable) public owners;
	// Mapping from token ID to creator address
    mapping (uint256 => address payable) public creators;
	// Mapping owner address to token count
    mapping (address => uint256) public _balances;
	// Mapping owner address to message list
	mapping (address => uint256[] ) public profileMessages;
	
	Msg[] public messages;
	
    event MessagePublished(uint256 messageId);
    event CommentPublished(uint256 messageId, uint256 replyToId);
	/**
     * @dev Checks that message sender has a profile.
     */
	modifier onlyRegisteredProfile(address payable profileAddress){
		Profile cp = Profile(profileAddress);
		address pa = cp.owner();
		require( pa == msg.sender, "Invalid Profile" );
		_;
	}
	
	//default message interaction for all publications
	string[] private _defaultMessageInteractions = ["like", "tips"];
	
	struct Msg {
		bool isEditable;
		bool isPrivate;
		
		uint256 replyToId;
		
		string messageType;
		string message;
		
		string[] plugins;
		string[] interactions;
		uint256[] comments;
	}
	

	
	

    constructor() ERC721("Messages", "Msg")
	{
		//reserved types
		//_messageTypes[ "tweet" ] = address()
	}
	
	
	
	//// Publication functions
	
	
	/**
     * @dev Creates a new ERC721 Typed Message.
     */
	function publishTypedMessage(address payable profileAddress, uint256 replyToId, string memory message, string memory messageType, string[] memory extra)
		onlyRegisteredProfile(profileAddress)
		public
		returns (uint256 newMessageId)
	{
		Msg memory p;
		if ( replyToId > 0) p.replyToId = replyToId;
		p.messageType = messageType;
		p.message = message;
		p.interactions = _defaultMessageInteractions;
		
		uint256 messageId = messages.length;
		messages.push(p);
		
		//assign
		_balances[profileAddress] += 1;
        owners[messageId] = profileAddress;
        creators[messageId] = profileAddress;
		
		profileMessages[profileAddress].push(messageId);
		
		//if replyToId then link comment in original message
		if ( replyToId > 0 ){
			messages[replyToId].comments.push(messageId);
			emit CommentPublished(messageId, replyToId);
		}
		else 
			emit MessagePublished(messageId);
			
		return messageId;
	}
	
	
	/**
     * @dev Creates a new ERC721 default Message.
     */
	function publishMessage(address payable profileAddress, uint256 replyToId, string memory message)
		public
		returns (uint256 messageId)
	{
		string[] memory p;
		return publishTypedMessage(profileAddress, replyToId, message, "tweet", p);
	}
	
	
    /**
     * @dev Retweet a post: add messageId to own message list independently of owner/creator.
     */
    function retweet(address payable profileAddress, uint256 messageId) 
		onlyRegisteredProfile(profileAddress)
		public
	{
		require ( profileAddress != owners[messageId], "Can't retweet own messages" );
		profileMessages[profileAddress].push(messageId);
	}
	
	
	
	//// Retrieval functions

	/**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256)
	{
		return messages.length;
	}

	
    /**
     * @dev Returns a message by ID.
     */
    function getMessage(uint256 index) 
		external view 
		returns (
			uint256 messageId, 
			string memory ownerName, 
			string memory messageURI, 
			uint256 replyToId, 
			uint256[] memory comments, 
			string[] memory interactions
		)
	{
		Msg memory p = messages[index];
		
		Profile cp = Profile(owners[index]);
		string memory profileName = cp.username();
		
		return (index, profileName, p.message, p.replyToId, p.comments, p.interactions);
	}
	
	
	
    /**
     * @dev Returns a profile message list.
     */
    function getProfileMessages(address profile) 
		external view 
		returns (uint256[] memory profileMsg )
	{
		return profileMessages[profile];
	}
	

	


	//// Message types management
	
	/**
	 * @dev Update a message type target contract
	 * For security, this has to be called by the old contract
	 */
	function updateMessageTypeAddress(address _add)
		public
	{
		//require()
	}

}