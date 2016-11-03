{% if salt['pillar.get']('aws:ec2_key_pairs', None) %}

{% set profile = salt['pillar.get']('aws:profile') %}


{% for name, key_pair in salt['pillar.get']('aws:ec2_key_pairs', {}).items() %}
EC2 key pair {{ name }} exists:
  boto_ec2.key_present:
    - name: {{ name }}
    - upload_public: {{ key_pair.public }}
    - profile: {{ profile }}
{% endfor %}

{% endif %}

# vim: filetype=sls tabstop=2 shiftwidth=2 expandtab
