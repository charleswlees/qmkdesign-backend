# This is straight from the documentation, see README for link
import api
import serverless_wsgi

def handle(event, context):
    return serverless_wsgi.handle_request(api.app, event, context)
