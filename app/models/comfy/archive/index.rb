class Comfy::Archive::Index < ApplicationRecord

  self.table_name = "comfy_archive_indices"

  # -- Relationships -----------------------------------------------------------
  belongs_to :site,
    class_name: "Comfy::Cms::Site"
  belongs_to :page,
    class_name: "Comfy::Cms::Page"

  # -- Validations -------------------------------------------------------------
  validates :label, :datetime_fragment,
    presence:   true
  validates :page,
    presence:   true,
    uniqueness: { scope: :page_id }

end
