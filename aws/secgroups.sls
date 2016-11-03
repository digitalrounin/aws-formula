{% if salt['pillar.get']('aws:vpcs', None) %}

{% set profile = salt['pillar.get']('aws:profile') %}

include:
  - aws.vpcs

# ----
# PASS 1
#   Create all the security groups first without adding rules.  There might be
#   cross dependencies between secgroup entries.
# ----
{% for vpc_name, vpc in salt['pillar.get']('aws:vpcs', {}).items() %}
{% set secgroups = vpc.get('secgroups', None) %}
{% if secgroups %}
{% for secgroup_name, secgroup in secgroups.items() %}
Security group {{ secgroup_name }} exists (pass 1):
  boto_secgroup.present:
    - name: {{ secgroup_name }}
    - description: {{ secgroup.description }}
    - vpc_name: {{ vpc_name }}
    - require:
      # Bug requires the full SLS path to work, not reletive.
      - sls: aws.vpcs
    - profile: {{ profile }}
{% endfor %}
{% endif %}
{% endfor %}

# ----
# PASS 2
#   Actually apply the rules now that all of the rules have been created.
# ----
{% for vpc_name, vpc in salt['pillar.get']('aws:vpcs', {}).items() %}
{% set secgroups = vpc.get('secgroups', None) %}
{% if secgroups %}
{% for secgroup_name, secgroup in secgroups.items() %}
Security group {{ secgroup_name }} configure (pass 2):
  boto_secgroup.present:
    - name: {{ secgroup_name }}
    - description: {{ secgroup.description }}
    - vpc_name: {{ vpc_name }}
    # Empty out `rules` and/or `rules_egress` if they are missing from pillar.
    # This is done for security resonces.
    - rules: {{ secgroup.get('rules', []) }}
    - rules_egress: {{ secgroup.get('rules_egress', []) }}
    - tags:
       Name: {{ secgroup_name }}
    - profile: {{ profile }}
{% endfor %}
{% endif %}
{% endfor %}


{% endif %}

# vim: filetype=sls tabstop=2 shiftwidth=2 expandtab
