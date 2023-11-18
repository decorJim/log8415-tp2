import time
import boto3

AWS_ACCESS_KEY_ID="ASIAXZSEYFC6RYELHZUK"
AWS_SECRET_ACCESS_KEY="1STZ5G0UuiQVXSwAKkiaSKo71ymjFo6csj9EIwMh"
AWS_SESSION_TOKEN="FwoGZXIvYXdzEDAaDPOwqg30ocdy2VPdDyLGATfMr9/eD+jLpVQ47fUDKHphH+9HEX3aYta0MyCiN35SvQGXXbFLCTd8iYQwMUkOOuUMnH2E7iX7S5SB9/uHVTendhz4hTbdaxKFa7fyqIZYPcrF5r4MktG4O2/MOZXW3On/ae84Cw7dlGvzZg+/ewqIEo6yszsRcUXF5mzFbl+mI2Jy7RAJal3Qx9sEYIBsYZXc2ClBZ1cECHE3gkL1PI1EPKETrO9Gb+2dDSJIDBJtHohdjSCacNJz8nEWUx2+K/e/kExwMCjA5s+qBjItIPIFUF8UbnInNBH7yW+CtzNjuUSMd6T8sfKTaKWr7h3Xqz4uiLL/mGnR2L8/"
session = boto3.Session(
    aws_access_key_id=AWS_ACCESS_KEY_ID,
    aws_secret_access_key=AWS_SECRET_ACCESS_KEY,
    aws_session_token=AWS_SESSION_TOKEN,
)

ec2_client = session.client("ec2", region_name="us-east-1")

ec2_resource = session.resource("ec2","us-east-1")
response_vpcs = ec2_client.describe_vpcs()
vpc_id = response_vpcs.get("Vpcs", [{}])[0].get("VpcId", "")

print("vpc_id",vpc_id)

response_security_group = ec2_client.create_security_group(
    GroupName="security-group-1", Description="Security group for our instances", VpcId=vpc_id
)

print("security_group_response")
print(response_security_group)

security_group_id = response_security_group["GroupId"]
print(security_group_id)

ec2_client.authorize_security_group_ingress(
    GroupId=security_group_id,
    IpPermissions=[
        {
            "IpProtocol": "tcp",
            "FromPort": 80,
            "ToPort": 80,
            "IpRanges": [{"CidrIp": "0.0.0.0/0"}],
        },
        {
            "IpProtocol": "tcp",
            "FromPort": 22,
            "ToPort": 22,
            "IpRanges": [{"CidrIp": "0.0.0.0/0"}],
        },
    ],
)


hadoop_script=open("hadoop.sh", "r").read()

cluster1_response=ec2_resource.create_instances(
    InstanceType="m4.large",
    MinCount=1,
    MaxCount=1,
    ImageId="ami-08c40ec9ead489470",
    SecurityGroupIds=[security_group_id],
    UserData=hadoop_script
)
print(cluster1_response)

time.sleep(60)

print("completed !")
