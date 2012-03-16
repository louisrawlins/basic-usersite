require 'mysql2'
require 'dm-mysql-adapter'
require 'data_mapper'

DataMapper.setup(:default, eval('"' + BasicUserSite.settings.storage_url + '"'))
DataMapper.setup(:abstract, 'abstract::')
DataMapper.setup(:vm_legacy, eval('"' + BasicUserSite.settings.vm_legacy_url + '"'))

require_relative 'user'
require_relative 'pwd_change_request'
DataMapper.finalize
DataMapper.auto_upgrade! :default

