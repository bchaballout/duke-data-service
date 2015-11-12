class Container < ActiveRecord::Base
  include SerializedAudit
  include Kinded

  audited
  belongs_to :project
	belongs_to :parent, class_name: "Folder"
  has_many :project_permissions, through: :project

  define_model_callbacks :set_parent_attribute
  validates :name, presence: true

  def ancestors
    if parent
      [parent.ancestors, parent].flatten
    else
      [project]
    end
  end

  def parent=(val)
    run_callbacks(:set_parent_attribute) do
      super(val)
    end
  end

  def parent_id=(val)
    run_callbacks(:set_parent_attribute) do
      super(val)
    end
  end

  def set_project_to_parent_project
    self.project = self.parent.project if self.parent
  end
end
