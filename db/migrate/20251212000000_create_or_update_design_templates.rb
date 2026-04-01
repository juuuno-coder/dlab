class CreateOrUpdateDesignTemplates < ActiveRecord::Migration[8.0]
  def change
    # 테이블이 없을 경우에만 생성
    unless table_exists?(:design_templates)
      create_table :design_templates do |t|
        t.string :title
        t.text :description
        t.string :category
        t.string :preview_url
        t.string :image_url       # 썸네일용 외부 이미지 URL
        t.boolean :is_featured, default: false # 메인 페이지 노출 여부
        t.timestamps
      end
    else
      # 테이블이 있다면 부족한 컬럼 추가
      add_column :design_templates, :image_url, :string unless column_exists?(:design_templates, :image_url)
      add_column :design_templates, :is_featured, :boolean, default: false unless column_exists?(:design_templates, :is_featured)
      add_column :design_templates, :preview_url, :string unless column_exists?(:design_templates, :preview_url)
    end
  end
end
