class CreateArchive < ActiveRecord::Migration[5.2]
  def change
    create_table :comfy_archive_indices do |t|
      t.integer :site_id,           null: false
      t.string  :label,             null: false
      t.string  :datetime_fragment, null: false
      t.integer :page_id,           null: false

      t.timestamps
    end
  end
end
