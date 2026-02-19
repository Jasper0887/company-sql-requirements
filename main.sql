WITH ingredients AS (
					SELECT *
					FROM menu_ingredients_details
					WHERE menu_ingredients_details.status = 'ACTIVE'
				),

				full_menu_with_ingredients AS (
					SELECT
						menu_item_header.uoms_id,
						menu_item_header.ingredient_total_cost,
						menu_item_header.tasteless_menu_code AS menu_item_header_code,
						menu_item_header.menu_item_description,
						menu_item_header.menu_categories_id,
						menu_item_header.id AS menu_item_header_id,
						menu_item_lines.*
					FROM menu_items AS menu_item_header
					LEFT JOIN ingredients AS menu_item_lines
						ON menu_item_lines.menu_items_id = menu_item_header.id
				),

				m_s_1_base AS (
					SELECT
						menu_book.menu_item_header_code AS menu_code,
						menu_book.menu_item_description AS menu_description,
						menu_categories.category_description AS menu_category,

						CASE
							WHEN batching_ingredients.bi_code IS NOT NULL THEN 'BATCH'
							WHEN item_masters.tasteless_code IS NOT NULL THEN 'IMFS'
							WHEN production_items.reference_number IS NOT NULL THEN 'PIMFS'
							WHEN new_ingredients.nwi_code IS NOT NULL THEN 'NEW'
							WHEN menu_as_ing.tasteless_menu_code IS NOT NULL THEN 'MMFF'
							ELSE 'UNKNOWN'
						END AS menu_type,

						COALESCE(
							batching_ingredients.bi_code,
							item_masters.tasteless_code,
							production_items.reference_number,
							new_ingredients.nwi_code,
							menu_as_ing.tasteless_menu_code
						) AS menu_item_ingredients_code,

						COALESCE(
							batching_ingredients.ingredient_description,
							item_masters.full_item_description,
							production_items.full_item_description,
							new_ingredients.item_description,
							menu_as_ing.menu_item_description
						) AS menu_item_ingredients_description,

						CASE
							WHEN item_masters.packaging_size IS NOT NULL THEN item_masters.packaging_size
							WHEN menu_book.production_items_id IS NOT NULL THEN production_items.packaging_size
							WHEN batching_ingredients.quantity IS NOT NULL THEN batching_ingredients.quantity
							WHEN new_ingredients.packaging_size IS NOT NULL THEN new_ingredients.packaging_size
							WHEN menu_book.packaging_size IS NOT NULL THEN menu_book.packaging_size
							ELSE 1
						END AS packaging_size,

						ROUND(
							menu_book.prep_qty / ROUND((menu_book.yield / 100), 4),
							4
						) AS ingredient_qty,

						COALESCE(packagings.packaging_description, uoms.uom_description) AS uom_description,

						CASE
							WHEN item_masters.landed_cost IS NOT NULL THEN item_masters.landed_cost
							WHEN menu_book.production_items_id IS NOT NULL THEN production_items.landed_cost
							WHEN batching_ingredients.ttp IS NOT NULL THEN batching_ingredients.ttp
							WHEN new_ingredients.ttp IS NOT NULL THEN new_ingredients.ttp
							WHEN menu_book.ingredient_total_cost IS NOT NULL THEN menu_book.ingredient_total_cost
							ELSE 1
						END AS landed_cost,

						CASE
							WHEN im_as_ing__batch_1.tasteless_menu_code IS NOT NULL THEN 'MMFF'
							WHEN bs1_header.bi_code IS NOT NULL THEN 'BATCH'
							WHEN ims_batch_1.tasteless_code IS NOT NULL THEN 'IMFS'
							WHEN pi1.reference_number IS NOT NULL THEN 'PIMFS'
							WHEN pi_batch_1.reference_number IS NOT NULL THEN 'PIMFS'
							WHEN ni_batch_1.nwi_code IS NOT NULL THEN 'NEW'
							WHEN bas_ing_1.bi_code IS NOT NULL THEN 'BATCH'
							WHEN ims1.tasteless_code IS NOT NULL THEN 'IMFS'
							WHEN ni1.nwi_code IS NOT NULL THEN 'NEW'
							WHEN im_as_ing_1.tasteless_menu_code IS NOT NULL THEN 'MMFF'
							ELSE 'UNKNOWN'
						END AS sub_types_1,

						COALESCE(
							im_as_ing__batch_1.tasteless_menu_code,
							bs1_header.bi_code,
							ims_batch_1.tasteless_code,
							pi_batch_1.reference_number,
							ni_batch_1.nwi_code,
							bas_ing_1.bi_code,
							ims1.tasteless_code,
							pi1.reference_number,
							ni1.nwi_code,
							im_as_ing_1.tasteless_menu_code
						) AS menu_item_ingredients_code_sub_1,

						COALESCE(
							im_as_ing__batch_1.menu_item_description,
							bs1_header.ingredient_description,
							ims_batch_1.full_item_description,
							pi_batch_1.full_item_description,
							ni_batch_1.item_description,
							bas_ing_1.ingredient_description,
							ims1.full_item_description,
							pi1.full_item_description,
							ni1.item_description,
							im_as_ing_1.menu_item_description
						) AS menu_item_ingredients_description_sub_1,

						CASE
							WHEN im_as_ing__batch_1.menu_item_description IS NOT NULL
								AND sub_main_ing_batch_1.packaging_size IS NOT NULL
								AND sub_main_ing_batch_1.packaging_size > 0
								THEN sub_main_ing_batch_1.packaging_size

							WHEN bs1_header.ingredient_description IS NOT NULL
								AND bs1_header.quantity IS NOT NULL
								AND bs1_header.quantity > 0
								THEN bs1_header.quantity

							WHEN ims_batch_1.full_item_description IS NOT NULL
								AND ims_batch_1.packaging_size IS NOT NULL
								AND ims_batch_1.packaging_size > 0
								THEN ims_batch_1.packaging_size

							WHEN pi_batch_1.full_item_description IS NOT NULL
								AND pi_batch_1.packaging_size IS NOT NULL
								AND pi_batch_1.packaging_size > 0
								THEN pi_batch_1.packaging_size

							WHEN ni_batch_1.item_description IS NOT NULL
								AND ni_batch_1.packaging_size IS NOT NULL
								AND ni_batch_1.packaging_size > 0
								THEN ni_batch_1.packaging_size

							WHEN bas_ing_1.ingredient_description IS NOT NULL
								AND bas_ing_1.quantity IS NOT NULL
								AND bas_ing_1.quantity > 0
								THEN bas_ing_1.quantity

							WHEN ims1.full_item_description IS NOT NULL
								AND ims1.packaging_size IS NOT NULL
								AND ims1.packaging_size > 0
								THEN ims1.packaging_size

							WHEN pi1.full_item_description IS NOT NULL
								AND pi1.packaging_size IS NOT NULL
								AND pi1.packaging_size > 0
								THEN pi1.packaging_size

							WHEN ni1.item_description IS NOT NULL
								AND ni1.packaging_size IS NOT NULL
								AND ni1.packaging_size > 0
								THEN ni1.packaging_size

							WHEN sub_main_ingr_1.packaging_size IS NOT NULL
								AND sub_main_ingr_1.packaging_size > 0
								THEN sub_main_ingr_1.packaging_size

							WHEN COALESCE(
									im_as_ing__batch_1.menu_item_description,
									bs1_header.ingredient_description,
									ims_batch_1.full_item_description,
									pi_batch_1.full_item_description,
									ni_batch_1.item_description,
									bas_ing_1.ingredient_description,
									ims1.full_item_description,
									pi1.full_item_description,
									ni1.item_description,
									im_as_ing_1.menu_item_description
								) IS NOT NULL
								THEN 1
						END AS sub_packaging_size_1,

						ROUND(
							COALESCE(sub_main_ingr_1.prep_qty, bs1.prep_qty)
							/ ROUND((COALESCE(sub_main_ingr_1.yield, bs1.yield) / 100), 4),
							4
						) AS sub_ingredient_qty_1,

						COALESCE(pack_sub_1.packaging_description, uom_sub_1.uom_description) AS sub_uom_1,

						CASE
							WHEN im_as_ing__batch_1.menu_item_description IS NOT NULL
								AND ims_batch_1.landed_cost IS NOT NULL
								AND ims_batch_1.landed_cost > 1
								THEN ims_batch_1.landed_cost

							WHEN bs1_header.ingredient_description IS NOT NULL
								AND bs1_header.ttp IS NOT NULL
								AND bs1_header.ttp > 1
								THEN bs1_header.ttp

							WHEN ims_batch_1.full_item_description IS NOT NULL
								AND ims_batch_1.landed_cost IS NOT NULL
								AND ims_batch_1.landed_cost > 1
								THEN ims_batch_1.landed_cost

							WHEN pi1.full_item_description IS NOT NULL
								AND pi1.landed_cost IS NOT NULL
								AND pi1.landed_cost > 1
								THEN pi1.landed_cost

							WHEN ni_batch_1.item_description IS NOT NULL
								AND ni_batch_1.ttp IS NOT NULL
								AND ni_batch_1.ttp > 1
								THEN ni_batch_1.ttp

							WHEN im_as_ing_1.menu_item_description IS NOT NULL
								AND im_as_ing_1.ingredient_total_cost IS NOT NULL
								AND im_as_ing_1.ingredient_total_cost > 1
								THEN im_as_ing_1.ingredient_total_cost

							WHEN bas_ing_1.ingredient_description IS NOT NULL
								AND bas_ing_1.ttp IS NOT NULL
								AND bas_ing_1.ttp > 1
								THEN bas_ing_1.ttp

							WHEN ims1.full_item_description IS NOT NULL
								AND ims1.landed_cost IS NOT NULL
								AND ims1.landed_cost > 1
								THEN ims1.landed_cost

							WHEN ni1.item_description IS NOT NULL
								AND ni1.ttp IS NOT NULL
								AND ni1.ttp > 1
								THEN ni1.ttp

							ELSE NULL
						END AS landed_cost_sub_1

					FROM full_menu_with_ingredients menu_book
					LEFT JOIN menu_categories
						ON menu_book.menu_categories_id = menu_categories.id
					LEFT JOIN batching_ingredients
						ON batching_ingredients.id = menu_book.batching_ingredients_id
					LEFT JOIN item_masters
						ON item_masters.id = menu_book.item_masters_id
					LEFT JOIN production_items
						ON production_items.id = menu_book.production_items_id
					LEFT JOIN new_ingredients
						ON new_ingredients.id = menu_book.new_ingredients_id
					LEFT JOIN menu_items AS menu_as_ing
						ON menu_as_ing.id = menu_book.menu_as_ingredient_id

					LEFT JOIN ingredients AS sub_main_ingr_1
						ON menu_as_ing.id = sub_main_ingr_1.menu_items_id

					LEFT JOIN uoms
						ON uoms.id = COALESCE(
							item_masters.uoms_id,
							batching_ingredients.uoms_id,
							sub_main_ingr_1.uom_id,
							production_items.uoms_id,
							new_ingredients.uoms_id
						)

					LEFT JOIN packagings
						ON packagings.id = COALESCE(
							item_masters.packagings_id,
							batching_ingredients.uoms_id,
							sub_main_ingr_1.uom_id,
							production_items.packagings_id,
							new_ingredients.uoms_id
						)

					LEFT JOIN menu_items AS im_as_ing_1
						ON im_as_ing_1.id = sub_main_ingr_1.menu_as_ingredient_id
					LEFT JOIN batching_ingredients AS bas_ing_1
						ON bas_ing_1.id = sub_main_ingr_1.batching_ingredients_id
					LEFT JOIN item_masters AS ims1
						ON ims1.id = sub_main_ingr_1.item_masters_id
					LEFT JOIN production_items AS pi1
						ON pi1.id = sub_main_ingr_1.production_items_id
					LEFT JOIN new_ingredients AS ni1
						ON ni1.id = sub_main_ingr_1.new_ingredients_id

					LEFT JOIN batching_ingredients_details AS bs1
						ON bs1.batching_ingredients_id = menu_book.batching_ingredients_id
					LEFT JOIN batching_ingredients AS bs1_header
						ON bs1_header.id = bs1.batching_as_ingredient_id
					LEFT JOIN ingredients AS sub_main_ing_batch_1
						ON sub_main_ing_batch_1.id = bs1.menu_as_ingredient_id
					LEFT JOIN menu_items AS im_as_ing__batch_1
						ON im_as_ing__batch_1.id = bs1.menu_as_ingredient_id
					LEFT JOIN item_masters AS ims_batch_1
						ON ims_batch_1.id = bs1.item_masters_id
					LEFT JOIN production_items AS pi_batch_1
						ON pi_batch_1.id = bs1.production_items_id
					LEFT JOIN new_ingredients AS ni_batch_1
						ON ni_batch_1.id = bs1.new_ingredients_id

					LEFT JOIN uoms AS uom_sub_1
						ON uom_sub_1.id = COALESCE(
							im_as_ing__batch_1.uoms_id,
							bs1_header.uoms_id,
							ims_batch_1.uoms_id,
							pi_batch_1.uoms_id,
							ni_batch_1.uoms_id,
							bas_ing_1.uoms_id,
							ims1.uoms_id,
							pi1.uoms_id,
							ni1.uoms_id,
							im_as_ing_1.uoms_id
						)

					LEFT JOIN packagings AS pack_sub_1
						ON pack_sub_1.id = COALESCE(
							im_as_ing__batch_1.uoms_id,
							bs1_header.uoms_id,
							ims_batch_1.packagings_id,
							pi_batch_1.packagings_id,
							ni_batch_1.uoms_id,
							bas_ing_1.uoms_id,
							ims1.packagings_id,
							pi1.packagings_id,
							ni1.uoms_id,
							im_as_ing_1.uoms_id
						)

					WHERE menu_book.status IS NOT NULL
				),

				m_s_1 AS (
					SELECT
						b.menu_code,
                        b.menu_description,
                        b.menu_category,
                        b.menu_type,
                        b.menu_item_ingredients_code,
                        b.menu_item_ingredients_description,
                        b.packaging_size,
                        b.ingredient_qty,
                        b.uom_description,
                        b.landed_cost,
						ROUND((b.ingredient_qty / b.packaging_size), 4) AS sku_converted,
						ROUND(ROUND((b.ingredient_qty / b.packaging_size), 4) * b.landed_cost, 4) AS cost,
                        b.sub_types_1,
                        b.menu_item_ingredients_code_sub_1,
                        b.menu_item_ingredients_description_sub_1,
                        b.sub_packaging_size_1,
                        b.sub_ingredient_qty_1,
                        b.sub_uom_1,
                        b.landed_cost_sub_1,
						ROUND((b.sub_ingredient_qty_1 / b.sub_packaging_size_1), 4) AS sku_converted_sub_1,
						ROUND(ROUND((b.sub_ingredient_qty_1 / b.sub_packaging_size_1), 4) * b.landed_cost_sub_1, 4) AS sub_unit_ost_1
					FROM m_s_1_base b
				)
select * from m_s_1
where m_s_1.menu_code = '6006056'
-- pinaka latest
-- make a void for menu_as_ing trat as menu header 7000000389
-- make a join also for ing 
-- do this all in php also