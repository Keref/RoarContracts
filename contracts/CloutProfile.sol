// contracts/CloutProfile.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract CloutProfile is ERC20 {
	using SafeMath for uint256;
	
	//Owner
	address public owner;
	
	//Owner @username // not to conflict with ERC20 default var name 
	string public username;
	
	//Owner description
	string  public description;
	
	//Owner stock reward in hundredth percent
	uint256 public founderReward = 1000; //= 10%
	
	//Shareholders dividends share in hundredth percent
	uint256 public shareholdersShare = 1000;
	
	//Lifetime dividends
	uint256 public lifetimeDividends = 0;
	
	event ReceivedPayment(uint256 value, bool sharedDividends);
	
	event StockBought(uint256 value, uint256 amount, address buyer );
	event StockSold(uint256 value, uint256 amount, address seller );
	
	modifier onlyOwner(){
		require( owner == msg.sender, "Unauthorized action" );
		_;
	}

    constructor(string memory _name, address _owner) 
		ERC20(_name, _name)
	{
		owner = _owner;
		username = _name;
    }
	
	
	
	/**
     * @dev Set the profile name.
     */
    function setProfileName(string memory _name) 
		public 
		onlyOwner
	{
		username = _name;
    }
		
		
	/**
     * @dev Set the profile information.
     */
    function setProfileDesc(string memory _description) 
		public 
		onlyOwner
	{
		description = _description;
    }	
	
	
	/**
     * @dev Set profile owner address.
     */
	function setOwnerAddress(address newOwner)
		public 
		onlyOwner
	{
		owner = newOwner;
	}
	
	
	// Payments 
	
	/**
	 * @dev Receive a payment and sends it to the profile owner
	 */ 
	function receivePayment()
		public payable
	{
		payable(owner).transfer( msg.value );
		emit ReceivedPayment(msg.value, false);
	}
	
	
	/**
	 * @dev Receive a payment and distribute a share to stockholders if any
	 */ 
	function receivePaymentAndShareDividends()
		external payable
	{
		if ( totalSupply() == 0 ) return receivePayment();
	
		uint256 shDividends = msg.value.mul(shareholdersShare).div(10000);
		uint256 shFounder = msg.value.sub(shDividends);
		
		lifetimeDividends = lifetimeDividends.add(shDividends);
		
		payable(owner).transfer( shFounder );
		emit ReceivedPayment(msg.value, true);
	}
	

	
	
	
	
	/**
	 * @dev Buy stock by sending Eth to the contract.
	 * User gets current stock price minus 10% to make the stock value increase on buying
	 */ 
	function buyStock()
		external payable
		returns (uint256 amountBought)
	{
		if (msg.value == 0 ) return 0;
		
		uint256 founderValue = msg.value.mul(founderReward).div(10000);
		uint256 buyerValue = msg.value.sub(founderValue);
		
		payable(owner).transfer(founderValue);
		//rest of the money stays in the smart contract as balance for the bonding curve

		//ratio would be fixed arbitrarily in a pure bonding curve, but will change as dividends are disitrbuted.
		// ratio = 100 if no outstanding shares, else, recalculate
		//ratio = totalValue / supply^2 
		//cant use floats, so work with 10^18th but need to mult the total value by 10**18 to account for the denominator square
		//ratio = 10^18 * totalValue / supply^2
		//since ratio is same before and after allocation, buying twice tokens, or once same total amount returns same amount of tokens
		
		uint256 beforeSupply = totalSupply();
		uint256 beforeValue = address(this).balance.sub(buyerValue).mul(10**22); //10**18 for eth precision, * 10^4 for cheaper stock price (sqrt influence)
		uint256 beforeSupplySquare = beforeSupply.mul(beforeSupply);
		
		uint256 ratio = 100; //default ratio if no outstanding shares
		if ( beforeSupplySquare > 0 ) ratio = beforeValue.div(beforeSupplySquare);

		//supply^2 =  totalValue * 10^18 / ratio
		uint256 afterSupplySquare = address(this).balance.mul(10**22).div(ratio);	

		uint256 _amountBought = sqrt(afterSupplySquare);
		_mint(msg.sender, _amountBought);
		
		emit StockBought( buyerValue, _amountBought, msg.sender );
		
		return _amountBought;
	}
	
	function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
	
	
	/**
	 * @dev Sell stock
	 * What you get is exactly the current stock price, no bonding curve on way down as it couldnt account for accrued dividends
	 * Also that would incentivize people to sell quickly when stock is high and make unsustainable ponzi games
	 */ 
	function sellStock(uint256 amountSold)
		external 
		returns (uint256 valueSold)
	{
		if (amountSold == 0) return 0;
		
		uint256 beforeSupply = totalSupply();
		require ( beforeSupply >= amountSold , "ProfileStock: Insufficient funds");
		
		uint256 beforeValue = address(this).balance.mul(10**22); 
		uint256 beforeSupplySquare = beforeSupply.mul(beforeSupply);
		
		uint256 ratio = beforeValue.div(beforeSupplySquare);

		uint256 afterSupply = beforeSupply.sub(amountSold);
		uint256 afterSupplySquare = afterSupply.mul(afterSupply);
		//ratio = totalValue / supply^2 
		uint256 afterValue = ratio.mul(afterSupplySquare);

		uint256 _valueSold = beforeValue.sub(afterValue).div(10**22);
		
		_burn(msg.sender, amountSold);
		payable(msg.sender).transfer (_valueSold );
		
		emit StockSold( _valueSold, amountSold, msg.sender );
		
		return _valueSold;
	}
	
	
	//Default receiving eth functions
	// Function to receive Ether. msg.data must be empty
    receive() external payable {}
    fallback() external payable {}


	
	
	/// From https://ethereum.stackexchange.com/questions/2910/can-i-square-root-in-solidity and hifi.finance github
	/// @notice Calculates the square root of x, rounding down.
	/// @dev Uses the Babylonian method https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method.
	/// @param x The uint256 number for which to calculate the square root.
	/// @return result The result as an uint256.
	function sqrt(uint256 x) internal pure returns (uint256 result) {
		if (x == 0) {
			return 0;
		}

		// Calculate the square root of the perfect square of a power of two that is the closest to x.
		uint256 xAux = uint256(x);
		result = 1;
		if (xAux >= 0x100000000000000000000000000000000) {
			xAux >>= 128;
			result <<= 64;
		}
		if (xAux >= 0x10000000000000000) {
			xAux >>= 64;
			result <<= 32;
		}
		if (xAux >= 0x100000000) {
			xAux >>= 32;
			result <<= 16;
		}
		if (xAux >= 0x10000) {
			xAux >>= 16;
			result <<= 8;
		}
		if (xAux >= 0x100) {
			xAux >>= 8;
			result <<= 4;
		}
		if (xAux >= 0x10) {
			xAux >>= 4;
			result <<= 2;
		}
		if (xAux >= 0x8) {
			result <<= 1;
		}

		// The operations can never overflow because the result is max 2^127 when it enters this block.
		unchecked {
			result = (result + x / result) >> 1;
			result = (result + x / result) >> 1;
			result = (result + x / result) >> 1;
			result = (result + x / result) >> 1;
			result = (result + x / result) >> 1;
			result = (result + x / result) >> 1;
			result = (result + x / result) >> 1; // Seven iterations should be enough
			uint256 roundedDownResult = x / result;
			return result >= roundedDownResult ? roundedDownResult : result;
		}
	}
}