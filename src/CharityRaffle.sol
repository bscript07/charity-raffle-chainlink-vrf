// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";
import {IVRFCoordinatorV2Plus} from "./VRFConsumerBaseV2PlusCustom.sol";
import {VRFConsumerBaseV2PlusCustom} from "./VRFConsumerBaseV2PlusCustom.sol";

error InsufficientValue();
error InvalidProof();
error VRFRequestAlreadyMade();
error InvalidRequest();
error InvalidRandomWords();
error NotAWinner();
error TransferFailed();
error InsufficientFunds();
error WinnersNotSelected();

contract CharityRaffle is OwnableUpgradeable, VRFConsumerBaseV2PlusCustom {
    uint256 public constant DENOMINATOR = 10000;

    uint256 public ticketPrice;
    uint256 public numOfWinners;
    uint256 public prizePercentageBPS;
    address public charityWallet;
    uint256 public vrfSubscriptionId;
    bytes32 public vrfKeyHash;
    uint256 public vrfRequestID;
    bytes32 public merkleRoot;

    uint256 public winnerReward;
    uint256 public charityFunds;
    bool public winnersSelected;

    address[] public participants;
    mapping(address => bool) public winners;

    event WinnersSelected(address[] winners);
    event TicketPurchased(address indexed buyer, uint256 qty);
    event RandomnessRequested(uint256 requestId);
    event PrizeClaimed(address indexed winner);
    event CharityWithdrawal(uint256 amount);

    function initialize(
        address _owner,
        address _charityWallet,
        uint256 _vrfSubscriptionId,
        bytes32 _keyHash,
        bytes32 _merkleRoot
    ) public initializer {
        __Ownable_init(_owner);
        s_vrfCoordinator = IVRFCoordinatorV2Plus(0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B);
        ticketPrice = 0.001 ether;
        numOfWinners = 2;
        prizePercentageBPS = 3000; // 30% funds allocate for prizes
        charityWallet = _charityWallet;
        vrfSubscriptionId = _vrfSubscriptionId;
        vrfKeyHash = _keyHash;
        merkleRoot = _merkleRoot;
    }

    function buyTicket(uint256 _qty, bytes32[] memory _proof) external payable {
        require(msg.value == ticketPrice * _qty, InsufficientValue());

        bytes32 leaf = keccak256(abi.encode(msg.sender));

        // // Verify proof for current participant
        require(MerkleProof.verify(_proof, merkleRoot, keccak256(abi.encodePacked(leaf))), InvalidProof());

        for (uint256 i = 0; i < _qty; i++) {
            participants.push(msg.sender);
        }

        emit TicketPurchased(msg.sender, _qty);
    }

    function requestRandomWinners() external onlyOwner {
        require(vrfRequestID == 0, VRFRequestAlreadyMade());

        vrfRequestID = s_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: vrfKeyHash,
                subId: vrfSubscriptionId,
                requestConfirmations: 3,
                callbackGasLimit: 1000000,
                numWords: uint32(numOfWinners),
                extraArgs: VRFV2PlusClient._argsToBytes(
                    // Set nativePayment to true to pay for VRF requests with Sepolia ETH instead of LINK
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: true})
                )
            })
        );
        uint256 fundsCollected = participants.length * ticketPrice;
        winnerReward = ((fundsCollected * prizePercentageBPS) / DENOMINATOR) / numOfWinners;
        charityFunds = fundsCollected - winnerReward * numOfWinners;

        emit RandomnessRequested(vrfRequestID);
    }

    function fulfillRandomWords(uint256 requestId, uint256[] calldata randomWords) internal override {
        require(requestId == vrfRequestID, InvalidRequest());
        require(randomWords.length == numOfWinners, InvalidRandomWords());

        address[] memory winnersArray = new address[](numOfWinners);

        for (uint256 i = 0; i < numOfWinners; i++) {
            uint256 randomWord = randomWords[i];

            while (true) {
                address winner = participants[randomWord % participants.length];

                if (!winners[winner]) {
                    winners[winner] = true;
                    winnersArray[i] = winner;
                    break;
                }

                randomWord++;
            }
        }

        winnersSelected = true;

        emit WinnersSelected(winnersArray);
    }

    function claimPrize() external {
        require(winners[msg.sender], NotAWinner());

        winners[msg.sender] = false;

        (bool ok,) = payable(msg.sender).call{value: winnerReward}("");
        require(ok, TransferFailed());

        emit PrizeClaimed(msg.sender);
    }

    function claimCharityFunds() external onlyOwner {
        require(charityFunds > 0, InsufficientFunds());
        require(winnersSelected, WinnersNotSelected());

        (bool ok,) = payable(msg.sender).call{value: charityFunds}("");
        require(ok, TransferFailed());

        emit CharityWithdrawal(charityFunds);
    }

    function owner() public view override(OwnableUpgradeable, VRFConsumerBaseV2PlusCustom) returns (address) {
        return OwnableUpgradeable.owner();
    }
}
