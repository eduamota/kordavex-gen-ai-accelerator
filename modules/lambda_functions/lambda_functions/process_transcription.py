import json
import boto3

def lambda_handler(event, context):
    s3 = boto3.client('s3')
    
    # Get the transcription job name from the event
    job_name = event['transcriptionJobName']
    
    # Fetch the transcription file from S3
    bucket = context.environment['OUTPUT_BUCKET']
    key = f"{job_name}.json"
    
    response = s3.get_object(Bucket=bucket, Key=key)
    transcription = json.loads(response['Body'].read().decode('utf-8'))
    
    # Process the transcription (this is a simple example)
    processed_text = transcription['results']['transcripts'][0]['transcript']
    
    # Save the processed text back to S3
    processed_key = f"processed_{job_name}.txt"
    s3.put_object(Bucket=bucket, Key=processed_key, Body=processed_text)
    
    return {
        'processedTextKey': processed_key
    }