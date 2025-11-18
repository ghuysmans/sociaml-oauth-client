module F = Sociaml_oauth_client_v1_0a.Signature.Make
module P = Sociaml_oauth_client_posix
module S = F (P.Clock) (P.MAC_SHA1) (P.Random)

let uri =
  Uri.of_string "http://example.com/request?b5=%3D%253D&a3=a&c%40=&a2=r%20b"

let test method' signature =
  let timestamp = 137131201 in
  let nonce = "7d8f3e4a" in
  let token = "kkk9d7dh3k39sjv7" in
  let token_secret = "dh893hdasih9" in
  let consumer_key = "9djdj82h48djs9d2" in
  let consumer_secret = "j49sk3j29djd" in
  List.sort compare @@ S.sign
    ~timestamp
    ~nonce
    ~body_parameters:["c2",""; "a3","2 q"]
    ~token ~token_secret
    ~consumer_key ~consumer_secret
    ~method' uri =
  ["oauth_consumer_key", consumer_key
  ;"oauth_nonce", nonce
  ;"oauth_signature", signature
  ;"oauth_signature_method", "HMAC-SHA1"
  ;"oauth_timestamp", string_of_int timestamp
  ;"oauth_token", token]

let () =
  assert (test `POST "r6%2FTJjbCOr97%2F%2BUU0NsvSne7s5g%3D");
  assert (test `GET "bYT5CMsGcbgUdFHObYMEfcx6bsw%3D");
