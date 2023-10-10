// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RentalContract {
    address public owner;

    struct Tenant {
        string fullName;
        string tenantAddress;
        address walletAddress;
        bool hasIssue;
    }

    struct RentalPlace {
        string location;
        uint256 rentStartDate;
        uint256 rentEndDate;
        address owner;
        bool isRented;
    }

    mapping(address => Tenant) public tenants;
    mapping(address => RentalPlace) public rentalPlaces;

    event TenantAdded(address indexed tenantWallet, string fullName, string tenantAddress);
    event RentalPlaceAdded(address indexed rentalPlaceOwner, string location);
    event RentStarted(address indexed tenantWallet, address indexed rentalPlaceOwner, uint256 rentStartDate);
    event RentEnded(address indexed tenantWallet, address indexed rentalPlaceOwner, uint256 rentEndDate, bool hasIssue);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can access this.");
        _;
    }

    function addTenant(string memory fullName, string memory tenantAddress, address tenantWallet) public {
        tenants[tenantWallet] = Tenant(fullName, tenantAddress, tenantWallet, false);
        emit TenantAdded(tenantWallet, fullName, tenantAddress);
    }

    function addRentalPlace(string memory location, uint256 rentStartDate, uint256 rentEndDate) public onlyOwner {
        rentalPlaces[msg.sender] = RentalPlace(location, rentStartDate, rentEndDate, msg.sender, false);
        emit RentalPlaceAdded(msg.sender, location);
    }

    function startRent(address tenantWallet) public onlyOwner {
        RentalPlace storage rentalPlace = rentalPlaces[msg.sender];
        Tenant storage tenant = tenants[tenantWallet];

        require(!rentalPlace.isRented, "The rental place is already rented.");

        rentalPlace.isRented = true;
        emit RentStarted(tenantWallet, rentalPlace.owner, rentalPlace.rentStartDate);
    }

    function endRent(address tenantWallet, bool hasIssue) public onlyOwner {
        RentalPlace storage rentalPlace = rentalPlaces[msg.sender];
        Tenant storage tenant = tenants[tenantWallet];

        require(rentalPlace.isRented, "The rental place is not rented.");

        rentalPlace.isRented = false;
        tenant.hasIssue = hasIssue;
        emit RentEnded(tenantWallet, rentalPlace.owner, rentalPlace.rentEndDate, hasIssue);
    }
}
