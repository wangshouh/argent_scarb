use array::{ArrayTrait, SpanTrait};
use serde::Serde;

#[derive(Copy, Drop, Serde)]
struct SignerSignature {
    signer: felt252,
    signature_r: felt252,
    signature_s: felt252,
}

fn deserialize_array_signer_signature(
    mut serialized: Span<felt252>
) -> Span<SignerSignature> {
    let mut output = ArrayTrait::new();
    loop {
        if serialized.len() == 0 {
            break output.span();
        }
        output.append(Serde::<SignerSignature>::deserialize(ref serialized).expect('argent/invalid-signature-length'));
    }
}
