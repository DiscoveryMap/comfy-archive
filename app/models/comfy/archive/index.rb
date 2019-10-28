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

  # -- Instance Mathods --------------------------------------------------------
  def url(relative: false)
    page.url(relative: relative)
  end

  def children(published = false)
    if published
      page.children.published
    else
      page.children
    end
  end

  def categories(published = false)
    category_ids = Comfy::Cms::Categorization.where(categorized_type: "Comfy::Cms::Page", categorized_id: self.children(published)).pluck(:category_id).uniq!
    Comfy::Cms::Category.where(id: category_ids)
  end

end
