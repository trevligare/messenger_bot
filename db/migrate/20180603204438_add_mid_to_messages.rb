class AddMidToMessages < ActiveRecord::Migration[5.2]
  def change
    add_column :messages, :mid, :string
  end
end
