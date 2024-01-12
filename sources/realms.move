module autonomous_realms::realms {
    /* 
        * stake a realms in realms collection to make a bigger map.
    */
    use std::error;
    use std::option::{Self, Option};
    use std::signer;
    use std::string::{Self, String};
    use std::table::{Self, Table};
    use std::vector;

    use aptos_framework::object::{Self, ConstructorRef, Object};

    use aptos_token_objects::collection;
    use aptos_token_objects::token;
    use aptos_std::string_utils;

    use autonomous_realms::utils;
    use autonomous_realms::realm::Realm;

    struct RealmCollection has key {
        name: String,
        description: String,
        mod_name: String, 
        realms_map: Table<u64, Realm>
    }

    public entry fun add_realm(acct: &signer, unique_id: vector<u8>) {
        // TODO: add realm to the collection.
    }
}