mod test_argent_account;
mod test_argent_account_signatures;

use array::ArrayTrait;
use option::OptionTrait;
use result::ResultTrait;
use traits::TryInto;

use starknet::{
    contract_address_const, Felt252TryIntoClassHash, deploy_syscall, account::Call,
    testing::set_contract_address
};

use argent_account::{Escape, EscapeStatus, ArgentAccount};
use argent_lib::Version;

#[starknet::interface]
trait ITestArgentAccount<TContractState> {
    // IAccount
    fn __validate_declare__(self: @TContractState, class_hash: felt252) -> felt252;
    fn __validate__(ref self: TContractState, calls: Array<Call>) -> felt252;
    fn __execute__(ref self: TContractState, calls: Array<Call>) -> Array<Span<felt252>>;
    fn is_valid_signature(
        self: @TContractState, hash: felt252, signature: Array<felt252>
    ) -> felt252;

    // IArgentAccount
    fn __validate_deploy__(
        self: @TContractState,
        class_hash: felt252,
        contract_address_salt: felt252,
        owner: felt252,
        guardian: felt252
    ) -> felt252;
    // External
    fn change_owner(
        ref self: TContractState, new_owner: felt252, signature_r: felt252, signature_s: felt252
    );
    fn change_guardian(ref self: TContractState, new_guardian: felt252);
    fn change_guardian_backup(ref self: TContractState, new_guardian_backup: felt252);
    fn trigger_escape_owner(ref self: TContractState, new_owner: felt252);
    fn trigger_escape_guardian(ref self: TContractState, new_guardian: felt252);
    fn escape_owner(ref self: TContractState);
    fn escape_guardian(ref self: TContractState);
    fn cancel_escape(ref self: TContractState);
    // Views
    fn get_owner(self: @TContractState) -> felt252;
    fn get_guardian(self: @TContractState) -> felt252;
    fn get_guardian_backup(self: @TContractState) -> felt252;
    fn get_escape(self: @TContractState) -> Escape;
    fn get_version(self: @TContractState) -> Version;
    fn get_name(self: @TContractState) -> felt252;
    fn get_guardian_escape_attempts(self: @TContractState) -> u32;
    fn get_owner_escape_attempts(self: @TContractState) -> u32;
    fn get_escape_and_status(self: @TContractState) -> (Escape, EscapeStatus);

    // IErc165
    fn supports_interface(self: @TContractState, interface_id: felt252) -> bool;

    // IDeprecatedArgentAccount
    fn getVersion(self: @TContractState) -> felt252;
    fn getName(self: @TContractState) -> felt252;
    fn supportsInterface(self: @TContractState, interface_id: felt252) -> felt252;
    fn isValidSignature(
        self: @TContractState, hash: felt252, signatures: Array<felt252>
    ) -> felt252;
}

const owner_pubkey: felt252 = 0x1ef15c18599971b7beced415a40f0c7deacfd9b0d1819e03d723d8bc943cfca;
const guardian_pubkey: felt252 = 0x759ca09377679ecd535a81e83039658bf40959283187c654c5416f439403cf5;
const wrong_owner_pubkey: felt252 =
    0x743829e0a179f8afe223fc8112dfc8d024ab6b235fd42283c4f5970259ce7b7;
const wrong_guardian_pubkey: felt252 =
    0x6eeee2b0c71d681692559735e08a2c3ba04e7347c0c18d4d49b83bb89771591;

fn initialize_account() -> ITestArgentAccountDispatcher {
    initialize_account_with(owner_pubkey, guardian_pubkey)
}

fn initialize_account_without_guardian() -> ITestArgentAccountDispatcher {
    initialize_account_with(owner_pubkey, 0)
}

fn initialize_account_with(owner: felt252, guardian: felt252) -> ITestArgentAccountDispatcher {
    let mut calldata = ArrayTrait::new();
    calldata.append(owner);
    calldata.append(guardian);
    let class_hash = ArgentAccount::TEST_CLASS_HASH.try_into().unwrap();
    let (contract_address, _) = deploy_syscall(class_hash, 0, calldata.span(), true).unwrap();

    // This will set the caller for subsequent calls (avoid 'argent/only-self')
    set_contract_address(contract_address_const::<1>());
    ITestArgentAccountDispatcher { contract_address }
}
