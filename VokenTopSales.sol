pragma solidity ^0.5.8;


// Voken Top-Sales
// 
// More info:
//   https://vision.network
//   https://voken.io
//
// Contact us:
//   support@vision.network
//   support@voken.io


/**
 * @title SafeMath for uint256
 * @dev Unsigned math operations with safety checks that revert on error.
 */
library SafeMath256 {
    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
     * @dev Integer division of two unsigned integers truncating the quotient,
     * reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b > 0);
        uint256 c = a / b;
        assert(a == b * c + a % b);
        return a / b;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}


/**
 * @title Ownable
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract
     * to the sender account.
     */
    constructor () internal {
        _owner = msg.sender;
    }

    /**
     * @return The address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == _owner);
        _;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0));
        address __previousOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(__previousOwner, newOwner);
    }

    /**
     * @dev Withdraw ether
     */
    function withdrawEther(address payable to, uint256 amount) external onlyOwner {
        require(to != address(0));
        uint256 balance = address(this).balance;
        require(balance >= amount);

        to.transfer(amount);
    }

    /**
     * @dev Rescue compatible ERC20 Token
     *
     * @param tokenAddr ERC20 The address of the ERC20 token contract
     * @param receiver The address of the receiver
     * @param amount uint256
     */
    function rescueTokens(address tokenAddr, address receiver, uint256 amount) external onlyOwner {
        IERC20 __token = IERC20(tokenAddr);
        require(receiver != address(0));
        uint256 __balance = __token.balanceOf(address(this));
        
        require(__balance >= amount);
        assert(__token.transfer(receiver, amount));
    }
}


/**
 * @title ERC20 interface
 * @dev see https://eips.ethereum.org/EIPS/eip-20
 */
interface IERC20{
    function balanceOf(address owner) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
}


/**
 * @title Batch Transfer Ether for Top-Sales
 */
contract VokenTopSales is Ownable{
    using SafeMath256 for uint256;

    /**
     * @dev Batch transfer Ether.
     */
    function batchTtransferEther(address payable[] memory accounts, uint256[] memory values) public payable {
        require(accounts.length == values.length);

        uint256 __etherSum;
        for (uint256 i = 0; i < accounts.length; i++) {
            __etherSum = __etherSum.add(values[i]);
        }

        require(msg.value >= __etherSum);

        for (uint256 i = 0; i < accounts.length; i++) {
            accounts[i].transfer(values[i]);
        }
    }
}
