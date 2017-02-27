jenkins::cli::exec { "create-jenkins-credentials-${title}":
  # lint:ignore:140chars
  unless  => "for i in \$(seq 1 ${::jenkins::cli_tries}); do \$HELPER_CMD credential_info ${title} && break || sleep ${::jenkins::cli_try_sleep}; done | grep ${title}",
  # lint:end
}
