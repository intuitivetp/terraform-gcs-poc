# Makefile for Terraform GCS POC - IaC-to-Visual Converter

.PHONY: help init plan apply destroy test test-coverage generate-diagrams generate-tests clean

# Default target
help:
	@echo "Terraform GCS POC - IaC-to-Visual Converter"
	@echo "============================================"
	@echo ""
	@echo "Available targets:"
	@echo "  make init              - Initialize Terraform"
	@echo "  make plan              - Run Terraform plan"
	@echo "  make apply             - Apply Terraform configuration"
	@echo "  make destroy           - Destroy infrastructure"
	@echo "  make test              - Run all tests"
	@echo "  make test-coverage     - Run tests with coverage"
	@echo "  make generate-diagrams - Generate architecture diagrams"
	@echo "  make generate-tests    - Generate test files"
	@echo "  make clean             - Clean generated files"
	@echo "  make demo              - Run complete demo"
	@echo ""

# Terraform commands
init:
	@echo "🔧 Initializing Terraform..."
	cd stacks/online-banking && terraform init

plan:
	@echo "📋 Running Terraform plan..."
	cd stacks/online-banking && terraform plan \
		-var="project_id=demo-project-12345" \
		-var="environment=dev" \
		-out=tfplan

apply:
	@echo "🚀 Applying Terraform configuration..."
	cd stacks/online-banking && terraform apply tfplan

destroy:
	@echo "💥 Destroying infrastructure..."
	cd stacks/online-banking && terraform destroy \
		-var="project_id=demo-project-12345" \
		-var="environment=dev" \
		-auto-approve

# Testing
test:
	@echo "🧪 Running tests..."
	cd tests && go test -v -timeout 30m ./...

test-coverage:
	@echo "📊 Running tests with coverage..."
	cd tests && go test -v -coverprofile=coverage.out -covermode=atomic ./...
	cd tests && go tool cover -html=coverage.out -o coverage.html
	@echo "✅ Coverage report generated: tests/coverage.html"

# Diagram generation
generate-diagrams: plan
	@echo "🎨 Generating architecture diagrams..."
	cd stacks/online-banking && \
		terraform show -json tfplan > terraform.tfstate && \
		python3 ../../scripts/generate-diagram.py terraform.tfstate \
			-o diagrams/architecture.mmd -t all
	@echo "✅ Diagrams generated in stacks/online-banking/diagrams/"

# Test generation
generate-tests:
	@echo "🧪 Generating test files..."
	python3 scripts/generate-tests.py stacks/online-banking \
		-o tests/online_banking_generated_test.go
	@echo "✅ Tests generated: tests/online_banking_generated_test.go"

# Clean
clean:
	@echo "🧹 Cleaning generated files..."
	rm -rf stacks/online-banking/.terraform
	rm -f stacks/online-banking/tfplan
	rm -f stacks/online-banking/terraform.tfstate
	rm -rf stacks/online-banking/diagrams
	rm -f tests/coverage.out
	rm -f tests/coverage.html
	@echo "✅ Cleaned"

# Demo
demo: init plan generate-diagrams generate-tests
	@echo ""
	@echo "🎉 Demo Complete!"
	@echo "================="
	@echo ""
	@echo "📁 Generated files:"
	@echo "  - stacks/online-banking/diagrams/architecture-*.mmd"
	@echo "  - tests/online_banking_generated_test.go"
	@echo ""
	@echo "📖 Next steps:"
	@echo "  1. View diagrams: cat stacks/online-banking/diagrams/architecture-architecture.mmd"
	@echo "  2. View tests: cat tests/online_banking_generated_test.go"
	@echo "  3. Run tests: make test"
	@echo "  4. View coverage: make test-coverage"
	@echo ""
	@echo "🌐 View diagrams online:"
	@echo "  - Mermaid Live Editor: https://mermaid.live"
	@echo "  - Copy diagram content and paste"
	@echo ""

# Quick demo without Terraform (uses existing files)
demo-quick:
	@echo "🎨 Quick Demo: Generate diagrams from plan..."
	@if [ -f stacks/online-banking/tfplan ]; then \
		cd stacks/online-banking && \
		terraform show -json tfplan > terraform.tfstate && \
		python3 ../../scripts/generate-diagram.py terraform.tfstate \
			-o diagrams/architecture.mmd -t all && \
		echo "✅ Diagrams generated!" && \
		echo "" && \
		echo "📊 View architecture diagram:" && \
		cat diagrams/architecture-architecture.mmd; \
	else \
		echo "❌ No Terraform plan found. Run 'make plan' first."; \
	fi

