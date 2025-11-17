module F = Sociaml_oauth_client_v1_0a.Signature.Make
module P = Sociaml_oauth_client_posix
module S = F (P.Clock) (P.MAC_SHA1) (P.Random)

let uri =
  Uri.of_string "http://example.com/request?b5=%3D%253D&a3=a&c%40=&a2=r%20b"

let auth method' =
  let h =
    S.add_authorization_header
      ~timestamp:137131201
      ~nonce:"7d8f3e4a"
      ~body_parameters:["c2",""; "a3","2 q"]
      ~token:"kkk9d7dh3k39sjv7"
      ~token_secret:"dh893hdasih9"
      ~consumer_key:"9djdj82h48djs9d2"
      ~consumer_secret:"j49sk3j29djd"
      ~method'
      ~uri
      (Cohttp.Header.init ())
  in
  Option.get (Cohttp.Header.get h "Authorization")

let () =
  assert (auth `POST = {|OAuth oauth_signature="r6%2FTJjbCOr97%2F%2BUU0NsvSne7s5g%3D",oauth_token="kkk9d7dh3k39sjv7",oauth_consumer_key="9djdj82h48djs9d2",oauth_nonce="7d8f3e4a",oauth_signature_method="HMAC-SHA1",oauth_timestamp="137131201"|});
  assert (auth `GET = {|OAuth oauth_signature="bYT5CMsGcbgUdFHObYMEfcx6bsw%3D",oauth_token="kkk9d7dh3k39sjv7",oauth_consumer_key="9djdj82h48djs9d2",oauth_nonce="7d8f3e4a",oauth_signature_method="HMAC-SHA1",oauth_timestamp="137131201"|})
