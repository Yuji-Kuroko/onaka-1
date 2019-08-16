class AddLocaleColumnToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :locale, :string, after: :score, default: 'ja', comment: 'user preferred locale'
  end
end
