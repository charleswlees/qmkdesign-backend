FROM hashicorp/terraform:latest

WORKDIR /workspace

COPY terraform/*.tf terraform/import.sh ./

# Clean any existing state
RUN rm -f terraform.tfstate* .terraform.lock.hcl;
RUN rm -rf .terraform/;
