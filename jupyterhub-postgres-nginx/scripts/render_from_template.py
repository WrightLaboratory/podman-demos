#! /usr/bin/env python

import argparse
import sys
import tomli

from os import getenv
from jinja2 import Environment, FileSystemLoader
from pathlib import Path


def render_yaml_from(template_filename, output_file, template_cfg, section='default'):

  with open(template_cfg, 'rb') as stream:
    config = tomli.load(stream)

  template_values = { k: config[section][k] for k in config[section] }

  p = Path(template_filename).absolute()
  environment = Environment(loader=FileSystemLoader(p.parent))
  template = environment.get_template(p.name)
  cfg = template.render(template_values)
  with open(output_file, mode='w', encoding='utf-8') as stream:
    stream.write(cfg)
  return


def main():
  parser = argparse.ArgumentParser()
  parser.add_argument('template', help='Path to Jinja2 template file')
  parser.add_argument('-c', '--config', help='Path to Jinja2 template configuration file with values')
  parser.add_argument('-o', '--output', help='Path to output file')
  args = parser.parse_args()

  try:
    template = args.template
    template_file = Path(template).expanduser().absolute()

    if (a := args.config) is None:
      p = Path(f'{template}.toml').expanduser().absolute()
    else:
      p = Path(a).expanduser().absolute()
    config_file = p

    if (a := args.output) is None and template.endswith('.j2'):
      p = Path(template.removesuffix('.j2')).expanduser().absolute()
    elif a is not None:
      p = Path(a).expanduser().absolute()
    else:
      p = Path(f'output.txt').expanduser().absolute()
    output_file=p

    #print(f"Template file : {template_file}")
    #print(f"Output file : {output_file}")
    #print(f"config file : {config_file}")
    
    render_yaml_from(template_filename=template_file, output_file=output_file, template_cfg=config_file)
    sys.exit(0)
  except IOError as e:
    print(f"{e.text}")
    sys.exit(1)

if __name__ == "__main__":
  main()
