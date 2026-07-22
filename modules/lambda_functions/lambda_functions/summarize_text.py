import json
import boto3

def lambda_handler(event, context):
    bedrock = boto3.client('bedrock-runtime')
    
    # Get the processed text key from the event
    processed_text_key = event['processedTextKey']
    
    # Fetch the processed text from S3
    s3 = boto3.client('s3')
    bucket = context.environment['OUTPUT_BUCKET']
    response = s3.get_object(Bucket=bucket, Key=processed_text_key)
    text = response['Body'].read().decode('utf-8')
    
    # Prepare the prompt for Bedrock
    prompt = f"Summarize the following text and extract action items:\n\n{text}"
    
    # Call Bedrock to summarize the text
    response = bedrock.invoke_model(
        modelId=context.environment['BEDROCK_MODEL_ID'],
        body=json.dumps({
            "prompt": prompt,
            "max_tokens_to_sample": 300
        })
    )
    
    summary = json.loads(response['body'].read())['completion']
    
    # Save the summary back to S3
    summary_key = f"summary_{processed_text_key}"
    s3.put_object(Bucket=bucket, Key=summary_key, Body=summary)
    
    return {
        'summaryKey': summary_key
    }