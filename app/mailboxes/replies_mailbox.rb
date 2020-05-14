class RepliesMailbox < ApplicationMailbox
  # mail
  # inbound_email => ActionMailbox::InboundEmail record
  MATCHER = /reply-(.+)@reply.example.com/i

  # Callbacks
  # before_processing :ensure_user

  def process
    return unless user.present?
    discussion.comments.create(
      user: user,
      body: mail.decoded    # Taken from https://github.com/mikel/mail as ActionMailbox is built on top of it.
    )
  end

  def user
    @user ||= User.find_by(email: mail.from)
  end

  def discussion
    @discussion ||= Discussion.find(discussion_id)
  end

  def discussion_id
    recipient = mail.recipients.find { |r| MATCHER.match?(r) }
    recipient[MATCHER, 1]
  end

  # def ensure_user
  #   bounce_with UserMailer.missing(inbound_email) unless user.present?
  # end
end
