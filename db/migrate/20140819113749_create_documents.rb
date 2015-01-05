class CreateDocuments < ActiveRecord::Migration
  def change
    create_table :documents do |t|
      t.belongs_to :shop
      t.belongs_to :discount
      t.integer :document_type
      t.integer :status
      t.string :screenshot
      t.string :original
      t.string :title
      t.string :file_name
      t.integer :upload_file_size
      t.string :content
      t.timestamps
    end
  end
end
