class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :slack_id, index: true
      t.integer :stamina_capacity, null: false, default: 60
      t.integer :last_stamina, null: false, default: 60
      t.timestamp :stamina_updated_at, null: false, default: '2019-07-01 00:00:00'
      t.timestamps
    end

    create_table :user_onakas do |t|
      t.references :user, foreign_key: true
      t.references :onaka, foreign_key: true
      t.timestamps
    end
  end
end
