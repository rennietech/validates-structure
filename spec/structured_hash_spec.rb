require 'spec_helper'

describe 'A simple instance of StructuredHash' do
  class MySimpleHash < ValidatesStructure::StructuredHash
    key 'apa', Integer, presence: true
  end

  describe 'given a hash' do
    before :each do
      @hash = { apa: 1 }
      @mine = MySimpleHash.new @hash
    end
    
    it 'should respond to ActiveModel validation methods' do
      @mine.should respond_to 'valid?'
      @mine.should respond_to 'errors'
    end

    it 'should have the original hash accessible' do
      @mine.raw.should eq(@hash)
    end

    it 'should have the hash items accessible through array lookup syntax (string key)' do
      @mine['apa'].should eq 1
    end

    it 'should have the hash items accessible through array lookup syntax (symbol key)' do
      @mine[:apa].should eq 1
    end
  end

  describe 'given a json string' do
    before :each do
      @json = '{"apa": 1}'
      @mine = MySimpleHash.new @json
    end

    it 'should have the original json accessible' do
      @mine.raw.should eq(@json)
    end

    it 'should have the hash items accessible through array lookup syntax' do
      @mine[:apa].should eq 1
    end
  end

  describe 'given a hash with superfluous keys' do
    it 'should not be valid (empty)' do
      MySimpleHash.new(nil).should_not be_valid
    end

    it 'should not be valid (primitive klass)' do
      MySimpleHash.new(3).should_not be_valid
    end

    it 'should not be valid (simple)' do
      MySimpleHash.new(apa: 1, bepa: 2 ).should_not be_valid
    end

    it 'should not be valid (nested hash)' do
      MySimpleHash.new(apa: { bepa: 2 } ).should_not be_valid
    end

    it 'should not be valid (nested array)' do
      MySimpleHash.new(apa: [2, 3, 4] ).should_not be_valid
    end

    it 'should not be valid (double nested array)' do
      MySimpleHash.new(apa: [[1,2,3], [1,2,3], [1,2,3]] ).should_not be_valid
    end

    it 'should not be valid (array of hashes)' do
      MySimpleHash.new(apa: [{apa: 1}, {bepa: 1}, {cepa: 1}] ).should_not be_valid
    end
  end

end

describe 'A nested instance of StructuredHash' do
  class MyStructuredHash < ValidatesStructure::StructuredHash
    key 'bepa', Hash, presence: true do
      key 'cepa', Integer, presence: true, format: { with: /3/i}
    end
  end

  describe 'given a valid hash' do
    before :each do
      @hash = { bepa: { cepa: 3 } }
      @mine = MyStructuredHash.new @hash
    end

    it 'should respond with "3" to "[:bepa][:cepa]"' do
      @mine[:bepa][:cepa].should eq 3
    end

    it 'should be valid' do
      @mine.should be_valid
    end
  end


  describe 'given an invalid hash' do
    before :each do
      @hash = { bepa: { cepa: 'invalid' } }
      @mine = MyStructuredHash.new @hash
    end

    it 'should not be valid' do
      @mine.should_not be_valid
    end
  end
end


describe 'A StructuredHash containing an array' do
  class MyArrayHash < ValidatesStructure::StructuredHash
    key 'apa', Hash, presence: true do
      key 'bepa', Array, presence: true do
        value Integer, presence: true
      end
    end
  end

  describe 'given a valid hash' do
    before :each do
      @hash = { apa: { bepa: [ 3, 5, 10 ] } }
      @mine = MyArrayHash.new @hash
    end

    it 'should be valid' do
      @mine.should be_valid
    end
  end

  describe 'given an invalid hash' do
    before :each do
      @hash = { apa: { bepa: [ 3, 'invalid', 10 ] } }
      @mine = MyArrayHash.new @hash
    end

    it 'should not be valid' do
      @mine.should_not be_valid
    end
  end
end


describe 'A compound instance of StructuredHash' do
  class MyInnerHash < ValidatesStructure::StructuredHash
      key 'bepa', Integer, presence: true
  end

  class MyOuterHash < ValidatesStructure::StructuredHash
    key 'apa', MyInnerHash, presence: true
  end

  describe 'given a valid hash' do
    before :each do
      @hash = { apa: { bepa: 3 } }
      @mine = MyOuterHash.new @hash
    end

    it 'should be valid' do
      @mine.should be_valid
    end
  end

  describe 'given an invalid hash' do
    before :each do
      @hash = { apa: { bepa: 'invalid' } }
      @mine = MyOuterHash.new @hash
    end

    it 'should not be valid' do
      @mine.should_not be_valid
    end
  end

  describe 'given a hash with superfluous keys' do
    it 'should not be valid' do
      MySimpleHash.new(apa: {bepa: 2}, cepa: 2 ).should_not be_valid
    end
  end
end

describe 'A StructuredHash with a custom validation' do
  class MyCustomHash < ValidatesStructure::StructuredHash
    key 'apa', Integer, presence: true, with: :validate_odd

    def validate_odd(attribute)
      errors.add attribute, "can't be even." if self[attribute].even?
    end
  end

  describe 'given a valid hash' do
    before :each do
      @hash = { apa: 3 }
      @mine = MyCustomHash.new @hash
    end

    it 'should be valid' do
      @mine.should be_valid
    end
  end

  describe 'given an invalid hash' do
    before :each do
      @hash = { apa: 2 }
      @mine = MyCustomHash.new @hash
    end

    it 'should not be valid' do
      @mine.should_not be_valid
    end
  end
end

describe 'A StructuredHash with an optional key' do
  class MyOptionalHash < ValidatesStructure::StructuredHash
    key 'apa', Integer
  end

  describe 'given a hash without the key' do
    before :each do
      @mine = MyOptionalHash.new({})
    end
    
    it 'should be valid' do
      @mine.should be_valid
    end
  end
end