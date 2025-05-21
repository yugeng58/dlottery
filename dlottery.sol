// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DLottery {
    address public owner;
    uint256 public ticketPrice = 0.01 ether;
    uint256 public lotteryId;
    uint256 public ticketCount;
    
    struct Lottery {
        uint256 id;
        uint256 startTime;
        uint256 endTime;
        address winner;
        uint256 prize;
        bool completed;
    }
    
    mapping(uint256 => Lottery) public lotteries;
    mapping(uint256 => mapping(address => uint256)) public ticketsBought;
    mapping(uint256 => address[]) public participants;
    
    event TicketPurchased(address indexed buyer, uint256 lotteryId, uint256 numberOfTickets);
    event WinnerSelected(uint256 indexed lotteryId, address winner, uint256 prize);
    event NewLotteryStarted(uint256 indexed lotteryId, uint256 startTime, uint256 endTime);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    
    constructor() {
        owner = msg.sender;
        startNewLottery();
    }
    
    function startNewLottery() public onlyOwner {
        // Complete previous lottery if it exists
        if (lotteryId > 0 && !lotteries[lotteryId].completed) {
            selectWinner();
        }
        
        // Start new lottery
        lotteryId++;
        lotteries[lotteryId] = Lottery({
            id: lotteryId,
            startTime: block.timestamp,
            endTime: block.timestamp + 7 days,
            winner: address(0),
            prize: 0,
            completed: false
        });
        
        emit NewLotteryStarted(lotteryId, block.timestamp, block.timestamp + 7 days);
    }
    
    function buyTickets(uint256 numberOfTickets) public payable {
        require(!lotteries[lotteryId].completed, "Lottery already completed");
        require(block.timestamp < lotteries[lotteryId].endTime, "Lottery has ended");
        require(msg.value == numberOfTickets * ticketPrice, "Incorrect ETH amount");
        
        if (ticketsBought[lotteryId][msg.sender] == 0) {
            participants[lotteryId].push(msg.sender);
        }
        
        ticketsBought[lotteryId][msg.sender] += numberOfTickets;
        ticketCount += numberOfTickets;
        lotteries[lotteryId].prize += msg.value;
        
        emit TicketPurchased(msg.sender, lotteryId, numberOfTickets);
    }
    
    function selectWinner() public {
        require(block.timestamp >= lotteries[lotteryId].endTime || msg.sender == owner, "Lottery not yet ended");
        require(!lotteries[lotteryId].completed, "Lottery already completed");
        require(participants[lotteryId].length > 0, "No participants");
        
        uint256 totalTickets = ticketCount;
        require(totalTickets > 0, "No tickets purchased");
        
        // Generate random number based on block difficulty, timestamp, and addresses
        uint256 randomNumber = uint256(keccak256(abi.encodePacked(block.prevrandao, block.timestamp, participants[lotteryId])));
        uint256 winningTicket = randomNumber % totalTickets;
        
        uint256 ticketCounter = 0;
        address winnerAddress;
        
        // Find winner based on ticket number
        for (uint256 i = 0; i < participants[lotteryId].length; i++) {
            address participant = participants[lotteryId][i];
            uint256 participantTickets = ticketsBought[lotteryId][participant];
            
            if (winningTicket >= ticketCounter && winningTicket < ticketCounter + participantTickets) {
                winnerAddress = participant;
                break;
            }
            
            ticketCounter += participantTickets;
        }
        
        // Update lottery details
        lotteries[lotteryId].winner = winnerAddress;
        lotteries[lotteryId].completed = true;
        
        // Calculate prize (90% to winner, 10% to owner)
        uint256 prize = lotteries[lotteryId].prize;
        uint256 winnerPrize = (prize * 90) / 100;
        uint256 ownerFee = prize - winnerPrize;
        
        // Transfer prizes
        payable(winnerAddress).transfer(winnerPrize);
        payable(owner).transfer(ownerFee);
        
        emit WinnerSelected(lotteryId, winnerAddress, winnerPrize);
        
        // Reset ticket count for next lottery
        ticketCount = 0;
    }
    
    function getCurrentLotteryInfo() public view returns (
        uint256 id,
        uint256 startTime,
        uint256 endTime,
        uint256 prize,
        bool completed
    ) {
        Lottery memory currentLottery = lotteries[lotteryId];
        return (
            currentLottery.id,
            currentLottery.startTime,
            currentLottery.endTime,
            currentLottery.prize,
            currentLottery.completed
        );
    }
    
    function getParticipantsCount() public view returns (uint256) {
        return participants[lotteryId].length;
    }
    
    function getMyTickets() public view returns (uint256) {
        return ticketsBought[lotteryId][msg.sender];
    }
    
    function getTimeLeft() public view returns (uint256) {
        if (block.timestamp >= lotteries[lotteryId].endTime) {
            return 0;
        }
        return lotteries[lotteryId].endTime - block.timestamp;
    }
    
    function updateTicketPrice(uint256 newPrice) public onlyOwner {
        ticketPrice = newPrice;
    }
    
    function withdrawFunds() public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
    
    function getLotteryWinner(uint256 _lotteryId) public view returns (address) {
        return lotteries[_lotteryId].winner;
    }
}
