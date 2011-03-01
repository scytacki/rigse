class ApplicationController < ActionController::Base
  include ExceptionNotifiable
  include Clipboard

  self.allow_forgery_protection = false


  def test
    render :text => mce_in_place_tag(Page.create,'description','none')
  end

  # helper :all # include all helpers, all the time
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  before_filter :setup_container
  before_filter :setup_project

  include AuthenticatedSystem
  include RoleRequirementSystem

  theme :get_theme

  helper :all # include all helpers, all the time
  filter_parameter_logging :password, :password_confirmation

  before_filter :check_user
  before_filter :original_user
  before_filter :portal_resources

  def self.set_theme(name)
    @@theme = name
  end

  def get_theme
    @@theme ||= (get_theme_from_settings)
  end

  def self.get_theme_from_settings
    project = Admin::Project.create_or_update_default_project_from_settings_yml
    settings = project.admin_project_settings
    theme = settings.theme
    theme.blank? ? 'default' : theme
  end

  protected

  def setup_container
    @container_type = self.class.name[/(.+)sController/,1]
    @container_id =  request.symbolized_path_parameters[:id]
  end

  def setup_project
    @project = Admin::Project.default_project
    if USING_JNLPS
      @jnlp_adaptor = JnlpAdaptor.new(@project)
      @jnlp_testing_adaptor = JnlpTestingAdaptor.new
    end
  end

  # Automatically respond with 404 for ActiveRecord::RecordNotFound
  def record_not_found
    render :file => File.join(RAILS_ROOT, 'public', '404.html'), :status => 404
  end


  def param_find(token_sym, force_nil=false)
    token = token_sym.to_s
     eval_string = <<-EOF
      if params[:#{token}]
        session[:#{token}] = cookies[:#{token}]= #{token} = params[:#{token}]
      elsif force_nil
         session[:#{token}] = cookies[:#{token}] = nil
      else
        #{token} = session[:#{token}] || cookies[:#{token}]
      end
    EOF
    eval eval_string
  end


  def get_scope(default)
    begin
      @scope = default
      if container_type = params[:scope_type]
        @scope = container_type.constantize.find(params[:scope_id])
      elsif container_type = params[:container_type]
        @scope = container_type.constantize.find(params[:container_id])
      end
      @scope
    rescue ActiveRecord::RecordNotFound
      nil
    end
  end

  private

  # setup the portal_teacher and student instance variables
  def portal_resources
    @portal_teacher = current_user.portal_teacher
    @portal_student = current_user.portal_student
  end

  # Accesses the user that this session originally logged in as.
  def original_user
    if session[:original_user_id]
      @original_user ||=  User.find(session[:original_user_id])
    else
      @original_user = current_user
    end
  end


  def check_user
    if logged_in?
      self.current_user = current_user
    else
      self.current_user = User.anonymous
    end
  end


  def redirect_back_or(path)
    redirect_to :back
  rescue ActionController::RedirectBackError
    redirect_to path
  end

end
