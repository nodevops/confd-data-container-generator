#!/usr/bin/python
import argparse
import os
import re
import sys


def validate_key(key, key_part_sep):
    """
    This function check the format of a key.
    A key is compound of key parts separated by a key part separator.
    Each key part accepts only lower case letters, upper case letters, digits and underscore characters.
    A key MUST start with a key part separator.
    :param key: the key to validate
    :param key_part_sep: the key part separator
    :raise : an Exception if the key format is no valid
    """
    if not key.startswith(key_part_sep):
        raise Exception("bad format for the key " + key +
                        ". It must start with a " + key_part_sep)
    # remove the first /
    new_key = key[1:]
    if len(new_key) == 0:
        raise Exception("bad format for the key " + key +
                        ". The first '/' must be followed by a word ")
    key_parts = new_key.split(key_part_sep)
    for key_part in key_parts:
        if not re.match('^\w+$', key_part):
            raise Exception("bad format for the key " + key +
                            ". The key part accepts only [A-Z][a-Z][0-9]_ characters")


def load_dictionary(directory_path, sep='=', part_key_sep='/', comment_char='#'):
    """
    Load a file into a dictionary. The format of the file must be key=value by line.
    If the line starts with a # it is considered as a comment.
    Blank lines are authorized.
    :param directory_path: the path of the dictionary file to load
    :param sep: the key/value separator. By default this is the  '=' character
    :param part_key_sep: the part key separator. By default the '/' character
    :param comment_char: the comment character. By default this is the # character
    :return: a dictionary containing the key/value pairs
    """

    if not os.path.exists(directory_path):
        return {}
    print "loading " + directory_path
    props = {}
    with open(directory_path, "rt") as f:
        for line in f:
            l = line.strip()
            if l and not l.startswith(comment_char):
                try:
                    key, value = l.split(sep, 1)
                except:
                    raise Exception("file " + directory_path + " : cannot parse line " + line)
                key = key.strip()
                try:
                    validate_key(key, part_key_sep)
                except Exception as e:
                    raise Exception(
                        "file " + directory_path + ' : ' + e.message)
                value = value.strip()
                if len(value) == 0:
                    raise Exception(
                        "file " + directory_path + " : missing value for property " + key +
                        " (while parsing line " + line + ")")

                props[key] = value
    if not props:
        print "\tDictionary is empty"
    return props


def store_dictionary(dictionary, file_path, output_type):
    """
    Store a dictionary in a file. Each key/value pair is converted to variable shell format.
    For example : /var1/var2=toto will be converted to VAR1_VAR2="toto"
    The value is surrounded by a double quote character
    :param dictionary: the dictionary to save
    :param file_path: the output file path
    :param output_type: the output format (env or dict)
    """
    with open(file_path, "wt") as f:
        for key, value in dictionary.items():
            key_env = key.upper().replace('/', '_')
            key_env = key_env[1:]
            if output_type == "env":
                f.write("export %s=\"%s\"\n" % (key_env, value))
            else:
                f.write("%s=%s\n" % (key, value))


def process_dictionaries(env, dictionaries_root_path, output_file_path, output_type):
    """
    Process a set of dictionary files according to :
        - an environment
        - a root dir which represents a tree of directories containing dictionary files
        - an output file in which the processing result will be saved
    :param env: the environment to process (ex. : p41, p2e).
    :param dictionaries_root_path: the root path of the directory containing dictionary files
    :param output_file_path: the file in which the processed result will be saved
    :param output_type: the output type (can be env or dict)
    """
    files_to_parse = [
        os.path.join(dictionaries_root_path, "common.dict"),
        os.path.join(dictionaries_root_path, env,  "main.dict"),
    ]
    all_props = {}
    for dict_file in files_to_parse:
        if os.path.isfile(dict_file):
            dictionary_props = load_dictionary(dict_file)
            for key, value in dictionary_props.iteritems():
                if key in all_props:
                    print "\tkey <" + key + "> overridden by value : <" + value + "> in file [" + dict_file + "]"
                else:
                    print "\tnew key <" + key + "> with value : <" + value + "> from file [" + dict_file + "]"
                all_props[key] = value
        else:
            print "\tfile [" + dict_file + "] does not seem to exist, skipping"

    store_dictionary(all_props, output_file_path, output_type)


if __name__ == '__main__':
    try:
        parser = argparse.ArgumentParser(description='Merge dictionaries and generate an env.sh')
        parser.add_argument('-e', '--env', required=True, help='the target environment')
        parser.add_argument('-r', '--root-path', required=True, help='the root path of the dictionary files to process')
        parser.add_argument('-f', '--file', required=False, default='env.sh', help='the name of the file to generate')
        parser.add_argument('-t', '--type', required=False, default='env', help='the output type, env or dict')
        args = parser.parse_args()

        if args.type not in ["env", "dict"]:
            raise ValueError("'%s' is not a valid value for option --type. Allowed values are 'env' and 'dict'" % args.type)
        print "Processing: env=" + args.env + \
              ", root=" + args.root_path + ", file=" + args.file + " type=" + args.type
        process_dictionaries(args.env, args.root_path, args.file, args.type)
        
    except Exception as e:
        print >> sys.stderr, "[ERROR] : ", e
        sys.exit(1)
