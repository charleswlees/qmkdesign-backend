FROM hashicorp/terraform:latest

WORKDIR /workspace

# Copy terraform files
COPY terraform/*.tf ./

# Clean any existing state
RUN rm -f terraform.tfstate* .terraform.lock.hcl
RUN rm -rf .terraform/
