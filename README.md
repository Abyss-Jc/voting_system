# Voting System on Sui Blockchain

## Overview
This project implements a simple and secure voting system as a Move smart contract for the Sui blockchain. It allows the creation of polls, issuance of voting tickets (NFTs), voting, and querying results. The system ensures that each user can only vote once per poll and provides transparency through event emission.

## Features
- **Poll Creation:** Admins can create polls with custom questions and options.
- **Voting Tickets:** Each eligible voter receives a unique NFT ticket to vote.
- **Single Vote Enforcement:** Each address can vote only once per poll.
- **Result Querying:** Anyone can check the vote count for each option.
- **Event Emission:** Every vote emits an event for tracking and analytics.

## How It Works
1. **Create a Poll:**
   - Use the `create_poll` function, passing the question and options as UTF-8 encoded byte arrays.
2. **Issue Voting Tickets:**
   - Use `issue_voting_ticket` to send a ticket NFT to each voter.
3. **Vote:**
   - Voters use their ticket to vote for an option. The ticket is destroyed after voting to prevent reuse.
4. **Close Poll:**
   - Use `close_poll` to end voting for a poll.
5. **Query Results:**
   - Use `get_vote_count` to check votes for each option.

## Usage Instructions

### 1. Publish the Module
Publish the Move module to Sui testnet or mainnet:
```pwsh
sui client publish --gas-budget 100000000
```

### 2. Create a Poll
Encode your question and options as UTF-8 bytes. Example using Python:
```python
question = "¿Cuál es tu color favorito?"
options = ["Rojo", "Azul", "Verde"]
print(list(question.encode("utf-8")))
for opt in options:
    print(list(opt.encode("utf-8")))
```
Call the function:
```pwsh
sui client call --package <package_address> --module voting_system --function create_poll --args "[bytes]" "[[bytes],[bytes],[bytes]]" --gas-budget 100000000
```

### 3. Issue Voting Tickets
```pwsh
sui client call --package <package_address> --module voting_system --function issue_voting_ticket --args <poll_id> <recipient_address> --gas-budget 100000000
```

### 4. Vote
```pwsh
sui client call --package <package_address> --module voting_system --function vote --args <poll_id> <ticket_id> <option_index> --gas-budget 100000000
```

### 5. Close Poll
```pwsh
sui client call --package <package_address> --module voting_system --function close_poll --args <poll_id> --gas-budget 100000000
```

### 6. Query Results
Check the poll object state using Sui Explorer or CLI to see vote counts and voters.

## Notes
- All string data must be passed as UTF-8 encoded bytes.
- Each ticket can only be used once.


