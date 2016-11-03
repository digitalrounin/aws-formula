{% if salt['pillar.get']('aws', None) %}

include:
  - .vpcs
  - .secgroups
  - .ec2_key_pairs
  # TODO - make this work
  # - .iam_roles

{% endif %}

# vim: filetype=sls tabstop=2 shiftwidth=2 expandtab
