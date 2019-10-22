class AddPageToComfyArchiveIndex < ActiveRecord::Migration[6.0]
  def change
    change_table :comfy_archive_indices do |t|
      t.integer :page_id, null: false
    end
  end
end
