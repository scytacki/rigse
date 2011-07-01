require File.expand_path('../../../spec_helper', __FILE__)

describe Admin::ProjectsController do
  describe "routing" do
    it "recognizes and generates #index" do
      { :get => "admin/projects" }.should route_to(:controller => "admin/projects", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "admin/projects/new" }.should route_to(:controller => "admin/projects", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "admin/projects/1" }.should route_to(:controller => "admin/projects", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "admin/projects/1/edit" }.should route_to(:controller => "admin/projects", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "admin/projects" }.should route_to(:controller => "admin/projects", :action => "create") 
    end

    it "recognizes and generates #update" do
      { :put => "admin/projects/1" }.should route_to(:controller => "admin/projects", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      { :delete => "admin/projects/1" }.should route_to(:controller => "admin/projects", :action => "destroy", :id => "1") 
    end
  end
end
