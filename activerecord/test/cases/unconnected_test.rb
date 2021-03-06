require File.expand_path('../helper', __FILE__)

class TestRecord < ActiveRecord::Base
end

class TestUnconnectedAdapter < ActiveRecord::TestCase
  self.use_transactional_fixtures = false unless supports_savepoints?

  def setup
    @underlying = ActiveRecord::Base.connection
    @specification = ActiveRecord::Base.remove_connection
  end

  def teardown
    @underlying = nil
    ActiveRecord::Base.establish_connection(@specification)
    load_schema if in_memory_db?
  end

  def test_connection_no_longer_established
    assert_raise(ActiveRecord::ConnectionNotEstablished) do
      TestRecord.find(1)
    end

    assert_raise(ActiveRecord::ConnectionNotEstablished) do
      TestRecord.new.save
    end
  end

  def test_underlying_adapter_no_longer_active
    assert !@underlying.active?, "Removed adapter should no longer be active"
  end
end
