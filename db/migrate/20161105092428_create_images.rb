class CreateImages < ActiveRecord::Migration[5.0]
  def change
    create_table :images do |t|
      t.attachment :img
      t.string :title
      t.string :caption
      t.integer :user_id

      t.timestamps
    end
  end
end
