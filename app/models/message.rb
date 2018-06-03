class Message < ApplicationRecord
  def allow_removal!
    self.soft_delete = true
    save
  end
end
