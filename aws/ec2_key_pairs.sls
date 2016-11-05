{% if salt['pillar.get']('aws:ec2_key_pairs', None) %}

{% for name, key_pair in salt['pillar.get']('aws:ec2_key_pairs', {}).items() %}
{% for region in key_pair.regions %}
EC2 key pair {{ name }} in {{ region }} exists:
  boto_ec2.key_present:
    - name: {{ name }}
    - upload_public: {{ key_pair.public }}
    - region: {{ region }}
{% endfor %}
{% endfor %}

{% endif %}

# vim: filetype=sls tabstop=2 shiftwidth=2 expandtab
