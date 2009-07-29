class Admin::ProjectsController < ApplicationController
  
  before_filter :admin_only
  # before_filter :setup_object, :except => [:index]
  before_filter :render_scope, :only => [:show]

  # editing / modifying / deleting require editable-ness
  # before_filter :can_edit, :except => [:index,:show,:print,:create,:new,:duplicate,:export] 
  # before_filter :can_create, :only => [:new, :create,:duplicate]
  # 
  # in_place_edit_for :activity, :name
  # in_place_edit_for :activity, :description
  
  protected  

  def admin_only
    current_user.has_role?('admin')
  end
  
  def can_create
    if (current_user.anonymous?)
      flash[:error] = "Anonymous users can not create activities"
      redirect_back_or activities_path
    end
  end
  
  def render_scope
    @render_scope = @admin_project
  end

  def can_edit
    if defined? @activity
      unless @activity.changeable?(current_user)
        error_message = "you (#{current_user.login}) can not #{action_name.humanize} #{@activity.name}"
        flash[:error] = error_message
        if request.xhr?
          render :text => "<div class='flash_error'>#{error_message}</div>"
        else
          redirect_back_or activities_path
        end
      end
    end
  end
  
  
  def setup_object
    if params[:id]
      if params[:id].length == 36
        @activity = Activity.find(:first, :conditions => ['uuid=?',params[:id]])
      else
        @activity = Activity.find(params[:id])
      end
    elsif params[:activity]
      @activity = Activity.new(params[:activity])
    else
      @activity = Activity.new
    end
    format = request.parameters[:format]
    unless format == 'otml' || format == 'jnlp'
      if @activity
        @page_title = @activity.name
        @investigation = @activity.investigation
      end
    end
  end
  
  public
  
  # GET /admin/projects
  # GET /admin/projects.xml
  def index
    @admin_projects = Admin::Project.search(params[:search], params[:page], nil)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @admin_projects }
    end
  end

  # GET /admin/projects/1
  # GET /admin/projects/1.xml
  def show
    @admin_project = Admin::Project.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @admin_project }
    end
  end

  # GET /admin/projects/new
  # GET /admin/projects/new.xml
  def new
    @admin_project = Admin::Project.new
    @scope = nil
    

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @admin_project }
    end
  end

  # GET /admin/projects/1/edit
  def edit
    @admin_project = Admin::Project.find(params[:id])
    if request.xhr?
      render :partial => 'remote_form', :locals => { :admin_project => @admin_project }
    end
  end

  # POST /admin/projects
  # POST /admin/projects.xml
  def create
    @admin_project = Admin::Project.new(params[:admin_project])

    respond_to do |format|
      if @admin_project.save
        flash[:notice] = 'Admin::Project was successfully created.'
        format.html { redirect_to(@admin_project) }
        format.xml  { render :xml => @admin_project, :status => :created, :location => @admin_project }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @admin_project.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /admin/projects/1
  # PUT /admin/projects/1.xml
  def update
    @admin_project = Admin::Project.find(params[:id])
    if request.xhr?
      @admin_project.update_attributes(params[:admin_project])
      render :partial => 'show', :locals => { :admin_project => @admin_project }
    else
      respond_to do |format|
        if @admin_project.update_attributes(params[:admin_project])
          flash[:notice] = 'Admin::Project was successfully updated.'
          format.html { redirect_to(@admin_project) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @admin_project.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /admin/projects/1
  # DELETE /admin/projects/1.xml
  def destroy
    @project = Admin::Project.find(params[:id])
    @project.destroy

    respond_to do |format|
      format.html { redirect_to(projects_url) }
      format.xml  { head :ok }
    end
  end
  
  def update_form
    if request.xhr?
      @admin_project = Admin::Project.new(params[:admin_project])
      @admin_project.id = params[:id]
      if @admin_project.snapshot_enabled
        @admin_project.jnlp_version_str = @admin_project.maven_jnlp_family.snapshot_version
      end
      render :partial => 'maven_jnlp_form', :locals => { :admin_project => @admin_project }
    else
      render :nothing => true
    end
  end
  
end
