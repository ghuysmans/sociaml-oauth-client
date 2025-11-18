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
    (Random : Sociaml_oauth_client.S.RANDOM) : S
