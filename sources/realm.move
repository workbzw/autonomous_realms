module autonomous_realms::realm {
    /* 
        * create realms which is a dynamic NFT based on token V2 standard;
        * realms could be combine into bigger realm using Collection.
        * render based on different modules.
    */
    use std::error;
    use std::option::{Self, Option};
    use std::signer;
    use std::string::{Self, String};
    use std::vector;

    use aptos_framework::object::{Self, ConstructorRef, Object};

    use aptos_token_objects::collection;
    use aptos_token_objects::token;
    use aptos_std::string_utils;

    use autonomous_realms::utils;

    struct OnChainConfig has key {
        collection: String,
        mint_count: u64,
        base_uri: String,
    }

    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    struct Realm has key {
        name: String, 
        description: String, 
        mutator_ref: token::MutatorRef,
    }

    fun init_module(account: &signer) {
        let name = string::utf8(b"Autonomous Realms!");
        let description = string::utf8(b"Realms Grow Autonomously");
        let num = 2100;
        let uri = string::utf8(b"https://google.com/");
        let base_uri =  string::utf8(b"https://google.com/");
        // let collection = string::utf8(b"Autonomous Realms!");
        // public fun create_fixed_collection(
        //     creator: &signer,
        //     description: String,
        //     max_supply: u64,
        //     name: String,
        //     royalty: Option<Royalty>,
        //     uri: String,
        // )
        // TODO: fixed or unlimited?
        collection::create_fixed_collection(
            account,
            description,
            num,
            name,
            option::none(),
            uri,
        );

        let on_chain_config = OnChainConfig {
            collection: name,
            mint_count: 0,
            base_uri: base_uri,
        };
        move_to(account, on_chain_config);
    }

    fun create(
        creator: &signer,
        description: String,
        name: String,
        // uri: String,
    ): ConstructorRef acquires OnChainConfig {
        let on_chain_config = borrow_global_mut<OnChainConfig>(signer::address_of(creator));
        let uri = utils::string_to_vector_u8(&on_chain_config.base_uri);
        let count = utils::u64_to_vec_u8_string(on_chain_config.mint_count);
        vector::append(&mut uri, count);
        vector::append(&mut uri, b".svg");
        on_chain_config.mint_count = on_chain_config.mint_count + 1;  // Increment the counter
        // TODO: return error if mint_count > max_supply
        token::create_named_token(
            creator,
            on_chain_config.collection,
            description,
            name,
            option::none(),
            string::utf8(uri),
        )
    }

    // Creation methods

    public fun create_realm(
        creator: &signer,
        name: String,
        description: String,
        // uri: String
    ): Object<Realm> acquires OnChainConfig {
        let constructor_ref = create(creator, description, name);
        let token_signer = object::generate_signer(&constructor_ref);

        let realm = Realm {
            name,
            description, 
            mutator_ref: token::generate_mutator_ref(&constructor_ref),
        };
        move_to(&token_signer, realm);

        object::address_to_object(signer::address_of(&token_signer))
    }

    // Public entry 

    public entry fun mint_realm(
        account: &signer,
        name: String,
        description: String
    ) acquires OnChainConfig {
        create_realm(account, name, description);
    }
}