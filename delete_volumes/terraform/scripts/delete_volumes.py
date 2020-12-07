#!/usr/bin/env python3
import boto3
import os
import logging


def lambda_handler(event, context):
    client = boto3.client('ec2', region_name='us-east-2')
    print("Gathering list of available EBS volumes")
    response = client.describe_volumes(
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
            resp = client.delete_volume(
                VolumeId=volume['VolumeId']
            )
            print(resp)


if __name__ == "__main__":
    lambda_handler("", "")

