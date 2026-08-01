require "socket"

class UnsafeTestOperation < StandardError; end

module TestSafety
  module CommandGuard
    def system(*) = raise UnsafeTestOperation, "System commands must be stubbed in tests"
    def exec(*) = raise UnsafeTestOperation, "System commands must be stubbed in tests"
    def spawn(*) = raise UnsafeTestOperation, "System commands must be stubbed in tests"
    def fork(*) = raise UnsafeTestOperation, "System commands must be stubbed in tests"

    define_method(:"`") do |*|
      raise UnsafeTestOperation, "System commands must be stubbed in tests"
    end
  end

  module PopenGuard
    def popen(*) = raise UnsafeTestOperation, "System commands must be stubbed in tests"
  end

  module NetworkGuard
    def new(*) = raise UnsafeTestOperation, "Network calls must be stubbed in tests"
    def open(*) = raise UnsafeTestOperation, "Network calls must be stubbed in tests"
    def tcp(*) = raise UnsafeTestOperation, "Network calls must be stubbed in tests"
    def udp(*) = raise UnsafeTestOperation, "Network calls must be stubbed in tests"
  end
end

Kernel.prepend(TestSafety::CommandGuard)
Kernel.singleton_class.prepend(TestSafety::CommandGuard)
Process.singleton_class.prepend(TestSafety::CommandGuard)
IO.singleton_class.prepend(TestSafety::PopenGuard)
Socket.singleton_class.prepend(TestSafety::NetworkGuard)
TCPSocket.singleton_class.prepend(TestSafety::NetworkGuard)
UDPSocket.singleton_class.prepend(TestSafety::NetworkGuard)
