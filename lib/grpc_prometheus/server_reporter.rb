module GRPCPrometheus
  class ServerReporter
    def initialize(server_metrics:, method:, grpc_type:)
      @server_metrics = server_metrics
      @labels = {
        grpc_service: method.owner.service_name,
        grpc_method: method.name.to_s.split('_').map(&:capitalize).join(''),
        grpc_type: grpc_type,
      }.freeze

      @server_metrics.
        server_started_counter.
        increment(@labels)
    end

   def handled(code)
      labels = @labels.dup.merge({ grpc_code: code })
      @server_metrics.
        server_handled_counter.
        increment(labels)
    end
  end
end
