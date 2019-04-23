pragma solidity ^0.5.7;

// Voken Migration Contract
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
 * @title SafeMath for uint16
 * @dev Unsigned math operations with safety checks that revert on error.
 */
library SafeMath16 {
    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint16 a, uint16 b) internal pure returns (uint16 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }

    /**
     * @dev Integer division of two unsigned integers truncating the quotient,
     * reverts on division by zero.
     */
    function div(uint16 a, uint16 b) internal pure returns (uint16) {
        assert(b > 0);
        uint16 c = a / b;
        assert(a == b * c + a % b);
        return a / b;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint16 a, uint16 b) internal pure returns (uint16) {
        require(b != 0);
        return a % b;
    }
}


/**
 * @title Ownable
 */
contract Ownable {
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract
     * to the sender account.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
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
        _owner = newOwner;
        emit OwnershipTransferred(_owner, newOwner);
    }

    /**
     * @dev Rescue compatible ERC20 Token
     *
     * @param tokenAddr ERC20 The address of the ERC20 token contract
     * @param receiver The address of the receiver
     * @param amount uint256
     */
    function rescueTokens(address tokenAddr, address receiver, uint256 amount) external onlyOwner {
        IERC20 _token = IERC20(tokenAddr);
        require(receiver != address(0));
        uint256 balance = _token.balanceOf(address(this));

        require(balance >= amount);
        assert(_token.transfer(receiver, amount));
    }

    /**
     * @dev Withdraw Ether
     */
    function withdrawEther(address payable to, uint256 amount) external onlyOwner {
        require(to != address(0));

        uint256 balance = address(this).balance;

        require(balance >= amount);
        to.transfer(amount);
    }
}


/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
    bool private _paused;

    event Paused(address account);
    event Unpaused(address account);

    constructor () internal {
        _paused = false;
    }

    /**
     * @return Returns true if the contract is paused, false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!_paused);
        _;
    }

    /**
     * @dev Called by a pauser to pause, triggers stopped state.
     */
    function setPaused(bool state) external onlyOwner {
        if (_paused && !state) {
            _paused = false;
            emit Unpaused(msg.sender);
        } else if (!_paused && state) {
            _paused = true;
            emit Paused(msg.sender);
        }
    }
}


/**
 * @title ERC20 interface
 * @dev see https://eips.ethereum.org/EIPS/eip-20
 */
interface IERC20 {
    function balanceOf(address owner) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
}


/**
 * @title Voken interface
 */
interface IVoken {
    function balanceOf(address owner) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function inWhitelist(address account) external view returns (bool);
    function referrer(address account) external view returns (address);
    function refCount(address account) external view returns (uint256);
}


/**
 * @title Voken Public Sale
 */
