class AddSoftDeleteToMessage < ActiveRecord::Migration[5.2]
  def change
    add_column :messages, :soft_delete, :boolean, default: false
  end
end
