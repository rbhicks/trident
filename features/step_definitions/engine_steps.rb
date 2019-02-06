module TridentEngineWorld
  require_relative '../../trident'

  def engine
    # no defense, fail fast and loud if something's
    # wrong with the test file
    test_file = File.open("#{__dir__}/../../Procmon.exe", 'rb')
    @engine ||= Trident::TridentEngine.new [{template_name:      :PeTemplate,
                                             template_file_name: 'pe_template'}],
                                           test_file.read
    test_file.close
    @engine
  end
  
  def dos_header
    @dos_header ||= engine.templates[:PeTemplate][:dos_header]
  end

  # def launch

  #   engine.move_absolute 19
    
    # engine.helper_functions['PeTemplate::CalculatedAddresses'.to_sym].send :bloo
    # engine.helper_functions['PeTemplate::CalculatedAddresses'.to_sym].send :wackadoo
    # engine.helper_functions['PeTemplate::Helpers'.to_sym].send :zorg

    # puts dos_header.name
    # puts dos_header.total_size
    # puts dos_header.magic_number
    # puts dos_header.bytes_on_last_page
    # puts dos_header.pages
    # puts dos_header.relocations
    # puts dos_header.paragraphs_in_header
    # puts dos_header.minimum_extra_paragraphs
    # puts dos_header.maximum_extra_paragraphs
    # puts dos_header.initial_ss
    # puts dos_header.initial_sp
    # puts dos_header.checksum
    # puts dos_header.initial_ip
    # puts dos_header.initial_cs
    # puts dos_header.relocation_table_address
    # puts dos_header.overlay_number
    # puts dos_header.reserved_0
    # puts dos_header.oem_id
    # puts dos_header.oem_info
    # puts dos_header.reserved_1
    # puts dos_header.pe_header_address

    # puts "\n"
#   end
end



World(TridentEngineWorld)

Given("a move_absolute action with a good offset") do
  @engine = engine
end

When("the engine.move_absolute with the good {int} action is taken") do |input_offset|
  @engine.move_absolute input_offset
end

Then("the engine's {int} should be {int}") do |current_offset, input_offset|
  expect(@engine.current_offset).to eq input_offset
end

############################################################################

Given("a move_absolute action with a bad offset") do
  @engine = engine
end

When("the engine.move_absolute with the bad {int} action is taken") do |input_offset|
  begin
    @engine.move_absolute input_offset
  rescue Trident::AbsoluteOffsetInvalid
    @exception = :AbsoluteOffsetInvalid
  end
end

Then "scan should fail with an AbsoluteOffsetInvalid exception" do
  expect(@exception).to eq :AbsoluteOffsetInvalid
end

############################################################################

Given("a move_relative action with a good offset and this {int}") do |starting_offset|
  @engine = engine
  @engine.move_absolute starting_offset
end

When("the engine.move_relative with the good {int} action is taken") do |input_offset|
  @engine.move_relative input_offset
end

Then("the {int} minus the {int} should equal the engine's {int}") do |starting_offset,
                                                                      input_offset,
                                                                      current_offset|
  expect(@engine.current_offset).to eq (starting_offset + input_offset)
end

############################################################################

Given("a move_relative action with a bad offset and this {int}") do |starting_offset|
  @engine = engine
  @engine.move_absolute starting_offset
end

When("the engine.move_relative with the bad {int} action is taken") do |input_offset|
  begin
    @engine.move_relative input_offset
  rescue Trident::RelativeOffsetInvalid
    @exception = :RelativeOffsetInvalid
  end
end

Then("scan should fail with an RelativeOffsetInvalid exception") do
  expect(@exception).to eq :RelativeOffsetInvalid
end

############################################################################

Given("a read action for the {int} with a valid size") do |current_offset|
  @engine = engine
  @engine.move_absolute current_offset
end

When("the engine.read with a valid read {int} action is taken") do |size|
  @binary_string = @engine.read size
end

Then("a binary string matching the original {string} is returned") do |source_string|
  expect(@binary_string).to eq source_string
end

############################################################################

Given("a read action for the {int} with an invalid size") do |current_offset|
  @engine = engine
  @engine.move_absolute current_offset
end

When("the engine.read with an invalid read {int} action is taken") do |size|
  begin
    @binary_string = @engine.read size
  rescue Trident::InvalidReadSize
    @exception = :InvalidReadSize
  end
end

Then("the scan will fail with an InvalidReadSize exception") do
  expect(@exception).to eq :InvalidReadSize
end

############################################################################

Given("a match action for the {int} with a matching sequence") do |current_offset|
  @engine = engine
  @engine.move_absolute current_offset
end

When("the engine.match with a matching {string} action is taken") do |sequence|
  @match_result = @engine.match sequence
end

Then("true is returned") do
  expect(@match_result).to be true
end

############################################################################

Given("a match action for the {int} with an unmatching sequence") do |current_offset|
  @engine = engine
  @engine.move_absolute current_offset
end

When("the engine.match with an unmatching {string} action is taken") do |sequence|
  @match_result = @engine.match sequence
end

Then("false is returned") do
  expect(@match_result).to be false
end

############################################################################

Given("a match action for the {int} with an invalid sequence") do |current_offset|
  @engine = engine
  @engine.move_absolute current_offset
end

When("the engine.match with an invalid {string} action is taken") do |sequence|
  begin
    if !sequence.empty?
      @engine.match ((sequence + " ") * 500000)
    else
      @engine.match sequence
    end
  rescue Trident::InvalidMatchSize
    @exception = :InvalidMatchSize
  end
end

Then("the scan will fail with an InvalidMatchSize exception") do
  expect(@exception).to eq :InvalidMatchSize
end

############################################################################

Given("A Dos Header template and a valid field name") do
  @engine     = engine
  @dos_header = engine.templates[:PeTemplate][:dos_header]
end

When("A valid {string} is referenced") do |field_name|
  @new_offset = (@dos_header.send field_name.to_sym)[:field_offset]
end

Then("The offset returned should match the {int}") do |expected_output|
  expect(@new_offset).to be expected_output
end

############################################################################

Given("A Dos Header template and a valid calculated address method") do
  @engine     = engine
  @dos_header = engine.templates[:PeTemplate][:dos_header]
end

When("A valid {string} is calculated") do |calculated_address|
  @calculated_address = engine.helper_functions['PeTemplate::CalculatedAddresses'.to_sym].send :pe_header, engine
end

Then("The address returned should match the {int}") do |expected_address|
  expect(@calculated_address).to be expected_address
end

############################################################################

Given("A Dos Header template and an invalid field name") do
  @engine     = engine
  @dos_header = engine.templates[:PeTemplate][:dos_header]
end

When("An invalid {string} is referenced") do |field_name|
  begin
      (@dos_header.send field_name.to_sym)
  rescue NoMethodError
    @exception = :NoMethodError
  end
end

Then("Then a NoMethoderror exception should be thrown for the invalid field name") do
  expect(@exception).to eq :NoMethodError
end

############################################################################

Given("A Dos Header template and an invalid calculated address method") do
  @engine     = engine
  @dos_header = engine.templates[:PeTemplate][:dos_header]
end

When("A invalid {string} is calculated") do |calculated_address|
  begin
      engine.helper_functions['PeTemplate::CalculatedAddresses'.to_sym].send calculated_address.to_sym, engine
  rescue NoMethodError
    @exception = :NoMethodError
  end  
end

Then("Then a NoMethoderror exception should be thrown for the invalid address") do
  expect(@exception).to eq :NoMethodError
end
