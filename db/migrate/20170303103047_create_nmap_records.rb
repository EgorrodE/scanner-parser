class CreateNmapRecords < ActiveRecord::Migration[5.0]
  def change
    create_table :nmap_records do |t|
      t.string :address
      t.string :host_name
      t.string :status
      t.datetime :timestamp
    end

    add_index :nmap_records, [:timestamp, :address], unique: true
  end
end
