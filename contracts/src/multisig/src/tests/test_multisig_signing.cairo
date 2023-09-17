use array::ArrayTrait;
use traits::Into;

use argent_multsig::tests::{
    ITestArgentMultisigDispatcherTrait, initialize_multisig_with,
    initialize_multisig_with_one_signer, signer_pubkey_1, signer_pubkey_2
};
use starknet::VALIDATED;

const message_hash: felt252 = 424242;

const signer_1_signature_r: felt252 =
    780418022109335103732757207432889561210689172704851180349474175235986529895;
const signer_1_signature_s: felt252 =
    117732574052293722698213953663617651411051623743664517986289794046851647347;

const signer_2_signature_r: felt252 =
    2543572729543774155040746789716602521360190010191061121815852574984983703153;
const signer_2_signature_s: felt252 =
    3047778680024311010844701802416003052323696285920266547201663937333620527443;

#[test]
#[available_gas(20000000)]
fn test_signature() {
    let multisig = initialize_multisig_with_one_signer();

    let mut signature = ArrayTrait::<felt252>::new();
    signature.append(signer_pubkey_1);
    signature.append(signer_1_signature_r);
    signature.append(signer_1_signature_s);
    assert(multisig.is_valid_signature(message_hash, signature) == VALIDATED, 'bad signature');
}

#[test]
#[available_gas(20000000)]
fn test_double_signature() {
    // init
    let threshold = 2;
    let mut signers_array = ArrayTrait::new();
    signers_array.append(signer_pubkey_1);
    signers_array.append(signer_pubkey_2);
    let multisig = initialize_multisig_with(threshold, signers_array.span());

    let mut signature = ArrayTrait::<felt252>::new();
    signature.append(signer_pubkey_1);
    signature.append(signer_1_signature_r);
    signature.append(signer_1_signature_s);
    signature.append(signer_pubkey_2);
    signature.append(signer_2_signature_r);
    signature.append(signer_2_signature_s);
    assert(multisig.is_valid_signature(message_hash, signature) == VALIDATED, 'bad signature');
}

#[test]
#[available_gas(20000000)]
#[should_panic(expected: ('argent/signatures-not-sorted', 'ENTRYPOINT_FAILED'))]
fn test_double_signature_order() {
    let threshold = 2;
    let mut signers_array = ArrayTrait::new();
    signers_array.append(signer_pubkey_2);
    signers_array.append(signer_pubkey_1);
    let multisig = initialize_multisig_with(threshold, signers_array.span());

    let mut signature = ArrayTrait::<felt252>::new();
    signature.append(signer_pubkey_2);
    signature.append(signer_2_signature_r);
    signature.append(signer_2_signature_s);
    signature.append(signer_pubkey_1);
    signature.append(signer_1_signature_r);
    signature.append(signer_1_signature_s);
    multisig.is_valid_signature(message_hash, signature);
}

#[test]
#[available_gas(20000000)]
#[should_panic(expected: ('argent/signatures-not-sorted', 'ENTRYPOINT_FAILED'))]
fn test_same_owner_twice() {
    let threshold = 2;
    let mut signers_array = ArrayTrait::new();
    signers_array.append(signer_pubkey_1);
    signers_array.append(signer_pubkey_2);
    let multisig = initialize_multisig_with(threshold, signers_array.span());

    let mut signature = ArrayTrait::<felt252>::new();
    signature.append(signer_pubkey_1);
    signature.append(signer_1_signature_r);
    signature.append(signer_1_signature_s);
    signature.append(signer_pubkey_1);
    signature.append(signer_1_signature_r);
    signature.append(signer_1_signature_s);
    multisig.is_valid_signature(message_hash, signature);
}

#[test]
#[available_gas(20000000)]
#[should_panic(expected: ('argent/invalid-signature-length', 'ENTRYPOINT_FAILED'))]
fn test_missing_owner_signature() {
    let threshold = 2;
    let mut signers_array = ArrayTrait::new();
    signers_array.append(signer_pubkey_1);
    signers_array.append(signer_pubkey_2);
    let multisig = initialize_multisig_with(threshold, signers_array.span());

    let mut signature = ArrayTrait::<felt252>::new();
    signature.append(signer_pubkey_1);
    signature.append(signer_1_signature_r);
    signature.append(signer_1_signature_s);
    multisig.is_valid_signature(message_hash, signature);
}

#[test]
#[available_gas(20000000)]
#[should_panic(expected: ('argent/invalid-signature-length', 'ENTRYPOINT_FAILED'))]
fn test_short_signature() {
    let multisig = initialize_multisig_with_one_signer();

    let mut signature = ArrayTrait::<felt252>::new();
    signature.append(signer_pubkey_1);
    signature.append(signer_1_signature_r);
    signature.append(signer_1_signature_s);
    signature.append(signer_pubkey_1);
    signature.append(signer_1_signature_r);
    signature.append(signer_1_signature_s);
    multisig.is_valid_signature(message_hash, signature);
}

#[test]
#[available_gas(20000000)]
#[should_panic(expected: ('argent/invalid-signature-length', 'ENTRYPOINT_FAILED'))]
fn test_long_signature() {
    let multisig = initialize_multisig_with_one_signer();

    let mut signature = ArrayTrait::<felt252>::new();
    signature.append(42);
    multisig.is_valid_signature(message_hash, signature);
}
