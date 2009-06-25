require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ExpectationsController do
  describe "route generation" do
    it "should map #index" do
      route_for(:controller => "expectations", :action => "index").should == "/expectations"
    end
  
    it "should map #new" do
      route_for(:controller => "expectations", :action => "new").should == "/expectations/new"
    end
  
    it "should map #show" do
      route_for(:controller => "expectations", :action => "show", :id => "1").should == "/expectations/1"
    end
  
    it "should map #edit" do
      route_for(:controller => "expectations", :action => "edit", :id => "1").should == "/expectations/1/edit"
    end
  
    it "should map #update" do
      route_for(:controller => "expectations", :action => "update", :id => "1").should == {:path => "/expectations/1", :method => :put}
    end
  
    it "should map #destroy" do
      route_for(:controller => "expectations", :action => "destroy", :id => "1").should == {:path => "/expectations/1", :method => :delete}
    end
  end

  describe "route recognition" do
    it "should generate params for #index" do
      params_from(:get, "/expectations").should == {:controller => "expectations", :action => "index"}
    end
  
    it "should generate params for #new" do
      params_from(:get, "/expectations/new").should == {:controller => "expectations", :action => "new"}
    end
  
    it "should generate params for #create" do
      params_from(:post, "/expectations").should == {:controller => "expectations", :action => "create"}
    end
  
    it "should generate params for #show" do
      params_from(:get, "/expectations/1").should == {:controller => "expectations", :action => "show", :id => "1"}
    end
  
    it "should generate params for #edit" do
      params_from(:get, "/expectations/1/edit").should == {:controller => "expectations", :action => "edit", :id => "1"}
    end
  
    it "should generate params for #update" do
      params_from(:put, "/expectations/1").should == {:controller => "expectations", :action => "update", :id => "1"}
    end
  
    it "should generate params for #destroy" do
      params_from(:delete, "/expectations/1").should == {:controller => "expectations", :action => "destroy", :id => "1"}
    end
  end
end
