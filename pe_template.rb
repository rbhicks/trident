module PeTemplate
  require_relative 'Trident'

  def PeTemplate::dos_header engine
    t = Trident::TridentTemplate.new engine, :PeTemplate, :dos_header do
       magic_number             @int_word_unsigned
       bytes_on_last_page       @int_word_unsigned
       pages                    @int_word_unsigned
       relocations              @int_word_unsigned
       paragraphs_in_header     @int_word_unsigned
       minimum_extra_paragraphs @int_word_unsigned
       maximum_extra_paragraphs @int_word_unsigned
       initial_ss               @int_word_unsigned
       initial_sp               @int_word_unsigned
       checksum                 @int_word_unsigned
       initial_ip               @int_word_unsigned
       initial_cs               @int_word_unsigned
       relocation_table_address @int_word_unsigned
       overlay_number           @int_word_unsigned
       reserved_0               @int_word_unsigned, 4
       oem_id                   @int_word_unsigned
       oem_info                 @int_word_unsigned
       reserved_1               @int_word_unsigned, 10
       pe_header_address        @int_dword_unsigned
    end
    t.finished
    t
  end

  module CalculatedAddresses 
    def CalculatedAddresses::pe_header engine
      engine.move_absolute engine.templates[:PeTemplate][:dos_header].pe_header_address[:field_offset]
      address_string = engine.read engine.templates[:PeTemplate][:dos_header].pe_header_address[:field_size]
      engine.hex_byte_string_to_integer address_string
    end        
  end

  def PeTemplate::image_file_header engine
    t = Trident::TridentTemplate.new engine, :PeTemplate, :image_file_header do
      machine                 @int_word_unsigned
      number_of_sections      @int_word_unsigned
      time_date_stamp         @int_dword_unsigned
      pointer_to_symbol_table @int_dword_unsigned
      number_of_symbols       @int_dword_unsigned
      size_of_optional_header @int_word_unsigned
      characteristics         @int_word_unsigned
    end
    t.finished
    t
  end

  def PeTemplate::image_data_directory engine
    t = Trident::TridentTemplate.new engine, :PeTemplate, :image_data_directory do   
      virtual_address @int_word_unsigned
      size            @int_dword_unsigned
    end
    t.finished
    t
  end

  def PeTemplate::image_optional_header_32 engine
    t = Trident::TridentTemplate.new engine, :PeTemplate, :image_optional_header_32 do   
      magic                          @int_word_unsigned
      major_linker_version           @int_byte_unsigned
      minor_linker_version           @int_byte_unsigned
      size_of_code                   @int_dword_unsigned
      size_of_initialized_data       @int_dword_unsigned
      size_of_uninitialized_data     @int_dword_unsigned
      address_of_entry_point         @int_dword_unsigned
      base_of_code                   @int_dword_unsigned
      base_of_data                   @int_dword_unsigned                 
      image_base                     @int_dword_unsigned
      section_alignment              @int_dword_unsigned
      file_alignment                 @int_dword_unsigned
      major_operating_system_version @int_word_unsigned
      minor_operating_system_version @int_word_unsigned
      major_image_version            @int_word_unsigned
      minor_image_version            @int_word_unsigned
      major_subsystem_version        @int_word_unsigned
      minor_subsystem_version        @int_word_unsigned
      win32_version_value            @int_dword_unsigned
      size_of_image                  @int_dword_unsigned
      size_of_headers                @int_dword_unsigned
      checksum                       @int_dword_unsigned
      subsystem                      @int_word_unsigned
      dll_characteristics            @int_word_unsigned
      size_of_stack_reserve          @int_dword_unsigned
      size_of_stack_commit           @int_dword_unsigned
      size_of_heap_reserve           @int_dword_unsigned
      size_of_heap_commit            @int_dword_unsigned
      loader_flags                   @int_dword_unsigned
      number_of_rva_and_sizes        @int_dword_unsigned
      data_directory                 :image_data_directory, 16
    end
    t.finished
    t
  end
end
