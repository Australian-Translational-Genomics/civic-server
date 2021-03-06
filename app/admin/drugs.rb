ActiveAdmin.register Drug do
  menu priority: 7
  permit_params :pubchem_id, :name

  filter :name
  filter :pubchem_id

  form do |f|
    f.semantic_errors(*f.object.errors.keys)
    f.inputs do
      f.input :name
      f.input :pubchem_id
    end
    f.actions
  end

  index do
    selectable_column
    column :name
    column :pubchem_id
    column :created_at
    column :updated_at
    actions
  end

  show do |f|
    attributes_table do
      row :name
      row :pubchem_id
      row :evidence_item_count do |d|
        d.evidence_items.count
      end
    end
  end
end
