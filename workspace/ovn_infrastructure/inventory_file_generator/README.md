# Inventories and Vars files Generation

The templates are used to generate inventories and vars files.

Vars files can also be generated based on vars from previous epics.

To run this create a config_file defining the below parameters.
## Definitions for parameters in config_file
|Variable name      | Definition           | Sample        |
|:-----------------:|:-------------------- |:-------------:|
|epic_name          |This parameter defines the name of the epic sample|int-epic23|
|construct_from      |This parameter defines the epic from which the vars files need to be generated.<br>If the vars file should be generated from another epic then the value should be its epic name<br>If the vars file should be generated from the template then the value should be null|int-epic8, null|
|epic_template_dir  |This parameter defines the type of template to be used for making the files|CLR, VSS, AUTH|
|vm_dc1             |This parameter takes the comma seperated hostnames in dc1. |sl73ovnapdxxx,..|
|vm_dc2             |This parameter takes the comma seperated hostnames in dc2. |sl73ovnapdxxx,..|

currently only VSS template is defined. It is defined based on int-epic8.

## Dependencies
[Jinja2](http://jinja.pocoo.org/docs/2.10/intro/) for converting templates to files.

[jinja2-cli yaml](https://github.com/mattrobenolt/jinja2-cli) for running jinja2 from command line.

## Usage
```bash
make config=path_to_config
```
