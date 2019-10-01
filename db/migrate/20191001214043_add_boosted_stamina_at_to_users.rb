class AddBoostedStaminaAtToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :boosted_stamina_at, :datetime, after: :stamina_updated_at, comment: 'stamina boosted at'
  end
end
