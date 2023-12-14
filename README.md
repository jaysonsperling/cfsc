# ------------------------------------------------------
# create_tree.rb - Create complicated folder tree setups
# ------------------------------------------------------
# Users can use this script and the associated config
# files to create complicated tree setups that include
# multiple folders with multiple files, all configured
# using the concept of "layers". Each layer represents
# a level in the folder heirchy and can be configured
# independently of the level above it.
# ------------------------------------------------------
# Layers note: The 'id' and 'parent' parameters are
# used to "link" layers together. You can define
# multiple childs of a layer and those children will
# have their level of the tree created in the parent ID
# ------------------------------------------------------
# There needs to be a single "id": "root" layer defined
# in the layers configuration file or else nothing will
# happen and you will get an error during execution

# Update these with your base and layer configuration
# files. They must be JSON and must have all of the
# required key-values. The default config.json and
# layers.json has an example configuration that you
# can use
