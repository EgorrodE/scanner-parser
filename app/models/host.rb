class Host < ApplicationRecord
  validates_uniqueness_of :address, allow_blank: true

  has_many :arp_records
  has_many :nmap_records

  def update_and_return(params)
    if self.update(params)
      self
    else
      nil
    end
  end

  def presence_bounds(date_from, date_to)
    @bounds = []
    @arp = arp_records.where("timestamp > ? and timestamp < ?", date_from, date_to).sort_by(&:timestamp)
    @nmap = nmap_records.where("timestamp > ? and timestamp < ?", date_from, date_to).sort_by(&:timestamp)
    @start_bound = [@arp.first.try(:timestamp), @nmap.first.try(:timestamp)].min
    while @start_bound
      next_bounds_pair
      puts "START = #{@start_bound}"
    end
    @bounds
  end

  private
  def next_bounds_pair
    @end_bound = [
      @arp.select{ |arp| arp.try(:timestamp) > @start_bound && arp.try(:timestamp) < @start_bound + CHECK_INTERVAL + TIME_ERROR }.first.try(:timestamp),
      @nmap.select{ |nmap| nmap.try(:timestamp) > @start_bound && nmap.try(:timestamp) < @start_bound + CHECK_INTERVAL + TIME_ERROR }.first.try(:timestamp)
    ].compact.min
    puts "END = #{@end_bound}"
    unless @end_bound
      @end_bound = @start_bound
      next_start_bound
      return
    end
    find_end_bound
    next_start_bound
  end

  def find_end_bound
    while @end_bound do
      next_bound = [
        @arp.select{ |arp| arp.try(:timestamp) > @end_bound && arp.try(:timestamp) < @end_bound + CHECK_INTERVAL + TIME_ERROR }.first.try(:timestamp),
        @nmap.select{ |nmap| nmap.try(:timestamp) > @end_bound && nmap.try(:timestamp) < @end_bound + CHECK_INTERVAL + TIME_ERROR }.first.try(:timestamp)
      ].compact.min
      puts "NEXT = #{next_bound}"
      break unless next_bound
      @end_bound = next_bound
    end
  end

  def next_start_bound
    @bounds << {
      start: @start_bound,
      end: @end_bound
    }
    @start_bound = [
      @arp.select{ |arp| arp.try(:timestamp) > @end_bound }.first.try(:timestamp),
      @nmap.select{ |nmap| nmap.try(:timestamp) > @end_bound }.first.try(:timestamp)
    ].compact.min
  end
end
