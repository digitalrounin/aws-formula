{% if salt['pillar.get']('aws:iam_roles', None) %}

{% set profile = salt['pillar.get']('aws:profile') %}

# TODO - make this work

{% for role in salt['pillar.get']('aws:iam_roles') %}
EC2 key pair {{ role.name }} exists:
  boto_iam_role.present:
    - name: {{ role.name }}
    - path: {{ role.path }}
    - create_instance_profile: {{ role.create_instance_profile }}
    - profile: {{ profile }}
{% endfor %}

{% endif %}

# vim: filetype=sls tabstop=2 shiftwidth=2 expandtab
