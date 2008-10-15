xml.instruct!
xml.tag! 'Connector', "command" => params["Command"], "resourceType" => params["Type"] do
  xml.tag! 'CurrentFolder', "path" => params[:CurrentFolder], "url" => params[:CurrentFolder]
  xml.tag! 'Folders' do
    for section in @section.children do
      xml.tag! 'Folder', "name" => section.name
    end
  end
  xml.tag! 'Files' do
    for page in @section.pages do
      xml.tag! 'File', "name" => page.name, "url" => page.path, "size" => "?"
    end
  end
end