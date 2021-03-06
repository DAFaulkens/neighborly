class ProjectObserver < ActiveRecord::Observer
  def after_save(project)
    build_project_total(project)

    if project.video_url.present? && project.video_url_changed?
      ProjectDownloaderWorker.perform_async(project.id)
    end
  end

  def after_create(project)
    deliver_default_notification_for(project, :project_received)
    notify_new_draft_project(project)
  end

  def from_online_to_waiting_funds(project)
    project.notify_owner(:project_in_wainting_funds)
  end

  def from_draft_to_rejected(project)
    deliver_default_notification_for(project, :project_rejected)
  end

  def from_draft_to_online(project)
    deliver_default_notification_for(project, :project_visible)
    project.update_attributes({ online_date: DateTime.now })
  end

  def from_draft_to_soon(project)
    project.notify_owner(:project_approved)
  end

  def from_soon_to_online(project)
    from_draft_to_online(project)
  end

  private

  def notify_new_draft_project(project)
    if (user = project.new_draft_recipient)
      Notification.notify_once(
        :new_draft_project,
        user,
        {project_id: project.id},
        {
          project: project,
          origin_email: project.user.email,
          origin_name: project.user.display_name
        }
      )
    end
  end

  def deliver_default_notification_for(project, notification_type)
    project.notify_owner(
      notification_type,
      { },
      {
        origin_email: Configuration[:email_contact],
        origin_name: Configuration[:company_name]
      }
    )
  end

  def build_project_total(project)
    ProjectTotalBuilder.new(project).perform
  end
end
