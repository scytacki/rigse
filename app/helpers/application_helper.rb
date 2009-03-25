module ApplicationHelper
  
  # Sets the page title and outputs title if container is passed in.
  # eg. <%= title('Hello World', :h2) %> will return the following:
  # <h2>Hello World</h2> as well as setting the page title.
  def title(str, container = nil)
    @page_title = str
    content_tag(container, str) if container
  end
  
  # Outputs the corresponding flash message if any are set
  def flash_messages
    messages = []
    %w(notice warning error).each do |msg|
      messages << content_tag(:div, html_escape(flash[msg.to_sym]), :id => "flash-#{msg}") unless flash[msg.to_sym].blank?
    end
    messages
  end
  
  # http://davidwparker.com/2008/11/12/simple-non-model-checkbox-in-rails/
  def check_box_tag_new(name, value = "1", options = {})
    html_options = { "type" => "checkbox", "name" => name, "id" => name, "value" => value }.update(options.stringify_keys)
    unless html_options["check"].nil?
      html_options["checked"] = "checked" if html_options["check"].to_i == 1
    end
    tag :input, html_options
  end
    
    def pdf_footer(message)
      pdf.footer [pdf.margin_box.left, pdf.margin_box.bottom + 25] do
        pdf.stroke_horizontal_rule
        pdf.pad(10) do
          pdf.text message, :size => 16
        end
      end      
  end
  
  def partial_for(component)
      # dynamically find the partial for the 
      class_name = component.class.name.underscore
      # return "#{class_name.pluralize}/sortable_#{class_name}"
      "#{class_name.pluralize}/#{class_name}"
  end
  
  def render_partial_for(component)
    class_name = component.class.name.underscore
    render :partial => "#{class_name.pluralize}/#{class_name}", :locals => { class_name.to_sym => component }
  end

  def dom_id_for(component, optional_prefix=nil)
    prefix_text = optional_prefix.nil? ? '' : "#{optional_prefix.to_s}_"
    class_name = component.class.name.underscore
    id_string = component.id.to_s
    "#{prefix_text}#{class_name}_#{id_string}"
  end
  
  def dom_class_for(component)
    component.class.name.underscore
  end
  
  
  
end
