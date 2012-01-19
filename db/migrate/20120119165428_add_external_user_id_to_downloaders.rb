class AddExternalUserIdToDownloaders < ActiveRecord::Migration
  def change
    add_column :downloaders, :external_user_id, :integer
  end
end
