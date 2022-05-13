aws sqs send-message --queue-url https://sqs.us-west-2.amazonaws.com/567168357526/queue.fifo  --message-body "hello" --message-group-id "12345"


aws sqs receive-message --queue-url https://sqs.us-west-2.amazonaws.com/567168357526/queue.fifo


aws sns publish --target-arn 'arn:aws:sns:us-west-2:567168357526:user-updates-topic' --message-structure "json"  --message '{"default":"This is the default Message"}'