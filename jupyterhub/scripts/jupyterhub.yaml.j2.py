#! /usr/bin/env python

from configparser import ConfigParser
from os import getenv
from jinja2 import Environment, FileSystemLoader
from pathlib import Path

config = ConfigParser()
config.read('jupyterhub.yaml.j2.ini')

jupyter_pod_values = { k: config['jupyterhub_pod'][k] for k in config['jupyterhub_pod'] }

p = Path('jupyterhub.yaml.j2').absolute()
environment = Environment(loader=FileSystemLoader(p.parent))
template = environment.get_template(p.name)
cfg = template.render(jupyter_pod_values)
with open('jupyterhub.yaml', mode='w', encoding='utf-8') as stream:
  stream.write(cfg)
