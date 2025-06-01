import json
import boto3
import os
from boto3.dynamodb.conditions import Key
from datetime import datetime

dynamodb = boto3.resource('dynamodb')
table_name = os.environ.get('PRODUCT_ORDERS_TABLE')
table = dynamodb.Table(table_name)

def lambda_handler(event, context):
    for record in event['Records']:
        body = json.loads(record['body'])
        detail = body.get('MessageBody', {}).get('detail', {})
        
        email = detail.get('email')
        order = detail.get('order', {})
        
        order_id = order.get('order_id')
        tracking_id = order.get('shipping_tracking_id')
        shipping_cost = order.get('shipping_cost', {})
        address = order.get('shipping_address', {})
        items = order.get('items', [])

        # Format order data for DynamoDB
        item = {
            'order_id': order_id,
            'email': email,
            'shipping_tracking_id': tracking_id,
            'shipping_cost': {
                'currency_code': shipping_cost.get('currency_code'),
                'units': shipping_cost.get('units'),
                'nanos': shipping_cost.get('nanos')
            },
            'shipping_address': address,
            'items': items,
            'timestamp': datetime.utcnow().isoformat()
        }

        # Store in DynamoDB
        try:
            table.put_item(Item=item)
            print(f"✅ Order {order_id} stored in DynamoDB.")
        except Exception as e:
            print(f"❌ Failed to store order {order_id}: {e}")

    return {
        'statusCode': 200,
        'body': json.dumps('All orders processed successfully.')
    }