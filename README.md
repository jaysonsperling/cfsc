# Complicated File Structure Creator

Using JSON configuration files, create a complicated file structure that includes nestled folders and files of various sizes.

## Executing
`ruby create_tree.rb`

## Configuration Files
### config.json
#### Example configuration:
```
{
  "file_creation_method": "dd",
  "verbose": true,
  "verbosity_level": "info"
}
```
#### Configuration File Syntax:
_file_creation_method_: **dd** or **mkfile**
_verbose_: **true** or **false** (currently not implemented)
_verbosity_level_: debug-level style, **info**, **debug** (currently not implemented)
> _file_creation_method_, when set to use **dd**, will automatically use /dev/urandom for its source

### layers.json
#### Example configuration:
```
{
  "root": "/Users/jayson/Scripts/Ruby/cfsc/tree",
  "layers": [
    {
      "id": "level_1",
      "parent": "root",
      "number_of_folders": 10,
      "folder_name_mask": "root-1_%",
      "number_of_files": 2,
      "size_of_files": "200MB",
      "file_name_mask": "ES Tracker-V%.xlsx"
    },
    {
      "id": "level_2",
      "parent": "root",
      "number_of_folders": 1,
      "folder_name_mask": "root-2_%",
      "number_of_files": 5,
      "size_of_files": "500MB",
      "file_name_mask": "file_%.tmp"
    },
    {
      "id": "level_2_empty_dirs",
      "parent": "root-2_1",
      "number_of_folders": 1,
      "folder_name_mask": "level2empty-%"
    }
  ]
}
```
#### Configuration File Syntax:
_root_: The root directory you want the structure generated from this script to live.
_layers_: Array of layer configurations

#### Defining Layers
A "layer" is one or more configuration sets that indicate the name of a folder, the count of folders, and the folder mask to be used to create an iterative set of folders. A layer can also define a collection of files that need to be made inside of it.

The purpose behind using a JSON configuration file is to make it a bit easier to setup the desired structure instead of having to type everything on the command line.

##### Required Parameters:
_id_: A value to help you identify the later (no spaces, but dashes and underscores are okay)
_parent_: The folder that this folder should be created (nested) under
_number_of_folders_: The number of folders you wish to make
_folder_name_mask_: The name of the folders that you want to create. The script uses % to indicate that you want to use the iterative count in place of the % ("folder_%", with number_of_folders being 2, will generate "folder_1" and "folder_2")
>In order to create multiple layers of folders, each folder configuration set will need to refer to the _parent_'s folder name.
>
> In the example above, _level_2_empty_dirs_ is referring to the root-2_1 folder that is created, via mask, as a part of configuration set id _level_2_.

##### Optional Parameters:
_number_of_files_: The number of files to create inside of the given folder
_size_of_files_: The size of files you want to create. Size must be supplied as a number then size value next to it, such as "5MB", "2B", or "3GB"
_file_name_mask_: Same concept as _folder_name_mask_; provide the file name with a % in it to have the % replaced by the iterative count as the script processes
