class ArpRecord < ApplicationRecord
  ARP_FILE_EXTENSION   = '.txt'
  ADDRESS_RANGE        = 0..24
  HW_TYPE_RANGE        = 25..32
  HW_ADDRESS_RANGE     = 33..52
  FLAGS_RANGE          = 53..58
  MASK_RANGE           = 59..74
  IFACE_RANGE          = 75..80
  
  validates_uniqueness_of :timestamp, scope: [:ip_address]

  belongs_to :host

  def self.upload_data(path)
    @arp_path = File.join(path, 'arp')
    @success_count = 0
    @failure_count = 0
    return { error: 'Arp directory not found' } unless File.exists? @arp_path
    create_records
    return { result: "#{@success_count} recordes created, #{@failure_count} failed"}
  end

  private

  def self.create_records
    Dir.entries(@arp_path).select do |entry|
      File.directory?(File.join(@arp_path, entry)) && !(entry == '.' || entry == '..')
    end.each{ |entry| create_date_records(File.join(@arp_path, entry)) }
    
    Dir.entries(@arp_path).select do |entry|
      File.file?(File.join(@arp_path, entry))
    end.each{ |entry| create_timestamp_records(File.join(@arp_path, entry)) }
  end

  def self.create_date_records(date_folder)
    Dir.entries(date_folder).select do |entry|
      path = File.join(date_folder, entry)
      File.file?(path) && File.extname(path) == ARP_FILE_EXTENSION
    end.each{ |entry| create_timestamp_records(File.join(date_folder, entry)) }
  end

  def self.create_timestamp_records(path)
    timestamp = Pathname.new(path).basename.to_s
    File.readlines(path).drop(1).each { |line| create_record(line, timestamp) }
  end

  def self.create_record(line, timestamp)
    params = {
      ip_address: line[ADDRESS_RANGE].strip,
      hw_type:    line[HW_TYPE_RANGE].strip,
      hw_address: line[HW_ADDRESS_RANGE].strip,
      flags:      line[FLAGS_RANGE].strip,
      mask:       line[MASK_RANGE].strip,
      iface:      line[IFACE_RANGE].strip,
      timestamp:  DateTime.parse(timestamp)
    }

    @record = find_by(params.slice(:timestamp, :ip_address)) || new(params)

    @record.host = Host.find_by(address: params[:hw_address]) || 
      NmapRecord.where(timestamp: (params[:timestamp] - TIME_ERROR)..(params[:timestamp] + TIME_ERROR), ip_address: params[:ip_address]).first.try(:host).try{ |h| h.update_and_return(address: params[:hw_address]) } ||
      Host.create(address: params[:hw_address])

    if @record.save
      @success_count += 1
    else
      @failure_count += 1
    end
  end
end
