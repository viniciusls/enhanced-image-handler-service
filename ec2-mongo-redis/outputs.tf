output "address" {
  value = aws_instance.ec2_mongo_redis.*.public_dns
}
