class NmapRecord < ApplicationRecord
  NMAP_FILE_EXTENSION = '.txt'

  validates_uniqueness_of :timestamp, scope: [:ip_address]

  belongs_to :host

  def self.upload_data(path)
    @nmap_path = File.join(path, 'nmap')
    @success_count = 0
    @failure_count = 0
    return { error: 'Arp directory not found' } unless File.exists? @nmap_path
    create_records
    return { result: "#{@success_count} recordes created, #{@failure_count} failed"}
  end

  private

  def self.create_records
    # Dir.entries(@nmap_path).select do |entry|
    #   File.directory?(File.join(@nmap_path, entry)) && !(entry == '.' || entry == '..')
    # end.each{ |entry| create_date_records(File.join(@nmap_path, entry)) }
    Dir.entries(@nmap_path).select do |entry|
      File.directory?(File.join(@nmap_path, entry)) && !(entry == '.' || entry == '..')
    end.each{ |entry| create_date_records(File.join(@nmap_path, entry)) }
  end

  def self.create_date_records(date_folder)
    Dir.entries(date_folder).select do |entry|
      path = File.join(date_folder, entry)
      File.file?(path) && File.extname(path) == NMAP_FILE_EXTENSION
    end.each{ |entry| create_timestamp_records(File.join(date_folder, entry)) }
  end

  def self.create_timestamp_records(path)
    timestamp = Pathname.new(path).basename.to_s
    File.readlines(path)[1..-2].each do |line|
      create_record(line, timestamp)
    end
  end

  def self.create_record(line, timestamp)
    captures = line.match(
      /Host: ((?:(?:\d+)\.){3}\d+) \((.*)\)\tStatus: (.*)/
    ).captures
    params = {
      ip_address: captures[0],
      host_name:  captures[1],
      status:     captures[2],
      timestamp:  DateTime.parse(timestamp)
    }

    @record = find_by(params.slice(:timestamp, :ip_address)) || new(params)

    @record.host = Host.find_by(name: params[:host_name]) ||
      ArpRecord.where(timestamp: (params[:timestamp] - TIME_ERROR)..(params[:timestamp] + TIME_ERROR), ip_address: params[:ip_address]).first.try(:host).try{ |h| h.update_and_return(name: params[:host_name]) } ||
      Host.create(name: params[:host_name])

    if @record.save
      @success_count += 1
    else
      @failure_count += 1
    end
  end
end
