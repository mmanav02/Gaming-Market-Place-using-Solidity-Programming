// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GamingMarketplace {
    address public owner;
    mapping(address => bool) public developers;
    mapping(address => bool) public gamers;
    mapping(address => mapping(uint256 => GunSkin)) public gunSkins;

    struct GunSkin {
        address owner;
        uint256 price;
        bool isForSale;
    }

    event GunSkinReleased(uint256 indexed skinId, address indexed owner, uint256 price);
    event GunSkinPurchased(uint256 indexed skinId, address indexed buyer, address indexed seller, uint256 price);
    event GunSkinPutForSale(uint256 indexed skinId, address indexed owner, uint256 price);
    event GunSkinRemovedFromSale(uint256 indexed skinId, address indexed owner);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    modifier onlyDeveloper() {
        require(developers[msg.sender], "Not a developer");
        _;
    }

    modifier onlyGamer() {
        require(gamers[msg.sender], "Not a gamer");
        _;
    }

    constructor() {
        owner = msg.sender;
        developers[owner] = true;
        gamers[owner] = true;
    }

    function addDeveloper(address _developer) external onlyOwner {
        developers[_developer] = true;
    }

    function addGamer(address _gamer) external onlyOwner {
        gamers[_gamer] = true;
    }

    function releaseGunSkin(uint256 _skinId, uint256 _price) external onlyOwner {
        require(gunSkins[owner][_skinId].price == 0, "Skin with the same ID already exists");
        gunSkins[owner][_skinId] = GunSkin(msg.sender, _price, false);
        emit GunSkinReleased(_skinId, msg.sender, _price);
    }

    function buyGunSkin(uint256 _skinId) external payable onlyGamer {
        GunSkin storage skin = gunSkins[owner][_skinId];
        require(skin.price > 0, "Gun skin does not exist");
        require(skin.isForSale, "Gun skin is not for sale");
        require(msg.value >= skin.price, "Insufficient funds");

        address previousOwner = skin.owner;
        skin.owner = msg.sender;
        skin.isForSale = false;

        payable(previousOwner).transfer(msg.value);
        emit GunSkinPurchased(_skinId, msg.sender, previousOwner, skin.price);
    }

    function putGunSkinForSale(uint256 _skinId, uint256 _price) external onlyDeveloper {
        GunSkin storage skin = gunSkins[msg.sender][_skinId];
        require(skin.price > 0, "Gun skin does not exist");
        require(skin.owner == msg.sender, "Not the owner of the gun skin");

        skin.price = _price;
        skin.isForSale = true;

        emit GunSkinPutForSale(_skinId, msg.sender, _price);
    }

    function removeGunSkinFromSale(uint256 _skinId) external onlyDeveloper {
        GunSkin storage skin = gunSkins[msg.sender][_skinId];
        require(skin.price > 0, "Gun skin does not exist");
        require(skin.owner == msg.sender, "Not the owner of the gun skin");

        skin.isForSale = false;

        emit GunSkinRemovedFromSale(_skinId, msg.sender);
    }
}
