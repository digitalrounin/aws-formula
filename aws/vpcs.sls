{% if salt['pillar.get']('aws:vpcs', None) %}

{% set profile = salt['pillar.get']('aws:profile') %}

{% for vpc_name, vpc in salt['pillar.get']('aws:vpcs', {}).items() %}
VPC {{ vpc_name }} exists:
  boto_vpc.present:
    - name: {{ vpc_name }}
    - cidr_block: {{ vpc.cidr_block }}
    - dns_support: True
    - dns_hostnames: True
    - profile: {{ profile }}

Internet gateway {{ vpc_name }} exists:
  boto_vpc.internet_gateway_present:
    - name: {{ vpc_name }}
    - vpc_name: {{ vpc_name }}
    - require:
      - boto_vpc: VPC {{ vpc_name }} exists
    - profile: {{ profile }}

DHCP options {{ vpc_name }} exists:
  boto_vpc.dhcp_options_present:
    - name: {{ vpc_name }}
    - vpc_name: {{ vpc_name }}
    - domain_name: {{ vpc.domain_name }}
    - domain_name_servers:
      - AmazonProvidedDNS
    - require:
      - boto_vpc: VPC {{ vpc_name }} exists
    - profile: {{ profile }}

{% set subnets = vpc.get('subnets', {}) %}
{% set subnet_names = subnets.keys() %}

{% for subnet_name, subnet in subnets.items() %}
Subnet {{ subnet_name }} exists:
  boto_vpc.subnet_present:
    - name: {{ subnet_name }}
    - cidr_block: {{ subnet.cidr_block }}
    - vpc_name: {{ vpc_name }}
    - availability_zone: {{ subnet.availability_zone }}
    - require:
      - boto_vpc: VPC {{ vpc_name }} exists
    - profile: {{ profile }}
{% endfor %}

Routing table {{ vpc_name }} exists:
  boto_vpc.route_table_present:
    - name: {{ vpc_name }}
    - vpc_name: {{ vpc_name }}
    - routes:
      - destination_cidr_block: 0.0.0.0/0
        internet_gateway_name: {{ vpc_name }}
    - subnet_names:
      {% for subnet_name in subnet_names %}
      - {{ subnet_name }}
      {% endfor %}
    - require:
      - boto_vpc: VPC {{ vpc_name }} exists
      - boto_vpc: Internet gateway {{ vpc_name }} exists
      {% for subnet_name in subnet_names %}
      - Subnet {{ subnet_name }} exists
      {% endfor %}

    - profile: {{ profile }}
{% endfor %}

{% endif %}

# vim: filetype=sls tabstop=2 shiftwidth=2 expandtab
