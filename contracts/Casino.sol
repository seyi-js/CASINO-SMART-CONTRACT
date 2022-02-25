// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Casino {
    address owner;

    //Minimum bet a user has to make to partipate in the game
    uint public minimumBet = 0.1 ether;

    //Total amount of ether bet for this current game
    uint public totalBet;

    //total bets made by users
    uint public numberOfBets;

    //Maximum amount of bets that can be made for each game
    uint public maxAmountOfBets = 10;

    //Betting limit to avoid excess gas consumption
    uint public constant BETS_LIMIT = 100;

    //Winning number
    uint public winningNumber;

    address[] public players;


    //Each number has an array of players betting on it. Associate each number with a bunch of players.
    mapping(uint => address[]) numberBetPlayers;

    //The number that each player has bet on
    mapping(address => uint) playerBetsNumber;


    modifier onEndGame(){
        require(numberOfBets >= maxAmountOfBets, "Betting has not ended." );
        _;
    }

    function InititateCasino(uint _minimumBet, uint _maximumAmountOfBets) public{
        

        require(_minimumBet > 0, "Minimum bet must be greater than 0.");
        require(_maximumAmountOfBets > 0 && _maximumAmountOfBets <= BETS_LIMIT, "Maximum amount od bet must be greater than 0.");
        owner = msg.sender;
        minimumBet = _minimumBet;
        maxAmountOfBets = _maximumAmountOfBets;


    }


    // Checks if a player is in the current game
    function checkIfPlayerExists(address player) public returns (bool){
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

        numberOfBets ++;
        totalBet ++;

        if(numberOfBets >= maxAmountOfBets){
            //Generate number winner
        }
    }


}

