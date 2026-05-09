// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
CCC MASTER ECOSYSTEM - VERSION FINAL
*/

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// =========================
// MASTER CONTROLLER
// =========================
contract MasterController is Ownable {

    address public masterWallet;

    mapping(address => bool) public authorizedTokens;

    event TokenRegistered(address token);
    event MasterUpdated(address newMaster);

    constructor(address _masterWallet) Ownable(msg.sender) {
        require(_masterWallet != address(0), "Invalid master");
        masterWallet = _masterWallet;
    }

    function registerToken(address token) external onlyOwner {
        authorizedTokens[token] = true;
        emit TokenRegistered(token);
    }

    function updateMaster(address _new) external onlyOwner {
        require(_new != address(0));
        masterWallet = _new;
        emit MasterUpdated(_new);
    }
}

// =========================
// CCC TOKEN
// =========================
contract CarbonCreditCoins is ERC20, Ownable {

    uint256 public constant MAX_SUPPLY = 20000000000 * 10**18;

    address public masterWallet;
    address public reserveWallet;

    string public imageURI;

    bool public locked = true;

    struct Certificate {
        string name;
        string link;
        uint256 timestamp;
        string description;
    }

    Certificate[] public certificates;

    event CertificateAdded(uint256 id);
    event TokensLocked(bool status);
    event MasterChanged(address newMaster);

    constructor(
        address _masterWallet,
        address _reserveWallet,
        string memory _imageURI
    )
        ERC20("Carbon Credit Coins", "CCC")
        Ownable(msg.sender)
    {
        require(_masterWallet != address(0));
        require(_reserveWallet != address(0));

        masterWallet = _masterWallet;
        reserveWallet = _reserveWallet;
        imageURI = _imageURI;

        // 🔥 MINT TOTAL → MASTER
        _mint(masterWallet, MAX_SUPPLY);

        // documentos
        certificates.push(Certificate(
            "Project Documentation",
            "https://documentccc.digital/",
            block.timestamp,
            "Environmental documentation"
        ));

        certificates.push(Certificate(
            "Audit Reports",
            "https://documentccc.online/",
            block.timestamp,
            "Audit reports"
        ));
    }

    // =========================
    // CONTROLE TOTAL MASTER
    // =========================
    function _update(address from, address to, uint256 value) internal override {

        if (locked) {
            require(from == address(0) || from == masterWallet, "Only master controls transfers");
        }

        super._update(from, to, value);
    }

    // =========================
    // ADMIN
    // =========================
    function unlockTransfers() external onlyOwner {
        locked = false;
        emit TokensLocked(false);
    }

    function lockTransfers() external onlyOwner {
        locked = true;
        emit TokensLocked(true);
    }

    function changeMaster(address _new) external onlyOwner {
        require(_new != address(0));
        masterWallet = _new;
        emit MasterChanged(_new);
    }

    function addCertificate(
        string memory name,
        string memory link,
        string memory desc
    ) external onlyOwner {

        certificates.push(
            Certificate(name, link, block.timestamp, desc)
        );

        emit CertificateAdded(certificates.length - 1);
    }

    function getCertificatesCount() external view returns (uint256) {
        return certificates.length;
    }
}
