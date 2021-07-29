// contracts/Messages.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./Profile.sol";
import "./Messages.sol";

contract InteractionTips {
	using SafeMath for uint256;
	
	address private _owner;
	address private _messagesContract;
	address private _profileFactory;
	
	uint256 private _feeCreatorInHundredthPercents = 100; //1%
	uint256 private _feeTippingInHundredthPercents = 10; //0.1%
	//total 98.9 percent to owner, 1% to creator, 0.1% to tipping plugin and token holders
	
	mapping (uint256  => Tips) private _tips;
	
	event TippedProfile(address profileAddress);
	
	struct Tips {
		uint256 total;
		uint256[] tippers;
		uint256[] tippersAmount;
	}

	constructor (address messageContract, address profileFactory ) {
		_owner = msg.sender;
		_messagesContract = messageContract;
		_profileFactory = profileFactory;
	}
	

	function getTips(uint256 index)
		public view
		returns ( uint256 total, uint256[] memory tippers, uint256[] memory tippersAmount )
	{
		return ( _tips[index].total, _tips[index].tippers, _tips[index].tippersAmount );
	}

	
	/**
	 * @dev Sends tip to message owner and creator, while keeping a fee
	 */ 
	function sendTip (uint256 index) 
		public payable
	{
		require ( msg.value > 0 , "Not enough tip sent");
		//check that message allows tips should be done at interface level as it's gas consuming to check array of plugins
		Messages msgs = Messages(_messagesContract);

		uint256 creatorTip = msg.value.mul(_feeCreatorInHundredthPercents).div(10000);
		uint256 ownerShare = uint256(10000).sub(_feeCreatorInHundredthPercents).sub(_feeTippingInHundredthPercents);
		uint256 ownerTip = msg.value.mul(ownerShare).div(10000);

		//accounting
		Tips storage t = _tips[index];
		t.total = t.total + msg.value;
		//sending tips
		forwardTip( msgs.owners(index), ownerTip );
		forwardTip( msgs.creators(index), creatorTip );
	}
	
	
	/**
	 * @dev sends the tip to the corresponding profile which will handle dividends
	 */
	function forwardTip(address payable profileAddress, uint256 tipValue)
		private
	{
		Profile cp = Profile(profileAddress);

		cp.receivePaymentAndShareDividends{value: tipValue}();

		emit TippedProfile(profileAddress);
	}
	
	
	
	/**
	 * @dev Withdraws all the fees
	 */ 
	function withdrawFees () 
		external 
	{
		//fees will be sent to a staking contract that locks base layer token and receives network dividends
		
	}
}