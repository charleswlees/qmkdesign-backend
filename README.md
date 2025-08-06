# QMK Backend

Built in Python using Flask

* Builds the firmware for the frontend and returns the compiled firmware to the user
* Stores User Data using a Database and S3 Bucket.


### Running The API 

To run the API locally please use the Docker container in this repository.
```bash
docker build -t qmkdesign-backend . && docker run -p 8080:8080 qmkdesign-backend
```

This API is also currently hosted on AWS [here](http://qmkdesign-backend-alb-1204214536.us-east-1.elb.amazonaws.com/)


### Sources 
Official Docs that were helpful
* [AWS Web Adapter](https://aws.amazon.com/blogs/compute/using-response-streaming-with-aws-lambda-web-adapter-to-optimize-performance/)
* [Terraform syntax](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function)
* [QMK Firmware](https://docs.qmk.fm/newbs_building_firmware)
* [Flask](https://flask.palletsprojects.com/en/stable/)

Articles that I found useful as well

* [Buliding image and sending to ECR via Workflow](https://github.com/aws-actions/amazon-ecr-login)
* [Hosting using Fargate](https://aws.amazon.com/blogs/containers/building-http-api-based-services-using-aws-fargate/)
* [More ECS Examples](https://dev.to/aws-builders/flask-application-deployment-using-aws-ecs-and-aws-dynamodb-with-terraform-45oh)
