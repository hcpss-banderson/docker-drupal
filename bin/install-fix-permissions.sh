#!/usr/bin/env bash

wget https://github.com/Metadrop/drupal-fix-permissions-script/archive/refs/tags/v1.0.1.tar.gz \
  && tar -xzf v1.0.1.tar.gz \
  && rm v1.0.1.tar.gz \
  && mv drupal-fix-permissions-script-1.0.1/autofix-drupal-perms.sh /usr/local/bin/autofix-drupal-perms.sh \
  && mv drupal-fix-permissions-script-1.0.1/drupal_fix_permissions.sh /usr/local/bin/drupal_fix_permissions.sh
