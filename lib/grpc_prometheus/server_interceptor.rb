module GRPCPrometheus
  class ServerInterceptor < ::GRPC::ServerInterceptor
    def initialize(server_metrics)
      @server_metrics = server_metrics
    end

    def request_response(request: nil, call: nil, method: nil)
      reporter = ServerReporter.new(
        server_metrics: @server_metrics,
        method: method,
        grpc_type: GRPCType::UNARY,
      )
      grpc_err = nil
      yield
    rescue => err
      grpc_err = to_grpc_err(err)
      raise err
    ensure
      binding.pry
      if grpc_err
        reporter.handled(Util::ALL_CODES[grpc_err.code])
      else
        reporter.handled(Util::ALL_CODES[::GRPC::Core::StatusCodes::OK])
      end
    end

    # These metrics for streaming messages can't be collected
    # with the current gRPC implementation in Ruby
    #
    # - grpc_server_msg_received_total
    # - grpc_server_msg_sent_total
    #
    # Need to wait for this Pull Request to be released:
    #
    # - https://github.com/grpc/grpc/pull/17651

    def client_streamer(call: nil, method: nil)
      reporter = ServerReporter.new(
        server_metrics: @server_metrics,
        method: method,
        grpc_type: GRPCType::CLIENT_STREAM,
      )
      grpc_err = nil
      yield
    rescue => err
      grpc_err = to_grpc_err(err)
      raise err
    ensure
      if grpc_err
        reporter.handled(Util::ALL_CODES[grpc_err.code])
      else
        reporter.handled(Util::ALL_CODES[::GRPC::Core::StatusCodes::OK])
      end
    end

    def server_streamer(request: nil, call: nil, method: nil)
      reporter = ServerReporter.new(
        server_metrics: @server_metrics,
        method: method,
        grpc_type: GRPCType::SERVER_STREAM,
      )
      grpc_err = nil
      yield
    rescue => err
      grpc_err = to_grpc_err(err)
      raise err
    ensure
      if grpc_err
        reporter.handled(Util::ALL_CODES[grpc_err.code])
      else
        reporter.handled(Util::ALL_CODES[::GRPC::Core::StatusCodes::OK])
      end
    end

    def bidi_streamer(requests: nil, call: nil, method: nil)
      reporter = ServerReporter.new(
        server_metrics: @server_metrics,
        method: method,
        grpc_type: GRPCType::BIDI_STREAM,
      )
      grpc_err = nil
      yield
    rescue => err
      grpc_err = to_grpc_err(err)
      raise err
    ensure
      if grpc_err
        reporter.handled(Util::ALL_CODES[grpc_err.code])
      else
        reporter.handled(Util::ALL_CODES[::GRPC::Core::StatusCodes::OK])
      end
    end

    private

    def to_grpc_err(err)
      if err.is_a?(::GRPC::BadStatus)
        err
      else
        ::GRPC::BadStatus.new_status_exception(
          ::GRPC::Core::StatusCodes::UNKNOWN,
          err.message
        )
      end
    end
  end
end
