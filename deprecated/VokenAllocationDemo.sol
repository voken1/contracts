pragma solidity ^0.5.10;

// Voken Allocation Contract (DEMO)
// 
// More info:
//   https://vision.network
//   https://voken.io
//
// Contact us:
//   support@vision.network
//   support@voken.io


/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow checks.
 */
library SafeMath256 {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
     * @dev Give an account access to this role.
     */
    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    /**
     * @dev Remove an account's access to this role.
     */
    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    /**
     * @dev Check if an account has this role.
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}


/**
 * @dev Allocation for VOKEN
 */
library Allocations {
    using SafeMath256 for uint256;

    struct Allocation {
        uint256 amount;
        uint256 timestamp;
        uint256 interval;
        uint256 steps;
    }

    /**
     * @dev Returns the available amount.
     */
    function available(Allocation storage self) internal view returns (uint256) {
        if (now > self.timestamp) {
            if (self.interval == 0) {
                return self.amount;
            }

            uint256 __passed = now.sub(self.timestamp).div(self.interval).add(1);

            if (__passed >= self.steps) {
                return self.amount;
            }

            return self.amount.mul(__passed).div(self.steps);
        }

        return 0;
    }

    /**
     * @dev Returns the reserved amount.
     */
    function reserved(Allocation storage self) internal view returns (uint256) {
        return self.amount.sub(available(self));
    }
}


/**
 * @dev Interface of the ERC20 standard
 */
interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


/**
 * @dev Interface of an allocation contract
 */
interface IAllocation {
    function reservedOf(address account) external view returns (uint256);
}


/**
 * @dev Interface of VOKEN
 */
interface IVoken {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function mintWithAllocation(address account, uint256 amount, address allocationContract) external returns (bool);
}



/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 */
contract Ownable {
    address internal _owner;
    address internal _newOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event OwnershipAccepted(address indexed previousOwner, address indexed newOwner);


    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the addresses of the current and new owner.
     */
    function owner() public view returns (address currentOwner, address newOwner) {
        currentOwner = _owner;
        newOwner = _newOwner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     *
     * IMPORTANT: Need to run {acceptOwnership} by the new owner.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");

        emit OwnershipTransferred(_owner, newOwner);
        _newOwner = newOwner;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     *
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Accept ownership of the contract.
     *
     * Can only be called by the new owner.
     */
    function acceptOwnership() public {
        require(msg.sender == _newOwner, "Ownable: caller is not the new owner address");
        require(msg.sender != address(0), "Ownable: caller is the zero address");

        emit OwnershipAccepted(_owner, msg.sender);
        _owner = msg.sender;
        _newOwner = address(0);
    }

    /**
     * @dev Rescue compatible ERC20 Token
     *
     * Can only be called by the current owner.
     */
    function rescueTokens(address tokenAddr, address recipient, uint256 amount) external onlyOwner {
        IERC20 _token = IERC20(tokenAddr);
        require(recipient != address(0), "Rescue: recipient is the zero address");
        uint256 balance = _token.balanceOf(address(this));

        require(balance >= amount, "Rescue: amount exceeds balance");
        _token.transfer(recipient, amount);
    }

    /**
     * @dev Withdraw Ether
     *
     * Can only be called by the current owner.
     */
    function withdrawEther(address payable recipient, uint256 amount) external onlyOwner {
        require(recipient != address(0), "Withdraw: recipient is the zero address");

        uint256 balance = address(this).balance;

        require(balance >= amount, "Withdraw: amount exceeds balance");
        recipient.transfer(amount);
    }
}


/**
 * @title Voken Allocation Demo Contract
 */
contract VokenAllocationDemo is Ownable, IAllocation {
    using SafeMath256 for uint256;
    using Roles for Roles.Role;
    using Allocations for Allocations.Allocation;

    IVoken private _voken;
    Roles.Role private _proxies;

    mapping (address => Allocations.Allocation[]) private _allocations;

    event Donate(address indexed account, uint256 amount);
    event ProxyAdded(address indexed account);
    event ProxyRemoved(address indexed account);


    /**
     * @dev Constructor
     */
    constructor () public {
        //
    }

    /**
     * @dev Donate
     */
    function () external payable {
        if (msg.value > 0) {
            emit Donate(msg.sender, msg.value);
        }
    }

    /**
     * @dev Returns the VOKEN main contract address.
     */
    function VOKEN() public view returns (IVoken) {
        return _voken;
    }

    /**
     * @dev Sets the VOKEN main contract address.
     */
    function setVokenMainContract(IVoken vokenMainContract) public onlyOwner {
        require(address(vokenMainContract) != address(0), "VOKEN: main contract is the zero address");
        _voken = vokenMainContract;
    }

    /**
     * @dev Throws if called by account which is not a proxy.
     */
    modifier onlyProxy() {
        require(isProxy(msg.sender), "ProxyRole: caller does not have the Proxy role");
        _;
    }

    /**
     * @dev Returns true if the `account` has the Proxy role.
     */
    function isProxy(address account) public view returns (bool) {
        return _proxies.has(account);
    }

    /**
     * @dev Give an `account` access to the Proxy role.
     *
     * Can only be called by the current owner.
     */
    function addProxy(address account) public onlyOwner {
        _proxies.add(account);
        emit ProxyAdded(account);
    }

    /**
     * @dev Remove an `account` access from the Proxy role.
     *
     * Can only be called by the current owner.
     */
    function removeProxy(address account) public onlyOwner {
        _proxies.remove(account);
        emit ProxyRemoved(account);
    }

    /**
     * @dev Returns the reserved amount of VOKENs by `account`.
     */
    function reservedOf(address account) public view returns (uint256) {
        uint256 __reserved;

        uint256 __len = _allocations[account].length;
        if (__len > 0) {
            for (uint256 i = 0; i < __len; i++) {
                __reserved = __reserved.add(_allocations[account][i].reserved());
            }
        }

        return __reserved;
    }

    /**
     * @dev Returns the allocations counter on `account`.
     */
    function allocations(address account) public view returns (uint256 allocationsCounter) {
        allocationsCounter = _allocations[account].length;
    }

    /**
     * @dev Returns the allocation on `account` and an `index`.
     */
    function allocation(address account, uint256 index) public view returns (uint256 amount,
                                                                             uint256 timestamp,
                                                                             uint256 interval,
                                                                             uint256 steps,
                                                                             uint256 available,
                                                                             uint256 reserved) {
        if (index < _allocations[account].length) {
            amount = _allocations[account][index].amount;
            timestamp = _allocations[account][index].timestamp;
            interval = _allocations[account][index].interval;
            steps = _allocations[account][index].steps;

            available = _allocations[account][index].available();
            reserved = amount.sub(available);
        }
    }

    /**
     * @dev Remove an allocation of an `account` by `index`.
     */
    function _removeAllocation(address account, uint256 index) internal {
        uint256 __len = _allocations[account].length;

        if (index >= __len) {
            return;
        }

        for (uint256 i = index; i < __len - 1; i++) {
            _allocations[account][i] = _allocations[account][i + 1];
        }

        delete _allocations[account][__len - 1];
        _allocations[account].length--;
    }

    /**
     * @dev Creates `amount` VOKENs and assigns them to `account`.
     *
     * With an `allocation`
     *
     * Can only be called by a proxy.
     */
    function mintWithAllocation(
        address account,
        uint256 amount,
        uint256 timestamp,
        uint256 interval,
        uint256 steps
    ) public onlyOwner returns (bool) {
        Allocations.Allocation memory __allocation;

        __allocation.amount = amount;
        __allocation.timestamp = timestamp;
        __allocation.interval = interval;
        __allocation.steps = steps;

        _allocations[account].push(__allocation);

        _voken.mintWithAllocation(account, amount, address(this));
        return true;
    }
}
