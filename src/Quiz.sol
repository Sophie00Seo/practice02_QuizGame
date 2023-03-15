// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Quiz{
    struct Quiz_item {
      uint id;
      string question;
      string answer;
      uint min_bet;
      uint max_bet;
      bool solved;
   }
    
    mapping(address => uint256)[] public bets;
    uint public vault_balance;

    address owner;

    uint quiz_num;
    mapping(uint => Quiz_item) public quiz_map; // index == id

    constructor () {
        owner = msg.sender;

        Quiz_item memory q;
        q.id = 1;
        q.question = "1+1=?";
        q.answer = "2";
        q.min_bet = 1 ether;
        q.max_bet = 2 ether;
        quiz_num = 0;
        addQuiz(q);
    }

    modifier _onlyOwner(){
        require(owner == msg.sender, "Not Owner");
        _;
    }

    receive() external payable{
        vault_balance += msg.value;
    }

    function addQuiz(Quiz_item memory q) public _onlyOwner {
        quiz_map[q.id] = q;
        quiz_num++;
        bets.push();
    }

    function getAnswer(uint quizId) public view _onlyOwner returns (string memory){
        return quiz_map[quizId].answer;
    }

    function getQuiz(uint quizId) public view returns (Quiz_item memory) {
        Quiz_item memory newquiz = quiz_map[quizId];
        newquiz.answer = "";
        return newquiz;
    }

    function getQuizNum() public view returns (uint){
        return quiz_num;
    }
    
    function betToPlay(uint quizId) public payable {
        require(quiz_map[quizId].min_bet <= msg.value, "too small amount for bet");
        require(quiz_map[quizId].max_bet >= msg.value, "too big amount for bet");
        
        bets[quizId-1][msg.sender] += msg.value;
    }

    function solveQuiz(uint quizId, string memory ans) public returns (bool) {
        string memory quiz_answer = quiz_map[quizId].answer;
        if(keccak256(abi.encode(quiz_answer)) == keccak256(abi.encode(ans))){
            vault_balance -= bets[quizId-1][msg.sender];
            quiz_map[quizId].solved = true;
            return true;
        }
        vault_balance += bets[quizId-1][msg.sender];
        bets[quizId-1][msg.sender] = 0;
        return false;
    }

    function claim() public {
        uint sum = 0;
        for(uint i=0; i<quiz_num; i++){
            if(quiz_map[i+1].solved) sum += bets[i][msg.sender] * 2;
        }
        require(sum > 0, "nothing to claim");
        payable(msg.sender).transfer(sum);
    }

}