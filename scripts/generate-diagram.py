#!/usr/bin/env python3
"""
Terraform State to Mermaid Diagram Generator

Parses Terraform state files and generates Mermaid architecture diagrams
showing resource relationships, dependencies, and network topology.
"""

import json
import sys
import argparse
from pathlib import Path
from typing import Dict, List, Set, Tuple
from dataclasses import dataclass, field


@dataclass
class Resource:
    """Represents a Terraform resource"""
    type: str
    name: str
    address: str
    provider: str
    attributes: Dict
    dependencies: List[str] = field(default_factory=list)
    
    @property
    def display_name(self) -> str:
        """Get a human-readable display name"""
        return self.name.replace("-", " ").title()
    
    @property
    def category(self) -> str:
        """Categorize resource by type"""
        categories = {
            "google_storage_bucket": "Storage",
            "google_cloud_run_service": "Compute",
            "google_sql_database_instance": "Database",
            "google_sql_database": "Database",
            "google_service_account": "IAM",
            "google_project_iam_member": "IAM",
            "google_storage_bucket_iam_member": "IAM",
            "google_cloud_run_service_iam_member": "IAM",
            "google_monitoring_dashboard": "Monitoring",
            "google_logging_project_sink": "Monitoring",
        }
        return categories.get(self.type, "Other")
    
    @property
    def icon(self) -> str:
        """Get icon for resource type"""
        icons = {
            "google_storage_bucket": "📦",
            "google_cloud_run_service": "🚀",
            "google_sql_database_instance": "🗄️",
            "google_sql_database": "💾",
            "google_service_account": "👤",
            "google_monitoring_dashboard": "📊",
            "google_logging_project_sink": "📝",
        }
        return icons.get(self.type, "🔧")
    
    @property
    def color(self) -> str:
        """Get color for resource category"""
        colors = {
            "Storage": "#4285f4",
            "Compute": "#34a853",
            "Database": "#fbbc04",
            "IAM": "#ea4335",
            "Monitoring": "#9c27b0",
            "Other": "#607d8b"
        }
        return colors.get(self.category, "#607d8b")


class TerraformStateParser:
    """Parse Terraform state file and extract resources"""
    
    def __init__(self, state_file: Path):
        self.state_file = state_file
        self.resources: Dict[str, Resource] = {}
        
    def parse(self) -> Dict[str, Resource]:
        """Parse the state file (supports both state and plan JSON formats)"""
        with open(self.state_file) as f:
            state = json.load(f)
        
        # Check if this is a plan JSON (from terraform show -json tfplan)
        if "planned_values" in state:
            # This is a plan JSON format
            root_module = state.get("planned_values", {}).get("root_module", {})
            self._parse_module_resources(root_module)
        elif "values" in state:
            # This is a state JSON format  
            root_module = state.get("values", {}).get("root_module", {})
            self._parse_module_resources(root_module, is_plan=False)
        else:
            # Legacy format
            for resource in state.get("resources", []):
                self._parse_resource(resource)
        
        return self.resources
    
    def _parse_module_resources(self, module_data: Dict, is_plan: bool = True):
        """Recursively parse resources from a module and its child modules"""
        # Parse resources at this level
        resources = module_data.get("resources", [])
        for resource in resources:
            if is_plan:
                self._parse_plan_resource(resource)
            else:
                self._parse_resource(resource)
        
        # Recursively parse child modules
        child_modules = module_data.get("child_modules", [])
        for child_module in child_modules:
            self._parse_module_resources(child_module, is_plan)
    
    def _parse_resource(self, resource_data: Dict):
        """Parse a single resource from state format"""
        resource_type = resource_data.get("type", "")
        resource_name = resource_data.get("name", "")
        resource_mode = resource_data.get("mode", "managed")
        
        if resource_mode != "managed":
            return
        
        for instance in resource_data.get("instances", []):
            address = f"{resource_type}.{resource_name}"
            
            resource = Resource(
                type=resource_type,
                name=resource_name,
                address=address,
                provider=resource_data.get("provider", ""),
                attributes=instance.get("attributes", {}),
                dependencies=instance.get("dependencies", [])
            )
            
            self.resources[address] = resource
    
    def _parse_plan_resource(self, resource_data: Dict):
        """Parse a single resource from plan format"""
        resource_type = resource_data.get("type", "")
        resource_name = resource_data.get("name", "")
        address = resource_data.get("address", f"{resource_type}.{resource_name}")
        resource_mode = resource_data.get("mode", "managed")
        
        if resource_mode != "managed":
            return
        
        resource = Resource(
            type=resource_type,
            name=resource_name,
            address=address,
            provider=resource_data.get("provider_name", ""),
            attributes=resource_data.get("values", {}),
            dependencies=[]
        )
        
        self.resources[address] = resource


