{% if salt['pillar.get']('aws:iam_roles', None) %}

{% set profile = salt['pillar.get']('aws:profile') %}

# TODO - make this work

{% for role_name, role in salt['pillar.get']('aws:iam_roles').items() %}
EC2 key pair {{ role_name }} exists:
  boto_iam_role.present:
    - name: {{ role_name }}
    - path: {{ role.path }}
    - create_instance_profile: {{ role.create_instance_profile }}
    - policies: {{ role.policies }}
    - profile: {{ profile }}
{% endfor %}

{% endif %}

# vim: filetype=sls tabstop=2 shiftwidth=2 expandtab
