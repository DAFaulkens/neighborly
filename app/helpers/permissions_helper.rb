module PermissionsHelper
  def permissions_discover_attrs
    { 'data-hyperlink-permission' => policy(Project).discover?, 'data-name' => 'Wanted to discover issuances' }
  end

  def permissions_project_attrs(project = @project)
    { 'data-hyperlink-permission' => policy(project).show?, 'data-name' => 'Wanted to view issuance' }
  end

  def permissions_new_project_contribution_attrs(project = @project)
    { 'data-hyperlink-permission' => policy(project.contributions.new(user: current_user)).create?, 'data-name' => 'Wanted to invest' }
  end

  def permissions_project_statement_attrs(project = @project)
    { 'data-hyperlink-permission' => policy(project).statement?, 'data-name' => 'Wanted to view statement' }
  end

  def permissions_project_maturities_attrs(project = @project)
    { 'data-hyperlink-permission' => policy(project.rewards.new).index?, 'data-name' => 'Wanted to view maturities' }
  end
end
