class MadbSmtpNotifier < ActionMailer::Base
  def after_create_instance(recipient, subscription, instance)
    recipients recipient
    from AppConfig.system_email_address
    entity = Entity.find(YAML.load(subscription.source_filter)[:entity_id])
    subject "New entry in table #{entity.name}"
    body :entity => entity, :instance => instance
  end
end
