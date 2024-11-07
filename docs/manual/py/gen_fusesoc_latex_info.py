#!/usr/bin/env python3
################################################################################
# @file   gen_fusesoc_latex_info.py
# @author Jay Convertino(electrobs@gmail.com)
# @date   2024.11.04
# @brief  Generate a latex file with information filtered from the fusesoc.core file
#
# @license MIT
# Copyright 2024 Jay Convertino
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.
################################################################################
import argparse
import yaml
import sys
import re
import os

def main():
  args = parse_args(sys.argv[1:])

  latex_file = None

  core_filtered = None

  try:
    stream = open(args.core_file, 'r')
    loaded = yaml.safe_load(stream)
    core_filtered = loaded.get(args.prime_key_filter)
  except FileNotFoundError as e:
    print(str(e))
    exit(0)

  #open file for text writing
  try:
    latex_file = open(args.output, 'w')
  except FileNotFoundError as e:
    print(str(e))
    exit(0)

  latex_file.write(create_latex_item_list(core_filtered, args.sub_key_filter, args.list_name))

  latex_file.close()

  exit(0)

#one big dumb yaml parse function that pulls out values and puts it in a itemized list
def create_latex_item_list(dict_of_values, target_values, name):
  temp = f"\\subsubsection{{{name}}}\n"
  temp += f"\\begin{{itemize}}\n"
  for key, stuff in {key:value for key, value in dict_of_values.items() if value.get(target_values)}.items():
    temp += f"\\item {key}\n"
    temp += f"\t\\begin{{itemize}}\n"
    list_temp = ""
    for sub_key, items in stuff.items():
      if type(items) is list:
        for item in items:
          list_temp += f"\t\item {item}\n"
      elif sub_key == "file_type":
        temp += f"\t\item[$\space$] Type: {items}\n"
      elif sub_key == "description":
        temp += f"\t\item[$\space$] Info: {items}\n"

    temp += list_temp

    temp += f"\t\end{{itemize}}\n"

  temp += f"\end{{itemize}}\n"

  return temp.replace('_', '\\' + '_')

# parse args for tuning build
def parse_args(argv):
  parser = argparse.ArgumentParser(description='Automate latex file generation by parsing information from the fusesoc.core file.')

  parser.add_argument('--prime_key_filter',      action='store',       default=None,               dest='prime_key_filter',    required=True, help='First key value used to filter the yaml.')
  parser.add_argument('--sub_key_filter',        action='store',       default=None,               dest='sub_key_filter',      required=True, help='Second key value used to filter the result of the first key value.')
  parser.add_argument('--list_name',             action='store',       default=None,               dest='list_name',           required=True, help='Name of the list to generate (will be a \subsection header).')
  parser.add_argument('--core_file',             action='store',       default=None,               dest='core_file',           required=True, help='Name of the fusesoc file to parse.')
  parser.add_argument('--output',                action='store',       default=None,               dest='output',              required=True, help='Name of the output latex file to generate (will be a .tex file).')

  return parser.parse_args()

# name is main is main
if __name__=="__main__":
  main()
