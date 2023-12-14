module Kernel
  require 'open3'
  require 'pp'
  # Yes, I know this is hacky.

  def load_and_validate_config_file(config_file, parameters)
    # Parameters:
    #    config_file: String, the path to the config file that we need to load
    #    parameters: String Array, the parameters that the config file must have in order to pass
    #
    # Returns:
    #    No return

    puts "\t[#{config_file}]: Beginning load and validation of configuration file"
    # Load the file and throw an error if it failed
    begin
      config_json = File.read(config_file)
    rescue => e
      abort "\t[#{config_file}]: Unable to read configuration:\n#{e}"
    end

    puts "\t[#{config_file}]: Parsing the JSON configuration"
    # Parse the JSON and throw an error if it's not parsable
    begin
      config = JSON.parse(config_json)
    rescue => e
      abort "\t[#{config_file}]: Unable to parse the JSON configuration:\n#{e}"
    end

    # Make sure that the configuration has the parameters that we need
    parameters.each do |param|
      unless config.has_key?(param)
        abort "\t[#{config_file}] Error: Configuration file is missing parameter #{param}"
      end
    end

    puts "\t[#{config_file}]: Validation completed successfully and configuration has been loaded"

    return config
  end

  def create_folder(path)
    # Parameters:
    #    path: String, fully qualified folder path (i.e. /Users/jayson/scripts)
    #
    # Returns:
    #    No return
    #

    # Check to see if directory already exists and bomb out if it does
    begin
      Dir.mkdir(path)
    rescue TypeError # this happens if the path is empty
      abort 'Unable to create the path as the path is empty - please check your layers configuration'
    rescue => e
      abort "Unable to create path #{path}:\n\t#{e}"
    end
  end

  def create_file(path, size, method, source="/dev/urandom")
    # Parameters:
    #    path: String, fully qualified file path (i.e. /Users/jayson/scripts/test-0001.out)
    #    size: String, a number followed by a size (b|kb|mb|gb)
    #    method: String/Enum, "dd", "mkfile"
    #    source: Hardwiring this to "/dev/urandom" because anything else is more expensive
    #
    # Returns:
    #    No return

    valid_methods = %w(dd mkfile)

    # Make sure we have a valid file creation method
    unless valid_methods.include?(method)
      abort "Incorrect file creation method specified: #{method}, use one of: #{valid_methods.join(' ')}"
    end

    # Make sure we have a valid file size
    unless size =~ /[. 0-9]+(B|KB|MB|GB)/i
      abort "Incorrect size definition: #{size}, please use B, KB, MB, GB for sizes"
    end

    # Preflight checks complete, let's do the thing
    case method
      when 'dd'
        # dd requires the block size to have only one character, so we need to see if there
        # is more than one character at the end, and if so, chop off the last character
        if size =~ /[. 0-9]+(KB|MB|GB)/i
          dd_size = size[0...-1]
        else
          dd_size = size
        end

        # dd doesn't like spaces in the output parameter, so wrap in single quotes if there
        # are any whitespaces in the 'path' name
        if path =~ /\s/
          dd_path = "'#{path}'"
        else
          dd_path = path
        end

        dd_command = "dd if=#{source} of=#{dd_path} bs=#{dd_size} count=1"

        stdout, stderr, status = Open3.capture3(dd_command)

        abort "dd: Unable to create file #{path}:\n\t#{stderr}" unless status.success?
      when 'mkfile'
        mkfile_command = "mkfile -n #{size} #{path}}"

        stdout, stderr, status = Open3.capture3(mkfile_command)

        abort "mkfile: Unable to create file #{path}:\n\t#{stderr}" unless status.success?
      else
        abort "Invalid file creation method was used: #{method}, use one of: #{valid_methods.join(' ')}"
    end
  end

  def path_builder(layers)
    # Parameters:
    #   layers: Hash of all of the layers
    #
    # Returns:
    #   Hash of all of the paths that will need to be created
    #
    # This function will build a path list of every layer's folders so we can actually
    # create the nestled folder easily

    paths = Hash.new

    layers['layers'].each do |layer|
      # Layers need to be ordered in the exact nestled path that they need to be created in
      layer_count = 1
      atomic_layer = Hash.new

      until layer_count > layer['number_of_folders'].to_i
        folder = layer['folder_name_mask'].gsub('%', layer_count.to_s)
        if layer['parent'] == 'root'
          full_path = "#{layers['root']}/#{folder}"
          parent_path = layers['root']
        else
          paths.each do |_, data|
            # We need to check other paths to see if it has a parent_path that matches our own
            if layer['parent'] == data['folder']
              full_path = data['full_path'] + "/" + folder
              parent_path = data['full_path']
            end
          end
        end

        # At a minimum, we need to know what path to create
        atomic_layer = {
          'full_path' => full_path,
          'parent_path' => parent_path,
          'folder' => folder
        }

        # Add in the file creation specifications IF they exist (we can either create just folders or
        # folders AND files)
        atomic_layer['number_of_files'] = layer['number_of_files'].to_i unless layer['number_of_files'] == nil
        atomic_layer['size_of_files'] = layer['size_of_files'] unless layer['size_of_files'] == nil
        atomic_layer['file_name_mask'] = layer['file_name_mask'] unless layer['file_name_mask'] == nil

        paths[layer['id'] + "::" + folder] = atomic_layer
  
      layer_count = layer_count + 1
      end
    end

    return paths
  end
end
