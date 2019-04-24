# frozen_string_literal: true

module GRPCPrometheus
  module Util
    ALL_CODES = {
      ::GRPC::Core::StatusCodes::OK                  => 'Ok',
      ::GRPC::Core::StatusCodes::CANCELLED           => 'Cancelled',
      ::GRPC::Core::StatusCodes::UNKNOWN             => 'Unknown',
      ::GRPC::Core::StatusCodes::INVALID_ARGUMENT    => 'InvalidArgument',
      ::GRPC::Core::StatusCodes::DEADLINE_EXCEEDED   => 'DeadlineExceeded',
      ::GRPC::Core::StatusCodes::NOT_FOUND           => 'NotFound',
      ::GRPC::Core::StatusCodes::ALREADY_EXISTS      => 'AlreadyExists',
      ::GRPC::Core::StatusCodes::PERMISSION_DENIED   => 'PermissionDenied',
      ::GRPC::Core::StatusCodes::UNAUTHENTICATED     => 'Unauthenticated',
      ::GRPC::Core::StatusCodes::RESOURCE_EXHAUSTED  => 'ResourceExhausted',
      ::GRPC::Core::StatusCodes::FAILED_PRECONDITION => 'FailedPrecondition',
      ::GRPC::Core::StatusCodes::ABORTED             => 'Aborted',
      ::GRPC::Core::StatusCodes::OUT_OF_RANGE        => 'OutOfRange',
      ::GRPC::Core::StatusCodes::UNIMPLEMENTED       => 'Unimplemented',
      ::GRPC::Core::StatusCodes::INTERNAL            => 'Internal',
      ::GRPC::Core::StatusCodes::UNAVAILABLE         => 'Unavailable',
      ::GRPC::Core::StatusCodes::DATA_LOSS           => 'DataLoss',
    }.freeze

    module_function

    def type_from_method_info(method_info)
      if method_info.input.is_a?(::GRPC::RpcDesc::Stream)
        if method_info.output.is_a?(::GRPC::RpcDesc::Stream)
          'bidi_stream'
        else
          'client_stream'
        end
      else
        if method_info.output.is_a?(::GRPC::RpcDesc::Stream)
          'server_stream'
        else
          'unary'
        end
      end
    end
  end
end
