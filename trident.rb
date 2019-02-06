module Trident

  RubyVM::InstructionSequence.compile_option = {
    tailcall_optimization: true,
    trace_instruction: false
  }                                                       

  class ScanError < StandardError
    def initialize(msg="Scan Error")
      super
    end
  end

  class AbsoluteOffsetInvalid < ScanError
    def initialize(msg="move_absolute offset is outside scan buffer bounds")
      super
    end
  end

  class RelativeOffsetInvalid < ScanError
    def initialize(msg="move_relative offset is outside scan buffer bounds")
      super
    end
  end

  class InvalidReadSize < ScanError
    def initialize(msg="read size is invalid")
      super
    end
  end

  class InvalidMatchSize < ScanError
    def initialize(msg="match size is invalid")
      super
    end
  end
  
  class TridentEngine

    attr_reader :templates, :helper_functions, :current_offset
    
    def initialize template_information, scan_buffer
      @template_information = template_information
      @templates            = {}
      @helper_functions     = {}
      @current_offset       = 0
      @current_last_offset  = scan_buffer.length - 1
      @scan_buffer          = scan_buffer
      

      # process all the template files provided
      @template_information.each do |template_information_hash|
        
        require_relative template_information_hash[:template_file_name]
        
        module_constant = Object.const_get template_information_hash[:template_name]
        @templates[template_information_hash[:template_name]] = {}

        # process all the template declarations that use the missing_method mechanism
        (module_constant.methods - Object.methods).each do |template_section_declarator|
          template = module_constant.send(template_section_declarator, self)
          @templates[template_information_hash[:template_name]][template_section_declarator] = template
        end

        # wire up the extra template functions through their path name's symbol
        # since the actual scan logic will look them up with their path name's symbol,
        # which they need to know about to use, but since we require them here we need
        # the sub-module/function path constant set up here
        module_constant.constants.each do |sub_module_constant|
          sub_module_path_constant = module_constant.const_get sub_module_constant
          @helper_functions[sub_module_path_constant.name.to_sym] = sub_module_path_constant
        end
      end
    end    

    def offset_is_valid offset
      offset <= @current_last_offset &&
      offset >= 0
    end

    def read_or_match_size_is_valid size
      @current_offset + size <= @current_last_offset &&
      size                   >= 0
    end

    def wildcard_match sequence, target
      sequence_string_bytes = sequence.split
      target_string_bytes   = target.split
      match                 = true
  
      sequence_string_bytes.each_with_index do |string_byte, index|
        if string_byte != "??"
          if string_byte != target_string_bytes[index]
            match = false
            break
          end
        end
      end
      match
    end

    def hex_byte_string_to_integer hex_byte_string
      #currently only little-endianness is supported
      reversed_hex_byte_array  = hex_byte_string.split.reverse
      reversed_hex_byte_array.join.to_i 16
    end
    
    def move_absolute absolute_offset
      fail AbsoluteOffsetInvalid unless offset_is_valid absolute_offset
      @current_offset = absolute_offset
    end

    def move_relative relative_offset
      # fail logic is inverted here to simplify validation:
      # since negative relative offsets are allowed it's
      # much simpler to set @current_offset first and
      # then validate since @current_offset should always
      # be positive
      @current_offset += relative_offset
      fail RelativeOffsetInvalid unless offset_is_valid @current_offset
    end
  
    def read size
      fail InvalidReadSize unless read_or_match_size_is_valid size
      raw_to_hex_char_format_string = ("%02x " * size).rstrip!
      read_slice                    = @scan_buffer.slice(@current_offset, size)

      (raw_to_hex_char_format_string % read_slice.bytes).upcase
    end

    def match sequence
      fail InvalidMatchSize unless !sequence.empty? && read_or_match_size_is_valid(sequence.length)
      size                          = sequence.split.size
      raw_to_hex_char_format_string = ("%02x " * size).rstrip!
      sequence_slice                = @scan_buffer.slice(@current_offset, size)

      wildcard_match sequence, (raw_to_hex_char_format_string % sequence_slice.bytes).upcase
    end
  end
  
  class TridentTemplate

    attr_reader :name, :total_size
   
    def initialize engine, template_name, name, &block

      ###################################################
      # would really want to make these class variables,
      # but it can't be done since class variables can't
      # be accessed inside a call in 'intance_eval'
      ###################################################
      
      @pad_byte           = 1
      @ascii_char         = 1
      @unicode_char       = 2
      @int_byte_unsigned  = 1
      @int_byte_signed    = 1
      @int_word_unsigned  = 2
      @int_word_signed    = 2
      @int_dword_unsigned = 4
      @int_dword_signed   = 4
      @int_qword_unsigned = 8
      @int_qword_signed   = 8

      @name            = nil
      @total_size      = 0
      @address_lambdas = {}

      current_field_offset = 0
      
      define_singleton_method :method_missing do |method_name, *args|
        field_size = 0
        if args[0].is_a? Integer
          field_size = args.reduce 1, :*
        else
          field_size = engine.templates[template_name][args[0]].total_size
          if args[1]
            field_size *= args[1]
          end
        end
        @total_size += field_size
        field_offset = current_field_offset
        define_singleton_method method_name do
          {field_size: field_size, field_offset: field_offset}
        end
        current_field_offset += field_size
      end

      @name = name
      instance_eval &block
    end

    def finished
      self.instance_eval { undef :method_missing }
    end
  end
end
