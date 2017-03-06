class CreateHosts < ActiveRecord::Migration[5.0]
  def change
    create_table :hosts do |t|
      t.string :name
      t.string :address
      t.timestamps
    end

    add_index :hosts, :address, unique: true

    add_belongs_to :arp_records, :host
    add_belongs_to :nmap_records, :host
    rename_column :arp_records, :address, :ip_address
    rename_column :nmap_records, :address, :ip_address
  end
end
