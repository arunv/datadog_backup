# frozen_string_literal: true

module DatadogBackup
  module ThreadPool
    TPOOL = ::Concurrent::ThreadPoolExecutor.new(
      min_threads: 2,
      max_threads: 2,
      fallback_policy: :abort
    )

    def self.watcher(logger)
      Thread.new(TPOOL) do |pool|
        while pool.queue_length.positive?
          sleep 2
          logger.info("#{pool.queue_length} tasks remaining for execution.")
        end
      end
    end

    def self.shutdown(logger)
      logger.fatal 'Shutdown signal caught. Performing orderly shut down of thread pool. Press Ctrl+C again to forcibly shut down, but be warned, DATA LOSS MAY OCCUR.'
      TPOOL.shutdown
      TPOOL.wait_for_termination
    rescue SystemExit, Interrupt
      logger.fatal 'OK Nuking, DATA LOSS MAY OCCUR.'
      TPOOL.kill
    end
  end
end
