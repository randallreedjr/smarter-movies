if ActiveRecord::Base.connection.table_exists? 'roles'
  config.use_dynamic_shortcuts
end