class MermaidGenerator:
    """Generate Mermaid diagrams from Terraform resources"""
    
    def __init__(self, resources: Dict[str, Resource]):
        self.resources = resources
        
    def generate_architecture_diagram(self) -> str:
        """Generate a complete architecture diagram"""
        lines = ["graph TB"]
        lines.append("")
        
        # Group resources by category
        categories = {}
        for resource in self.resources.values():
            category = resource.category
            if category not in categories:
                categories[category] = []
            categories[category].append(resource)
        
        # Generate subgraphs for each category
        for category, resources in categories.items():
            if not resources:
                continue
                
            lines.append(f"    subgraph {category}")
            for resource in resources:
                node_id = self._get_node_id(resource.address)
                label = f"{resource.icon} {resource.display_name}"
                if resource.type in ["google_storage_bucket", "google_sql_database"]:
                    # Show bucket/database names
                    if "name" in resource.attributes:
                        label += f"<br/>{resource.attributes['name']}"
                lines.append(f"        {node_id}[{label}]")
            lines.append("    end")
            lines.append("")
        
        # Generate relationships
        lines.append("    %% Dependencies")
        for resource in self.resources.values():
            source_id = self._get_node_id(resource.address)
            
            # Parse dependencies
            for dep in resource.dependencies:
                if dep in self.resources:
                    target_id = self._get_node_id(dep)
                    lines.append(f"    {source_id} --> {target_id}")
            
            # Infer additional relationships from attributes
            self._add_inferred_relationships(resource, lines)
        
        lines.append("")
        
        # Add styling
        lines.append("    %% Styling")
        for resource in self.resources.values():
            node_id = self._get_node_id(resource.address)
            color = resource.color
            lines.append(f"    style {node_id} fill:{color},stroke:#333,color:#fff")
        
        return "\n".join(lines)
    
    def generate_network_diagram(self) -> str:
        """Generate a network topology diagram"""
        lines = ["graph LR"]
        lines.append("")
        lines.append("    Internet([Internet]) --> LB[Load Balancer]")
        lines.append("    LB --> Frontend[Frontend]")
        lines.append("    Frontend --> API[API Backend]")
        lines.append("    API --> DB[(Database)]")
        lines.append("    API --> Storage[Document Storage]")
        lines.append("")
        lines.append("    style Internet fill:#f9f,stroke:#333")
        lines.append("    style Frontend fill:#4285f4,stroke:#333,color:#fff")
        lines.append("    style API fill:#34a853,stroke:#333,color:#fff")
        lines.append("    style DB fill:#fbbc04,stroke:#333,color:#fff")
        lines.append("    style Storage fill:#4285f4,stroke:#333,color:#fff")
        
        return "\n".join(lines)
    
    def generate_data_flow_diagram(self) -> str:
        """Generate a data flow diagram"""
        lines = ["graph TD"]
        lines.append("")
        lines.append("    User([User]) --> Frontend[Frontend UI]")
        lines.append("    Frontend --> API[API Service]")
        lines.append("    API --> Auth{Authentication}")
        lines.append("    Auth -->|Valid| DB[(Database)]")
        lines.append("    Auth -->|Invalid| Error[Error Response]")
        lines.append("    DB --> Cache[(Cache Layer)]")
        lines.append("    Cache --> API")
        lines.append("    API --> Storage[Document Storage]")
        lines.append("    API --> Logs[Cloud Logging]")
        lines.append("    API --> Metrics[Cloud Monitoring]")
        lines.append("")
        lines.append("    style User fill:#f9f,stroke:#333")
        lines.append("    style Auth fill:#ea4335,stroke:#333,color:#fff")
        lines.append("    style DB fill:#fbbc04,stroke:#333,color:#fff")
        
        return "\n".join(lines)
    
    def _get_node_id(self, address: str) -> str:
        """Convert resource address to valid node ID"""
        import re
        # Extract content from brackets for uniqueness (like ["service_name"])
        bracket_match = re.search(r'\["([^"]+)"\]', address)
        suffix = ""
        if bracket_match:
            # Get the service name and clean it
            service_name = bracket_match.group(1)
            # Take the first part before any dots (e.g., "cloudresourcemanager" from "cloudresourcemanager.googleapis.com")
            suffix = "_" + service_name.split(".")[0].replace("-", "_")
        
        # Remove everything inside brackets
        clean_address = re.sub(r'\[.*?\]', '', address)
        # Replace dots and dashes with underscores
        clean_address = clean_address.replace(".", "_").replace("-", "_")
        
        return clean_address + suffix
    
    def _add_inferred_relationships(self, resource: Resource, lines: List[str]):
        """Infer relationships from resource attributes"""
        source_id = self._get_node_id(resource.address)
        
        # Cloud Run to SQL
        if resource.type == "google_cloud_run_service":
            for dep in resource.dependencies:
                if "google_sql_database_instance" in dep:
                    target_id = self._get_node_id(dep)
                    lines.append(f"    {source_id} -.->|connects to| {target_id}")
        
        # IAM bindings
        if "iam_member" in resource.type:
            # Link IAM to the resource it's granting access to
            pass


