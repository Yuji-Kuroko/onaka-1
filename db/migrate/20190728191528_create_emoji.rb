class CreateEmoji < ActiveRecord::Migration[5.2]
  def change
    create_table :emojis do |t|
      t.string :name, null: false
      t.references :onaka
      t.timestamps
    end

    add_index :emojis, :name, unique: true
  end
end
