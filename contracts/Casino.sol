// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Casino {
    address payable owner;

    //Minimum bet a user has to make to partipate in the game
    uint public minimumBet = 0.1 ether;

    //Total amount of ether bet for this current game
    uint public totalBet;

    //total number bets made by users
    uint public numberOfBets;

    //Maximum amount of bets that can be made for each game
    uint public maxAmountOfBets = 10;

    //Betting limit to avoid excess gas consumption
    uint public constant BETS_LIMIT = 100;

    //Winning number
    uint public winningNumber;

    address[] public  players;


    //Each number has an array of players betting on it. Associate each number with a bunch of players.
    mapping(uint => address[]) public numberBetPlayers;

    //The number that each player has bet on
    mapping(address => uint) public playerBetsNumber;


    modifier onEndGame(){
        require(numberOfBets >= maxAmountOfBets, "Betting has not ended." );
        _;
    }


    constructor() public {
        InititateCasino(1,10);
    }
    function InititateCasino(uint _minimumBet, uint _maximumAmountOfBets) private{
        

        require(_minimumBet > 0, "Minimum bet must be greater than 0.");
        require(_maximumAmountOfBets > 0 && _maximumAmountOfBets <= BETS_LIMIT, "Maximum amount od bet must be greater than 0.");
        owner = payable(msg.sender);
        minimumBet = _minimumBet;
        maxAmountOfBets = _maximumAmountOfBets;


    }


    // Checks if a player is in the current game
    function checkIfPlayerExists(address player) public view returns (bool){
        if(playerBetsNumber[player] > 0) {
            return true;
        }

        return false;
    }

    function bet(uint numberToBet) public payable{
        require(numberOfBets < maxAmountOfBets, "Maximum number of bets reached.");

        require(!checkIfPlayerExists(msg.sender), "User exists.");


        require(numberToBet >= 1 && numberToBet <=10, "number to bet must be between 1 - 10.");

        require(msg.value >= minimumBet, "Amount cannot be less than 0.1 ether ");


        playerBetsNumber[msg.sender] = numberToBet;

        //Add the user address to the list of punters for a particular number;
        numberBetPlayers[numberToBet].push(msg.sender);
        //players.push(msg.sender);

        numberOfBets ++;
        totalBet ++;

        if(numberOfBets >= maxAmountOfBets){
           GenerateRandomNumber();
        }
    }

    function GenerateRandomNumber () private  returns(uint){
        uint random_number = uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players)));

        winningNumber = random_number % 10 + 1;

        distributePrizes();
    }


// Send Ether to winners and reset the game.
function distributePrizes() private onEndGame {
    uint winnerEtherAmount = totalBet / numberBetPlayers[winningNumber].length;

    //numberBetPlayers[winningNumber] pulls out the number and voters attached

    //Loop through the winners and send ether to them

    for(uint i= 0; i<numberBetPlayers[winningNumber].length; i++){
        
        payable(numberBetPlayers[winningNumber][i]).transfer(winnerEtherAmount);
    }


    // for(uint i= 1; i <= 10; i++){
    //     numberBetPlayers[i].length = 0;
    // }

    totalBet =0;
    numberOfBets =0;
}
    


}

