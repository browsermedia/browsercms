module TestLogging
  def log(msg)
    Rails.logger.info(msg)
  end
  
  def log_array(obj, *columns)
    lengths = columns.map{|m| m.to_s.length }

    obj.each do |r|
      columns.each_with_index do |m, i|
        v = r.send(m)
        if v.to_s.length > lengths[i]
          lengths[i] = v.to_s.length
        end
      end
    end

    str = "  "
    columns.each_with_index do |m, i|
      str << "%#{lengths[i]}s" % m
      str << "  "
    end
    str << "\n  "

    columns.each_with_index do |m, i|
      str << ("-"*lengths[i])
      str << "  "
    end
    str << "\n  "

    obj.each do |r|
      columns.each_with_index do |m, i|
        str << "%#{lengths[i]}s" % r.send(m)
        str << "  "
      end
      str << "\n  "      
    end

    log str    
  end  
  
  def log_table(cls, options={})
    if options[:include_columns]
      columns = options[:include_columns]
    elsif options[:exclude_columns]
      columns = cls.column_names - options[:exclude_columns].map(&:to_s)
    else
      columns = cls.column_names      
    end
    log_array (cls.uses_soft_delete? ? cls.find_with_deleted(:all) : cls.all), *columns
  end
  
  def log_table_with(cls, *columns)
    log_table(cls, :include_columns => columns)
  end
  
  def log_table_without(cls, *columns)
    log_table(cls, :exclude_columns => columns)
  end

  def log_table_without_stamps(cls, *columns)
    log_table(cls, :exclude_columns => %w[created_at updated_at created_by_id updated_by_id] + columns)
  end    
end