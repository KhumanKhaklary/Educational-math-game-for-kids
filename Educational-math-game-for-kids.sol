// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MathKidsGame {
    
    struct Player {
        string name;
        uint256 totalScore;
        uint256 gamesPlayed;
        uint256 lastPlayTime;
    }
    
    mapping(address => Player) public players;
    mapping(address => bool) public isRegistered;
    uint256 public totalPlayersCount;
    address[] public playerAddresses; // Array to store all player addresses
    
    event PlayerRegistered(address indexed player, string name);
    event GameCompleted(address indexed player, uint256 score, uint256 totalScore);
    event RewardEarned(address indexed player, uint256 amount);
    
    // Function 1: Register a new player
    function registerPlayer(string memory _name) public {
        require(!isRegistered[msg.sender], "Player already registered");
        require(bytes(_name).length > 0, "Name cannot be empty");
        
        players[msg.sender] = Player({
            name: _name,
            totalScore: 0,
            gamesPlayed: 0,
            lastPlayTime: 0
        });
        
        isRegistered[msg.sender] = true;
        playerAddresses.push(msg.sender); // Add to address array
        totalPlayersCount += 1;
        emit PlayerRegistered(msg.sender, _name);
    }
    
    // Function 2: Submit game results (addition/subtraction problems solved)
    function submitGameResult(uint256 _correctAnswers, uint256 _totalQuestions) public {
        require(isRegistered[msg.sender], "Player not registered");
        require(_totalQuestions > 0, "Total questions must be greater than 0");
        require(_correctAnswers <= _totalQuestions, "Correct answers cannot exceed total questions");
        
        Player storage player = players[msg.sender];
        
        // Calculate score based on percentage (0-100)
        uint256 gameScore = (_correctAnswers * 100) / _totalQuestions;
        
        player.totalScore += gameScore;
        player.gamesPlayed += 1;
        player.lastPlayTime = block.timestamp;
        
        emit GameCompleted(msg.sender, gameScore, player.totalScore);
        
        // Award bonus points for perfect scores
        if (gameScore == 100) {
            player.totalScore += 50; // Bonus points
            emit RewardEarned(msg.sender, 50);
        }
    }
    
    // Function 3: Get player statistics
    function getPlayerStats(address _player) public view returns (
        string memory name,
        uint256 totalScore,
        uint256 gamesPlayed,
        uint256 averageScore,
        uint256 lastPlayTime
    ) {
        require(isRegistered[_player], "Player not registered");
        
        Player memory player = players[_player];
        uint256 avgScore = player.gamesPlayed > 0 ? player.totalScore / player.gamesPlayed : 0;
        
        return (
            player.name,
            player.totalScore,
            player.gamesPlayed,
            avgScore,
            player.lastPlayTime
        );
    }
    
    // Function 4: Get leaderboard position
    function getPlayerRank(address _player) public view returns (uint256 rank) {
        require(isRegistered[_player], "Player not registered");
        
        uint256 playerScore = players[_player].totalScore;
        uint256 betterPlayers = 0;
        
        // Count players with higher total scores
        for (uint256 i = 0; i < playerAddresses.length; i++) {
            if (players[playerAddresses[i]].totalScore > playerScore) {
                betterPlayers++;
            }
        }
        
        // Return rank (1-based indexing)
        return betterPlayers + 1;
    }
    
    // Function 5: Reset player progress (for practice mode)
    function resetProgress() public {
        require(isRegistered[msg.sender], "Player not registered");
        
        Player storage player = players[msg.sender];
        player.totalScore = 0;
        player.gamesPlayed = 0;
        player.lastPlayTime = block.timestamp;
    }
    
    // Helper function to check if player exists
    function playerExists(address _player) public view returns (bool) {
        return isRegistered[_player];
    }
    
    // Get total registered players count
    function getTotalPlayers() public view returns (uint256) {
        return totalPlayersCount;
    }
}

