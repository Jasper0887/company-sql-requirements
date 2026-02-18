WITH ingredients as (
 SELECT 
	*
FROM menu_ingredients_details 
WHERE  menu_ingredients_details.status = 'ACTIVE'
),

full_menu_with_ingredients as (select 
	-- menu_item_header.id as pogi,
    menu_item_header.uoms_id,
    menu_item_header.ingredient_total_cost,
	menu_item_header.tasteless_menu_code as menu_item_header_code, -- Menu Code
    menu_item_header.menu_item_description,
    menu_item_header.menu_categories_id,
	menu_item_header.id as menu_item_header_id,
	menu_item_lines.*
from menu_items as menu_item_header
left join ingredients as menu_item_lines
	on menu_item_lines.menu_items_id = menu_item_header.id
),

m_s_1 as (SELECT 

menu_book.menu_item_header_code as menu_code,
menu_book.menu_item_description as menu_description,
menu_categories.category_description as menu_category,
 
     CASE 
        WHEN batching_ingredients.bi_code IS NOT NULL THEN 'BATCH'
        WHEN item_masters.tasteless_code IS NOT NULL THEN 'IMFS'
        WHEN production_items.reference_number IS NOT NULL THEN 'PIMFS'
        WHEN new_ingredients.nwi_code IS NOT NULL THEN 'NEW'
        WHEN menu_as_ing.tasteless_menu_code IS NOT NULL THEN 'MMFF'
        ELSE 'UNKNOWN'
    END AS menu_type,
 
coalesce(
	batching_ingredients.bi_code,
	item_masters.tasteless_code,
	production_items.reference_number,
	new_ingredients.nwi_code,
	menu_as_ing.tasteless_menu_code
) as  menu_item_ingredients_code,

coalesce(
	batching_ingredients.ingredient_description,
	item_masters.full_item_description,
	production_items.full_item_description,
	new_ingredients.item_description,
	menu_as_ing.menu_item_description
) as  menu_item_ingredients_description,

(
    CASE WHEN(
        `item_masters`.`packaging_size` IS NOT NULL
    ) THEN `item_masters`.`packaging_size` WHEN(
        menu_book.`production_items_id` IS NOT NULL
    ) THEN `production_items`.`packaging_size` WHEN(
        batching_ingredients.`quantity` IS NOT NULL
    ) THEN batching_ingredients.`quantity` WHEN(
        `new_ingredients`.`packaging_size` IS NOT NULL
    ) THEN `new_ingredients`.`packaging_size` WHEN(
        menu_book.`packaging_size` IS NOT NULL
    ) THEN menu_book.`packaging_size` ELSE 1
END
) AS `packaging_size`,

ROUND(
    (
       menu_book.prep_qty / ROUND(
            (
                menu_book.yield / 100
            ),
            4
        )
    ),
    4
) AS `ingredient_qty`,
coalesce(packagings.packaging_description , `uoms`.`uom_description`) AS `uom_description`,
round((
    CASE WHEN(
        `item_masters`.`packaging_size` IS NOT NULL
    ) THEN `item_masters`.`packaging_size` WHEN(
        menu_book.`production_items_id` IS NOT NULL
    ) THEN `production_items`.`packaging_size` WHEN(
        batching_ingredients.`quantity` IS NOT NULL
    ) THEN batching_ingredients.`quantity` WHEN(
        `new_ingredients`.`packaging_size` IS NOT NULL
    ) THEN `new_ingredients`.`packaging_size` WHEN(
        menu_book.`packaging_size` IS NOT NULL
    ) THEN menu_book.`packaging_size` ELSE 1
END
) / ROUND(
    (
       menu_book.prep_qty / ROUND(
            (
                menu_book.yield / 100
            ),
            4
        )
    ),
    4
), 4) as sku_converted,


CASE WHEN(
    item_masters.landed_cost IS NOT NULL
) THEN item_masters.landed_cost WHEN(
    menu_book.production_items_id IS NOT NULL
) THEN production_items.landed_cost WHEN(
    batching_ingredients.ttp IS NOT NULL
) THEN batching_ingredients.ttp WHEN(
    new_ingredients.ttp IS NOT NULL
) THEN new_ingredients.ttp WHEN(
    menu_book.ingredient_total_cost IS NOT NULL
) THEN menu_book.ingredient_total_cost ELSE 1
END as landed_cost,


round(round((
    CASE WHEN(
        `item_masters`.`packaging_size` IS NOT NULL
    ) THEN `item_masters`.`packaging_size` WHEN(
        menu_book.`production_items_id` IS NOT NULL
    ) THEN `production_items`.`packaging_size` WHEN(
        batching_ingredients.`quantity` IS NOT NULL
    ) THEN batching_ingredients.`quantity` WHEN(
        `new_ingredients`.`packaging_size` IS NOT NULL
    ) THEN `new_ingredients`.`packaging_size` WHEN(
        menu_book.`packaging_size` IS NOT NULL
    ) THEN menu_book.`packaging_size` ELSE 1
END
) / ROUND(
    (
       menu_book.prep_qty / ROUND(
            (
                menu_book.yield / 100
            ),
            4
        )
    ),
    4
), 4) *
CASE WHEN(
    item_masters.landed_cost IS NOT NULL
) THEN item_masters.landed_cost WHEN(
    menu_book.production_items_id IS NOT NULL
) THEN production_items.landed_cost WHEN(
    batching_ingredients.ttp IS NOT NULL
) THEN batching_ingredients.ttp WHEN(
    new_ingredients.ttp IS NOT NULL
) THEN new_ingredients.ttp WHEN(
    menu_book.ingredient_total_cost IS NOT NULL
) THEN menu_book.ingredient_total_cost ELSE 1
END, 4)
as cost,
CASE
            WHEN im_as_ing__batch_1.tasteless_menu_code IS NOT NULL
                THEN 'MMFF'

            WHEN bs1_header.bi_code IS NOT NULL
                THEN 'BATCH'

            WHEN ims_batch_1.tasteless_code IS NOT NULL
                THEN 'IMFS'

            WHEN pi1.reference_number IS NOT NULL
                THEN 'PIMFS'

          WHEN pi_batch_1.reference_number IS NOT NULL
                THEN 'PIMFS'

            WHEN ni_batch_1.nwi_code IS NOT NULL
                THEN 'NEW'

            WHEN bas_ing_1.bi_code IS NOT NULL
                THEN 'BATCH'

            WHEN ims1.tasteless_code IS NOT NULL
                THEN 'IMFS'

            WHEN ni1.nwi_code IS NOT NULL
                THEN 'NEW'

            WHEN im_as_ing_1.tasteless_menu_code IS NOT NULL
                THEN 'MMFF'

            ELSE 'UNKNOWN'
        END AS sub_types_1,

COALESCE(
	COALESCE(
		im_as_ing__batch_1.tasteless_menu_code,
        bs1_header.bi_code,
        ims_batch_1.tasteless_code,
        pi_batch_1.reference_number,
        ni_batch_1.nwi_code,
        im_as_ing__batch_1.tasteless_menu_code
    ),
    bas_ing_1.bi_code,
    ims1.tasteless_code,
    --  pis_ing_1.item_code,
    pi1.reference_number,
    ni1.nwi_code,
    im_as_ing_1.tasteless_menu_code
) AS menu_item_ingredients_code_sub_1,

COALESCE(
	COALESCE(
		im_as_ing__batch_1.menu_item_description,
        bs1_header.ingredient_description,
        ims_batch_1.full_item_description,
        pi_batch_1.full_item_description,
        ni_batch_1.item_description,
        im_as_ing__batch_1.menu_item_description
    ),
    bas_ing_1.ingredient_description,
    ims1.full_item_description,
    -- pis_ing_1item_code,
    pi1.full_item_description,
    ni1.item_description,
    im_as_ing_1.menu_item_description
) AS menu_item_ingredients_description_sub_1,

 CASE
                    /* 1) menu-as-ingredient coming from batch line (menu item) */
                    WHEN im_as_ing__batch_1.menu_item_description IS NOT NULL
                         AND sub_main_ing_batch_1.packaging_size IS NOT NULL
                         AND sub_main_ing_batch_1.packaging_size > 0
                    THEN sub_main_ing_batch_1.packaging_size

                    /* 2) batch ingredient line description */
                    WHEN bs1_header.ingredient_description IS NOT NULL
                         AND bs1_header.quantity IS NOT NULL
                         AND bs1_header.quantity > 0
                    THEN bs1_header.quantity

                    /* 1) item master in batch line */
                    WHEN ims_batch_1.full_item_description IS NOT NULL
                         AND ims_batch_1.packaging_size IS NOT NULL
                         AND ims_batch_1.packaging_size > 0
                    THEN ims_batch_1.packaging_size

                    /* 4) production item in batch line */
                    WHEN pi_batch_1.full_item_description IS NOT NULL
                         AND pi_batch_1.packaging_size IS NOT NULL
                         AND pi_batch_1.packaging_size > 0
                    THEN pi_batch_1.packaging_size

                    /* 5) new ingredient in batch line */
                    WHEN ni_batch_1.item_description IS NOT NULL
                         AND ni_batch_1.packaging_size IS NOT NULL
                         AND ni_batch_1.packaging_size > 0
                    THEN ni_batch_1.packaging_size

                    /* 6) menu-as-ingredient path (MMFF) – batching ingredient */
                    WHEN bas_ing_1.ingredient_description IS NOT NULL
                         AND bas_ing_1.quantity IS NOT NULL
                         AND bas_ing_1.quantity > 0
                    THEN bas_ing_1.quantity

                    /* 7) menu-as-ingredient path (MMFF) – item master */
                    WHEN ims1.full_item_description IS NOT NULL
                         AND ims1.packaging_size IS NOT NULL
                         AND ims1.packaging_size > 0
                    THEN ims1.packaging_size

                    /* 8) menu-as-ingredient path (MMFF) – production item */
                    WHEN pi1.full_item_description IS NOT NULL
                         AND pi1.packaging_size IS NOT NULL
                         AND pi1.packaging_size > 0
                    THEN pi1.packaging_size

                    /* 9) menu-as-ingredient path (MMFF) – new ingredient */
                    WHEN ni1.item_description IS NOT NULL
                         AND ni1.packaging_size IS NOT NULL
                         AND ni1.packaging_size > 0
                    THEN ni1.packaging_size

                    /* 10) fallback: ingredient line packaging size */
                    WHEN sub_main_ingr_1.packaging_size IS NOT NULL
                         AND sub_main_ingr_1.packaging_size > 0
                    THEN sub_main_ingr_1.packaging_size

                    /* 11) final fallback: only if *any* description exists */
                    WHEN COALESCE(
                            COALESCE(
                                im_as_ing__batch_1.menu_item_description,
                                bs1_header.ingredient_description,
                                ims_batch_1.full_item_description,
                                pi_batch_1.full_item_description,
                                ni_batch_1.item_description,
                                im_as_ing__batch_1.menu_item_description
                            ),
                            bas_ing_1.ingredient_description,
                            ims1.full_item_description,
                            pi1.full_item_description,
                            ni1.item_description,
                            im_as_ing_1.menu_item_description
                         ) IS NOT NULL
                    THEN 1
                END AS sub_packaging_size_1,


                 ROUND(
                         (
                             COALESCE(sub_main_ingr_1.prep_qty,
                                      bs1.prep_qty) / ROUND(
                                     (
                                         COALESCE(sub_main_ingr_1.yield,
                                                  bs1.yield) / 100
                                         ),
                                     4
                                                      )
                             ),
                         4
                 )                                                                       AS sub_ingredient_qty_1,

                 coalesce(pack_sub_1.packaging_description, uom_sub_1.`uom_description`) as sub_uom_1,


                 round(ROUND(
                               (
                                   COALESCE(sub_main_ingr_1.prep_qty,
                                            bs1.prep_qty) / ROUND(
                                           (
                                               COALESCE(sub_main_ingr_1.yield,
                                                        bs1.yield) / 100
                                               ),
                                           4
                                                            )
                                   ),
                               4
                       ) / (CASE
                            /* 1) menu-as-ingredient coming from batch line (menu item) */
                            WHEN im_as_ing__batch_1.menu_item_description IS NOT NULL
                                 AND sub_main_ing_batch_1.packaging_size IS NOT NULL
                                 AND sub_main_ing_batch_1.packaging_size > 0
                            THEN sub_main_ing_batch_1.packaging_size

                            /* 2) batch ingredient line description */
                            WHEN bs1_header.ingredient_description IS NOT NULL
                                 AND bs1_header.quantity IS NOT NULL
                                 AND bs1_header.quantity > 0
                            THEN bs1_header.quantity

                            /* 1) item master in batch line */
                            WHEN ims_batch_1.full_item_description IS NOT NULL
                                 AND ims_batch_1.packaging_size IS NOT NULL
                                 AND ims_batch_1.packaging_size > 0
                            THEN ims_batch_1.packaging_size

                            /* 4) production item in batch line */
                            WHEN pi_batch_1.full_item_description IS NOT NULL
                                 AND pi_batch_1.packaging_size IS NOT NULL
                                 AND pi_batch_1.packaging_size > 0
                            THEN pi_batch_1.packaging_size

                            /* 5) new ingredient in batch line */
                            WHEN ni_batch_1.item_description IS NOT NULL
                                 AND ni_batch_1.packaging_size IS NOT NULL
                                 AND ni_batch_1.packaging_size > 0
                            THEN ni_batch_1.packaging_size

                            /* 6) menu-as-ingredient path (MMFF) – batching ingredient */
                            WHEN bas_ing_1.ingredient_description IS NOT NULL
                                 AND bas_ing_1.quantity IS NOT NULL
                                 AND bas_ing_1.quantity > 0
                            THEN bas_ing_1.quantity

                            /* 7) menu-as-ingredient path (MMFF) – item master */
                            WHEN ims1.full_item_description IS NOT NULL
                                 AND ims1.packaging_size IS NOT NULL
                                 AND ims1.packaging_size > 0
                            THEN ims1.packaging_size

                            /* 8) menu-as-ingredient path (MMFF) – production item */
                            WHEN pi1.full_item_description IS NOT NULL
                                 AND pi1.packaging_size IS NOT NULL
                                 AND pi1.packaging_size > 0
                            THEN pi1.packaging_size

                            /* 9) menu-as-ingredient path (MMFF) – new ingredient */
                            WHEN ni1.item_description IS NOT NULL
                                 AND ni1.packaging_size IS NOT NULL
                                 AND ni1.packaging_size > 0
                            THEN ni1.packaging_size

                            /* 10) fallback: ingredient line packaging size */
                            WHEN sub_main_ingr_1.packaging_size IS NOT NULL
                                 AND sub_main_ingr_1.packaging_size > 0
                            THEN sub_main_ingr_1.packaging_size

                            /* 11) final fallback: only if *any* description exists */
                            WHEN COALESCE(
                                    COALESCE(
                                        im_as_ing__batch_1.menu_item_description,
                                        bs1_header.ingredient_description,
                                        ims_batch_1.full_item_description,
                                        pi_batch_1.full_item_description,
                                        ni_batch_1.item_description,
                                        im_as_ing__batch_1.menu_item_description
                                    ),
                                    bas_ing_1.ingredient_description,
                                    ims1.full_item_description,
                                    pi1.full_item_description,
                                    ni1.item_description,
                                    im_as_ing_1.menu_item_description
                                 ) IS NOT NULL
                            THEN 1
                        END
                           ), 4)                                                         as sku_converted_sub_1,


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
                END AS landed_cost_sub_1,


                 round(ROUND(
                               (
                                   COALESCE(sub_main_ingr_1.prep_qty,
                                            bs1.prep_qty) / ROUND(
                                           (
                                               COALESCE(sub_main_ingr_1.yield,
                                                        bs1.yield) / 100
                                               ),
                                           4
                                                            )
                                   ),
                               4
                       ) / (CASE
                                /* 1) menu-as-ingredient coming from batch line (menu item) */
                                WHEN im_as_ing__batch_1.menu_item_description IS NOT NULL
                                     AND sub_main_ing_batch_1.packaging_size IS NOT NULL
                                     AND sub_main_ing_batch_1.packaging_size > 0
                                THEN sub_main_ing_batch_1.packaging_size

                                /* 2) batch ingredient line description */
                                WHEN bs1_header.ingredient_description IS NOT NULL
                                     AND bs1_header.quantity IS NOT NULL
                                     AND bs1_header.quantity > 0
                                THEN bs1_header.quantity

                                /* 1) item master in batch line */
                                WHEN ims_batch_1.full_item_description IS NOT NULL
                                     AND ims_batch_1.packaging_size IS NOT NULL
                                     AND ims_batch_1.packaging_size > 0
                                THEN ims_batch_1.packaging_size

                                /* 4) production item in batch line */
                                WHEN pi_batch_1.full_item_description IS NOT NULL
                                     AND pi_batch_1.packaging_size IS NOT NULL
                                     AND pi_batch_1.packaging_size > 0
                                THEN pi_batch_1.packaging_size

                                /* 5) new ingredient in batch line */
                                WHEN ni_batch_1.item_description IS NOT NULL
                                     AND ni_batch_1.packaging_size IS NOT NULL
                                     AND ni_batch_1.packaging_size > 0
                                THEN ni_batch_1.packaging_size

                                /* 6) menu-as-ingredient path (MMFF) – batching ingredient */
                                WHEN bas_ing_1.ingredient_description IS NOT NULL
                                     AND bas_ing_1.quantity IS NOT NULL
                                     AND bas_ing_1.quantity > 0
                                THEN bas_ing_1.quantity

                                /* 7) menu-as-ingredient path (MMFF) – item master */
                                WHEN ims1.full_item_description IS NOT NULL
                                     AND ims1.packaging_size IS NOT NULL
                                     AND ims1.packaging_size > 0
                                THEN ims1.packaging_size

                                /* 8) menu-as-ingredient path (MMFF) – production item */
                                WHEN pi1.full_item_description IS NOT NULL
                                     AND pi1.packaging_size IS NOT NULL
                                     AND pi1.packaging_size > 0
                                THEN pi1.packaging_size

                                /* 9) menu-as-ingredient path (MMFF) – new ingredient */
                                WHEN ni1.item_description IS NOT NULL
                                     AND ni1.packaging_size IS NOT NULL
                                     AND ni1.packaging_size > 0
                                THEN ni1.packaging_size

                                /* 10) fallback: ingredient line packaging size */
                                WHEN sub_main_ingr_1.packaging_size IS NOT NULL
                                     AND sub_main_ingr_1.packaging_size > 0
                                THEN sub_main_ingr_1.packaging_size

                                /* 11) final fallback: only if *any* description exists */
                                WHEN COALESCE(
                                        COALESCE(
                                            im_as_ing__batch_1.menu_item_description,
                                            bs1_header.ingredient_description,
                                            ims_batch_1.full_item_description,
                                            pi_batch_1.full_item_description,
                                            ni_batch_1.item_description,
                                            im_as_ing__batch_1.menu_item_description
                                        ),
                                        bas_ing_1.ingredient_description,
                                        ims1.full_item_description,
                                        pi1.full_item_description,
                                        ni1.item_description,
                                        im_as_ing_1.menu_item_description
                                     ) IS NOT NULL
                                THEN 1
                            END
                               ), 4) * CASE
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
                END     as sub_unit_ost_1

FROM full_menu_with_ingredients menu_book

left JOIN menu_categories
	on menu_book.menu_categories_id = menu_categories.id

 LEFT JOIN batching_ingredients
	ON  batching_ingredients.id = menu_book.batching_ingredients_id

LEFT JOIN item_masters
	ON item_masters.id = menu_book.item_masters_id

LEFT JOIN production_items
	ON production_items.id = menu_book.production_items_id

LEFT JOIN new_ingredients
	ON new_ingredients.id = menu_book.new_ingredients_id

LEFT JOIN menu_items as menu_as_ing
	ON menu_as_ing.id = menu_book.menu_as_ingredient_id




-- sub_ing

-- production items
-- LEFT JOIN production_item_lines pis_ing_1
	-- ON pis_ing_1.production_item_id = production_items.reference_number AND production_item_line_type = 'ingredient'

-- menu as ing sub ing
LEFT JOIN ingredients as sub_main_ingr_1
	ON menu_as_ing.id = sub_main_ingr_1.menu_items_id

LEFT JOIN uoms ON
            uoms.id = COALESCE(
                        `item_masters`.`uoms_id`,
                        batching_ingredients.`uoms_id`,
                        sub_main_ingr_1.`uom_id`,
                        `production_items`.`uoms_id`,
                        new_ingredients.uoms_id
                    )
LEFT JOIN packagings ON
            packagings.id = COALESCE(
                        `item_masters`.`packagings_id`,
                        batching_ingredients.`uoms_id`,
                        sub_main_ingr_1.`uom_id`,
                        `production_items`.`packagings_id`,
                        new_ingredients.uoms_id
                    )

LEFT JOIN menu_items as im_as_ing_1
	ON im_as_ing_1.id = sub_main_ingr_1.menu_as_ingredient_id

 LEFT JOIN batching_ingredients as bas_ing_1
	ON  bas_ing_1.id = sub_main_ingr_1.batching_ingredients_id

LEFT JOIN item_masters as ims1
	ON ims1.id = sub_main_ingr_1.item_masters_id

LEFT JOIN production_items as pi1
	ON pi1.id = sub_main_ingr_1.production_items_id

LEFT JOIN new_ingredients as ni1
	ON ni1.id = sub_main_ingr_1.new_ingredients_id

-- batching
LEFT JOIN batching_ingredients_details as bs1
	ON  bs1.batching_ingredients_id = menu_book.batching_ingredients_id

 LEFT JOIN batching_ingredients as bs1_header
	ON  bs1_header.id = bs1.batching_as_ingredient_id

LEFT JOIN ingredients as sub_main_ing_batch_1
	ON sub_main_ing_batch_1.id = bs1.menu_as_ingredient_id

LEFT JOIN menu_items as im_as_ing__batch_1
	ON im_as_ing__batch_1.id = bs1.menu_as_ingredient_id

LEFT JOIN item_masters as ims_batch_1
	ON ims_batch_1.id = bs1.item_masters_id

LEFT JOIN production_items as pi_batch_1
	ON pi_batch_1.id = bs1.production_items_id

LEFT JOIN new_ingredients as ni_batch_1
	ON ni_batch_1.id = bs1.new_ingredients_id

LEFT JOIN uoms as uom_sub_1 ON
            uom_sub_1.id =     COALESCE(
                            COALESCE(
                                im_as_ing__batch_1.uoms_id,
                                bs1_header.uoms_id,
                                ims_batch_1.uoms_id,
                                pi_batch_1.uoms_id,
                                ni_batch_1.uoms_id,
                                im_as_ing__batch_1.uoms_id
                            ), -- batch
                            bas_ing_1.uoms_id,
                            ims1.uoms_id,
                            -- pis_ing_1item_code,
                            pi1.uoms_id,
                            ni1.uoms_id,
                            im_as_ing_1.uoms_id
                        )


LEFT JOIN packagings as pack_sub_1 ON
            pack_sub_1.id =   COALESCE(
                            COALESCE(
                                im_as_ing__batch_1.uoms_id,
                                bs1_header.uoms_id,
                                ims_batch_1.packagings_id,
                                pi_batch_1.packagings_id,
                                ni_batch_1.uoms_id,
                                im_as_ing__batch_1.uoms_id
                            ), -- batch
                            bas_ing_1.uoms_id,
                            ims1.packagings_id,
                            -- pis_ing_1item_code,
                            pi1.packagings_id,
                            ni1.uoms_id,
                            im_as_ing_1.uoms_id
                        )


where menu_book.status is not null),