def main():
    parser = argparse.ArgumentParser(
        description="Generate Mermaid diagrams from Terraform state"
    )
    parser.add_argument(
        "state_file",
        type=Path,
        help="Path to terraform.tfstate file"
    )
    parser.add_argument(
        "-o", "--output",
        type=Path,
        help="Output file (default: architecture.mmd)"
    )
    parser.add_argument(
        "-t", "--type",
        choices=["architecture", "network", "dataflow", "all"],
        default="architecture",
        help="Diagram type to generate"
    )
    parser.add_argument(
        "--format",
        choices=["mermaid", "markdown"],
        default="mermaid",
        help="Output format"
    )
    
    args = parser.parse_args()
    
    if not args.state_file.exists():
        print(f"Error: State file not found: {args.state_file}", file=sys.stderr)
        sys.exit(1)
    
    # Parse state
    print(f"Parsing Terraform state: {args.state_file}")
    parser_obj = TerraformStateParser(args.state_file)
    resources = parser_obj.parse()
    print(f"Found {len(resources)} resources")
    
    if len(resources) == 0:
        print("⚠️  WARNING: No resources found in state file!")
        print("This could mean:")
        print("  1. Terraform plan had no resources to create")
        print("  2. State file format is not recognized")
        print("  3. Resources are in an unexpected location in the JSON")
        print("")
        print("Generating minimal placeholder diagrams...")
        print("")
    
    # Generate diagram
    generator = MermaidGenerator(resources)
    
    diagrams = {}
    if args.type == "all":
        diagrams["architecture"] = generator.generate_architecture_diagram()
        diagrams["network"] = generator.generate_network_diagram()
        diagrams["dataflow"] = generator.generate_data_flow_diagram()
    elif args.type == "architecture":
        diagrams["architecture"] = generator.generate_architecture_diagram()
    elif args.type == "network":
        diagrams["network"] = generator.generate_network_diagram()
    elif args.type == "dataflow":
        diagrams["dataflow"] = generator.generate_data_flow_diagram()
    
    # Output
    for diagram_type, content in diagrams.items():
        if args.output:
            output_file = args.output.parent / f"{args.output.stem}-{diagram_type}{args.output.suffix}"
        else:
            output_file = Path(f"{diagram_type}.mmd")
        
        if args.format == "markdown":
            content = f"```mermaid\n{content}\n```"
            output_file = output_file.with_suffix(".md")
        
        with open(output_file, "w") as f:
            f.write(content)
        
        print(f"Generated {diagram_type} diagram: {output_file}")


if __name__ == "__main__":
    main()

