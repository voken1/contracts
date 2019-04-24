pragma solidity ^0.5.7;

// Voken Public Sale
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
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint16 a, uint16 b) internal pure returns (uint16) {
        assert(b <= a);
        return a - b;
    }

    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
     */
    function mul(uint16 a, uint16 b) internal pure returns (uint16 c) {
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
    function div(uint16 a, uint16 b) internal pure returns (uint16) {
        assert(b > 0);
        uint256 c = a / b;
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
    address private _owner;
    address payable internal _receiver;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event ReceiverChanged(address indexed previousReceiver, address indexed newReceiver);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract
     * to the sender account.
     */
    constructor () internal {
        _owner = msg.sender;
        _receiver = msg.sender;
        // emit OwnershipTransferred(address(0), _owner);
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
        address __previousOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(__previousOwner, newOwner);
    }

    /**
     * @dev change receiver.
     */
    function changeReceiver(address payable newReceiver) external onlyOwner {
        require(newReceiver != address(0));
        address __previousReceiver = _receiver;
        _receiver = newReceiver;
        emit ReceiverChanged(__previousReceiver, newReceiver);
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
     * @dev Withdraw ether
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
        require(!_paused, "Paused.");
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

    // Voken
    IVoken public Voken;

    // start timestamp
    uint32 _startTimestamp;

    // referral rewards, 35% for 15 levels
    uint256[15] private _whitelistRefRewards = [
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

    // wei
    uint256 private _weiMinimum = 0.1 ether;    // 0.1 Ether Minimum
    uint256 private _weiMaximum = 100 ether;    // 100 Ether Maximum
    uint256 private _weiBonus = 10 ether;       // >10 Ether for Bonus

    // audit ether price
    uint256 private _etherPrice;    // Audit ETH USD Price (1 Ether = xx.xxxxxx USD, with 6 decimals)

    // audit ether price auditor
    mapping (address => bool) private _etherPriceAuditors;

    // price
    uint256 private _vokenUsdStart = 1000;     // $ 0.00100 USD    
    uint256 private _vokenUsdStageStep = 10;   // $ 0.00001 USD
    uint256 private _vokenUsdPrice = _vokenUsdStart;

    uint256 private _stageUsdCapStart = 100000000;  // $    100 USD
    uint256 private _stageUsdCapStep = 1000000;     // $     +1 USD
    uint256 private _stageUsdCapMax = 15100000000;  // $ 15,100 USD

    // progress
    uint16 private _stage;
    uint16 private _stageMax = 60000;   // 60,000 stages total
    uint16 private _season;
    uint16 private _seasonMax = 100;    // 100 seasons total
    uint16 private _seasonStages = 600; // each 600 stages is a season

    // sum
    uint256 private _txs;
    uint256 private _vokenTxs;
    uint256 private _vokenBonusTxs;
    uint256 private _vokenWhitelistTxs;
    uint256 private _vokenIssued;
    uint256 private _vokenBonus;
    uint256 private _vokenWhitelist;
    uint256 private _weiSold;
    uint256 private _weiRefRewarded;
    uint256 private _weiTopSales;
    uint256 private _weiTeam;
    uint256 private _weiPending;
    uint256 private _weiPendingTransfered;

    // Top-Sales
    uint256 private _topSalesRatioStart = 15000000;         // 15%, with 8 decimals
    uint256 private _topSalesRatioProgress = 50000000;      // 50%, with 8 decimals
    uint256 private _topSalesRatio = _topSalesRatioStart;   // 15% + 50% x(_stage/_stageMax)

    // stage
    mapping (uint16 => uint256) private _stageUsdSold;
    mapping (uint16 => uint256) private _stageVokenIssued;

    // season
    mapping (uint16 => uint256) private _seasonWeiSold;
    mapping (uint16 => uint256) private _seasonWeiTopSales;
    mapping (uint16 => uint256) private _seasonWeiTopSalesTransfered;

    // account
    mapping (address => uint256) private _accountVokenIssued;
    mapping (address => uint256) private _accountVokenBonus;
    mapping (address => uint256) private _accountVokenWhitelisted;
    mapping (address => uint256) private _accountWeiPurchased;
    mapping (address => uint256) private _accountWeiRefRewarded;

    // ref
    mapping (uint16 => address[]) private _seasonRefAccounts;
    mapping (uint16 => mapping (address => bool)) private _seasonHasRefAccount;
    mapping (uint16 => mapping (address => uint256)) private _usdSeasonAccountPurchased;
    mapping (uint16 => mapping (address => uint256)) private _usdSeasonAccountRef;

    event AuditEtherPriceChanged(uint256 value, address indexed account);
    event AuditEtherPriceAuditorChanged(address indexed account, bool state);

    event PendingTransfered(address indexed account, uint256 amount);
    event SeasonTopSalesTransfered(uint16 seasonNumber, address indexed account, uint256 amount);

    event StageClosed(uint256 _stageNumber, address indexed account);
    event SeasonClosed(uint16 _seasonNumber, address indexed account);

    /**
     * @dev start timestamp
     */
    function startTimestamp() public view returns (uint32) {
        return _startTimestamp;
    }

    /**
     * @dev set start timestamp
     */
    function setStartTimestamp(uint32 timestamp) external onlyOwner {
        _startTimestamp = timestamp;
    }

    /**
     * @dev Throws if not ether price auditor.
     */
    modifier onlyEtherPriceAuditor() {
        require(_etherPriceAuditors[msg.sender]);
        _;
    }

    /**
     * @dev set audit ether price.
     */
    function setEtherPrice(uint256 value) external onlyEtherPriceAuditor {
        _etherPrice = value;
        emit AuditEtherPriceChanged(value, msg.sender);
    }

    /**
     * @dev get ether price auditor state.
     */
    function etherPriceAuditor(address account) public view returns (bool) {
        return _etherPriceAuditors[account];
    }

    /**
     * @dev set ether price auditor state.
     */
    function setEtherPriceAuditor(address account, bool state) external onlyOwner {
        _etherPriceAuditors[account] = state;
        emit AuditEtherPriceAuditorChanged(account, state);
    }

    /**
     * @dev stage Voken price in USD, by stage index
     */
    function stageVokenUsdPrice(uint16 stageIndex) private view returns (uint256) {
        return _vokenUsdStart.add(_vokenUsdStageStep.mul(stageIndex));
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
        return usdAmount.mul(1000000).div(_vokenUsdPrice);
    }

    /**
     * @dev USD => voken
     */
    function usd2vokenByStage(uint256 usdAmount, uint16 stageIndex) public view returns (uint256) {
        return usdAmount.mul(1000000).div(stageVokenUsdPrice(stageIndex));
    }


    /**
     * @dev calculate season number, by stage index
     */
    function calcSeason(uint16 stageIndex) private view returns (uint16) {
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
     * @dev pending remain, in wei
     */
    function pendingRemain() private view returns (uint256) {
        return _weiPending.sub(_weiPendingTransfered);
    }

    /**
     * @dev transfer pending
     */
    function transferPending(address payable to) external onlyOwner {
        uint256 __weiRemain = pendingRemain();
        require(to != address(0));

        _weiPendingTransfered = _weiPendingTransfered.add(__weiRemain);
        emit PendingTransfered(to, __weiRemain);
        to.transfer(__weiRemain);
    }

    /**
     * @dev status
     */
    function status() public view returns (uint256 auditEtherPrice,
                                           uint16 stage,
                                           uint16 season,
                                           uint256 vokenUsdPrice,
                                           uint256 currentTopSalesRatio,
                                           uint256 txs,
                                           uint256 vokenTxs,
                                           uint256 vokenBonusTxs,
                                           uint256 vokenWhitelistTxs,
                                           uint256 vokenIssued,
                                           uint256 vokenBonus,
                                           uint256 vokenWhitelist) {
        auditEtherPrice = _etherPrice;

        if (_stage > _stageMax) {
            stage = _stageMax;
            season = _seasonMax;
        } else {
            stage = _stage;
            season = _season;
        }

        vokenUsdPrice = _vokenUsdPrice;
        currentTopSalesRatio = _topSalesRatio;

        txs = _txs;
        vokenTxs = _vokenTxs;
        vokenBonusTxs = _vokenBonusTxs;
        vokenWhitelistTxs = _vokenWhitelistTxs;
        vokenIssued = _vokenIssued;
        vokenBonus = _vokenBonus;
        vokenWhitelist = _vokenWhitelist;
    }

    /**
     * @dev rewards status
     */
    function sum() public view returns(uint256 weiSold,
                                       uint256 weiReferralRewarded,
                                       uint256 weiTopSales,
                                       uint256 weiTeam,
                                       uint256 weiPending,
                                       uint256 weiPendingTransfered,
                                       uint256 weiPendingRemain) {
        weiSold = _weiSold;
        weiReferralRewarded = _weiRefRewarded;
        weiTopSales = _weiTopSales;
        weiTeam = _weiTeam;
        weiPending = _weiPending;
        weiPendingTransfered = _weiPendingTransfered;
        weiPendingRemain = pendingRemain();
    }

    /**
     * @dev Throws if not started.
     */
    modifier onlyOnSale() {
        require(_startTimestamp > 0 && now > _startTimestamp, "Voken Public-Sale has not started yet.");
        require(_etherPrice > 0, "Audit ETH price must be greater than zero.");
        require(!paused(), "Voken Public-Sale is paused.");
        require(_stage <= _stageMax, "Voken Public-Sale Closed.");
        _;
    }

    /**
     * @dev Top-Sales ratio
     */
    function topSalesRatio(uint16 stageIndex) private view returns (uint256) {
        return _topSalesRatioStart.add(_topSalesRatioProgress.mul(stageIndex).div(_stageMax));
    }

    /**
     * @dev USD => wei, for Top-Sales
     */
    function usd2weiTopSales(uint256 usdAmount) private view returns (uint256) {
        return usd2wei(usdAmount.mul(_topSalesRatio).div(100000000));
    }

    /**
     * @dev calculate stage dollor cap, by stage index
     */
    function stageUsdCap(uint16 stageIndex) private view returns (uint256) {
        uint256 __usdCap = _stageUsdCapStart.add(_stageUsdCapStep.mul(stageIndex)); 

        if (__usdCap > _stageUsdCapMax) {
            return _stageUsdCapMax;
        }

        return __usdCap;
    }

    /**
     * @dev stage Vokdn Cap, by stage index
     */
    function stageVokenCap(uint16 stageIndex) private view returns (uint256) {
        return usd2vokenByStage(stageUsdCap(stageIndex), stageIndex);
    }

    /**
     * @dev stage status, by stage index
     */
    function stageStatus(uint16 stageIndex) public view returns (uint256 vokenUsdPrice,
                                                                 uint256 vokenCap,
                                                                 uint256 vokenOnSale,
                                                                 uint256 vokenSold,
                                                                 uint256 usdCap,
                                                                 uint256 usdOnSale,
                                                                 uint256 usdSold,
                                                                 uint256 weiTopSalesRatio) {
        if (stageIndex > _stageMax) {
            return (0, 0, 0, 0, 0, 0, 0, 0);
        }

        vokenUsdPrice = stageVokenUsdPrice(stageIndex);

        vokenSold = _stageVokenIssued[stageIndex];
        vokenCap = stageVokenCap(stageIndex);
        vokenOnSale = vokenCap.sub(vokenSold);

        usdSold = _stageUsdSold[stageIndex];
        usdCap = stageUsdCap(stageIndex);
        usdOnSale = usdCap.sub(usdSold);

        weiTopSalesRatio = topSalesRatio(stageIndex);
    }

    /**
     * @dev season Top-Sales remain, in wei
     */
    function seasonTopSalesRemain(uint16 seasonNumber) private view returns (uint256) {
        return _seasonWeiTopSales[seasonNumber].sub(_seasonWeiTopSalesTransfered[seasonNumber]);
    }

    /**
     * @dev season Top-Sales rewards, by season number, in wei
     */
    function seasonTopSalesRewards(uint16 seasonNumber) public view returns (uint256 weiSold,
                                                                             uint256 weiTopSales,
                                                                             uint256 weiTopSalesTransfered,
                                                                             uint256 weiTopSalesRemain) {
        weiSold = _seasonWeiSold[seasonNumber];
        weiTopSales = _seasonWeiTopSales[seasonNumber];
        weiTopSalesTransfered = _seasonWeiTopSalesTransfered[seasonNumber];
        weiTopSalesRemain = seasonTopSalesRemain(seasonNumber);
    }

    /**
     * @dev transfer Top-Sales, by season number
     */
    function transferTopSales(uint16 seasonNumber, address payable to) external onlyOwner {
        uint256 __weiRemain = seasonTopSalesRemain(seasonNumber);
        require(to != address(0));
        
        _seasonWeiTopSalesTransfered[seasonNumber] = _seasonWeiTopSalesTransfered[seasonNumber].add(__weiRemain);
        emit SeasonTopSalesTransfered(seasonNumber, to, __weiRemain);
        to.transfer(__weiRemain);
    }

    /**
     * @dev accountQuery
     */
    function accountQuery(address account) public view returns (uint256 vokenIssued,
                                                                uint256 vokenBonus,
                                                                uint256 vokenWhitelisted,
                                                                uint256 weiPurchased,
                                                                uint256 weiReferralRewarded) {
        vokenIssued = _accountVokenIssued[account];
        vokenBonus = _accountVokenBonus[account];
        vokenWhitelisted = _accountVokenWhitelisted[account];
        weiPurchased = _accountWeiPurchased[account];
        weiReferralRewarded = _accountWeiRefRewarded[account];
    }

    /**
     * @dev accounts in a specific season
     */
    function seasonRefAccounts(uint16 seasonNumber) public view returns (address[] memory accounts) {
        accounts = _seasonRefAccounts[seasonNumber];
    }

    /**
     * @dev season => account => USD purchased
     */
    function usdSeasonAccountPurchased(uint16 seasonIndex, address account) public view returns (uint256) {
        return _usdSeasonAccountPurchased[seasonIndex][account];
    }

    /**
     * @dev season => account => referral dollors
     */
    function usdSeasonAccountRef(uint16 seasonIndex, address account) public view returns (uint256) {
        return _usdSeasonAccountRef[seasonIndex][account];
    }

    /**
     * @dev constructor
     */
    constructor () public {
        Voken = IVoken(0x01dEF33c7B614CbFdD04A243eD5513A763abE39f);
        _stage = 0;
        _season = 1;

        _etherPriceAuditors[msg.sender] = true;
    }

    /**
     * @dev receive ETH, and send Vokens
     */
    function () external payable onlyOnSale {
        require(msg.value >= _weiMinimum);
        require(msg.value <= _weiMaximum);

        uint256 __usdAmount = wei2usd(msg.value);
        uint256 __usdRemain = __usdAmount;
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
        __usdUsed = __usdAmount.sub(__usdRemain);
        __weiUsed = usd2wei(__usdUsed);

        // Bonus 10%
        if (msg.value >= _weiBonus) {
            __vokenBonus = __vokenIssued.div(10);
            assert(vokenBonusTransfer(__vokenBonus));
        }

        // Whitelisted
        // BUY-ONE-AND-GET-ONE-MORE-FREE
        if (Voken.inWhitelist(msg.sender) && __vokenIssued > 0) {
            // both issued and bonus
            assert(vokenWhitelistedTransfer(__vokenIssued.add(__vokenBonus)));

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

        // counter
        if (__weiUsed > 0) {
            _txs = _txs.add(1);
            _weiSold = _weiSold.add(__weiUsed);
            _accountWeiPurchased[msg.sender] = _accountWeiPurchased[msg.sender].add(__weiUsed);
        }

        // wei team
        uint256 __weiTeam = _weiSold.sub(_weiRefRewarded).sub(_weiTopSales).sub(_weiPending).sub(_weiTeam);
        _weiTeam = _weiTeam.add(__weiTeam);
        _receiver.transfer(__weiTeam);
        
        // assert finished
        assert(true);
    }

    /**
     * @dev USD => Voken
     */
    function ex(uint256 usdAmount) private returns (uint256, uint256) {
        uint256 __stageUsdCap = stageUsdCap(_stage);
        uint256 __vokenIssued;

        // in stage
        if (_stageUsdSold[_stage].add(usdAmount) <= __stageUsdCap) {
            exCount(usdAmount);

            __vokenIssued = usd2voken(usdAmount);
            assert(vokenIssuedTransfer(__vokenIssued));

            // close stage, if stage dollor cap reached
            if (__stageUsdCap == _stageUsdSold[_stage]) {
                assert(closeStage());
            }

            return (__vokenIssued, 0);
        }

        // close stage
        uint256 __usdUsed = __stageUsdCap.sub(_stageUsdSold[_stage]);
        uint256 __usdRemain = usdAmount.sub(__usdUsed);

        exCount(__usdUsed);

        __vokenIssued = usd2voken(__usdUsed);
        assert(vokenIssuedTransfer(__vokenIssued));
        assert(closeStage());

        return (__vokenIssued, __usdRemain);
    }

    /**
     * @dev ex counter
     */
    function exCount(uint256 usdAmount) private {
        uint256 __weiSold = usd2wei(usdAmount);
        uint256 __weiTopSales = usd2weiTopSales(usdAmount);
        
        _stageUsdSold[_stage] = _stageUsdSold[_stage].add(usdAmount);                   // stage sold, in USD
        _seasonWeiSold[_season] = _seasonWeiSold[_season].add(__weiSold);               // season sold, in wei
        _seasonWeiTopSales[_season] = _seasonWeiTopSales[_season].add(__weiTopSales);   // season Top-Sales, in wei
        _weiTopSales = _weiTopSales.add(__weiTopSales);                                 // sum Top-Sales, in wei

        _usdSeasonAccountPurchased[_season][msg.sender] = _usdSeasonAccountPurchased[_season][msg.sender].add(usdAmount);   // season => address => purchased, in USD

        // season referral account
        if (Voken.inWhitelist(msg.sender)) {
            address __cursor = msg.sender;
            for(uint16 i = 0; i < _whitelistRefRewards.length; i++) {
                address __refAccount = Voken.referrer(__cursor);
    
                if (__cursor != __refAccount) {
                    if (Voken.refCount(__refAccount) > i) {
                        if (!_seasonHasRefAccount[_season][__refAccount]) {
                            _seasonRefAccounts[_season].push(__refAccount);
                            _seasonHasRefAccount[_season][__refAccount] = true;
                        }

                        _usdSeasonAccountRef[_season][__refAccount] = _usdSeasonAccountRef[_season][__refAccount].add(usdAmount);
                    }
                }

                __cursor = Voken.referrer(__cursor);
            }
        }
    }

    /**
     * @dev Voken issued transfer
     */
    function vokenIssuedTransfer(uint256 amount) private returns (bool) {
        _vokenTxs = _vokenTxs.add(1);
        
        _vokenIssued = _vokenIssued.add(amount);
        _stageVokenIssued[_stage] = _stageVokenIssued[_stage].add(amount);
        _accountVokenIssued[msg.sender] = _accountVokenIssued[msg.sender].add(amount);

        return Voken.transfer(msg.sender, amount);
    }

    /**
     * @dev Voken bonus transfer
     */
    function vokenBonusTransfer(uint256 amount) private returns (bool) {
        _vokenBonusTxs = _vokenBonusTxs.add(1);

        _vokenBonus = _vokenBonus.add(amount);
        _accountVokenBonus[msg.sender] = _accountVokenBonus[msg.sender].add(amount);

        return Voken.transfer(msg.sender, amount);
    }

    /**
     * @dev Voken whitelisted transfer
     */
    function vokenWhitelistedTransfer(uint256 amount) private returns (bool) {
        _vokenWhitelistTxs = _vokenWhitelistTxs.add(1);

        _vokenWhitelist = _vokenWhitelist.add(amount);
        _accountVokenWhitelisted[msg.sender] = _accountVokenWhitelisted[msg.sender].add(amount);

        return Voken.transfer(msg.sender, amount);
    }

    /**
     * Close current stage
     */
    function closeStage() private returns (bool) {
        emit StageClosed(_stage, msg.sender);
        _stage = _stage.add(1);
        _vokenUsdPrice = stageVokenUsdPrice(_stage);
        _topSalesRatio = topSalesRatio(_stage);

        // Close current season
        uint16 __seasonNumber = calcSeason(_stage);
        if (_season < __seasonNumber) {
            emit SeasonClosed(_season, msg.sender);
            _season = __seasonNumber;
        }

        return true;
    }

    /**
     * @dev send referral rewards
     */
    function sendRefRewards(uint256 weiAmount) private {
        address __cursor = msg.sender;
        uint256 __weiRemain = weiAmount;

        // _whitelistRefRewards
        for(uint16 i = 0; i < _whitelistRefRewards.length; i++) {
            uint256 __weiReward = weiAmount.mul(_whitelistRefRewards[i]).div(100);
            address payable __receiver = address(uint160(Voken.referrer(__cursor)));

            if (__cursor != __receiver) {
                if (Voken.refCount(__receiver) > i) {
                    _weiRefRewarded = _weiRefRewarded.add(__weiReward);
                    _accountWeiRefRewarded[__receiver] = _accountWeiRefRewarded[__receiver].add(__weiReward);
                    __weiRemain = __weiRemain.sub(__weiReward);

                    __receiver.transfer(__weiReward);
                } else {
                    _weiPending = _weiPending.add(__weiReward);
                }
            } else {
                _weiPending = _weiPending.add(__weiReward);
            }

            __cursor = Voken.referrer(__cursor);
        }
    }
}
