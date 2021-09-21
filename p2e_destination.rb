class P2EDestination

  DEFAULT_OPTIONS = {
    create_report: false,
    p2e_csv_options: {
      col_sep: ",",
      force_quotes: false
    },
    iz_exclude_csv_options: {
      col_sep: ",",
      force_quotes: false
    },
    report_csv_options: {
      col_sep: ",",
      force_quotes: true
    }
  }

  def initialize(
    p2e_filename:,
    iz_exclude_filename:,
    report_filename:,
    options: {}
  )
    @report_headers_written = false
    @options = DEFAULT_OPTIONS.deep_merge(options)

    @p2e_filename        = ::File.expand_path(p2e_filename)
    @iz_exclude_filename = ::File.expand_path(iz_exclude_filename)
    @report_filename     = ::File.expand_path(report_filename)

    check_file!(@p2e_filename)
    check_file!(@iz_exclude_filename)
    check_file!(@report_filename)

    @p2e_file        = ::File.open(@p2e_filename, 'wb+')
    @iz_exclude_file = ::File.open(@iz_exclude_filename, 'wb+')
    @report_file     = ::File.open(@report_filename, 'wb+') if @options[:create_report]
  end

  def write(data)
    return if data.blank?

    write_p2e(data)
    write_iz_exclude(data) if data[:iz_exclude].present?
    write_report(data)     if @options[:create_report]
  end

  def close
    @p2e_file.close        if @p2e_file
    @iz_exclude_file.close if @iz_exclude_file
    @report_file.close     if @report_file
  end

private

  def check_file!(filename)
    if ::File.exists?(filename)
      raise "File `#{filename}` exists."
    end
  end

  def write_p2e(data)
    p2e_data = [
      "PAD01#{data[:id]}",
      data[:type]
    ]
    line = CSV.generate_line(p2e_data, **@options[:p2e_csv_options])
    @p2e_file.write(line)
  end

  def write_iz_exclude(data)
    iz_exclude_data = [
      "#{data[:id]}PAD01",
    ]
    line = CSV.generate_line(iz_exclude_data, **@options[:iz_exclude_csv_options])
    @iz_exclude_file.write(line)
  end

  def write_report(data)
    unless @report_headers_written
      line = CSV.generate_line(data.keys, **@options[:report_csv_options])
      @report_file.write(line)
      @report_headers_written = true
    end

    line = CSV.generate_line(data.values, **@options[:report_csv_options])
    @report_file.write(line)
  end

end
