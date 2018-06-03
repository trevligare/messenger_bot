class Message < ApplicationRecord

  def self.vacuum
    soft_deleted = Message.where(soft_delete: true)
    Rails.logger.info "Deleteing #{soft_deleted.length} soft_deleted messages" if soft_deleted.length
    soft_deleted.delete_all
    expired = Message.where("created_at < ?", 25.hours.ago)
    Rails.logger.info "Deleteing #{expired.length} expired messages" if expired.length
  end

  def allow_removal!
    self.soft_delete = true
    save
  end
end
