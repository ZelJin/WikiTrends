class CreateArticles < ActiveRecord::Migration
  def change
    create_table(:articles) do |t|
      t.string :name, null: false, default: ''
      t.float :trend, null: false, default: -1
      t.timestamps
    end

    add_index :articles, :name, unique: true
  end
end