m_s_2 as (select
        m_s_1.*,

          CASE
            WHEN im_as_ing__batch_2.tasteless_menu_code IS NOT NULL
                THEN 'MMFF'

            WHEN bs2_line.bi_code IS NOT NULL
                THEN 'BATCH'

            WHEN ims_batch_2.tasteless_code IS NOT NULL
                THEN 'IMFS'

            WHEN pi2.reference_number IS NOT NULL
                THEN 'PIMFS'

          WHEN pi_batch_2.reference_number IS NOT NULL
                THEN 'PIMFS'

            WHEN ni_batch_2.nwi_code IS NOT NULL
                THEN 'NEW'

            WHEN im_as_ing_2_line.tasteless_menu_code IS NOT NULL
                THEN 'MMFF'

            WHEN bas_ing_2.bi_code IS NOT NULL
                THEN 'BATCH'

            WHEN ims2.tasteless_code IS NOT NULL
                THEN 'IMFS'

            WHEN ni2.nwi_code IS NOT NULL
                THEN 'NEW'

            WHEN im_as_ing_2.tasteless_menu_code IS NOT NULL
                THEN 'MMFF'

            ELSE 'UNKNOWN'
        END AS sub_types_2,

    COALESCE(
    	COALESCE(
    		im_as_ing__batch_2.tasteless_menu_code,
            bs2_line.bi_code,
            ims_batch_2.tasteless_code,
            pi2.reference_number,
            ni_batch_2.nwi_code,
            im_as_ing_2_line.tasteless_menu_code
        ),
        bas_ing_2.bi_code,
        ims2.tasteless_code,
        pi_batch_2.reference_number,
      --  pis_ing_2.item_code,
        ni2.nwi_code
    ) AS menu_item_ingredients_code_sub_2,

    COALESCE(
    	COALESCE(
    		im_as_ing__batch_2.menu_item_description,
            bs2_line.ingredient_description,
            ims_batch_2.full_item_description,
            pi2.full_item_description,
            ni_batch_2.item_description,
            im_as_ing_2_line.menu_item_description
        ),
        bas_ing_2.ingredient_description,
        ims2.full_item_description,
        pi_batch_2.full_item_description,
       -- pis_ing_2.description,
        ni2.item_description
    ) AS menu_item_ingredients_description_sub_2,

     CASE
                    /* 1) menu-as-ingredient coming from batch line (menu item) */
                    WHEN im_as_ing__batch_2.menu_item_description IS NOT NULL
                         AND sub_main_ing_batch_2.packaging_size IS NOT NULL
                         AND sub_main_ing_batch_2.packaging_size > 0
                    THEN sub_main_ing_batch_2.packaging_size

                    /* 2) batch ingredient line description */
                    WHEN bs2_header.ingredient_description IS NOT NULL
                         AND bs2_header.quantity IS NOT NULL
                         AND bs2_header.quantity > 0
                    THEN bs2_header.quantity

                    /* 2) item master in batch line */
                    WHEN ims_batch_2.full_item_description IS NOT NULL
                         AND ims_batch_2.packaging_size IS NOT NULL
                         AND ims_batch_2.packaging_size > 0
                    THEN ims_batch_2.packaging_size

                    /* 4) production item in batch line */
                    WHEN pi_batch_2.full_item_description IS NOT NULL
                         AND pi_batch_2.packaging_size IS NOT NULL
                         AND pi_batch_2.packaging_size > 0
                    THEN pi_batch_2.packaging_size

                    /* 5) new ingredient in batch line */
                    WHEN ni_batch_2.item_description IS NOT NULL
                         AND ni_batch_2.packaging_size IS NOT NULL
                         AND ni_batch_2.packaging_size > 0
                    THEN ni_batch_2.packaging_size

                    /* 6) menu-as-ingredient path (MMFF) – batching ingredient */
                    WHEN bas_ing_2.ingredient_description IS NOT NULL
                         AND bas_ing_2.quantity IS NOT NULL
                         AND bas_ing_2.quantity > 0
                    THEN bas_ing_2.quantity

                    /* 7) menu-as-ingredient path (MMFF) – item master */
                    WHEN ims2.full_item_description IS NOT NULL
                         AND ims2.packaging_size IS NOT NULL
                         AND ims2.packaging_size > 0
                    THEN ims2.packaging_size

                    /* 8) menu-as-ingredient path (MMFF) – production item */
                    WHEN pi2.full_item_description IS NOT NULL
                         AND pi2.packaging_size IS NOT NULL
                         AND pi2.packaging_size > 0
                    THEN pi2.packaging_size

                    /* 9) menu-as-ingredient path (MMFF) – new ingredient */
                    WHEN ni2.item_description IS NOT NULL
                         AND ni2.packaging_size IS NOT NULL
                         AND ni2.packaging_size > 0
                    THEN ni2.packaging_size

                    /* 10) fallback: ingredient line packaging size */
                    WHEN sub_main_ingr_2.packaging_size IS NOT NULL
                         AND sub_main_ingr_2.packaging_size > 0
                    THEN sub_main_ingr_2.packaging_size

                    /* 11) final fallback: only if *any* description exists */
                    WHEN COALESCE(
                            COALESCE(
                                im_as_ing__batch_2.menu_item_description,
                                bs2_header.ingredient_description,
                                ims_batch_2.full_item_description,
                                pi_batch_2.full_item_description,
                                ni_batch_2.item_description,
                                im_as_ing__batch_2.menu_item_description
                            ),
                            bas_ing_2.ingredient_description,
                            ims2.full_item_description,
                            pi2.full_item_description,
                            ni2.item_description,
                            im_as_ing_2.menu_item_description
                         ) IS NOT NULL
                    THEN 2
                END AS sub_packaging_size_2,


                 ROUND(
                         (
                             COALESCE(sub_main_ingr_2.prep_qty,
                                      bs2.prep_qty) / ROUND(
                                     (
                                         COALESCE(sub_main_ingr_2.yield,
                                                  bs2.yield) / 100
                                         ),
                                     4
                                                      )
                             ),
                         4
                 )                                                                       AS sub_ingredient_qty_2,

                 coalesce(pack_sub_2.packaging_description, uom_sub_2.`uom_description`) as sub_uom_2,


                 round(ROUND(
                               (
                                   COALESCE(sub_main_ingr_2.prep_qty,
                                            bs2.prep_qty) / ROUND(
                                           (
                                               COALESCE(sub_main_ingr_2.yield,
                                                        bs2.yield) / 100
                                               ),
                                           4
                                                            )
                                   ),
                               4
                       ) / (CASE
                            /* 1) menu-as-ingredient coming from batch line (menu item) */
                            WHEN im_as_ing__batch_2.menu_item_description IS NOT NULL
                                 AND sub_main_ing_batch_2.packaging_size IS NOT NULL
                                 AND sub_main_ing_batch_2.packaging_size > 0
                            THEN sub_main_ing_batch_2.packaging_size

                            /* 2) batch ingredient line description */
                            WHEN bs2_header.ingredient_description IS NOT NULL
                                 AND bs2_header.quantity IS NOT NULL
                                 AND bs2_header.quantity > 0
                            THEN bs2_header.quantity

                            /* 2) item master in batch line */
                            WHEN ims_batch_2.full_item_description IS NOT NULL
                                 AND ims_batch_2.packaging_size IS NOT NULL
                                 AND ims_batch_2.packaging_size > 0
                            THEN ims_batch_2.packaging_size

                            /* 4) production item in batch line */
                            WHEN pi_batch_2.full_item_description IS NOT NULL
                                 AND pi_batch_2.packaging_size IS NOT NULL
                                 AND pi_batch_2.packaging_size > 0
                            THEN pi_batch_2.packaging_size

                            /* 5) new ingredient in batch line */
                            WHEN ni_batch_2.item_description IS NOT NULL
                                 AND ni_batch_2.packaging_size IS NOT NULL
                                 AND ni_batch_2.packaging_size > 0
                            THEN ni_batch_2.packaging_size

                            /* 6) menu-as-ingredient path (MMFF) – batching ingredient */
                            WHEN bas_ing_2.ingredient_description IS NOT NULL
                                 AND bas_ing_2.quantity IS NOT NULL
                                 AND bas_ing_2.quantity > 0
                            THEN bas_ing_2.quantity

                            /* 7) menu-as-ingredient path (MMFF) – item master */
                            WHEN ims2.full_item_description IS NOT NULL
                                 AND ims2.packaging_size IS NOT NULL
                                 AND ims2.packaging_size > 0
                            THEN ims2.packaging_size

                            /* 8) menu-as-ingredient path (MMFF) – production item */
                            WHEN pi2.full_item_description IS NOT NULL
                                 AND pi2.packaging_size IS NOT NULL
                                 AND pi2.packaging_size > 0
                            THEN pi2.packaging_size

                            /* 9) menu-as-ingredient path (MMFF) – new ingredient */
                            WHEN ni2.item_description IS NOT NULL
                                 AND ni2.packaging_size IS NOT NULL
                                 AND ni2.packaging_size > 0
                            THEN ni2.packaging_size

                            /* 10) fallback: ingredient line packaging size */
                            WHEN sub_main_ingr_2.packaging_size IS NOT NULL
                                 AND sub_main_ingr_2.packaging_size > 0
                            THEN sub_main_ingr_2.packaging_size

                            /* 11) final fallback: only if *any* description exists */
                            WHEN COALESCE(
                                    COALESCE(
                                        im_as_ing__batch_2.menu_item_description,
                                        bs2_header.ingredient_description,
                                        ims_batch_2.full_item_description,
                                        pi_batch_2.full_item_description,
                                        ni_batch_2.item_description,
                                        im_as_ing__batch_2.menu_item_description
                                    ),
                                    bas_ing_2.ingredient_description,
                                    ims2.full_item_description,
                                    pi2.full_item_description,
                                    ni2.item_description,
                                    im_as_ing_2.menu_item_description
                                 ) IS NOT NULL
                            THEN 2
                        END
                           ), 4)                                                         as sku_converted_sub_2,


               CASE
                    WHEN im_as_ing__batch_2.menu_item_description IS NOT NULL
                         AND ims_batch_2.landed_cost IS NOT NULL
                         AND ims_batch_2.landed_cost > 1
                    THEN ims_batch_2.landed_cost

                    WHEN bs2_line.ingredient_description IS NOT NULL
                         AND bs2_header.ttp IS NOT NULL
                         AND bs2_header.ttp > 1
                    THEN bs2_header.ttp

                    WHEN ims_batch_2.full_item_description IS NOT NULL
                         AND ims_batch_2.landed_cost IS NOT NULL
                         AND ims_batch_2.landed_cost > 1
                    THEN ims_batch_2.landed_cost

                    WHEN pi2.full_item_description IS NOT NULL
                         AND pi2.landed_cost IS NOT NULL
                         AND pi2.landed_cost > 1
                    THEN pi2.landed_cost

                    WHEN ni_batch_2.item_description IS NOT NULL
                         AND ni_batch_2.ttp IS NOT NULL
                         AND ni_batch_2.ttp > 1
                    THEN ni_batch_2.ttp

                    WHEN im_as_ing_2_line.menu_item_description IS NOT NULL
                         AND im_as_ing_2.ingredient_total_cost IS NOT NULL
                         AND im_as_ing_2.ingredient_total_cost > 1
                    THEN im_as_ing_2.ingredient_total_cost

                    WHEN bas_ing_2.ingredient_description IS NOT NULL
                         AND bas_ing_2.ttp IS NOT NULL
                         AND bas_ing_2.ttp > 1
                    THEN bas_ing_2.ttp

                    WHEN ims2.full_item_description IS NOT NULL
                         AND ims2.landed_cost IS NOT NULL
                         AND ims2.landed_cost > 1
                    THEN ims2.landed_cost

                    WHEN ni2.item_description IS NOT NULL
                         AND ni2.ttp IS NOT NULL
                         AND ni2.ttp > 1
                    THEN ni2.ttp

                    ELSE NULL
                END AS landed_cost_sub_2,


                 round(ROUND(
                               (
                                   COALESCE(sub_main_ingr_2.prep_qty,
                                            bs2.prep_qty) / ROUND(
                                           (
                                               COALESCE(sub_main_ingr_2.yield,
                                                        bs2.yield) / 100
                                               ),
                                           4
                                                            )
                                   ),
                               4
                       ) / (CASE
                                /* 1) menu-as-ingredient coming from batch line (menu item) */
                                WHEN im_as_ing__batch_2.menu_item_description IS NOT NULL
                                     AND sub_main_ing_batch_2.packaging_size IS NOT NULL
                                     AND sub_main_ing_batch_2.packaging_size > 0
                                THEN sub_main_ing_batch_2.packaging_size

                                /* 2) batch ingredient line description */
                                WHEN bs2_header.ingredient_description IS NOT NULL
                                     AND bs2_header.quantity IS NOT NULL
                                     AND bs2_header.quantity > 0
                                THEN bs2_header.quantity

                                /* 2) item master in batch line */
                                WHEN ims_batch_2.full_item_description IS NOT NULL
                                     AND ims_batch_2.packaging_size IS NOT NULL
                                     AND ims_batch_2.packaging_size > 0
                                THEN ims_batch_2.packaging_size

                                /* 4) production item in batch line */
                                WHEN pi_batch_2.full_item_description IS NOT NULL
                                     AND pi_batch_2.packaging_size IS NOT NULL
                                     AND pi_batch_2.packaging_size > 0
                                THEN pi_batch_2.packaging_size

                                /* 5) new ingredient in batch line */
                                WHEN ni_batch_2.item_description IS NOT NULL
                                     AND ni_batch_2.packaging_size IS NOT NULL
                                     AND ni_batch_2.packaging_size > 0
                                THEN ni_batch_2.packaging_size

                                /* 6) menu-as-ingredient path (MMFF) – batching ingredient */
                                WHEN bas_ing_2.ingredient_description IS NOT NULL
                                     AND bas_ing_2.quantity IS NOT NULL
                                     AND bas_ing_2.quantity > 0
                                THEN bas_ing_2.quantity

                                /* 7) menu-as-ingredient path (MMFF) – item master */
                                WHEN ims2.full_item_description IS NOT NULL
                                     AND ims2.packaging_size IS NOT NULL
                                     AND ims2.packaging_size > 0
                                THEN ims2.packaging_size

                                /* 8) menu-as-ingredient path (MMFF) – production item */
                                WHEN pi2.full_item_description IS NOT NULL
                                     AND pi2.packaging_size IS NOT NULL
                                     AND pi2.packaging_size > 0
                                THEN pi2.packaging_size

                                /* 9) menu-as-ingredient path (MMFF) – new ingredient */
                                WHEN ni2.item_description IS NOT NULL
                                     AND ni2.packaging_size IS NOT NULL
                                     AND ni2.packaging_size > 0
                                THEN ni2.packaging_size

                                /* 10) fallback: ingredient line packaging size */
                                WHEN sub_main_ingr_2.packaging_size IS NOT NULL
                                     AND sub_main_ingr_2.packaging_size > 0
                                THEN sub_main_ingr_2.packaging_size

                                /* 11) final fallback: only if *any* description exists */
                                WHEN COALESCE(
                                        COALESCE(
                                            im_as_ing__batch_2.menu_item_description,
                                            bs2_header.ingredient_description,
                                            ims_batch_2.full_item_description,
                                            pi_batch_2.full_item_description,
                                            ni_batch_2.item_description,
                                            im_as_ing__batch_2.menu_item_description
                                        ),
                                        bas_ing_2.ingredient_description,
                                        ims2.full_item_description,
                                        pi2.full_item_description,
                                        ni2.item_description,
                                        im_as_ing_2.menu_item_description
                                     ) IS NOT NULL
                                THEN 1
                            END
                               ), 4) * CASE
                    WHEN im_as_ing__batch_2.menu_item_description IS NOT NULL
                         AND ims_batch_2.landed_cost IS NOT NULL
                         AND ims_batch_2.landed_cost > 1
                    THEN ims_batch_2.landed_cost

                    WHEN bs2_line.ingredient_description IS NOT NULL
                         AND bs2_header.ttp IS NOT NULL
                         AND bs2_header.ttp > 1
                    THEN bs2_header.ttp

                    WHEN ims_batch_2.full_item_description IS NOT NULL
                         AND ims_batch_2.landed_cost IS NOT NULL
                         AND ims_batch_2.landed_cost > 1
                    THEN ims_batch_2.landed_cost

                    WHEN pi2.full_item_description IS NOT NULL
                         AND pi2.landed_cost IS NOT NULL
                         AND pi2.landed_cost > 1
                    THEN pi2.landed_cost

                    WHEN ni_batch_2.item_description IS NOT NULL
                         AND ni_batch_2.ttp IS NOT NULL
                         AND ni_batch_2.ttp > 1
                    THEN ni_batch_2.ttp

                    WHEN im_as_ing_2_line.menu_item_description IS NOT NULL
                         AND im_as_ing_2.ingredient_total_cost IS NOT NULL
                         AND im_as_ing_2.ingredient_total_cost > 1
                    THEN im_as_ing_2.ingredient_total_cost

                    WHEN bas_ing_2.ingredient_description IS NOT NULL
                         AND bas_ing_2.ttp IS NOT NULL
                         AND bas_ing_2.ttp > 1
                    THEN bas_ing_2.ttp

                    WHEN ims2.full_item_description IS NOT NULL
                         AND ims2.landed_cost IS NOT NULL
                         AND ims2.landed_cost > 1
                    THEN ims2.landed_cost

                    WHEN ni2.item_description IS NOT NULL
                         AND ni2.ttp IS NOT NULL
                         AND ni2.ttp > 1
                    THEN ni2.ttp

                    ELSE NULL
                END     as sub_unit_ost_2

from m_s_1

-- production items
-- LEFT JOIN production_item_lines pis_ing_2
	-- ON pis_ing_2.production_item_id = m_s_1.menu_item_ingredients_code_sub_1 AND m_s_1.sub_types_1 = 'PIMFS' AND pis_ing_2.production_item_line_type = 'ingredient'

-- menu as ing sub ing

LEFT JOIN menu_items as im_as_ing_2
	ON im_as_ing_2.tasteless_menu_code = m_s_1.menu_item_ingredients_code_sub_1 AND m_s_1.sub_types_1 = 'MMFF'

LEFT JOIN ingredients as sub_main_ingr_2
	ON im_as_ing_2.id = sub_main_ingr_2.menu_items_id

LEFT JOIN menu_items as im_as_ing_2_line
	ON im_as_ing_2_line.id = sub_main_ingr_2.menu_as_ingredient_id

 LEFT JOIN batching_ingredients as bas_ing_2
	ON  bas_ing_2.id = sub_main_ingr_2.batching_ingredients_id

LEFT JOIN item_masters as ims2
	ON ims2.id = sub_main_ingr_2.item_masters_id

LEFT JOIN production_items as pi2
	ON pi2.id = sub_main_ingr_2.production_items_id

LEFT JOIN new_ingredients as ni2
	ON ni2.id = sub_main_ingr_2.new_ingredients_id

-- batching
LEFT JOIN batching_ingredients as bs2_header -- parent
	ON  bs2_header.bi_code = m_s_1.menu_item_ingredients_code_sub_1 AND m_s_1.sub_types_1 = 'BATCH'

LEFT JOIN batching_ingredients_details as bs2 -- lines
	ON  bs2.batching_ingredients_id = bs2_header.id

LEFT JOIN batching_ingredients as bs2_line -- lines batch
	ON  bs2_line.id = bs2.batching_as_ingredient_id

LEFT JOIN ingredients as sub_main_ing_batch_2
	ON sub_main_ing_batch_2.id = bs2.menu_as_ingredient_id

LEFT JOIN menu_items as im_as_ing__batch_2
	ON im_as_ing__batch_2.id = bs2.menu_as_ingredient_id

LEFT JOIN item_masters as ims_batch_2
	ON ims_batch_2.id = bs2.item_masters_id

LEFT JOIN production_items as pi_batch_2
	ON pi_batch_2.id = bs2.production_items_id

LEFT JOIN new_ingredients as ni_batch_2
	ON ni_batch_2.id = bs2.new_ingredients_id

LEFT JOIN uoms as uom_sub_2 ON
            uom_sub_2.id =     COALESCE(
                            COALESCE(
                                im_as_ing__batch_2.uoms_id,
                                bs2_header.uoms_id,
                                ims_batch_2.uoms_id,
                                pi_batch_2.uoms_id,
                                ni_batch_2.uoms_id,
                                im_as_ing__batch_2.uoms_id
                            ), -- batch
                            bas_ing_2.uoms_id,
                            ims2.uoms_id,
                            -- pis_ing_2item_code,
                            pi2.uoms_id,
                            ni2.uoms_id,
                            im_as_ing_2.uoms_id
                        )


LEFT JOIN packagings as pack_sub_2 ON
            pack_sub_2.id =   COALESCE(
                            COALESCE(
                                im_as_ing__batch_2.uoms_id,
                                bs2_header.uoms_id,
                                ims_batch_2.packagings_id,
                                pi_batch_2.packagings_id,
                                ni_batch_2.uoms_id,
                                im_as_ing__batch_2.uoms_id
                            ), -- batch
                            bas_ing_2.uoms_id,
                            ims2.packagings_id,
                            -- pis_ing_2item_code,
                            pi2.packagings_id,
                            ni2.uoms_id,
                            im_as_ing_2.uoms_id
                        )



),

