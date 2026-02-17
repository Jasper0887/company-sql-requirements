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
        WHEN EXISTS (
            SELECT 1
            FROM batching_ingredients
            WHERE bi_code = COALESCE(
                COALESCE(im_as_ing__batch_1.tasteless_menu_code, 
                         bs1_header.bi_code, 
                         ims_batch_1.tasteless_code, 
                         pi_batch_1.reference_number, 
                         ni_batch_1.nwi_code, 
                         im_as_ing__batch_1.tasteless_menu_code), 
                bas_ing_1.bi_code, 
                ims1.tasteless_code, 
                pis_ing_1.item_code, 
                ni1.nwi_code, 
                im_as_ing_1.tasteless_menu_code
            )
        ) THEN 'BATCH'
        WHEN EXISTS (
            SELECT 1
            FROM item_masters
            WHERE tasteless_code = COALESCE(
                COALESCE(im_as_ing__batch_1.tasteless_menu_code, 
                         bs1_header.bi_code, 
                         ims_batch_1.tasteless_code, 
                         pi_batch_1.reference_number, 
                         ni_batch_1.nwi_code, 
                         im_as_ing__batch_1.tasteless_menu_code), 
                bas_ing_1.bi_code, 
                ims1.tasteless_code, 
                pis_ing_1.item_code, 
                ni1.nwi_code, 
                im_as_ing_1.tasteless_menu_code
            )
        ) THEN 'IMFS'
        WHEN EXISTS (
            SELECT 1
            FROM production_items
            WHERE reference_number = COALESCE(
                COALESCE(im_as_ing__batch_1.tasteless_menu_code, 
                         bs1_header.bi_code, 
                         ims_batch_1.tasteless_code, 
                         pi_batch_1.reference_number, 
                         ni_batch_1.nwi_code, 
                         im_as_ing__batch_1.tasteless_menu_code), 
                bas_ing_1.bi_code, 
                ims1.tasteless_code, 
                pis_ing_1.item_code, 
                ni1.nwi_code, 
                im_as_ing_1.tasteless_menu_code
            )
        ) THEN 'PIMFS'
        WHEN EXISTS (
            SELECT 1
            FROM new_ingredients
            WHERE nwi_code = COALESCE(
                COALESCE(im_as_ing__batch_1.tasteless_menu_code, 
                         bs1_header.bi_code, 
                         ims_batch_1.tasteless_code, 
                         pi_batch_1.reference_number, 
                         ni_batch_1.nwi_code, 
                         im_as_ing__batch_1.tasteless_menu_code), 
                bas_ing_1.bi_code, 
                ims1.tasteless_code, 
                pis_ing_1.item_code, 
                ni1.nwi_code, 
                im_as_ing_1.tasteless_menu_code
            )
        ) THEN 'NEW'
        WHEN EXISTS (
            SELECT 1
            FROM menu_items
            WHERE tasteless_menu_code = COALESCE(
                COALESCE(im_as_ing__batch_1.tasteless_menu_code, 
                         bs1_header.bi_code, 
                         ims_batch_1.tasteless_code, 
                         pi_batch_1.reference_number, 
                         ni_batch_1.nwi_code, 
                         im_as_ing__batch_1.tasteless_menu_code), 
                bas_ing_1.bi_code, 
                ims1.tasteless_code, 
                pis_ing_1.item_code, 
                ni1.nwi_code, 
                im_as_ing_1.tasteless_menu_code
            )
        ) THEN 'MMFF'
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
    pis_ing_1.item_code,
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
    pis_ing_1.description,
    ni1.item_description,
    im_as_ing_1.menu_item_description
) AS menu_item_ingredients_description_sub_1

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
LEFT JOIN production_item_lines pis_ing_1
	ON pis_ing_1.production_item_id = production_items.reference_number AND production_item_line_type = 'ingredient'
  
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
  
where menu_book.status is not null),

m_s_2 as (select   
    m_s_1.*, 

    CASE 
        WHEN EXISTS (
            SELECT 1
            FROM batching_ingredients
            WHERE bi_code = COALESCE(
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
                                        pis_ing_2.item_code,
                                        ni2.nwi_code,
                                        im_as_ing_2.tasteless_menu_code
                                    )
        ) THEN 'BATCH'
        WHEN EXISTS (
            SELECT 1
            FROM item_masters
            WHERE tasteless_code = COALESCE(
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
                                        pis_ing_2.item_code,
                                        ni2.nwi_code,
                                        im_as_ing_2.tasteless_menu_code
                                    )
        ) THEN 'IMFS'
        WHEN EXISTS (
            SELECT 1
            FROM production_items
            WHERE reference_number = COALESCE(
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
                                        pis_ing_2.item_code,
                                        ni2.nwi_code,
                                        im_as_ing_2.tasteless_menu_code
                                    )
        ) THEN 'PIMFS'
        WHEN EXISTS (
            SELECT 1
            FROM new_ingredients
            WHERE nwi_code = COALESCE(
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
                                        pis_ing_2.item_code,
                                        ni2.nwi_code,
                                        im_as_ing_2.tasteless_menu_code
                                    )
        ) THEN 'NEW'
        WHEN EXISTS (
            SELECT 1
            FROM menu_items
            WHERE tasteless_menu_code = COALESCE(
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
                                        pis_ing_2.item_code,
                                        ni2.nwi_code,
                                        im_as_ing_2.tasteless_menu_code
                                    )
        ) THEN 'MMFF'
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
        pis_ing_2.item_code,
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
        pis_ing_2.description,
        ni2.item_description 
    ) AS menu_item_ingredients_description_sub_2 
  
