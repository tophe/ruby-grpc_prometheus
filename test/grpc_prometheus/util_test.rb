require 'test_helper'
require 'foo_services_pb'

class GRPCPrometheus::UtilTest < Minitest::Test
  def test_type_from_method_info_unary
    assert_equal 'unary', GRPCPrometheus::Util.type_from_method_info(Yuya::Takeyama::Test::Foo::Service.rpc_descs[:Unary])
  end

  def test_type_from_method_info_client_stream
    assert_equal 'client_stream', GRPCPrometheus::Util.type_from_method_info(Yuya::Takeyama::Test::Foo::Service.rpc_descs[:ClientStream])
  end

  def test_type_from_method_info_server_stream
    assert_equal 'server_stream', GRPCPrometheus::Util.type_from_method_info(Yuya::Takeyama::Test::Foo::Service.rpc_descs[:ServerStream])
  end

  def test_type_from_method_info_bidi_stream
    assert_equal 'bidi_stream', GRPCPrometheus::Util.type_from_method_info(Yuya::Takeyama::Test::Foo::Service.rpc_descs[:BidiStream])
  end
end
