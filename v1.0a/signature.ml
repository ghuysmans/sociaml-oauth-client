module type S = sig
  val sign :
      ?timestamp : int ->
      ?nonce : string ->
      ?body_parameters : (string * string) list ->
      ?callback : Uri.t  ->
      ?token : string ->
      ?token_secret : string ->
      consumer_key : string ->
      consumer_secret : string ->
      method' : [ | `POST | `GET ] ->
      Uri.t ->
      (string * string) list
  val add_authorization_header : 
      ?timestamp : int ->
      ?nonce : string ->
      ?body_parameters : (string * string) list ->
      ?callback : Uri.t  ->
      ?token : string ->
      ?token_secret : string ->
      consumer_key : string ->
      consumer_secret : string ->
      method' : [ | `POST | `GET ] ->
      uri : Uri.t ->
      Cohttp.Header.t ->
      Cohttp.Header.t
end

module Make 
    (Clock : Sociaml_oauth_client.S.CLOCK)
    (MAC : Sociaml_oauth_client.S.MAC)
    (Random : Sociaml_oauth_client.S.RANDOM) : S = struct
  
  open Cohttp
  
  module Util = Sociaml_oauth_client.Util.Make(Random)

  let sign
      ?(timestamp = Clock.time () |> int_of_float)
      ?(nonce = Util.generate_nonce 32)
      ?body_parameters: (parameters: (string * string) list = [])
      ?callback: (callback: Uri.t option)
      ?token: (token: string option)
      ?token_secret: (token_secret: string = "")
      ~consumer_key: consumer_key
      ~consumer_secret: consumer_secret
      ~method': (method': [ | `POST | `GET ]) (* FIXME *)
      uri
      = 
 
    let oauth_params = [
        "oauth_consumer_key", consumer_key;
        "oauth_nonce", nonce;
        "oauth_signature_method", "HMAC-SHA1";
        "oauth_timestamp", timestamp |> string_of_int;
      ] |> List.append (match callback with
      | Some callback -> ["oauth_callback", Uri.to_string callback |> Util.pct_encode;]
      | None -> []) |> List.append (match token with
      | Some token -> ["oauth_token", token;]
      | None -> [])    
    in
    
    let uri_without_query = Uri.with_query uri [] in
    
    let (|+) = MAC.add_string in 
    let (_, hmac) = (Util.pct_encode consumer_secret) ^ 
        "&" ^ (Util.pct_encode token_secret) |>
      MAC.init |+ 
      (match method' with | `POST -> "POST&" | `GET -> "GET&") |+
    	(Uri.to_string uri_without_query |> Util.pct_encode) |+ "&" |>
		  fun hmac -> Uri.query uri |> List.fold_left 
          (fun acc (key, values) ->             
            match List.length values with
            | 1 -> List.append acc [key, List.hd values]
            | _ -> List.fold_left  
              (fun accc value -> 
                List.append accc [key, value]) [] values |>
                  List.append acc) parameters |>
        List.append oauth_params |> 
        List.map (fun (key, value) -> (Util.pct_encode key, Util.pct_encode value)) |>
        List.sort (fun (key1, _) (key2, _) -> String.compare key1 key2) |>
        List.fold_left (fun (i, hmac) (key, value) ->
          (i + 1, hmac |+ 
          (match i with | 0 -> "" | _ -> Util.pct_encode "&") |+
          (Util.pct_encode key) |+ (Util.pct_encode "=") |+ (Util.pct_encode value))) (0, hmac)
    in  
    let s = MAC.result hmac |> Base64.encode_exn |> Util.pct_encode in
    ("oauth_signature", s) :: oauth_params
   
  let add_authorization_header
      ?timestamp ?nonce
      ?body_parameters
      ?callback
      ?token ?token_secret
      ~consumer_key ~consumer_secret
      ~method' ~uri
      headers = 
    sign
      ?timestamp ?nonce
      ?body_parameters
      ?callback
      ?token ?token_secret
      ~consumer_key ~consumer_secret
      ~method' uri |>
    List.map (fun (key, value) -> key ^ "=\"" ^ Util.pct_encode value ^ "\"") |>
    String.concat "," |>
    (^) "OAuth " |>
    Header.add headers "Authorization"
end
