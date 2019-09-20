Todo:
- Add compression on the server [X]
- Add Docker
- Turn on SSL
- Run for million sets

```
Server:
PrivateIntersectionSumServerMessage:

  message ServerRoundOne {
    optional EncryptedSet encrypted_set = 1;
  }

  message ServerRoundTwo {
    optional int64 intersection_size = 1;
    optional bytes encrypted_sum = 2;
  }

Client:

StartProtocolRequest{}

message ClientRoundOne {
    optional bytes public_key = 1;
    optional EncryptedSet encrypted_set = 2;
    optional EncryptedSet reencrypted_set = 3;
  }

message EncryptedSet {
  repeated EncryptedElement elements = 1;
}

// Holds an encrypted value and possibly encrypted associated data.
message EncryptedElement {
  optional bytes element = 1;
  optional bytes associated_data = 2;
}

```


`server_impl.cc` runs server_round_one

`EncryptSet` - encrypts the set

`ComputeIntersection` computes the intersection


SHA3 schanged to SHA2



```
ec_commutative_cipher.cc 

StatusOr<std::string> ECCommutativeCipher::Encrypt(
    const std::string& plaintext) const {
  StatusOr<ECPoint> status_or_point;
  if (hash_type_ == SHA512) {
    status_or_point = group_.GetPointByHashingToCurveSha512(plaintext);
  } else if (hash_type_ == SHA256) {
    status_or_point = group_.GetPointByHashingToCurveSha256(plaintext);
  } else {
    return InvalidArgumentError("Invalid hash type.");
  }

  if (!status_or_point.ok()) {
    return status_or_point.status();
  }
  ASSIGN_OR_RETURN(ECPoint encrypted_point,
                   Encrypt(status_or_point.ValueOrDie()));
  return encrypted_point.ToBytesCompressed();
}

StatusOr<std::string> ECCommutativeCipher::ReEncrypt(
    const std::string& ciphertext) const {
  ASSIGN_OR_RETURN(ECPoint point, group_.CreateECPoint(ciphertext));
  ASSIGN_OR_RETURN(ECPoint reencrypted_point, Encrypt(point));
  return reencrypted_point.ToBytesCompressed();
}```


