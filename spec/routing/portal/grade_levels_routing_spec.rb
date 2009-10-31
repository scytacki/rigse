require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Portal::GradeLevelsController do
  describe "route generation" do
    it "maps #index" do
      route_for(:controller => "portal_grade_levels", :action => "index").should == "/portal_grade_levels"
    end

    it "maps #new" do
      route_for(:controller => "portal_grade_levels", :action => "new").should == "/portal_grade_levels/new"
    end

    it "maps #show" do
      route_for(:controller => "portal_grade_levels", :action => "show", :id => "1").should == "/portal_grade_levels/1"
    end

    it "maps #edit" do
      route_for(:controller => "portal_grade_levels", :action => "edit", :id => "1").should == "/portal_grade_levels/1/edit"
    end

    it "maps #create" do
      route_for(:controller => "portal_grade_levels", :action => "create").should == {:path => "/portal_grade_levels", :method => :post}
    end

    it "maps #update" do
      route_for(:controller => "portal_grade_levels", :action => "update", :id => "1").should == {:path =>"/portal_grade_levels/1", :method => :put}
    end

    it "maps #destroy" do
      route_for(:controller => "portal_grade_levels", :action => "destroy", :id => "1").should == {:path =>"/portal_grade_levels/1", :method => :delete}
    end
  end

  describe "route recognition" do
    it "generates params for #index" do
      params_from(:get, "/portal_grade_levels").should == {:controller => "portal_grade_levels", :action => "index"}
    end

    it "generates params for #new" do
      params_from(:get, "/portal_grade_levels/new").should == {:controller => "portal_grade_levels", :action => "new"}
    end

    it "generates params for #create" do
      params_from(:post, "/portal_grade_levels").should == {:controller => "portal_grade_levels", :action => "create"}
    end

    it "generates params for #show" do
      params_from(:get, "/portal_grade_levels/1").should == {:controller => "portal_grade_levels", :action => "show", :id => "1"}
    end

    it "generates params for #edit" do
      params_from(:get, "/portal_grade_levels/1/edit").should == {:controller => "portal_grade_levels", :action => "edit", :id => "1"}
    end

    it "generates params for #update" do
      params_from(:put, "/portal_grade_levels/1").should == {:controller => "portal_grade_levels", :action => "update", :id => "1"}
    end

    it "generates params for #destroy" do
      params_from(:delete, "/portal_grade_levels/1").should == {:controller => "portal_grade_levels", :action => "destroy", :id => "1"}
    end
  end
end
