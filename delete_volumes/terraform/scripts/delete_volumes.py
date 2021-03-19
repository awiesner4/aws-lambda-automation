#!/usr/bin/env python3
import boto3
import os
import logging


def delete_volumes(aws_client):
    print("Gathering list of available EBS volumes")
    response = aws_client.describe_volumes(
        Filters=[
            {
                'Name': 'status',
                'Values': [
                    'available'
                ]
            },
        ],
    )

    if not response['Volumes']:
        print("No available volumes found")
    else:
        print("Starting deletion of available volumes")
        for volume in response['Volumes']:
            print(f"Deleting volume: {volume['VolumeId']}")
            resp = aws_client.delete_volume(
                VolumeId=volume['VolumeId']
            )
            print(resp)


def lambda_handler(event, context):
    regions = os.environ['TARGET_REGIONS'].replace(" ", "").split(",")

    for region in regions:
        client = boto3.client('ec2', region_name=region)
        delete_volumes(client)


if __name__ == "__main__":
    lambda_handler("", "")

