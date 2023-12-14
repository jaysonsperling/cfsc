require 'json'
require 'pry'
require 'pp'
require_relative 'helpers.rb' # provides load_config() (yes, I know this is hacky...)

config_file = "config.json"
layers_file = "layers.json"

# Define the parameters that we need in the JSON config for execution
required_config_parameters = %w(file_creation_method verbose verbosity_level)
required_layers_parameters = %w(root layers)

# Load the configuration using load_and_validate_config_file and throw those
# JSON config hashes into variables that we will use during execution
puts 'Loading configurations...'
config = load_and_validate_config_file(config_file, required_config_parameters)
layers = load_and_validate_config_file(layers_file, required_layers_parameters)
root_layer = layers['root']

puts 'Configurations loaded successfully'
puts ''

# Create a hash of all the fully qualified parent paths from layers
layer_paths = path_builder(layers)

# Create the folder structure first, then we'll loop through again to create the files
puts 'Creating folder structure:'
print "\t[Root folder]: #{layers['root']}"
create_folder(layers['root'])
puts ' -- Done'
layer_paths.each do |layer_name, data|
  print "\t[#{layer_name}]: #{data['full_path']}"
  create_folder(data['full_path'])
  puts ' -- Done'
end
puts ''

# Loop through layer_paths again and start creating files!
# I want to make sure that all of the folders have been created first...
puts 'Creating files (this may take a while):'
layer_paths.each do |layer_name, data|
  if data['number_of_files'] && data['size_of_files'] && data['file_name_mask'] && data['number_of_files'] > 0
    current_number = 1
    until current_number > data['number_of_files']
      file_to_create = data['full_path'] + "/" + data['file_name_mask'].gsub('%', current_number.to_s)
      print "\t[#{file_to_create} with #{config['file_creation_method']} (#{data['size_of_files']})]"
      create_file(data['full_path'] + "/" + data['file_name_mask'].gsub('%', current_number.to_s), data['size_of_files'], config['file_creation_method'])
      puts ' -- Done'
      current_number = current_number + 1
    end
  end
end

puts "Run executed successfully - please find your new file structure in #{layers['root']}"
