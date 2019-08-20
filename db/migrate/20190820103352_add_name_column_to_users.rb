class AddNameColumnToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :name, :string, after: :slack_id, comment: 'Slack display name'
  end
end
