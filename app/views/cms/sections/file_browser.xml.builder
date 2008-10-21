xml.instruct!
xml.tag! 'Connector', "command" => params["Command"], "resourceType" => params["Type"] do
  xml.tag! 'CurrentFolder', "path" => params[:CurrentFolder], "url" => params[:CurrentFolder]
  xml.tag! 'Folders' do
    for section in @section.sections do
      xml.tag! 'Folder', "name" => section.name
    end
  end
  xml.tag! 'Files' do
    for file in @files do
      xml.tag! 'File', "name" => file.name, "url" => file.path, "size" => file.file_size
    end
  end
end