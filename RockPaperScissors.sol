pragma solidity ^0.7.0;

contract RockPaperScissors {
    enum Choice { Rock, Paper, Scissors }

    struct Player {
        address addr;
        bytes32 hash;
        Choice choice;
        bool revealed;
    }

    mapping(address => Player) public players;

    event Commit(address player, bytes32 hash);

    event Reveal(address player, Choice choice);

    modifier onlyOnce {
        require(players[msg.sender].hash == 0, "You have already committed a choice");
        _;
    }

    // Function to commit a player's choice
    function commit(bytes32 hash) public onlyOnce {
        players[msg.sender].addr = msg.sender;
        players[msg.sender].hash = hash;
        emit Commit(msg.sender, hash);
    }

    // Function to reveal a player's choice
    function reveal(Choice choice) public {
        require(!players[msg.sender].revealed, "You have already revealed your choice");
        require(keccak256(abi.encodePacked(choice)) == players[msg.sender].hash, "Invalid hash");
        players[msg.sender].choice = choice;
        players[msg.sender].revealed = true;
        emit Reveal(msg.sender, choice);
    }

    // Function to determine the winner of the game
    function getWinner() public view returns (address) {
        // Ensure that both players have revealed their choices
        require(players[msg.sender].revealed, "You have not revealed your choice");
        require(players[players[msg.sender].addr].revealed, "Other player has not revealed their choice");

        // Determine the winner based on the choices
        if (players[msg.sender].choice == players[players[msg.sender].addr].choice) {
            return address(0); // draw
        } else if (
            (players[msg.sender].choice == Choice.Rock && players[players[msg.sender].addr].choice == Choice.Scissors) ||
            (players[msg.sender].choice == Choice.Paper && players[players[msg.sender].addr].choice == Choice.Rock) ||
            (players[msg.sender].choice == Choice.Scissors && players[players[msg.sender].addr].choice == Choice.Paper)
        ) {
            return msg.sender; // sender wins
        } else {
            return players[msg.sender].addr; // other player wins
        }
    }
}