contract VokenPublicSale is Ownable, Pausable{
    using SafeMath16 for uint16;
    using SafeMath256 for uint256;

    IVoken public Voken;

    uint256 private _etherPrice;    // Audit ETH Price, in USD, with 6 decimals

    uint256[15] private _whitelistRefRewards = [    // 35% for 15 levels
        6,  // 6% for Level.1
        6,  // 6% for Level.2
        5,  // 5% for Level.3
        4,  // 4% for Level.4
        3,  // 3% for Level.5
        2,  // 2% for Level.6
        1,  // 1% for Level.7
        1,  // 1% for Level.8
        1,  // 1% for Level.9
        1,  // 1% for Level.10
        1,  // 1% for Level.11
        1,  // 1% for Level.12
        1,  // 1% for Level.13
        1,  // 1% for Level.14
        1   // 1% for Level.15
    ];

    uint256 private _weiMinimum = 100000000000000000;       // 0.1 Ether
    uint256 private _weiMaximum = 100000000000000000000;    // 100 Ether
    uint256 private _weiBonus = 10000000000000000000;       //  10 Ether

    uint256 private _priceStart = 1000;     // $ 0.00100 USD    
    uint256 private _priceStageStep = 10;   // $ 0.00001 USD
    uint256 private _price = _priceStart;

    uint256 private _txs;
    uint256 private _vokenTxs;
    uint256 private _bonusTxs;
    uint256 private _whitelistTxs;

    uint256 private _vokenIssued;
    uint256 private _vokenBonus;
    uint256 private _vokenWhitelisted;

    uint16 private _stage;
    uint16 private _stageMax = 60000;   // 60,000 stages total

    uint256 private _stageUsdCapStart = 100000000;  // $    100 USD
    uint256 private _stageUsdCapStep = 1000000;     // $     +1 USD
    uint256 private _stageUsdCapMax = 15100000000;  // $ 15,100 USD

    uint256 private _topSalesRatioStart = 15000000;         // 15%, with 8 decimals
    uint256 private _topSalesRatioProgress = 50000000;      // 50%, with 8 decimals
    uint256 private _topSalesRatio = _topSalesRatioStart;   // 15% + 50% x(_stage/_stageMax)

    uint16 private _season;
    uint16 private _seasonMax = 100;
    uint16 private _seasonStages = 600; // each 600 stages is a season

    mapping (uint16 => uint256) private _stageUsdSold;
    mapping (uint16 => uint256) private _stageVokenIssued;
    mapping (uint16 => uint256) private _seasonUsdSold;
    mapping (uint16 => uint256) private _seasonVokenIssued;
    mapping (uint16 => uint256) private _seasonWeiSold;
    mapping (uint16 => uint256) private _seasonWeiRefRewared;
    mapping (uint16 => uint256) private _seasonWeiTopSales;
    
    mapping (address => uint256) private _accountVokenIssued;
    mapping (address => uint256) private _accountVokenBonus;
    mapping (address => uint256) private _accountVokenWhitelisted;

    mapping (address => uint256) private _accountWeiPurchased;
    mapping (address => uint256) private _accountWeiRefRewarded;

    event StageClosed(uint256 _stageNumber, address indexed account);
    event SeasonClosed(uint16 _seasonNumber, address indexed account);

    uint256 private _weiSold;           // Sold,      in wei
    uint256 private _weiRefRewarded;    // Rewarded,  in wei
    uint256 private _weiPending;        // Pending,   in wei
    uint256 private _weiTopSales;       // Top-Sales, in wei
    uint256 private _weiRaised;         // Raised,    in wei

    mapping (uint16 => mapping (address => uint256)) private _usdSeasonAccountPurchased;
    mapping (uint16 => mapping (address => uint256)) private _weiSeasonAccountRef;

    /**
     * @dev Audit ETH Price, in USD
     */
    function auditEtherPrice() public view returns (uint256) {
        return _etherPrice;
    }

    /**
     * @dev Voken price of current stage
     */
    function price() public view returns (uint256) {
        return _price;
    }
    
    /**
     * @dev Tx counter 
     */
    function txs() public view returns (uint256) {
        return _txs;
    }

    /**
     * @dev Voken Tx counter 
     */
    function vokenTxs() public view returns (uint256) {
        return _vokenTxs;
    }

    /**
     * @dev Bonus Tx counter 
     */
    function bonusTxs() public view returns (uint256) {
        return _bonusTxs;
    }

    /**
     * @dev Whitelist Tx counter 
     */
    function whitelistTxs() public view returns (uint256) {
        return _whitelistTxs;
    }

    /**
     * @dev Voken issued 
     */
    function vokenIssued() public view returns (uint256) {
        return _vokenIssued;
    }

    /**
     * @dev Voken bonus 
     */
    function vokenBonus() public view returns (uint256) {
        return _vokenBonus;
    }

    /**
     * @dev stage index
     */
    function stage() public view returns (uint16) {
        return _stage;
    }

    /**
     * @dev Top-Sales ratio
     */
    function topSalesRatio() public view returns (uint256) {
        return _topSalesRatio;
    }

    /**
     * @dev season number
     */
    function season() public view returns (uint16) {
        return _season;
    }

    /**
     * @dev Sold, in wei
     */
    function weiSold() public view returns (uint256) {
        return _weiSold;
    }

    /**
     * @dev Referral rewarded, in wei
     */
    function weiRefRewarded() public view returns (uint256) {
        return _weiRefRewarded;
    }

    /**
     * @dev Pending, in wei
     */
    function weiPending() public view returns (uint256) {
        return _weiPending;
    }

    /**
     * @dev Top-Sales, in wei
     */
    function weiTopSales() public view returns (uint256) {
        return _weiTopSales;
    }

    /**
     * @dev Raised, in wei
     */
    function weiRaised() public view returns (uint256) {
        return _weiSold.sub(_weiRefRewarded).sub(_weiTopSales).sub(_weiPending);
    }

    /**
     * @dev stage dollor sold, by stage index
     */
    function stageUsdSold(uint16 stageIndex) public view returns (uint256) {
        return _stageUsdSold[stageIndex];
    }

    /**
     * @dev stage Voken issued, by stage index
     */
    function stageVokenIssued(uint16 stageIndex) public view returns (uint256) {
        return _stageVokenIssued[stageIndex];
    }

    /**
     * @dev season dollor sold, by season index
     */
    function seasonUsdSold(uint16 seasonIndex) public view returns (uint256) {
        return _seasonUsdSold[seasonIndex];
    }

    /**
     * @dev season Voken issued, by season index
     */
    function seasonVokenIssued(uint16 seasonIndex) public view returns (uint256) {
        return _seasonVokenIssued[seasonIndex];
    }

    /**
     * @dev season urchased, by season index, in wei
     */
    function seasonWeiSold(uint16 seasonIndex) public view returns (uint256) {
        return _seasonWeiSold[seasonIndex];
    }

    /**
     * @dev season referral rewared, by season index, in wei
     */
    function seasonWeiRefRewared(uint16 seasonIndex) public view returns (uint256) {
        return _seasonWeiRefRewared[seasonIndex];
    }

    /**
     * @dev season Top-Sales, by season index, in wei
     */
    function seasonWeiTopSales(uint16 seasonIndex) public view returns (uint256) {
        return _seasonWeiTopSales[seasonIndex];
    }

    /**
     * @dev Voken issued, by account
     */
    function accountVokenIssued(address account) public view returns (uint256) {
        return _accountVokenIssued[account];
    }

    /**
     * @dev Voken bonus, by account
     */
    function accountVokenBonus(address account) public view returns (uint256) {
        return _accountVokenBonus[account];
    }

    /**
     * @dev Voken whitelisted, by account
     */
    function accountVokenWhitelisted(address account) public view returns (uint256) {
        return _accountVokenWhitelisted[account];
    }

    /**
     * @dev Wei purchased, by account
     */
    function accountWeiPurchased(address account) public view returns (uint256) {
        return _accountWeiPurchased[account];
    }

    /**
     * @dev Wei rewared, by account
     */
    function accountWeiRefRewarded(address account) public view returns (uint256) {
        return _accountWeiRefRewarded[account];
    }

    /**
     * @dev set Audit ETH USD Price (1 Ether = xx.xxxxxx USD)
     */
    function setEtherPrice(uint256 etherPrice) external onlyOwner returns (bool) {
        _etherPrice = etherPrice;
        return true;
    }

    /**
     * @dev stage Voken price in USD, by stage index
     */
    function stagePrice(uint16 stageIndex) public view returns (uint256) {
        return _priceStart.add(_priceStageStep.mul(stageIndex));
    }

    /**
     * @dev wei => USD
     */
    function wei2usd(uint256 amount) private view returns (uint256) {
        return amount.mul(_etherPrice).div(1000000000000000000);
    }

    /**
     * @dev USD => wei
     */
    function usd2wei(uint256 amount) private view returns (uint256) {
        return amount.mul(1000000000000000000).div(_etherPrice);
    }

    /**
     * @dev USD => voken
     */
    function usd2voken(uint256 usdAmount) private view returns (uint256) {
        return usdAmount.mul(1000000).div(_price);
    }

    /**
     * @dev USD => wei, for Top-Sales
     */
    function usd2weiTopSales(uint256 usdAmount) public view returns (uint256) {
        return usd2wei(usdAmount.mul(_topSalesRatio).div(100000000));
    }

    /**
     * @dev USD => voken
     */
    function usd2vokenByStage(uint256 usdAmount, uint16 stageIndex) public view returns (uint256) {
        return usdAmount.mul(1000000).div(stagePrice(stageIndex));
    }

    /**
     * @dev calculate season number, by stage index
     */
    function calcSeason(uint16 stageIndex) public view returns (uint16) {
        if (stageIndex > 0) {
            uint16 __seasonNumber = stageIndex.div(_seasonStages);

            if (stageIndex.mod(_seasonStages) > 0) {
                return __seasonNumber.add(1);
            }
            
            return __seasonNumber;
        }
        
        return 1;
    }

    /**
     * @dev calculate stage dollor cap, by stage index
     */
    function stageUsdCap(uint16 stageIndex) public view returns (uint256) {
        uint256 __usdCap = _stageUsdCapStart.add(_stageUsdCapStep.mul(stageIndex)); 

        if (__usdCap > _stageUsdCapMax) {
            return _stageUsdCapMax;
        }

        return __usdCap;
    }

    /**
     * @dev stage USD on-sale, by stage index
     */
    function stageUsdOnSale(uint16 stageIndex) public view returns (uint256) {
        return stageUsdCap(stageIndex).sub(stageUsdSold(stageIndex));
    }

    /**
     * @dev stage Vokdn Cap, by stage index
     */
    function stageVokenCap(uint16 stageIndex) public view returns (uint256) {
        uint256 __usdCap = stageUsdCap(stageIndex);
        return usd2vokenByStage(__usdCap, stageIndex);
    }

    /**
     * @dev stage Vokens on-sale, by stage index
     */
    function stageVokenOnSale(uint16 stageIndex) public view returns (uint256) {
        return stageUsdOnSale(stageIndex).mul(1000000).div(stagePrice(stageIndex));
    }

    /**
     * @dev season => account => USD purchased
     */
    function usdSeasonAccountPurchased(uint16 seasonIndex, address account) public view returns (uint256) {
        return _usdSeasonAccountPurchased[seasonIndex][account];
    }

    /**
     * @dev season => account => referral weis
     */
    function weiSeasonAccountRef(uint16 seasonIndex, address account) public view returns (uint256) {
        return _weiSeasonAccountRef[seasonIndex][account];
    }

    // without seasonUsdCap() seasonUsdOnSale etc.


    /**
     * @dev constructor
     */
    constructor() public {
        Voken = IVoken(0x01dEF33c7B614CbFdD04A243eD5513A763abE39f);
        _etherPrice = 170000000;
        _stage = 0;
        _season = 1;
    }

    /**
     * @dev receive ETH, and send Vokens
     */
    function () external payable whenNotPaused {
        require(msg.value >= _weiMinimum);
        require(msg.value <= _weiMaximum);
        
        uint256 __usd = wei2usd(msg.value);
        uint256 __usdRemain = __usd;
        uint256 __vokenIssued;
        uint256 __vokenBonus;
        uint256 __usdUsed;
        uint256 __weiUsed;

        // USD => Voken
        while (__usdRemain > 0 && _stage <= _stageMax) {
            uint256 __txVokenIssued;
            
            (__txVokenIssued, __usdRemain) = ex(__usdRemain);
            
            __vokenIssued = __vokenIssued.add(__txVokenIssued);
        }

        // Used
        __usdUsed = __usd.sub(__usdRemain);
        __weiUsed = usd2wei(__usdUsed);

        // Bonus 10%
        if (msg.value >= _weiBonus) {
            __vokenBonus = __vokenIssued.div(10);
            assert(vokenBonusTransfer(__vokenBonus));
        }

        // Whitelisted
        // BUY-ONE-AND-GET-ONE-MORE-FREE
        if (Voken.inWhitelist(msg.sender) && __vokenIssued > 0) {
            assert(vokenWhitelistedTransfer(__vokenIssued));

            // SAME to Bonus
            if (__vokenBonus > 0) {
                assert(vokenBonusTransfer(__vokenBonus));
            }
            
            // 35% for 15 levels
            sendRefRewards(__weiUsed);
        }

        // if wei remains, refund wei back
        if (__usdRemain > 0) {
            uint256 __weiRemain = usd2wei(__usdRemain);
            
            __weiUsed = msg.value.sub(__weiRemain);
            
            // Refund wei back
            msg.sender.transfer(__weiRemain);
        }

        // Tx counter + 1
        if (__weiUsed > 0) {
            _weiSold = _weiSold.add(__weiUsed);
            _accountWeiPurchased[msg.sender] = _accountWeiPurchased[msg.sender].add(__weiUsed);
            _txs = _txs.add(1);
        }
    }

    /**
     * @dev send referral rewards
     */
    function sendRefRewards(uint256 weiAmount) private {
        address __cursor = msg.sender;
        uint256 __weiRemain = weiAmount;

        // _whitelistRefRewards
        for(uint i = 0; i < _whitelistRefRewards.length; i++) {
            uint256 __weiReward = weiAmount.mul(_whitelistRefRewards[i]).div(100);
            address payable __receiver = address(uint160(Voken.referrer(__cursor)));

            if (__cursor != __receiver) {
                if (Voken.refCount(__receiver) > i) {
                    __receiver.transfer(__weiReward);
                    _weiSeasonAccountRef[_season][__receiver] = _weiSeasonAccountRef[_season][__receiver].add(weiAmount);

                    _weiRefRewarded = _weiRefRewarded.add(__weiReward);
                    _seasonWeiRefRewared[_season] = _seasonWeiRefRewared[_season].add(__weiReward);
                    _accountWeiRefRewarded[__receiver] = _accountWeiRefRewarded[__receiver].add(__weiReward);
                    __weiRemain = __weiRemain.sub(__weiReward);
                } else {
                    _weiPending = _weiPending.add(__weiReward);
                }
            } else {
                _weiPending = _weiPending.add(__weiReward);
            }

            __cursor = Voken.referrer(__cursor);
        }
    }

    /**
     * @dev Voken issued transfer
     */
    function vokenIssuedTransfer(uint256 amount) private returns (bool) {
        _vokenTxs = _vokenTxs.add(1);
        
        _vokenIssued = _vokenIssued.add(amount);
        _stageVokenIssued[_stage] = _stageVokenIssued[_stage].add(amount);
        _seasonVokenIssued[_season] = _seasonVokenIssued[_season].add(amount);
        _accountVokenIssued[msg.sender] = _accountVokenIssued[msg.sender].add(amount);

        return Voken.transfer(msg.sender, amount);
    }

    /**
     * @dev Voken bonus transfer
     */
    function vokenBonusTransfer(uint256 amount) private returns (bool) {
        _bonusTxs = _bonusTxs.add(1);

        _vokenBonus = _vokenBonus.add(amount);
        _accountVokenBonus[msg.sender] = _accountVokenBonus[msg.sender].add(amount);

        return Voken.transfer(msg.sender, amount);
    }

    /**
     * @dev Voken whitelisted transfer
     */
    function vokenWhitelistedTransfer(uint256 amount) private returns (bool) {
        _whitelistTxs = _whitelistTxs.add(1);

        _vokenWhitelisted = _vokenWhitelisted.add(amount);
        _accountVokenWhitelisted[msg.sender] = _accountVokenWhitelisted[msg.sender].add(amount);

        return Voken.transfer(msg.sender, amount);
    }

    /**
     * Close current stage
     */
    function closeStage() private returns (bool) {
        emit StageClosed(_stage, msg.sender);
        _stage = _stage.add(1);
        _price = stagePrice(_stage);
        _topSalesRatio = _topSalesRatioStart.add(_topSalesRatioProgress.mul(_stage).div(_stageMax));

        // Close current season?
        uint16 __seasonNumber = calcSeason(_stage);
        if (_season < __seasonNumber) {
            emit SeasonClosed(_season, msg.sender);
            _season = __seasonNumber;
        }

        return true;
    }

    /**
     * @dev USD => Voken
     */
    function ex(uint256 usdAmount) private returns (uint256, uint256) {
        uint256 __stageUsdCap = stageUsdCap(_stage);
        uint256 __vokenIssued;
        uint256 __weiSold;
        uint256 __weiTopSales;

        // in stage
        if (_stageUsdSold[_stage].add(usdAmount) <= __stageUsdCap) {
            __weiSold = usd2wei(usdAmount);
            
            _stageUsdSold[_stage] = _stageUsdSold[_stage].add(usdAmount);
            _seasonUsdSold[_season] = _seasonUsdSold[_season].add(usdAmount);
            _seasonWeiSold[_season] = _seasonWeiSold[_season].add(__weiSold);

            _usdSeasonAccountPurchased[_season][msg.sender] = _usdSeasonAccountPurchased[_season][msg.sender].add(usdAmount);

            __vokenIssued = usd2voken(usdAmount);
            assert(vokenIssuedTransfer(__vokenIssued));
            
            // reached cap? close stage
            if (__stageUsdCap == _stageUsdSold[_stage]) {
                assert(closeStage());
            }

            // Top-Sales
            __weiTopSales = usd2weiTopSales(usdAmount);
            _weiTopSales = _weiTopSales.add(__weiTopSales);
            _seasonWeiTopSales[_season] = _seasonWeiTopSales[_season].add(__weiTopSales);

            return (__vokenIssued, 0);
        }

        // close stage
        uint256 __usdUsed = __stageUsdCap.sub(_stageUsdSold[_stage]);
        uint256 __usdRemain = usdAmount.sub(__usdUsed);

        __weiSold = usd2wei(__usdUsed);

        _stageUsdSold[_stage] = _stageUsdSold[_stage].add(__usdUsed);
        _seasonUsdSold[_season] = _seasonUsdSold[_season].add(__usdUsed);
        _seasonWeiSold[_season] = _seasonWeiSold[_season].add(__weiSold);

        _usdSeasonAccountPurchased[_season][msg.sender] = _usdSeasonAccountPurchased[_season][msg.sender].add(__usdUsed);

        __vokenIssued = usd2voken(__usdUsed);
        assert(vokenIssuedTransfer(__vokenIssued));
        assert(closeStage());

        // Top-Sales
        __weiTopSales = usd2weiTopSales(__usdUsed);
        _weiTopSales = _weiTopSales.add(__weiTopSales);
        _seasonWeiTopSales[_season] = _seasonWeiTopSales[_season].add(__weiTopSales);

        return (__vokenIssued, __usdRemain);
    }
}
