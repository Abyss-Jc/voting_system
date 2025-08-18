module voting::voting_system;

use std::string;
use sui::event;


// Objeto principal de votación
public struct Poll has key {
    id: UID,
    question: string::String, // Fixed unbound type reference
    options: vector<string::String>,
    votes: vector<VoteEntry>, // Updated to use VoteEntry struct
    voters: vector<address>, // Updated to use vector instead of VecSet
    is_active: bool,
}

// Objeto NFT para control de votos
public struct VotingTicket has key, store {
    id: UID,
}

// Evento para seguimiento
public struct VoteEvent has copy, drop {
    poll_id: ID,
    voter: address,
    option_index: u8,
}

public struct VoteEntry has copy, drop, store { // Made struct public
    option_index: u8,
    count: u64,
}

// ===== FUNCIONES PÚBLICAS =====

// 1. Crear nueva votación
public fun create_poll(
    question: vector<u8>,
    options: vector<vector<u8>>,
    ctx: &mut TxContext,
) {
    let poll = Poll {
        id: object::new(ctx),
        question: string::utf8(question),
        options: create_options_vector(options),
        votes: vector::empty(), // Updated to use vector for key-value pairs
        voters: vector::empty(), // Initialize as empty vector
        is_active: true,
    };

    // Emitir como objeto compartido
    transfer::share_object(poll);
}

// 2. Emitir tickets de votación (NFTs)
public fun issue_voting_ticket(poll: &mut Poll, recipient: address, ctx: &mut TxContext) {
    assert!(poll.is_active, 0);
    let ticket = VotingTicket {
        id: object::new(ctx),
    };
    transfer::public_transfer(ticket, recipient);
}

// 3. Votar usando el NFT
public fun vote(
    poll: &mut Poll,
    ticket: VotingTicket,
    option_index: u8,
    ctx: &mut TxContext,
) {
    let voter = tx_context::sender(ctx);

    // Validaciones
    assert!(poll.is_active, 0); // Votación activa?
    assert!(!contains_voter(&poll.voters, &voter), 1); // Ya votó?
    assert!(option_index < vector::length(&poll.options) as u8, 2); // Opción válida?

    // Registrar voto
    let mut found = false;
    let mut i = 0;
    while (i < vector::length(&poll.votes)) {
        let entry = vector::borrow_mut(&mut poll.votes, i);
        if (entry.option_index == option_index) {
            entry.count = entry.count + 1;
            found = true;
            break
        };
        i = i + 1;
    };
    if (!found) {
        vector::push_back(&mut poll.votes, VoteEntry {
            option_index,
            count: 1,
        });
    };

    // Registrar votante
    vector::push_back(&mut poll.voters, voter);

    // Emitir evento
    event::emit(VoteEvent {
        poll_id: object::id(poll),
        voter,
        option_index,
    });

    // Destruir NFT para evitar reutilización
    let VotingTicket { id: ticket_id } = ticket; // Destructure to move out the id
    object::delete(ticket_id);
}

// Helper function to check if a voter exists in the vector
fun contains_voter(voters: &vector<address>, voter: &address): bool {
    let mut i = 0;
    while (i < vector::length(voters)) {
        if (*vector::borrow(voters, i) == *voter) {
            return true
        };
        i = i + 1;
    };
    false
}

// 4. Cerrar votación
public fun close_poll(poll: &mut Poll) {
    poll.is_active = false;
}

// ===== FUNCIONES DE CONSULTA =====

public fun get_vote_count(poll: &Poll, option_index: u8): u64 {
    let mut i = 0;
    while (i < vector::length(&poll.votes)) {
        let entry = *vector::borrow(&poll.votes, i);
        if (entry.option_index == option_index) {
            return entry.count
        };
        i = i + 1;
    };
    0
}

public fun has_voted(poll: &Poll, voter: address): bool {
    contains_voter(&poll.voters, &voter)
}

// ===== HELPERS =====
fun create_options_vector(options: vector<vector<u8>>): vector<string::String> {
    let mut result = vector::empty<string::String>();
    let mut i = 0; // Declare as 'mut' for assignment
    while (i < vector::length(&options)) {
        vector::push_back(&mut result, string::utf8(*vector::borrow(&options, i)));
        i = i + 1;
    };
    result
}







