{
  dockerTools,
  buildEnv,
  techforum_app,
}:
dockerTools.buildImage {
  name = "techforum_app";
  tag = "techforum";
  created = "now";
  copyToRoot = buildEnv {
    name = "toCopy";
    paths = [ techforum_app ];
    pathsToLink = [ "/bin" ];
  };

  config.Cmd = [ "/bin/integration_demo" ];
}
