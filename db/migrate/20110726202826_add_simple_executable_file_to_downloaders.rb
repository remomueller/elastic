class AddSimpleExecutableFileToDownloaders < ActiveRecord::Migration
  def change
    add_column :downloaders, :simple_executable_file, :string
  end
end