m_s_3 as (select m_s_2.*,
                 CASE
                     WHEN im_as_ing__batch_3.tasteless_menu_code IS NOT NULL
                         THEN 'MFF'

                     WHEN bs3_line.bi_code IS NOT NULL
                         THEN 'BATCH'

                     WHEN ims_batch_3.tasteless_code IS NOT NULL
                         THEN 'IMFS'

                     WHEN pi3.reference_number IS NOT NULL
                         THEN 'PIMFS'

                     WHEN pi_batch_3.reference_number IS NOT NULL
                         THEN 'PIMFS'

                     WHEN ni_batch_3.nwi_code IS NOT NULL
                         THEN 'NEW'

                     WHEN im_as_ing_3_line.tasteless_menu_code IS NOT NULL
                         THEN 'MFF'

                     WHEN bas_ing_3.bi_code IS NOT NULL
                         THEN 'BATCH'

                     WHEN ims3.tasteless_code IS NOT NULL
                         THEN 'IMFS'

                     WHEN ni3.nwi_code IS NOT NULL
                         THEN 'NEW'

                     WHEN im_as_ing_3.tasteless_menu_code IS NOT NULL
                         THEN 'MFF'

                     ELSE 'UNKNOWN'
                     END                                                                 AS sub_types_3,

                 COALESCE(
                         COALESCE(
                                 im_as_ing__batch_3.tasteless_menu_code,
                                 bs3_line.bi_code,
                                 ims_batch_3.tasteless_code,
                                 pi3.reference_number,
                                 ni_batch_3.nwi_code,
                                 im_as_ing_3_line.tasteless_menu_code
                         ),
                         bas_ing_3.bi_code,
                         ims3.tasteless_code,
                         pi_batch_3.reference_number,
                     --  pis_ing_3.item_code,
                         ni3.nwi_code
                 )                                                                       AS menu_item_ingredients_code_sub_3,

                 COALESCE(
                         COALESCE(
                                 im_as_ing__batch_3.menu_item_description,
                                 bs3_line.ingredient_description,
                                 ims_batch_3.full_item_description,
                                 pi3.full_item_description,
                                 ni_batch_3.item_description,
                                 im_as_ing_3_line.menu_item_description
                         ),
                         bas_ing_3.ingredient_description,
                         ims3.full_item_description,
                         pi_batch_3.full_item_description,
                     -- pis_ing_3.description,
                         ni3.item_description
                 )                                                                       AS menu_item_ingredients_description_sub_3,

                 CASE
                    /* 1) menu-as-ingredient coming from batch line (menu item) */
                    WHEN im_as_ing__batch_3.menu_item_description IS NOT NULL
                         AND sub_main_ing_batch_3.packaging_size IS NOT NULL
                         AND sub_main_ing_batch_3.packaging_size > 0
                    THEN sub_main_ing_batch_3.packaging_size

                    /* 2) batch ingredient line description */
                    WHEN bs3_header.ingredient_description IS NOT NULL
                         AND bs3_header.quantity IS NOT NULL
                         AND bs3_header.quantity > 0
                    THEN bs3_header.quantity

                    /* 3) item master in batch line */
                    WHEN ims_batch_3.full_item_description IS NOT NULL
                         AND ims_batch_3.packaging_size IS NOT NULL
                         AND ims_batch_3.packaging_size > 0
                    THEN ims_batch_3.packaging_size

                    /* 4) production item in batch line */
                    WHEN pi_batch_3.full_item_description IS NOT NULL
                         AND pi_batch_3.packaging_size IS NOT NULL
                         AND pi_batch_3.packaging_size > 0
                    THEN pi_batch_3.packaging_size

                    /* 5) new ingredient in batch line */
                    WHEN ni_batch_3.item_description IS NOT NULL
                         AND ni_batch_3.packaging_size IS NOT NULL
                         AND ni_batch_3.packaging_size > 0
                    THEN ni_batch_3.packaging_size

                    /* 6) menu-as-ingredient path (MMFF) – batching ingredient */
                    WHEN bas_ing_3.ingredient_description IS NOT NULL
                         AND bas_ing_3.quantity IS NOT NULL
                         AND bas_ing_3.quantity > 0
                    THEN bas_ing_3.quantity

                    /* 7) menu-as-ingredient path (MMFF) – item master */
                    WHEN ims3.full_item_description IS NOT NULL
                         AND ims3.packaging_size IS NOT NULL
                         AND ims3.packaging_size > 0
                    THEN ims3.packaging_size

                    /* 8) menu-as-ingredient path (MMFF) – production item */
                    WHEN pi3.full_item_description IS NOT NULL
                         AND pi3.packaging_size IS NOT NULL
                         AND pi3.packaging_size > 0
                    THEN pi3.packaging_size

                    /* 9) menu-as-ingredient path (MMFF) – new ingredient */
                    WHEN ni3.item_description IS NOT NULL
                         AND ni3.packaging_size IS NOT NULL
                         AND ni3.packaging_size > 0
                    THEN ni3.packaging_size

                    /* 10) fallback: ingredient line packaging size */
                    WHEN sub_main_ingr_3.packaging_size IS NOT NULL
                         AND sub_main_ingr_3.packaging_size > 0
                    THEN sub_main_ingr_3.packaging_size

                    /* 11) final fallback: only if *any* description exists */
                    WHEN COALESCE(
                            COALESCE(
                                im_as_ing__batch_3.menu_item_description,
                                bs3_header.ingredient_description,
                                ims_batch_3.full_item_description,
                                pi_batch_3.full_item_description,
                                ni_batch_3.item_description,
                                im_as_ing__batch_3.menu_item_description
                            ),
                            bas_ing_3.ingredient_description,
                            ims3.full_item_description,
                            pi3.full_item_description,
                            ni3.item_description,
                            im_as_ing_3.menu_item_description
                         ) IS NOT NULL
                    THEN 3
                END AS sub_packaging_size_3,


                 ROUND(
                         (
                             COALESCE(sub_main_ingr_3.prep_qty,
                                      bs3.prep_qty) / ROUND(
                                     (
                                         COALESCE(sub_main_ingr_3.yield,
                                                  bs3.yield) / 100
                                         ),
                                     4
                                                      )
                             ),
                         4
                 )                                                                       AS sub_ingredient_qty_3,

                 coalesce(pack_sub_3.packaging_description, uom_sub_3.`uom_description`) as sub_uom_3,


                 round(ROUND(
                               (
                                   COALESCE(sub_main_ingr_3.prep_qty,
                                            bs3.prep_qty) / ROUND(
                                           (
                                               COALESCE(sub_main_ingr_3.yield,
                                                        bs3.yield) / 100
                                               ),
                                           4
                                                            )
                                   ),
                               4
                       ) / (CASE
                            /* 1) menu-as-ingredient coming from batch line (menu item) */
                            WHEN im_as_ing__batch_3.menu_item_description IS NOT NULL
                                 AND sub_main_ing_batch_3.packaging_size IS NOT NULL
                                 AND sub_main_ing_batch_3.packaging_size > 0
                            THEN sub_main_ing_batch_3.packaging_size

                            /* 2) batch ingredient line description */
                            WHEN bs3_header.ingredient_description IS NOT NULL
                                 AND bs3_header.quantity IS NOT NULL
                                 AND bs3_header.quantity > 0
                            THEN bs3_header.quantity

                            /* 3) item master in batch line */
                            WHEN ims_batch_3.full_item_description IS NOT NULL
                                 AND ims_batch_3.packaging_size IS NOT NULL
                                 AND ims_batch_3.packaging_size > 0
                            THEN ims_batch_3.packaging_size

                            /* 4) production item in batch line */
                            WHEN pi_batch_3.full_item_description IS NOT NULL
                                 AND pi_batch_3.packaging_size IS NOT NULL
                                 AND pi_batch_3.packaging_size > 0
                            THEN pi_batch_3.packaging_size

                            /* 5) new ingredient in batch line */
                            WHEN ni_batch_3.item_description IS NOT NULL
                                 AND ni_batch_3.packaging_size IS NOT NULL
                                 AND ni_batch_3.packaging_size > 0
                            THEN ni_batch_3.packaging_size

                            /* 6) menu-as-ingredient path (MMFF) – batching ingredient */
                            WHEN bas_ing_3.ingredient_description IS NOT NULL
                                 AND bas_ing_3.quantity IS NOT NULL
                                 AND bas_ing_3.quantity > 0
                            THEN bas_ing_3.quantity

                            /* 7) menu-as-ingredient path (MMFF) – item master */
                            WHEN ims3.full_item_description IS NOT NULL
                                 AND ims3.packaging_size IS NOT NULL
                                 AND ims3.packaging_size > 0
                            THEN ims3.packaging_size

                            /* 8) menu-as-ingredient path (MMFF) – production item */
                            WHEN pi3.full_item_description IS NOT NULL
                                 AND pi3.packaging_size IS NOT NULL
                                 AND pi3.packaging_size > 0
                            THEN pi3.packaging_size

                            /* 9) menu-as-ingredient path (MMFF) – new ingredient */
                            WHEN ni3.item_description IS NOT NULL
                                 AND ni3.packaging_size IS NOT NULL
                                 AND ni3.packaging_size > 0
                            THEN ni3.packaging_size

                            /* 10) fallback: ingredient line packaging size */
                            WHEN sub_main_ingr_3.packaging_size IS NOT NULL
                                 AND sub_main_ingr_3.packaging_size > 0
                            THEN sub_main_ingr_3.packaging_size

                            /* 11) final fallback: only if *any* description exists */
                            WHEN COALESCE(
                                    COALESCE(
                                        im_as_ing__batch_3.menu_item_description,
                                        bs3_header.ingredient_description,
                                        ims_batch_3.full_item_description,
                                        pi_batch_3.full_item_description,
                                        ni_batch_3.item_description,
                                        im_as_ing__batch_3.menu_item_description
                                    ),
                                    bas_ing_3.ingredient_description,
                                    ims3.full_item_description,
                                    pi3.full_item_description,
                                    ni3.item_description,
                                    im_as_ing_3.menu_item_description
                                 ) IS NOT NULL
                            THEN 3
                        END
                           ), 4)                                                         as sku_converted_sub_3,


               CASE
                    WHEN im_as_ing__batch_3.menu_item_description IS NOT NULL
                         AND ims_batch_3.landed_cost IS NOT NULL
                         AND ims_batch_3.landed_cost > 1
                    THEN ims_batch_3.landed_cost

                    WHEN bs3_line.ingredient_description IS NOT NULL
                         AND bs3_header.ttp IS NOT NULL
                         AND bs3_header.ttp > 1
                    THEN bs3_header.ttp

                    WHEN ims_batch_3.full_item_description IS NOT NULL
                         AND ims_batch_3.landed_cost IS NOT NULL
                         AND ims_batch_3.landed_cost > 1
                    THEN ims_batch_3.landed_cost

                    WHEN pi3.full_item_description IS NOT NULL
                         AND pi3.landed_cost IS NOT NULL
                         AND pi3.landed_cost > 1
                    THEN pi3.landed_cost

                    WHEN ni_batch_3.item_description IS NOT NULL
                         AND ni_batch_3.ttp IS NOT NULL
                         AND ni_batch_3.ttp > 1
                    THEN ni_batch_3.ttp

                    WHEN im_as_ing_3_line.menu_item_description IS NOT NULL
                         AND im_as_ing_3.ingredient_total_cost IS NOT NULL
                         AND im_as_ing_3.ingredient_total_cost > 1
                    THEN im_as_ing_3.ingredient_total_cost

                    WHEN bas_ing_3.ingredient_description IS NOT NULL
                         AND bas_ing_3.ttp IS NOT NULL
                         AND bas_ing_3.ttp > 1
                    THEN bas_ing_3.ttp

                    WHEN ims3.full_item_description IS NOT NULL
                         AND ims3.landed_cost IS NOT NULL
                         AND ims3.landed_cost > 1
                    THEN ims3.landed_cost

                    WHEN ni3.item_description IS NOT NULL
                         AND ni3.ttp IS NOT NULL
                         AND ni3.ttp > 1
                    THEN ni3.ttp

                    ELSE NULL
                END AS landed_cost_sub_3,


                 round(ROUND(
                               (
                                   COALESCE(sub_main_ingr_3.prep_qty,
                                            bs3.prep_qty) / ROUND(
                                           (
                                               COALESCE(sub_main_ingr_3.yield,
                                                        bs3.yield) / 100
                                               ),
                                           4
                                                            )
                                   ),
                               4
                       ) / (CASE
                                /* 1) menu-as-ingredient coming from batch line (menu item) */
                                WHEN im_as_ing__batch_3.menu_item_description IS NOT NULL
                                     AND sub_main_ing_batch_3.packaging_size IS NOT NULL
                                     AND sub_main_ing_batch_3.packaging_size > 0
                                THEN sub_main_ing_batch_3.packaging_size

                                /* 2) batch ingredient line description */
                                WHEN bs3_header.ingredient_description IS NOT NULL
                                     AND bs3_header.quantity IS NOT NULL
                                     AND bs3_header.quantity > 0
                                THEN bs3_header.quantity

                                /* 3) item master in batch line */
                                WHEN ims_batch_3.full_item_description IS NOT NULL
                                     AND ims_batch_3.packaging_size IS NOT NULL
                                     AND ims_batch_3.packaging_size > 0
                                THEN ims_batch_3.packaging_size

                                /* 4) production item in batch line */
                                WHEN pi_batch_3.full_item_description IS NOT NULL
                                     AND pi_batch_3.packaging_size IS NOT NULL
                                     AND pi_batch_3.packaging_size > 0
                                THEN pi_batch_3.packaging_size

                                /* 5) new ingredient in batch line */
                                WHEN ni_batch_3.item_description IS NOT NULL
                                     AND ni_batch_3.packaging_size IS NOT NULL
                                     AND ni_batch_3.packaging_size > 0
                                THEN ni_batch_3.packaging_size

                                /* 6) menu-as-ingredient path (MMFF) – batching ingredient */
                                WHEN bas_ing_3.ingredient_description IS NOT NULL
                                     AND bas_ing_3.quantity IS NOT NULL
                                     AND bas_ing_3.quantity > 0
                                THEN bas_ing_3.quantity

                                /* 7) menu-as-ingredient path (MMFF) – item master */
                                WHEN ims3.full_item_description IS NOT NULL
                                     AND ims3.packaging_size IS NOT NULL
                                     AND ims3.packaging_size > 0
                                THEN ims3.packaging_size

                                /* 8) menu-as-ingredient path (MMFF) – production item */
                                WHEN pi3.full_item_description IS NOT NULL
                                     AND pi3.packaging_size IS NOT NULL
                                     AND pi3.packaging_size > 0
                                THEN pi3.packaging_size

                                /* 9) menu-as-ingredient path (MMFF) – new ingredient */
                                WHEN ni3.item_description IS NOT NULL
                                     AND ni3.packaging_size IS NOT NULL
                                     AND ni3.packaging_size > 0
                                THEN ni3.packaging_size

                                /* 10) fallback: ingredient line packaging size */
                                WHEN sub_main_ingr_3.packaging_size IS NOT NULL
                                     AND sub_main_ingr_3.packaging_size > 0
                                THEN sub_main_ingr_3.packaging_size

                                /* 11) final fallback: only if *any* description exists */
                                WHEN COALESCE(
                                        COALESCE(
                                            im_as_ing__batch_3.menu_item_description,
                                            bs3_header.ingredient_description,
                                            ims_batch_3.full_item_description,
                                            pi_batch_3.full_item_description,
                                            ni_batch_3.item_description,
                                            im_as_ing__batch_3.menu_item_description
                                        ),
                                        bas_ing_3.ingredient_description,
                                        ims3.full_item_description,
                                        pi3.full_item_description,
                                        ni3.item_description,
                                        im_as_ing_3.menu_item_description
                                     ) IS NOT NULL
                                THEN 1
                            END
                               ), 4) * CASE
                    WHEN im_as_ing__batch_3.menu_item_description IS NOT NULL
                         AND ims_batch_3.landed_cost IS NOT NULL
                         AND ims_batch_3.landed_cost > 1
                    THEN ims_batch_3.landed_cost

                    WHEN bs3_line.ingredient_description IS NOT NULL
                         AND bs3_header.ttp IS NOT NULL
                         AND bs3_header.ttp > 1
                    THEN bs3_header.ttp

                    WHEN ims_batch_3.full_item_description IS NOT NULL
                         AND ims_batch_3.landed_cost IS NOT NULL
                         AND ims_batch_3.landed_cost > 1
                    THEN ims_batch_3.landed_cost

                    WHEN pi3.full_item_description IS NOT NULL
                         AND pi3.landed_cost IS NOT NULL
                         AND pi3.landed_cost > 1
                    THEN pi3.landed_cost

                    WHEN ni_batch_3.item_description IS NOT NULL
                         AND ni_batch_3.ttp IS NOT NULL
                         AND ni_batch_3.ttp > 1
                    THEN ni_batch_3.ttp

                    WHEN im_as_ing_3_line.menu_item_description IS NOT NULL
                         AND im_as_ing_3.ingredient_total_cost IS NOT NULL
                         AND im_as_ing_3.ingredient_total_cost > 1
                    THEN im_as_ing_3.ingredient_total_cost

                    WHEN bas_ing_3.ingredient_description IS NOT NULL
                         AND bas_ing_3.ttp IS NOT NULL
                         AND bas_ing_3.ttp > 1
                    THEN bas_ing_3.ttp

                    WHEN ims3.full_item_description IS NOT NULL
                         AND ims3.landed_cost IS NOT NULL
                         AND ims3.landed_cost > 1
                    THEN ims3.landed_cost

                    WHEN ni3.item_description IS NOT NULL
                         AND ni3.ttp IS NOT NULL
                         AND ni3.ttp > 1
                    THEN ni3.ttp

                    ELSE NULL
                END     as sub_unit_ost_3

          from m_s_2

                   -- production items
-- LEFT JOIN production_item_lines pis_ing_3
                   -- ON pis_ing_3.production_item_id = m_s_2.menu_item_ingredients_code_sub_2 AND m_s_2.sub_types_2 = 'PIMFS' AND pis_ing_3.production_item_line_type = 'ingredient'

-- menu as ing sub ing

                   LEFT JOIN menu_items as im_as_ing_3
                             ON im_as_ing_3.tasteless_menu_code = m_s_2.menu_item_ingredients_code_sub_2 AND
                                m_s_2.sub_types_2 = 'MMFF'

                   LEFT JOIN ingredients as sub_main_ingr_3
                             ON im_as_ing_3.id = sub_main_ingr_3.menu_items_id

                   LEFT JOIN menu_items as im_as_ing_3_line
                             ON im_as_ing_3_line.id = sub_main_ingr_3.menu_as_ingredient_id

                   LEFT JOIN batching_ingredients as bas_ing_3
                             ON bas_ing_3.id = sub_main_ingr_3.batching_ingredients_id

                   LEFT JOIN item_masters as ims3
                             ON ims3.id = sub_main_ingr_3.item_masters_id

                   LEFT JOIN production_items as pi3
                             ON pi3.id = sub_main_ingr_3.production_items_id

                   LEFT JOIN new_ingredients as ni3
                             ON ni3.id = sub_main_ingr_3.new_ingredients_id

-- batching
                   LEFT JOIN batching_ingredients as bs3_header -- parent
                             ON bs3_header.bi_code = m_s_2.menu_item_ingredients_code_sub_2 AND
                                m_s_2.sub_types_2 = 'BATCH'

                   LEFT JOIN batching_ingredients_details as bs3 -- lines
                             ON bs3.batching_ingredients_id = bs3_header.id

                   LEFT JOIN batching_ingredients as bs3_line -- lines batch
                             ON bs3_line.id = bs3.batching_as_ingredient_id

                   LEFT JOIN ingredients as sub_main_ing_batch_3
                             ON sub_main_ing_batch_3.id = bs3.menu_as_ingredient_id

                   LEFT JOIN menu_items as im_as_ing__batch_3
                             ON im_as_ing__batch_3.id = bs3.menu_as_ingredient_id

                   LEFT JOIN item_masters as ims_batch_3
                             ON ims_batch_3.id = bs3.item_masters_id

                   LEFT JOIN production_items as pi_batch_3
                             ON pi_batch_3.id = bs3.production_items_id

                   LEFT JOIN new_ingredients as ni_batch_3
                             ON ni_batch_3.id = bs3.new_ingredients_id

                   LEFT JOIN uoms as uom_sub_3 ON
              uom_sub_3.id = COALESCE(
                      COALESCE(
                              im_as_ing__batch_3.uoms_id,
                              bs3_header.uoms_id,
                              ims_batch_3.uoms_id,
                              pi_batch_3.uoms_id,
                              ni_batch_3.uoms_id,
                              im_as_ing__batch_3.uoms_id
                      ), -- batch
                      bas_ing_3.uoms_id,
                      ims3.uoms_id,
                  -- pis_ing_3item_code,
                      pi3.uoms_id,
                      ni3.uoms_id,
                      im_as_ing_3.uoms_id
                             )


                   LEFT JOIN packagings as pack_sub_3 ON
              pack_sub_3.id = COALESCE(
                      COALESCE(
                              im_as_ing__batch_3.uoms_id,
                              bs3_header.uoms_id,
                              ims_batch_3.packagings_id,
                              pi_batch_3.packagings_id,
                              ni_batch_3.uoms_id,
                              im_as_ing__batch_3.uoms_id
                      ), -- batch
                      bas_ing_3.uoms_id,
                      ims3.packagings_id,
                  -- pis_ing_3item_code,
                      pi3.packagings_id,
                      ni3.uoms_id,
                      im_as_ing_3.uoms_id
                              )
)

select  * from  m_s_3
where m_s_3.menu_code = '6006056'
-- pinaka latest
-- make a void for menu_as_ing trat as menu header 7000000389
-- make a join also for ing 
-- do this all in php also