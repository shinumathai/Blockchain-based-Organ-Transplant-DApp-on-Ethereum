pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract OrganTransplantNFT is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    struct OrganDonor {
        address donor;
        string organType;
        string bloodGroup;
        bool isAvailable;
    }

    struct OrganRecipient {
        address recipient;
        string organType;
        string bloodGroup;
        string medicalProofs;
        bool isRequestingOrgan;
    }

    struct OrganTransplant {
        uint256 organId;
        address donor;
        address recipient;
        uint256 timestamp;
        uint256 tokenId;
        uint256 incentives;
    }

    mapping(address => OrganDonor) public organDonors;
    mapping(address => OrganRecipient) public organRecipients;
    mapping(uint256 => OrganTransplant) public organTransplants;
    mapping(uint256 => string) private _tokenURIs;
    address[] public registeredRecipients;

    event OrganDonorRegistered(address donor, string organType, string bloodGroup, bool isAvailable);
    event OrganRecipientRegistered(address recipient, string organType, string bloodGroup, string medicalProofs, bool isRequestingOrgan);
    event OrganTransplantMatched(uint256 organId, address donor, address recipient, uint256 tokenId);

    constructor() ERC721("OrganTransplantNFT", "OTN") {}

    function registerDonor(string memory organType, string memory bloodGroup) public {
        require(organDonors[msg.sender].donor == address(0), "Donor already registered");
        organDonors[msg.sender] = OrganDonor(msg.sender, organType, bloodGroup, true);
        emit OrganDonorRegistered(msg.sender, organType, bloodGroup, true);
    }

    function registerRecipient(string memory organType, string memory bloodGroup, string memory medicalProofs) public {
        require(organRecipients[msg.sender].recipient == address(0), "Recipient already registered");
        organRecipients[msg.sender] = OrganRecipient(msg.sender, organType, bloodGroup, medicalProofs, true);
        registeredRecipients.push(msg.sender);
        emit OrganRecipientRegistered(msg.sender, organType, bloodGroup, medicalProofs, true);
    }

    function findMatchingRecipient(address donor) private view returns (address) {
        address matchingRecipient = address(0);

        for (uint256 i = 0; i < registeredRecipients.length; i++) {
            address candidate = registeredRecipients[i];
            if (organRecipients[candidate].recipient != address(0) &&
                organRecipients[candidate].isRequestingOrgan &&
                keccak256(abi.encodePacked(organDonors[donor].organType)) == keccak256(abi.encodePacked(organRecipients[candidate].organType)) &&
                keccak256(abi.encodePacked(organDonors[donor].bloodGroup)) == keccak256(abi.encodePacked(organRecipients[candidate].bloodGroup))) {
                matchingRecipient = candidate;
                break;
            }
        }

        return matchingRecipient;
    }

    function _setTokenURI(uint256 tokenId, string memory uri) internal virtual {
      _tokenURIs[tokenId] = uri;
    }
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
    require(_exists(tokenId), "ERC721URIStorage: URI query for nonexistent token");
    return _tokenURIs[tokenId];
    }

    function matchOrganTransplant(address donor) public {
    require(organDonors[donor].donor == donor, "Invalid donor address");

    address recipient = findMatchingRecipient(donor);
    require(recipient != address(0), "No suitable recipient found");

    _tokenIds.increment();
    uint256 tokenId = _tokenIds.current();
    uint256 organId = tokenId;
    uint256 timestamp = block.timestamp;
    uint256 incentives = 0; // Set incentives as required

    // Set donor and recipient status to unavailable
    organDonors[donor].isAvailable = false;
    organRecipients[recipient].isRequestingOrgan = false;

    _mint(recipient, tokenId);
    organTransplants[tokenId] = OrganTransplant(organId, donor, recipient, timestamp, tokenId, incentives);

    // Store metadata (timestamp, donor address, recipient address, matched transaction hash) on the minted NFT/token
    string memory metadata = string(abi.encodePacked(
        '{"timestamp":', uint2str(timestamp),
        ', "donor":"', addressToString(donor),
        '", "recipient":"', addressToString(recipient),
        '", "matchedTransactionHash":"', bytes32ToString(blockhash(block.number - 1)), '"}'
    ));
    _setTokenURI(tokenId, metadata);

    emit OrganTransplantMatched(organId, donor, recipient, tokenId);
}

function getOrganTransplantDetails(uint256 tokenId) public view returns (uint256 organId, address donor, address recipient, uint256 timestamp, uint256 incentives) {
    OrganTransplant memory transplant = organTransplants[tokenId];
    return (transplant.organId, transplant.donor, transplant.recipient, transplant.timestamp, transplant.incentives);
}

function setDonorAvailability(bool availability) public {
    require(organDonors[msg.sender].donor == msg.sender, "Not a registered donor");
    organDonors[msg.sender].isAvailable = availability;
}

function setRecipientRequestStatus(bool requestStatus) public {
    require(organRecipients[msg.sender].recipient == msg.sender, "Not a registered recipient");
    organRecipients[msg.sender].isRequestingOrgan = requestStatus;
}

// Helper functions for metadata encoding
function uint2str(uint256 _i) private pure returns (string memory _uintAsString) {
    if (_i == 0) {
        return "0";
    }
    uint256 j = _i;
    uint256 len;
    while (j != 0) {
        len++;
        j /= 10;
    }
    bytes memory bstr = new bytes(len);
    uint256 k = len - 1;
    while (_i != 0) {
        bstr[k--] = bytes1(uint8(48 + _i % 10));
        _i /= 10;
    }
    return string(bstr);
}

function addressToString(address _addr) private pure returns (string memory) {
    bytes32 value = bytes32(uint256(uint160(_addr)));
    bytes memory alphabet = "0123456789abcdef";
    bytes memory str = new bytes(42);
    str[0] = '0';
    str[1] = 'x';
    for (uint256 i = 0; i < 20; i++){
    str[2 + i * 2] = alphabet[uint8(value[i + 12] >> 4)];
    str[3 + i * 2] = alphabet[uint8(value[i + 12] & 0x0f)];
    }
return string(str);
}  
function bytes32ToString(bytes32 _bytes32) private pure returns (string memory) {
    bytes memory alphabet = "0123456789abcdef";
    bytes memory str = new bytes(66);
    str[0] = '0';
    str[1] = 'x';
    for (uint256 i = 0; i < 32; i++) {
        str[2 + i * 2] = alphabet[uint8(_bytes32[i] >> 4)];
        str[3 + i * 2] = alphabet[uint8(_bytes32[i] & 0x0f)];
    }
    return string(str);
}
}
    