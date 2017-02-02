class ApplicationJob < ActiveJob::Base
  def self.gateway_exchange
    channel.exchange(opts[:exchange], opts[:exchange_options])
  end

  def self.distributor_exchange
    channel.exchange('active_jobs', type: :direct, durable: true)
  end

  def self.message_log_queue
    channel.queue('message_log', durable: true)
  end

  def self.job_wrapper
    distributor_exchange.bind(gateway_exchange)
    message_log_queue.bind(gateway_exchange)
    klass = self
    Class.new(ActiveJob::QueueAdapters::SneakersAdapter::JobWrapper) do
      from_queue klass.queue_name,
        exchange: klass.distributor_exchange.name,
        exchange_type: klass.distributor_exchange.type
    end
  end

  private

  def self.opts
    Sneakers::CONFIG
  end

  def self.conn
    @conn ||= opts[:connection] || Bunny.new(@opts[:amqp], :vhost => @opts[:vhost], :heartbeat => @opts[:heartbeat], :logger => Sneakers::logger)
    @conn.start
  end

  def self.channel
    @channel ||= conn.create_channel
  end
end
