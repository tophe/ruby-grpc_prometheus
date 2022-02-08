module GRPCPrometheus
  class ServerReporter
    attr_reader :labels
    def initialize(server_metrics:, method:, grpc_type:)

      @server_metrics = server_metrics
      @labels = {
        grpc_service: method.owner,
        grpc_method: method.name.to_s.split('_').map(&:capitalize).join(''),
        grpc_type: grpc_type,
      }

      @server_metrics.
        server_started_counter.
        increment(labels: @labels)
    end



   def handled(code, start_time)
      labels = @labels.dup.merge({ grpc_code: code })

      @server_metrics.
        server_handled_counter.
        increment(labels: labels)

      # puts (Time.now - start_time) * 1000
      #
      @server_metrics.
        summary.
        observe((Time.now - start_time) * 1000, labels: labels)

    end
  end
end
