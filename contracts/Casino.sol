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

    Player[] private winners;

    struct Player {
        address addr;//User Address
        uint number;//The number that was voted for;
    }

    Player[] public  players;



    modifier onEndGame(){
        require(numberOfBets >= maxAmountOfBets, "Betting has not ended." );
        _;
    }


    constructor()  {
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
        bool answer = false;
        for(uint i = 0; i < players.length; i++){
            if(players[i].addr == player){
                answer = true;
                break;
            }


        }
        return answer;
    }

    function bet(uint numberToBet) public payable{
        require(numberOfBets < maxAmountOfBets, "Maximum number of bets reached.");

        require(!checkIfPlayerExists(msg.sender), "User exists.");


        require(numberToBet >= 1 && numberToBet <=10, "number to bet must be between 1 - 10.");

        require(msg.value >= minimumBet, "Amount cannot be less than 0.1 ether ");


        Player memory thePlayer =Player({
            addr:msg.sender,
            number:numberToBet
        });

        players.push(thePlayer);

       

        numberOfBets ++;
        totalBet ++;

        if(numberOfBets >= maxAmountOfBets){
           GenerateRandomNumber();
        }
    }

    function GenerateRandomNumber () private{
        uint random_number = uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp)));

        winningNumber = random_number % 10 + 1;

        distributePrizes();
    }


    function GetWinners() private returns(Player[] storage){
       

        for(uint i =0; i < players.length;  i++){
            if(players[i].number == winningNumber){
                winners.push(players[i]);
            }
        }

        return winners;
    }

// Send Ether to winners and reset the game.
function distributePrizes() private onEndGame {



    uint winnerEtherAmount = totalBet /winners.length;


    //Loop through the winners and send ether to them

    for(uint i= 0; i<winners.length; i++){
        
        payable(winners[i].addr).transfer(winnerEtherAmount);
    }


    

    delete winners;

    totalBet =0;
    numberOfBets =0;
}
    


}

