import yaml
import argparse


def yaml_quoted_presenter(dumper, data):
  return dumper.represent_scalar('tag:yaml.org,2002:str', data, style='"')


def add_gha_caching_to_compose_file(
    compose_file_path: str,
    service_name: str,
    version: str
) -> None:
  with open(compose_file_path, 'r') as fh:
    compose = yaml.safe_load(fh.read())

  compose['services'][service_name]['build']['cache_from'] = \
      [f'type=gha,scope={service_name}-{version}']
  compose['services'][service_name]['build']['cache_to'] = \
      [f'type=gha,scope={service_name}-{version}']

  yaml.add_representer(str, yaml_quoted_presenter)

  with open(compose_file_path, 'w') as fh:
    fh.write("---\n")
    yaml.dump(compose, default_flow_style=False, sort_keys=False, stream=fh)


if __name__ == '__main__':
  parser = argparse.ArgumentParser()
  parser.add_argument(
    "compose_file",
    help="the path to the docker compose file",
  )
  parser.add_argument(
    "service",
    help="the docker compose service to add caching to",
  )
  parser.add_argument(
    "version",
    help="the python version in use for this build",
  )
  args = parser.parse_args()
  add_gha_caching_to_compose_file(
    args.compose_file,
    args.service,
    args.version,
  )
