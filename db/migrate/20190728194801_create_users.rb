class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.integer :stamina_capacity, null: false, default: 60
      t.integer :last_stamina, null: false, default: 60
      t.timestamp :stamina_updated_at, null: false, default: '2019-07-01 00:00:00'
      t.timestamps
    end

    add_index :users, :name, unique: true

    create_table :user_emojis do |t|
      t.references :user, foreign_key: true
      t.references :emoji, foreign_key: true
      t.integer :count, null: false, default: 1
      t.timestamps
    end
  end
end
