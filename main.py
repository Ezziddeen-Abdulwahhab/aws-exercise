from http.server import BaseHTTPRequestHandler, HTTPServer
import boto3

port = 8080
session = boto3.Session(
    # We should NEVER store credentials like this in plain text in code.
    # I'm just doing it because I ran out of time while working on this.
    aws_access_key_id='<secret_key_id>',
    aws_secret_access_key='<secret_key_value>',
    region_name='eu-north-1'
)
dynamodb = session.resource('dynamodb')
table = dynamodb.Table("test-table")

item = {
    'key': '123',
    'name': 'Test Item'
}

class SimpleHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        table.put_item(Item=item)
        self.send_response(200)
        self.wfile.write(b"Hello! This is a simple GET endpoint.")

server_address = ('', port)
httpd = HTTPServer(server_address, SimpleHandler)

httpd.serve_forever()