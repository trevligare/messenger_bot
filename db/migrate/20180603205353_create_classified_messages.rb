class CreateClassifiedMessages < ActiveRecord::Migration[5.2]
  def change
    create_table :classified_messages do |t|
      t.string :classifier_id
      t.text :text
      t.string :classification

      t.timestamps
    end
  end
end
