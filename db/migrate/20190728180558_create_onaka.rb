class CreateOnaka < ActiveRecord::Migration[5.2]
  def change
    create_table :onakas do |t|
      t.string :name, null: false
      t.string :url
      t.string :custom_display_name
      t.text :description, null: false, default: ''
      t.integer :frequency, null: false, default: 0
      t.timestamps
    end

    add_index :onakas, :name, unique: true
  end
end
