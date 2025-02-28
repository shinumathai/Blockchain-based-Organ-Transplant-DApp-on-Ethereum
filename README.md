# Blockchain based Organ Transplant DApp on Ethereum
# OT Chain
OT Chain is an ERC721-based decentralized application designed to streamline the organ donation and transplantation process, ensuring transparency, traceability, and increased efficiency. It allows for registration  of donors and recipients and automatically  matches them based on organ type, blood group, medical urgency, and waiting time. The project also incentivizes successful organ transplants by minting unique NFTs representing the transplant.

## Features
- Register as an organ donor or recipient
- Match organ donors with suitable recipients
- Mint NFTs representing successful organ transplants
- Store metadata (timestamp, donor address, recipient address, matched transaction hash) on minted NFTs

## Installation
To set up the project locally, follow these steps:

1. Clone the repository:
    ```bash
    git clone https://github.com//OrganTransplantNFT.git
    cd OrganTransplantNFT
    ```

2. Install the required dependencies:
    ```bash
    npm install
    ```

3. Compile the smart contracts:
    ```bash
    npx hardhat compile
    ```

4. Deploy the smart contracts:
    ```bash
    npx hardhat run scripts/deploy.js --network 
    ```

## Usage
To use the project, follow these instructions:

1. Register as an organ donor:
    ```solidity
    OrganTransplantNFT.registerDonor("Kidney", "O+");
    ```

2. Register as an organ recipient:
    ```solidity
    OrganTransplantNFT.registerRecipient("Kidney", "O+", "MedicalProofs123");
    ```

3. Match an organ transplant:
    ```solidity
    OrganTransplantNFT.matchOrganTransplant(donor_address);
    ```

4. Retrieve organ transplant details:
    ```solidity
    OrganTransplantNFT.getOrganTransplantDetails(tokenId);
    ```

## Contributing
To contribute, please follow these steps:

1. Fork the repository
2. Create a new branch (`git checkout -b feature-branch`)
3. Commit your changes (`git commit -m 'Add new feature'`)
4. Push to the branch (`git push origin feature-branch`)
5. Create a new Pull Request

## License
This project is licensed under the MIT License. 
