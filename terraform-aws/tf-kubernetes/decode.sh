aws sts decode-authorization-message --encoded-message $1 --query DecodedMessage --output text | jq '.'
