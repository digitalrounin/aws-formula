{% if salt['pillar.get']('aws:vpcs', None) %}

{% for vpc_name, vpc in salt['pillar.get']('aws:vpcs', {}).items() %}
VPC {{ vpc_name }} exists:
  boto_vpc.present:
    - name: {{ vpc_name }}
    - cidr_block: {{ vpc.cidr_block }}
    - dns_support: True
    - dns_hostnames: True
    - region: {{ vpc.region }}

Internet gateway {{ vpc_name }} exists:
  boto_vpc.internet_gateway_present:
    - name: {{ vpc_name }}
    - vpc_name: {{ vpc_name }}
    - region: {{ vpc.region }}

DHCP options {{ vpc_name }} exists:
  boto_vpc.dhcp_options_present:
    - name: {{ vpc_name }}
    - vpc_name: {{ vpc_name }}
    - domain_name: {{ vpc.domain_name }}
    - domain_name_servers:
      - AmazonProvidedDNS
    - region: {{ vpc.region }}

{% set subnets = vpc.get('subnets', {}) %}
{% set subnet_names = subnets.keys() %}

{% for subnet_name, subnet in subnets.items() %}
Subnet {{ subnet_name }} exists:
  boto_vpc.subnet_present:
    - name: {{ subnet_name }}
    - cidr_block: {{ subnet.cidr_block }}
    - vpc_name: {{ vpc_name }}
    - availability_zone: {{ subnet.availability_zone }}
    - region: {{ vpc.region }}
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
    - region: {{ vpc.region }}

{% endfor %}

{% endif %}

# vim: filetype=sls tabstop=2 shiftwidth=2 expandtab
