class CreateViews < ActiveRecord::Migration
  def change
    create_table(:views) do |t|
      t.integer :article_id
      t.date :date, null: false, default: Date.today
      t.integer :clicks, null: false, default: 0
    end

    add_index :views, [:article_id, :date], unique: true
  end
end
