# This Python file creates a AWS Lambda function
# that returns a HTTP response with an API key in the JSON body.

import os
import json
import boto3

def lambda_handler(event, context):
    api_key = os.environ['API_KEY']
    return {
        'statusCode': 200,
        'body': json.dumps({'api_key': api_key})
    }
