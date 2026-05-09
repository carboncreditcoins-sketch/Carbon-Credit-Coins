// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
MASTER SYSTEM - CARBON CREDIT COINS (CCC)
Full Professional Architecture
*/

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IERC20Ext {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
}

/* =========================
   MASTER CONTROLLER
========================= */
contract MasterController is Ownable {

    address public masterWallet;

    event Forwarded(address token, uint256 amount);
    event Received(address from, uint256 amount);

    constructor(address _masterWallet) Ownable(msg.sender) {
        require(_masterWallet != address(0), "Invalid master");
        masterWallet = _masterWallet;
    }

    receive() external payable {
        emit Received(msg.sender, msg.value);
        payable(masterWallet).transfer(msg.value);
    }

    function forwardToken(address token) public {
        uint256 balance = IERC20Ext(token).balanceOf(address(this));
        require(balance > 0, "No balance");
        IERC20Ext(token).transfer(masterWallet, balance);

        emit Forwarded(token, balance);
    }

    function changeMaster(address newMaster) external onlyOwner {
        require(newMaster != address(0), "Invalid");
        masterWallet = newMaster;
    }
}

/* =========================
   CCC TOKEN
========================= */
contract CarbonCreditCoins is ERC20, Ownable {

    uint256 public constant MAX_SUPPLY = 20000000000 * 10**18;

    string public imageURI;
    string public projectInfo;

    address public reserveWallet;
    address public masterWallet;

    struct Certificate {
        string name;
        string link;
        uint256 timestamp;
        string description;
    }

    Certificate[] public certificates;

    event CertificateAdded(uint256 id, string name);

    constructor(
        address _masterWallet,
        address _reserveWallet,
        string memory _imageURI
    )
        ERC20("Carbon Credit Coins", "CCC")
        Ownable(_masterWallet)
    {
        require(_masterWallet != address(0), "Invalid master");

        masterWallet = _masterWallet;
        reserveWallet = _reserveWallet;
        imageURI = _imageURI;

        projectInfo = "CCC token with transparency layer";

        _mint(_masterWallet, MAX_SUPPLY);

        certificates.push(Certificate(
            "Whitepaper",
            "https://whitepaperccc.online/",
            block.timestamp,
            "Official document"
        ));
    }

    function addCertificate(
        string memory name,
        string memory link,
        string memory desc
    ) external onlyOwner {
        certificates.push(
            Certificate(name, link, block.timestamp, desc)
        );
    }

    function getCertificatesCount() external view returns (uint256) {
        return certificates.length;
    }
}

/* =========================
   FACTORY (AUTO DEPLOY)
========================= */
contract TokenFactory is Ownable {

    address public masterWallet;

    event TokenCreated(address token);

    constructor(address _masterWallet) Ownable(msg.sender) {
        masterWallet = _masterWallet;
    }

    function createCCC(
        address reserveWallet,
        string memory imageURI
    ) external onlyOwner returns (address) {

        CarbonCreditCoins token = new CarbonCreditCoins(
            masterWallet,
            reserveWallet,
            imageURI
        );

        emit TokenCreated(address(token));

        return address(token);
    }
}
