WITH ingredients as (
 SELECT 
	main_menu.menu_items_id,
	item_masters.tasteless_code,
	production_items.reference_number,
	new_ingredients.nwi_code,
	menu_as_ing.tasteless_menu_code,
	batching_ingredients.bi_code,
	main_menu.ingredient_name,
	main_menu.row_id,
	main_menu.ingredient_group,
	main_menu.is_primary,
	main_menu.is_selected,
	main_menu.is_existing,
	main_menu.status,
	main_menu.packaging_size,
	main_menu.qty,
	main_menu.prep_qty,
	main_menu.uom_id,
	main_menu.uom_name,
	main_menu.menu_ingredients_preparations_id,
	main_menu.yield,
	main_menu.ttp,
	main_menu.cost,
	main_menu.total_cost,
	main_menu.created_by,
	main_menu.updated_by,
	main_menu.deleted_by,
	main_menu.created_at,
	main_menu.updated_at,
	main_menu.deleted_at 
FROM menu_ingredients_details as main_menu
  
LEFT JOIN batching_ingredients 
	ON  batching_ingredients.id = main_menu.batching_ingredients_id

LEFT JOIN item_masters 
	ON item_masters.id = main_menu.item_masters_id

LEFT JOIN production_items 
	ON production_items.id = main_menu.production_items_id
  
LEFT JOIN new_ingredients 
	ON new_ingredients.id = main_menu.new_ingredients_id

LEFT JOIN menu_items as menu_as_ing
	ON menu_as_ing.id = main_menu.menu_as_ingredient_id 
),

full_menu_with_ingredients as (select 
	menu_item_header.tasteless_menu_code as menu_item_header_code, -- Menu Code
	menu_item_header.id as menu_item_header_id,
	menu_item_lines.*
from menu_items as menu_item_header
left join ingredients as menu_item_lines
	on menu_item_lines.menu_items_id = menu_item_header.id
)

SELECT * FROM full_menu_with_ingredients menu_book  

where menu_book.status is not null and menu_book.menu_item_header_code = '6006056'
