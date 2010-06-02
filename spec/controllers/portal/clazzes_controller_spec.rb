require 'spec_helper'

describe Portal::ClazzesController do
  integrate_views
  
  def setup_for_repeated_tests
    @controller = Portal::ClazzesController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    
    # cleanup after previous tests
    Portal::Teacher.destroy_all
    Portal::Course.destroy_all
    Portal::Clazz.destroy_all
    Portal::School.destroy_all
    User.destroy_all
    
    generate_default_project_and_jnlps_with_mocks
    generate_portal_resources_with_mocks
    
    # set up our user types
    @normal_user = Factory.next(:anonymous_user)
    @admin_user = Factory.next(:admin_user)
    @authorized_teacher = Factory.create(:portal_teacher, :user => Factory.create(:user, :login => "authorized_teacher"))
    @unauthorized_teacher = Factory.create(:portal_teacher, :user => Factory.create(:user, :login => "unauthorized_teacher"))
    
    @authorized_teacher_user = @authorized_teacher.user
    @unauthorized_teacher_user = @unauthorized_teacher.user
    
    # another teacher, to act as an arbitrary third party
    @random_teacher = Factory.create(:portal_teacher, :user => Factory.create(:user, :login => "random_teacher"))
    
    @mock_course = Factory.create(:portal_course)
    @mock_clazz = mock_clazz({ :teachers => [@authorized_teacher], :course => @mock_course })
  end
  
  def login_as(user_sym)
    @logged_in_user = instance_variable_get("@#{user_sym.to_s}")
    
    @controller.stub!(:current_user).and_return(@logged_in_user)
    @logged_in_user
  end

  def mock_clazz(stubs={})
    mock_clazz = Factory.create(:portal_clazz, stubs) #mock_model(Portal::Clazz)
    #mock_clazz.stub!(stubs) unless stubs.empty?
    
    mock_clazz
  end
  
  before(:each) do
    setup_for_repeated_tests
    login_as :admin_user # Make admin our default test user
    
    Admin::Project.should_receive(:default_project).and_return(@mock_project)
  end

  describe "GET show" do
    it "assigns the requested class as @portal_clazz" do
      get :show, :id => @mock_clazz.id
      assigns[:portal_clazz].should == @mock_clazz
    end
    
    it "shows the full class summary, with edit button if current user is authorized" do
      [:admin_user, :authorized_teacher_user, :unauthorized_teacher_user].each do |user|
        setup_for_repeated_tests
        login_as user
        
        get :show, { :id => @mock_clazz.id }

        # All users should see the full class details summary
        with_tag("div#details_portal__clazz_#{@mock_clazz.id}") do
          with_tag('div.action_menu') do
            with_tag('div.action_menu_right') do
              if user == :unauthorized_teacher_user
                # Unauthorized users should not see an "edit" link in the class details section
                without_tag('a', :text => 'edit')
              else
                with_tag('a', :text => 'edit')
              end
            end
          end
        end
      end
    end
    
    it "shows the list of all teachers assigned to the requested class" do
      teachers = [@authorized_teacher, @random_teacher]
      @mock_clazz.teachers = teachers
    
      get :show, :id => @mock_clazz.id
      
      with_tag("div.block_list") do
        with_tag("ul") do
          teachers.each do |teacher|
            with_tag("li", :text => /#{teacher.name}/)
          end
        end
      end
    end
  end # end describe GET show
  
  describe "XMLHttpRequest edit" do
    it "shows the details of all teachers assigned to the requested class with removal links" do
      [:admin_user, :authorized_teacher_user, :unauthorized_teacher_user].each do |user|
        setup_for_repeated_tests
        login_as user
        
        teachers = [@authorized_teacher, @random_teacher]
        @mock_clazz.teachers = teachers
      
        xml_http_request :post, :edit, :id => @mock_clazz.id
        
        # All users should see the list of current teachers
        with_tag("div#teachers_listing") do
          teachers.each do |teacher|
            with_tag("tr#portal__teacher_#{teacher.id}") do |e|
              with_tag("img[src*='delete']")
            end
          end
        end
      end
    end
    
    describe "conditions for a user trying to remove a teacher from a class" do
      it "the user is allowed to remove any teacher in the list" do
        teachers = [@authorized_teacher, @random_teacher]
        @mock_clazz.teachers = teachers
        
        xml_http_request :post, :edit, :id => @mock_clazz.id
        
        with_tag("div#teachers_listing") do
          teachers.each do |teacher|
            with_tag("tr#portal__teacher_#{teacher.id}") do
              with_tag("a.rollover[onclick*=?]", remove_teacher_portal_clazz_path(@mock_clazz.id, :teacher_id => teacher.id)) do
                with_tag("img[src*='delete.png']")
              end
            end
          end
        end
      end
      
      it "the user is not allowed to edit this class in the first place" do
        login_as :unauthorized_teacher_user
        
        teachers = [@authorized_teacher, @random_teacher]
        @mock_clazz.teachers = teachers
        
        xml_http_request :post, :edit, :id => @mock_clazz.id
        
        # Perhaps the entire page shouldn't display, but at the very least, none of the teachers should have removal links
        with_tag("div#teachers_listing") do
          teachers.each do |teacher|
            with_tag("tr#portal__teacher_#{teacher.id}") do
              with_tag("img[src*='delete_grey.png'][title=?]", Portal::Clazz::ERROR_REMOVE_TEACHER_UNAUTHORIZED)
            end
          end
        end
      end
      
      it "this teacher is the last teacher assigned to this class" do
        # @mock_clazz should only have one teacher, but let's make sure
        teachers = [@authorized_teacher]
        @mock_clazz.teachers = teachers
        
        xml_http_request :post, :edit, :id => @mock_clazz.id
        
        # There should be only one teacher listed, and it should not be enabled
        with_tag("div#teachers_listing") do
          with_tag("tr#portal__teacher_#{teachers.first.id}") do
            with_tag("img[src*='delete_grey.png'][title=?]", Portal::Clazz::ERROR_REMOVE_TEACHER_LAST_TEACHER)
          end
        end
      end
      
      it "this teacher is the current user" do
        login_as :authorized_teacher_user
        
        teachers = [@authorized_teacher, @random_teacher]
        @mock_clazz.teachers = teachers
        
        xml_http_request :post, :edit, :id => @mock_clazz.id
        
        # Only the current user's teacher should be disabled; all others should be enabled
        with_tag("div#teachers_listing") do
          teachers.each do |teacher|
            with_tag("tr#portal__teacher_#{teacher.id}") do
              if teacher.user == @logged_in_user
                with_tag("img[src*='delete_grey.png'][title=?]", Portal::Clazz::ERROR_REMOVE_TEACHER_CURRENT_USER)
              else
                with_tag("a.rollover[onclick*=?]", remove_teacher_portal_clazz_path(@mock_clazz.id, :teacher_id => teacher.id)) do
                  with_tag("img[src*='delete.png']")
                end
              end
            end
          end
        end
      end
    end
    
    it "populates the list of available teachers for ADD functionality if current user is authorized" do
      [:admin_user, :authorized_teacher_user, :unauthorized_teacher_user].each do |user|
        setup_for_repeated_tests
        login_as user
        
        1.upto 10 do |i|
          teacher = Factory.create(:portal_teacher, :user => Factory.create(:user, :login => "teacher#{i}"))
          @mock_course.school.portal_teachers << teacher
        end
      
        xml_http_request :post, :edit, :id => @mock_clazz.id
        
        if user == :unauthorized_teacher_user
          # Unauthorized users should not see the "add teacher" dropdown
          without_tag("select#teacher_id_selector[name=teacher_id]")
        else
          with_tag("select#teacher_id_selector[name=teacher_id]") do
            without_tag("option[value=?]", @authorized_teacher.id) # cannot add teachers who are already assigned to this class
        
            @mock_course.school.portal_teachers.each do |t|
              with_tag("option[value=?]", t.id)
            end
          end
        end
      end
    end
  end 
  
  describe "POST add_teacher" do
    it "will add the selected teacher to the given class if the current user is authorized" do
      # @id
      # @teacher_id
      [:admin_user, :authorized_teacher_user, :unauthorized_teacher_user].each do |user|
        setup_for_repeated_tests
        login_as user
        
        post :add_teacher, { :id => @mock_clazz.id, :teacher_id => @unauthorized_teacher.id }
      
        @mock_clazz.reload
        
        if user == :unauthorized_teacher_user
          # Unauthorized users cannot add teachers, and will receive an error message
          assert !@mock_clazz.teachers.include?(@unauthorized_teacher)
          assert @response.body.include?(Portal::ClazzesController::ERROR_UNAUTHORIZED)
        else
          # Authorized users can add teachers
          assert @mock_clazz.teachers.include?(@unauthorized_teacher)
        end
      end
    end
  end
  
  describe "DELETE remove_teacher" do
    it "will remove the selected teacher from the given class if the current user is authorized" do
      # @id
      # @teacher_id
      [:admin_user, :authorized_teacher_user, :unauthorized_teacher_user].each do |user|
        setup_for_repeated_tests
        login_as user
        
        teachers = [@authorized_teacher, @random_teacher] # Any teachers except for @unauthorized_teacher will work here
        @mock_clazz.teachers = teachers
          
        delete :remove_teacher, { :id => @mock_clazz.id, :teacher_id => teachers.first.id }
  
        @mock_clazz.reload
        
        if user == :unauthorized_teacher_user
          # Unauthorized users cannot remove teachers, and will receive an error message
          assert @mock_clazz.teachers.include?(teachers.first)
          assert @response.body.include?(Portal::ClazzesController::ERROR_UNAUTHORIZED)
        else
          # Authorized users can remove teachers
          assert !@mock_clazz.teachers.include?(teachers.first)
        end
      end
    end
    
    it "will not let me remove the last teacher from the given class" do
      delete :remove_teacher, { :id => @mock_clazz.id, :teacher_id => @authorized_teacher.id }

      @mock_clazz.reload

      assert @mock_clazz.teachers.include?(@authorized_teacher)
      assert @response.body.include?(Portal::ClazzesController::CANNOT_REMOVE_LAST_TEACHER)
    end
  end
  
end