from m_s_1  
  
-- production items
LEFT JOIN production_item_lines pis_ing_2
	ON pis_ing_2.production_item_id = m_s_1.menu_item_ingredients_code_sub_1 AND m_s_1.sub_types_1 = 'PIMFS' AND pis_ing_2.production_item_line_type = 'ingredient'
  
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
	ON ni_batch_2.id = bs2.new_ingredients_id)

select   
    m_s_2.*, 

    CASE 
        WHEN EXISTS (
            SELECT 1
            FROM batching_ingredients
            WHERE bi_code = COALESCE(
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
                                        pis_ing_3.item_code,
                                        ni3.nwi_code,
                                        im_as_ing_3.tasteless_menu_code
                                    )
        ) THEN 'BATCH'
        WHEN EXISTS (
            SELECT 1
            FROM item_masters
            WHERE tasteless_code = COALESCE(
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
                                        pis_ing_3.item_code,
                                        ni3.nwi_code,
                                        im_as_ing_3.tasteless_menu_code
                                    )
        ) THEN 'IMFS'
        WHEN EXISTS (
            SELECT 1
            FROM production_items
            WHERE reference_number = COALESCE(
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
                                        pis_ing_3.item_code,
                                        ni3.nwi_code,
                                        im_as_ing_3.tasteless_menu_code
                                    )
        ) THEN 'PIMFS'
        WHEN EXISTS (
            SELECT 1
            FROM new_ingredients
            WHERE nwi_code = COALESCE(
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
                                        pis_ing_3.item_code,
                                        ni3.nwi_code,
                                        im_as_ing_3.tasteless_menu_code
                                    )
        ) THEN 'NEW'
        WHEN EXISTS (
            SELECT 1
            FROM menu_items
            WHERE tasteless_menu_code = COALESCE(
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
                                        pis_ing_3.item_code,
                                        ni3.nwi_code,
                                        im_as_ing_3.tasteless_menu_code
                                    )
        ) THEN 'MMFF'
        ELSE 'UNKNOWN'
    END AS sub_types_3,
    
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
        pis_ing_3.item_code,
        ni3.nwi_code 
    ) AS menu_item_ingredients_code_sub_3,
    
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
        pis_ing_3.description,
        ni3.item_description 
    ) AS menu_item_ingredients_description_sub_3 
  
from m_s_2
  
-- production items
LEFT JOIN production_item_lines pis_ing_3
	ON pis_ing_3.production_item_id = m_s_2.menu_item_ingredients_code_sub_2 AND m_s_2.sub_types_2 = 'PIMFS' AND pis_ing_3.production_item_line_type = 'ingredient'
  
-- menu as ing sub ing

LEFT JOIN menu_items as im_as_ing_3
	ON im_as_ing_3.tasteless_menu_code = m_s_2.menu_item_ingredients_code_sub_2 AND m_s_2.sub_types_2 = 'MMFF' 
  
LEFT JOIN ingredients as sub_main_ingr_3
	ON im_as_ing_3.id = sub_main_ingr_3.menu_items_id
  
LEFT JOIN menu_items as im_as_ing_3_line
	ON im_as_ing_3_line.id = sub_main_ingr_3.menu_as_ingredient_id 
  
 LEFT JOIN batching_ingredients as bas_ing_3
	ON  bas_ing_3.id = sub_main_ingr_3.batching_ingredients_id

LEFT JOIN item_masters as ims3
	ON ims3.id = sub_main_ingr_3.item_masters_id

LEFT JOIN production_items as pi3
	ON pi3.id = sub_main_ingr_3.production_items_id
  
LEFT JOIN new_ingredients as ni3
	ON ni3.id = sub_main_ingr_3.new_ingredients_id
    
-- batching
LEFT JOIN batching_ingredients as bs3_header -- parent
	ON  bs3_header.bi_code = m_s_2.menu_item_ingredients_code_sub_2 AND m_s_2.sub_types_2 = 'BATCH'
  
LEFT JOIN batching_ingredients_details as bs3 -- lines
	ON  bs3.batching_ingredients_id = bs3_header.id

LEFT JOIN batching_ingredients as bs3_line -- lines batch
	ON  bs3_line.id = bs3.batching_as_ingredient_id

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
  
where m_s_2.menu_code = '6006056'

-- make a void for menu_as_ing trat as menu header 7000000389
-- make a join also for ing 
-- do this all in php also