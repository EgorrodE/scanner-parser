class CreateArpRecords < ActiveRecord::Migration[5.0]
  def change
    create_table :arp_records do |t|
      t.string :address
      t.string :hw_type
      t.string :hw_address
      t.string :flags
      t.string :mask
      t.string :iface
      t.datetime :timestamp
    end

    add_index :arp_records, [:timestamp, :address], unique: true
  end
end
