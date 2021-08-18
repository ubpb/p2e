# If you need an ssh tunnel use: ssh -L 1521:localhost:1521 your_oracle_box

Bundler.require
Dotenv.load(File.expand_path('.env', __dir__))

def set_default_options(&block)
  options do
    add :aleph_sid, "--aleph-sid SID", "Aleph SID", String, default: ENV.fetch("ALEPH_SID") { "aleph22" }
    add :aleph_user, "-u", "--aleph-user USER", "Aleph User", String, default: ENV.fetch("ALEPH_USER") { "padview" }
    add :aleph_password, "-p", "--aleph-password PASS", "Aleph Password", String, default: ENV.fetch("ALEPH_PASSWORD") { "" }
    add :aleph_host, "--aleph-host HOST", "Aleph Host", String, default: ENV.fetch("ALEPH_HOST") { "localhost" }
    add :aleph_port, "--aleph-port PORT", "Aleph Port", String, default: ENV.fetch("ALEPH_PORT") { "1521" }
    add :log_level, "-l", "--log-level LOG_LEVEL", "Log level", String, default: "error"
    block.call(self) if block_given?
  end
end

def logger
  @logger ||= Logger.new(STDOUT)
  @logger.level = options[:log_level]
  @logger
end

def db
  @db ||= Sequel.oracle(
    options[:aleph_sid],
    user: options[:aleph_user],
    password: options[:aleph_password],
    host: options[:aleph_host],
    port: options[:aleph_port],
    logger: logger
  )
end

def create_progress_bar(count)
  @progress_bar = ProgressBar.create(
    title: "Progress",
    total: count,
    format: "%t: |%B| %p%% %e",
    throttle_rate: 1,
    autostart: false
  )
end

def progress_bar
  @progress_bar
end
