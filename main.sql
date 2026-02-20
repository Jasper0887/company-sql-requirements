WITH ingredients AS (
    SELECT
        *
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

        uoms.uom_description AS uom_small_unit,
        COALESCE(packagings.packaging_description, uoms.uom_description) AS uom_large_unit,

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

        uom_sub_1.uom_description AS uom_small_unit_sub_1,
        COALESCE(pack_sub_1.packaging_description, uom_sub_1.uom_description) AS uom_large_unit_sub_1,

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
            menu_as_ing.uoms_id,
            production_items.uoms_id,
            new_ingredients.uoms_id
        )

    LEFT JOIN packagings
        ON packagings.id = COALESCE(
            item_masters.packagings_id,
            production_items.packagings_id
        )

    -- ingredients section
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
            -- batch sub
            im_as_ing__batch_1.uoms_id,
            bs1_header.uoms_id,
            ims_batch_1.uoms_id,
            pi_batch_1.uoms_id,
            ni_batch_1.uoms_id,
            bas_ing_1.uoms_id,
            -- menu list sub
            ims1.uoms_id,
            pi1.uoms_id,
            ni1.uoms_id,
            im_as_ing_1.uoms_id
        )

    LEFT JOIN packagings AS pack_sub_1
        ON pack_sub_1.id = COALESCE(
            ims_batch_1.packagings_id,
            pi_batch_1.packagings_id,
            ims1.packagings_id,
            pi1.packagings_id
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
        b.uom_small_unit,
        ROUND((b.ingredient_qty / b.packaging_size), 4) AS sku_converted,
        b.uom_large_unit,
        b.landed_cost,
        ROUND(ROUND((b.ingredient_qty / b.packaging_size), 4) * b.landed_cost, 4) AS cost,
        b.sub_types_1,
        b.menu_item_ingredients_code_sub_1,
        b.menu_item_ingredients_description_sub_1,
        b.sub_packaging_size_1,
        b.sub_ingredient_qty_1,
        b.uom_small_unit_sub_1,
        ROUND((b.sub_ingredient_qty_1 / b.sub_packaging_size_1), 4) AS sku_converted_sub_1,
        b.uom_large_unit_sub_1,
        b.landed_cost_sub_1,
        ROUND(
            ROUND((b.sub_ingredient_qty_1 / b.sub_packaging_size_1), 4) * b.landed_cost_sub_1,
            4
        ) AS sub_unit_ost_1
    FROM m_s_1_base b
),

m_s_2_base AS (
    SELECT
        m_s_1.*,

        /* ---------- TYPE ---------- */
        CASE
            WHEN im_as_ing__batch_2.tasteless_menu_code IS NOT NULL THEN 'MMFF'
            WHEN bs2_line.bi_code IS NOT NULL THEN 'BATCH'
            WHEN ims_batch_2.tasteless_code IS NOT NULL THEN 'IMFS'
            WHEN pi2.reference_number IS NOT NULL THEN 'PIMFS'
            WHEN pi_batch_2.reference_number IS NOT NULL THEN 'PIMFS'
            WHEN ni_batch_2.nwi_code IS NOT NULL THEN 'NEW'
            WHEN im_as_ing_2_line.tasteless_menu_code IS NOT NULL THEN 'MMFF'
            WHEN bas_ing_2.bi_code IS NOT NULL THEN 'BATCH'
            WHEN ims2.tasteless_code IS NOT NULL THEN 'IMFS'
            WHEN ni2.nwi_code IS NOT NULL THEN 'NEW'
            WHEN im_as_ing_2.tasteless_menu_code IS NOT NULL THEN 'MMFF'
            ELSE 'UNKNOWN'
        END AS sub_types_2,

        /* ---------- CODE ---------- */
        COALESCE(
            im_as_ing__batch_2.tasteless_menu_code,
            bs2_line.bi_code,
            ims_batch_2.tasteless_code,
            pi2.reference_number,
            pi_batch_2.reference_number,
            ni_batch_2.nwi_code,
            im_as_ing_2_line.tasteless_menu_code,
            bas_ing_2.bi_code,
            ims2.tasteless_code,
            ni2.nwi_code
        ) AS menu_item_ingredients_code_sub_2,

        /* ---------- DESCRIPTION ---------- */
        COALESCE(
            im_as_ing__batch_2.menu_item_description,
            bs2_line.ingredient_description,
            ims_batch_2.full_item_description,
            pi2.full_item_description,
            pi_batch_2.full_item_description,
            ni_batch_2.item_description,
            im_as_ing_2_line.menu_item_description,
            bas_ing_2.ingredient_description,
            ims2.full_item_description,
            ni2.item_description
        ) AS menu_item_ingredients_description_sub_2,

        /* ---------- PACKAGING ---------- */
        COALESCE(
            ims_batch_2.packaging_size,
            pi2.packaging_size,
            pi_batch_2.packaging_size,
            ni_batch_2.packaging_size,
            ims2.packaging_size,
            ni2.packaging_size,
            1
        ) sub_packaging_size_2,

        /* ---------- QTY ---------- */
        ROUND(
            COALESCE(sub_main_ingr_2.prep_qty, bs2.prep_qty)
            / ROUND((COALESCE(sub_main_ingr_2.yield, bs2.yield) / 100), 4),
            4
        ) AS sub_ingredient_qty_2,

        /* ---------- UOM SMALL UNIT ---------- */
        COALESCE(pack_sub_2.packaging_description, uom_sub_2.uom_description) AS uom_small_unit_sub_2,

        /* ---------- LANDED COST ---------- */
        COALESCE(
            im_as_ing__batch_2.ingredient_total_cost,
            bs2_line.ttp,
            ims_batch_2.landed_cost,
            pi2.landed_cost,
            pi_batch_2.landed_cost,
            ni_batch_2.ttp,
            im_as_ing_2_line.ingredient_total_cost,
            bas_ing_2.ttp,
            ims2.landed_cost,
            ni2.ttp,
            NULL
        ) AS landed_cost_sub_2,

        /* ---------- UOM LARGE UNIT ---------- */
        uom_sub_2.uom_description AS uom_large_unit_sub_2

    FROM m_s_1

    /* ===== Ingredients section ===== */

    /* ===== MENU SUBS ===== */
    LEFT JOIN menu_items im_as_ing_2
        ON im_as_ing_2.tasteless_menu_code = m_s_1.menu_item_ingredients_code_sub_1
       AND m_s_1.sub_types_1 = 'MMFF'

    LEFT JOIN ingredients sub_main_ingr_2
        ON im_as_ing_2.id = sub_main_ingr_2.menu_items_id

    LEFT JOIN menu_items im_as_ing_2_line
        ON im_as_ing_2_line.id = sub_main_ingr_2.menu_as_ingredient_id

    LEFT JOIN batching_ingredients bas_ing_2
        ON bas_ing_2.id = sub_main_ingr_2.batching_ingredients_id

    LEFT JOIN item_masters ims2
        ON ims2.id = sub_main_ingr_2.item_masters_id

    LEFT JOIN production_items pi2
        ON pi2.id = sub_main_ingr_2.production_items_id

    LEFT JOIN new_ingredients ni2
        ON ni2.id = sub_main_ingr_2.new_ingredients_id

    /* ===== BATCH SUBS ===== */
    LEFT JOIN batching_ingredients bs2_header
        ON bs2_header.bi_code = m_s_1.menu_item_ingredients_code_sub_1
       AND m_s_1.sub_types_1 = 'BATCH'

    LEFT JOIN batching_ingredients_details bs2
        ON bs2.batching_ingredients_id = bs2_header.id

    LEFT JOIN batching_ingredients bs2_line
        ON bs2_line.id = bs2.batching_as_ingredient_id

    LEFT JOIN ingredients sub_main_ing_batch_2
        ON sub_main_ing_batch_2.id = bs2.menu_as_ingredient_id

    LEFT JOIN menu_items im_as_ing__batch_2
        ON im_as_ing__batch_2.id = bs2.menu_as_ingredient_id

    LEFT JOIN item_masters ims_batch_2
        ON ims_batch_2.id = bs2.item_masters_id

    LEFT JOIN production_items pi_batch_2
        ON pi_batch_2.id = bs2.production_items_id

    LEFT JOIN new_ingredients ni_batch_2
        ON ni_batch_2.id = bs2.new_ingredients_id

    LEFT JOIN uoms AS uom_sub_2
        ON uom_sub_2.id = COALESCE(
            im_as_ing__batch_2.uoms_id,
            bs2_line.uoms_id,
            ims_batch_2.uoms_id,
            pi2.uoms_id,
            pi_batch_2.uoms_id,
            ni_batch_2.uoms_id,
            im_as_ing_2_line.uoms_id,
            bas_ing_2.uoms_id,
            ims2.uoms_id,
            ni2.uoms_id
        )

    LEFT JOIN packagings AS pack_sub_2
        ON pack_sub_2.id = COALESCE(
            ims_batch_2.packagings_id,
            pi_batch_2.packagings_id,
            ims2.packagings_id,
            pi2.packagings_id
        )
),

m_s_2 AS (
    SELECT
        b.*,
        ROUND((b.sub_ingredient_qty_2 / b.sub_packaging_size_2), 4) AS sku_converted_sub_2,
        ROUND(
            ROUND((b.sub_ingredient_qty_2 / b.sub_packaging_size_2), 4) * b.landed_cost_sub_2,
            4
        ) AS sub_unit_cost_2
    FROM m_s_2_base b
),

m_s_3_base AS (
    SELECT
        m_s_2.*,

        /* ---------- TYPE ---------- */
        CASE
            WHEN im_as_ing__batch_3.tasteless_menu_code IS NOT NULL THEN 'MMFF'
            WHEN bs3_line.bi_code IS NOT NULL THEN 'BATCH'
            WHEN ims_batch_3.tasteless_code IS NOT NULL THEN 'IMFS'
            WHEN pi3.reference_number IS NOT NULL THEN 'PIMFS'
            WHEN pi_batch_3.reference_number IS NOT NULL THEN 'PIMFS'
            WHEN ni_batch_3.nwi_code IS NOT NULL THEN 'NEW'
            WHEN im_as_ing_3_line.tasteless_menu_code IS NOT NULL THEN 'MMFF'
            WHEN bas_ing_3.bi_code IS NOT NULL THEN 'BATCH'
            WHEN ims3.tasteless_code IS NOT NULL THEN 'IMFS'
            WHEN ni3.nwi_code IS NOT NULL THEN 'NEW'
            WHEN im_as_ing_3.tasteless_menu_code IS NOT NULL THEN 'MMFF'
            ELSE 'UNKNOWN'
        END AS sub_types_3,

        /* ---------- CODE ---------- */
        COALESCE(
            im_as_ing__batch_3.tasteless_menu_code,
            bs3_line.bi_code,
            ims_batch_3.tasteless_code,
            pi3.reference_number,
            pi_batch_3.reference_number,
            ni_batch_3.nwi_code,
            im_as_ing_3_line.tasteless_menu_code,
            bas_ing_3.bi_code,
            ims3.tasteless_code,
            ni3.nwi_code
        ) AS menu_item_ingredients_code_sub_3,

        /* ---------- DESCRIPTION ---------- */
        COALESCE(
            im_as_ing__batch_3.menu_item_description,
            bs3_line.ingredient_description,
            ims_batch_3.full_item_description,
            pi3.full_item_description,
            pi_batch_3.full_item_description,
            ni_batch_3.item_description,
            im_as_ing_3_line.menu_item_description,
            bas_ing_3.ingredient_description,
            ims3.full_item_description,
            ni3.item_description
        ) AS menu_item_ingredients_description_sub_3,

        /* ---------- PACKAGING ---------- */
        COALESCE(
            ims_batch_3.packaging_size,
            pi3.packaging_size,
            pi_batch_3.packaging_size,
            ni_batch_3.packaging_size,
            ims3.packaging_size,
            ni3.packaging_size,
            1
        ) sub_packaging_size_3,

        /* ---------- QTY ---------- */
        ROUND(
            COALESCE(sub_main_ingr_3.prep_qty, bs3.prep_qty)
            / ROUND((COALESCE(sub_main_ingr_3.yield, bs3.yield) / 100), 4),
            4
        ) AS sub_ingredient_qty_3,

        /* ---------- UOM SMALL UNIT ---------- */
        COALESCE(pack_sub_3.packaging_description, uom_sub_3.uom_description) AS uom_small_unit_sub_3,

        /* ---------- LANDED COST ---------- */
        COALESCE(
            im_as_ing__batch_3.ingredient_total_cost,
            bs3_line.ttp,
            ims_batch_3.landed_cost,
            pi3.landed_cost,
            pi_batch_3.landed_cost,
            ni_batch_3.ttp,
            im_as_ing_3_line.ingredient_total_cost,
            bas_ing_3.ttp,
            ims3.landed_cost,
            ni3.ttp,
            NULL
        ) AS landed_cost_sub_3,

        /* ---------- UOM LARGE UNIT ---------- */
        uom_sub_3.uom_description AS uom_large_unit_sub_3

    FROM m_s_2

    /* ===== Ingredients section ===== */

    /* ===== MENU SUBS ===== */
    LEFT JOIN menu_items im_as_ing_3
        ON im_as_ing_3.tasteless_menu_code = m_s_2.menu_item_ingredients_code_sub_2
       AND m_s_2.sub_types_2 = 'MMFF'

    LEFT JOIN ingredients sub_main_ingr_3
        ON im_as_ing_3.id = sub_main_ingr_3.menu_items_id

    LEFT JOIN menu_items im_as_ing_3_line
        ON im_as_ing_3_line.id = sub_main_ingr_3.menu_as_ingredient_id

    LEFT JOIN batching_ingredients bas_ing_3
        ON bas_ing_3.id = sub_main_ingr_3.batching_ingredients_id

    LEFT JOIN item_masters ims3
        ON ims3.id = sub_main_ingr_3.item_masters_id

    LEFT JOIN production_items pi3
        ON pi3.id = sub_main_ingr_3.production_items_id

    LEFT JOIN new_ingredients ni3
        ON ni3.id = sub_main_ingr_3.new_ingredients_id

    /* ===== BATCH SUBS ===== */
    LEFT JOIN batching_ingredients bs3_header
        ON bs3_header.bi_code = m_s_2.menu_item_ingredients_code_sub_2
       AND m_s_2.sub_types_2 = 'BATCH'

    LEFT JOIN batching_ingredients_details bs3
        ON bs3.batching_ingredients_id = bs3_header.id

    LEFT JOIN batching_ingredients bs3_line
        ON bs3_line.id = bs3.batching_as_ingredient_id

    LEFT JOIN ingredients sub_main_ing_batch_3
        ON sub_main_ing_batch_3.id = bs3.menu_as_ingredient_id

    LEFT JOIN menu_items im_as_ing__batch_3
        ON im_as_ing__batch_3.id = bs3.menu_as_ingredient_id

    LEFT JOIN item_masters ims_batch_3
        ON ims_batch_3.id = bs3.item_masters_id

    LEFT JOIN production_items pi_batch_3
        ON pi_batch_3.id = bs3.production_items_id

    LEFT JOIN new_ingredients ni_batch_3
        ON ni_batch_3.id = bs3.new_ingredients_id

    LEFT JOIN uoms AS uom_sub_3
        ON uom_sub_3.id = COALESCE(
            im_as_ing__batch_3.uoms_id,
            bs3_line.uoms_id,
            ims_batch_3.uoms_id,
            pi3.uoms_id,
            pi_batch_3.uoms_id,
            ni_batch_3.uoms_id,
            im_as_ing_3_line.uoms_id,
            bas_ing_3.uoms_id,
            ims3.uoms_id,
            ni3.uoms_id
        )

    LEFT JOIN packagings AS pack_sub_3
        ON pack_sub_3.id = COALESCE(
            ims_batch_3.packagings_id,
            pi_batch_3.packagings_id,
            ims3.packagings_id,
            pi3.packagings_id
        )
),

m_s_3 AS (
    SELECT
        b.*,
        ROUND((b.sub_ingredient_qty_3 / b.sub_packaging_size_3), 4) AS sku_converted_sub_3,
        ROUND(
            ROUND((b.sub_ingredient_qty_3 / b.sub_packaging_size_3), 4) * b.landed_cost_sub_3,
            4
        ) AS sub_unit_cost_3
    FROM m_s_3_base b
),

m_s_4_base AS (
    SELECT
        m_s_3.*,

        /* ---------- TYPE ---------- */
        CASE
            WHEN im_as_ing__batch_4.tasteless_menu_code IS NOT NULL THEN 'MMFF'
            WHEN bs4_line.bi_code IS NOT NULL THEN 'BATCH'
            WHEN ims_batch_4.tasteless_code IS NOT NULL THEN 'IMFS'
            WHEN pi4.reference_number IS NOT NULL THEN 'PIMFS'
            WHEN pi_batch_4.reference_number IS NOT NULL THEN 'PIMFS'
            WHEN ni_batch_4.nwi_code IS NOT NULL THEN 'NEW'
            WHEN im_as_ing_4_line.tasteless_menu_code IS NOT NULL THEN 'MMFF'
            WHEN bas_ing_4.bi_code IS NOT NULL THEN 'BATCH'
            WHEN ims4.tasteless_code IS NOT NULL THEN 'IMFS'
            WHEN ni4.nwi_code IS NOT NULL THEN 'NEW'
            WHEN im_as_ing_4.tasteless_menu_code IS NOT NULL THEN 'MMFF'
            ELSE 'UNKNOWN'
        END AS sub_types_4,

        /* ---------- CODE ---------- */
        COALESCE(
            im_as_ing__batch_4.tasteless_menu_code,
            bs4_line.bi_code,
            ims_batch_4.tasteless_code,
            pi4.reference_number,
            pi_batch_4.reference_number,
            ni_batch_4.nwi_code,
            im_as_ing_4_line.tasteless_menu_code,
            bas_ing_4.bi_code,
            ims4.tasteless_code,
            ni4.nwi_code
        ) AS menu_item_ingredients_code_sub_4,

        /* ---------- DESCRIPTION ---------- */
        COALESCE(
            im_as_ing__batch_4.menu_item_description,
            bs4_line.ingredient_description,
            ims_batch_4.full_item_description,
            pi4.full_item_description,
            pi_batch_4.full_item_description,
            ni_batch_4.item_description,
            im_as_ing_4_line.menu_item_description,
            bas_ing_4.ingredient_description,
            ims4.full_item_description,
            ni4.item_description
        ) AS menu_item_ingredients_description_sub_4,

        /* ---------- PACKAGING ---------- */
        COALESCE(
            ims_batch_4.packaging_size,
            pi4.packaging_size,
            pi_batch_4.packaging_size,
            ni_batch_4.packaging_size,
            ims4.packaging_size,
            ni4.packaging_size,
            1
        ) sub_packaging_size_4,

        /* ---------- QTY ---------- */
        ROUND(
            COALESCE(sub_main_ingr_4.prep_qty, bs4.prep_qty)
            / ROUND((COALESCE(sub_main_ingr_4.yield, bs4.yield) / 100), 4),
            4
        ) AS sub_ingredient_qty_4,

        /* ---------- UOM SMALL UNIT ---------- */
        COALESCE(pack_sub_4.packaging_description, uom_sub_4.uom_description) AS uom_small_unit_sub_4,

        /* ---------- LANDED COST ---------- */
        COALESCE(
            im_as_ing__batch_4.ingredient_total_cost,
            bs4_line.ttp,
            ims_batch_4.landed_cost,
            pi4.landed_cost,
            pi_batch_4.landed_cost,
            ni_batch_4.ttp,
            im_as_ing_4_line.ingredient_total_cost,
            bas_ing_4.ttp,
            ims4.landed_cost,
            ni4.ttp,
            NULL
        ) AS landed_cost_sub_4,

        /* ---------- UOM LARGE UNIT ---------- */
        uom_sub_4.uom_description AS uom_large_unit_sub_4

    FROM m_s_3

    /* ===== Ingredients section ===== */

    /* ===== MENU SUBS ===== */
    LEFT JOIN menu_items im_as_ing_4
        ON im_as_ing_4.tasteless_menu_code = m_s_3.menu_item_ingredients_code_sub_3
       AND m_s_3.sub_types_3 = 'MMFF'

    LEFT JOIN ingredients sub_main_ingr_4
        ON im_as_ing_4.id = sub_main_ingr_4.menu_items_id

    LEFT JOIN menu_items im_as_ing_4_line
        ON im_as_ing_4_line.id = sub_main_ingr_4.menu_as_ingredient_id

    LEFT JOIN batching_ingredients bas_ing_4
        ON bas_ing_4.id = sub_main_ingr_4.batching_ingredients_id

    LEFT JOIN item_masters ims4
        ON ims4.id = sub_main_ingr_4.item_masters_id

    LEFT JOIN production_items pi4
        ON pi4.id = sub_main_ingr_4.production_items_id

    LEFT JOIN new_ingredients ni4
        ON ni4.id = sub_main_ingr_4.new_ingredients_id

    /* ===== BATCH SUBS ===== */
    LEFT JOIN batching_ingredients bs4_header
        ON bs4_header.bi_code = m_s_3.menu_item_ingredients_code_sub_3
       AND m_s_3.sub_types_3 = 'BATCH'

    LEFT JOIN batching_ingredients_details bs4
        ON bs4.batching_ingredients_id = bs4_header.id

    LEFT JOIN batching_ingredients bs4_line
        ON bs4_line.id = bs4.batching_as_ingredient_id

    LEFT JOIN ingredients sub_main_ing_batch_4
        ON sub_main_ing_batch_4.id = bs4.menu_as_ingredient_id

    LEFT JOIN menu_items im_as_ing__batch_4
        ON im_as_ing__batch_4.id = bs4.menu_as_ingredient_id

    LEFT JOIN item_masters ims_batch_4
        ON ims_batch_4.id = bs4.item_masters_id

    LEFT JOIN production_items pi_batch_4
        ON pi_batch_4.id = bs4.production_items_id

    LEFT JOIN new_ingredients ni_batch_4
        ON ni_batch_4.id = bs4.new_ingredients_id

    LEFT JOIN uoms AS uom_sub_4
        ON uom_sub_4.id = COALESCE(
            im_as_ing__batch_4.uoms_id,
            bs4_line.uoms_id,
            ims_batch_4.uoms_id,
            pi4.uoms_id,
            pi_batch_4.uoms_id,
            ni_batch_4.uoms_id,
            im_as_ing_4_line.uoms_id,
            bas_ing_4.uoms_id,
            ims4.uoms_id,
            ni4.uoms_id
        )

    LEFT JOIN packagings AS pack_sub_4
        ON pack_sub_4.id = COALESCE(
            ims_batch_4.packagings_id,
            pi_batch_4.packagings_id,
            ims4.packagings_id,
            pi4.packagings_id
        )
),

m_s_4 AS (
    SELECT
        b.*,
        ROUND((b.sub_ingredient_qty_4 / b.sub_packaging_size_4), 4) AS sku_converted_sub_4,
        ROUND(
            ROUND((b.sub_ingredient_qty_4 / b.sub_packaging_size_4), 4) * b.landed_cost_sub_4,
            4
        ) AS sub_unit_cost_4
    FROM m_s_4_base b
),

m_s_5_base AS (
    SELECT
        m_s_4.*,

        /* ---------- TYPE ---------- */
        CASE
            WHEN im_as_ing__batch_5.tasteless_menu_code IS NOT NULL THEN 'MMFF'
            WHEN bs5_line.bi_code IS NOT NULL THEN 'BATCH'
            WHEN ims_batch_5.tasteless_code IS NOT NULL THEN 'IMFS'
            WHEN pi5.reference_number IS NOT NULL THEN 'PIMFS'
            WHEN pi_batch_5.reference_number IS NOT NULL THEN 'PIMFS'
            WHEN ni_batch_5.nwi_code IS NOT NULL THEN 'NEW'
            WHEN im_as_ing_5_line.tasteless_menu_code IS NOT NULL THEN 'MMFF'
            WHEN bas_ing_5.bi_code IS NOT NULL THEN 'BATCH'
            WHEN ims5.tasteless_code IS NOT NULL THEN 'IMFS'
            WHEN ni5.nwi_code IS NOT NULL THEN 'NEW'
            WHEN im_as_ing_5.tasteless_menu_code IS NOT NULL THEN 'MMFF'
            ELSE 'UNKNOWN'
        END AS sub_types_5,

        /* ---------- CODE ---------- */
        COALESCE(
            im_as_ing__batch_5.tasteless_menu_code,
            bs5_line.bi_code,
            ims_batch_5.tasteless_code,
            pi5.reference_number,
            pi_batch_5.reference_number,
            ni_batch_5.nwi_code,
            im_as_ing_5_line.tasteless_menu_code,
            bas_ing_5.bi_code,
            ims5.tasteless_code,
            ni5.nwi_code
        ) AS menu_item_ingredients_code_sub_5,

        /* ---------- DESCRIPTION ---------- */
        COALESCE(
            im_as_ing__batch_5.menu_item_description,
            bs5_line.ingredient_description,
            ims_batch_5.full_item_description,
            pi5.full_item_description,
            pi_batch_5.full_item_description,
            ni_batch_5.item_description,
            im_as_ing_5_line.menu_item_description,
            bas_ing_5.ingredient_description,
            ims5.full_item_description,
            ni5.item_description
        ) AS menu_item_ingredients_description_sub_5,

        /* ---------- PACKAGING ---------- */
        COALESCE(
            ims_batch_5.packaging_size,
            pi5.packaging_size,
            pi_batch_5.packaging_size,
            ni_batch_5.packaging_size,
            ims5.packaging_size,
            ni5.packaging_size,
            1
        ) sub_packaging_size_5,

        /* ---------- QTY ---------- */
        ROUND(
            COALESCE(sub_main_ingr_5.prep_qty, bs5.prep_qty)
            / ROUND((COALESCE(sub_main_ingr_5.yield, bs5.yield) / 100), 4),
            4
        ) AS sub_ingredient_qty_5,

        /* ---------- UOM SMALL UNIT ---------- */
        COALESCE(pack_sub_5.packaging_description, uom_sub_5.uom_description) AS uom_small_unit_sub_5,

        /* ---------- LANDED COST ---------- */
        COALESCE(
            im_as_ing__batch_5.ingredient_total_cost,
            bs5_line.ttp,
            ims_batch_5.landed_cost,
            pi5.landed_cost,
            pi_batch_5.landed_cost,
            ni_batch_5.ttp,
            im_as_ing_5_line.ingredient_total_cost,
            bas_ing_5.ttp,
            ims5.landed_cost,
            ni5.ttp,
            NULL
        ) AS landed_cost_sub_5,

        /* ---------- UOM LARGE UNIT ---------- */
        uom_sub_5.uom_description AS uom_large_unit_sub_5

    FROM m_s_4

    /* ===== Ingredients section ===== */

    /* ===== MENU SUBS ===== */
    LEFT JOIN menu_items im_as_ing_5
        ON im_as_ing_5.tasteless_menu_code = m_s_4.menu_item_ingredients_code_sub_4
       AND m_s_4.sub_types_4 = 'MMFF'

    LEFT JOIN ingredients sub_main_ingr_5
        ON im_as_ing_5.id = sub_main_ingr_5.menu_items_id

    LEFT JOIN menu_items im_as_ing_5_line
        ON im_as_ing_5_line.id = sub_main_ingr_5.menu_as_ingredient_id

    LEFT JOIN batching_ingredients bas_ing_5
        ON bas_ing_5.id = sub_main_ingr_5.batching_ingredients_id

    LEFT JOIN item_masters ims5
        ON ims5.id = sub_main_ingr_5.item_masters_id

    LEFT JOIN production_items pi5
        ON pi5.id = sub_main_ingr_5.production_items_id

    LEFT JOIN new_ingredients ni5
        ON ni5.id = sub_main_ingr_5.new_ingredients_id

    /* ===== BATCH SUBS ===== */
    LEFT JOIN batching_ingredients bs5_header
        ON bs5_header.bi_code = m_s_4.menu_item_ingredients_code_sub_4
       AND m_s_4.sub_types_4 = 'BATCH'

    LEFT JOIN batching_ingredients_details bs5
        ON bs5.batching_ingredients_id = bs5_header.id

    LEFT JOIN batching_ingredients bs5_line
        ON bs5_line.id = bs5.batching_as_ingredient_id

    LEFT JOIN ingredients sub_main_ing_batch_5
        ON sub_main_ing_batch_5.id = bs5.menu_as_ingredient_id

    LEFT JOIN menu_items im_as_ing__batch_5
        ON im_as_ing__batch_5.id = bs5.menu_as_ingredient_id

    LEFT JOIN item_masters ims_batch_5
        ON ims_batch_5.id = bs5.item_masters_id

    LEFT JOIN production_items pi_batch_5
        ON pi_batch_5.id = bs5.production_items_id

    LEFT JOIN new_ingredients ni_batch_5
        ON ni_batch_5.id = bs5.new_ingredients_id

    LEFT JOIN uoms AS uom_sub_5
        ON uom_sub_5.id = COALESCE(
            im_as_ing__batch_5.uoms_id,
            bs5_line.uoms_id,
            ims_batch_5.uoms_id,
            pi5.uoms_id,
            pi_batch_5.uoms_id,
            ni_batch_5.uoms_id,
            im_as_ing_5_line.uoms_id,
            bas_ing_5.uoms_id,
            ims5.uoms_id,
            ni5.uoms_id
        )

    LEFT JOIN packagings AS pack_sub_5
        ON pack_sub_5.id = COALESCE(
            ims_batch_5.packagings_id,
            pi_batch_5.packagings_id,
            ims5.packagings_id,
            pi5.packagings_id
        )
),

m_s_5 AS (
    SELECT
        b.*,
        ROUND((b.sub_ingredient_qty_5 / b.sub_packaging_size_5), 4) AS sku_converted_sub_5,
        ROUND(
            ROUND((b.sub_ingredient_qty_5 / b.sub_packaging_size_5), 4) * b.landed_cost_sub_5,
            4
        ) AS sub_unit_cost_5
    FROM m_s_5_base b
),

m_s_6_base AS (
    SELECT
        m_s_5.*,

        /* ---------- TYPE ---------- */
        CASE
            WHEN im_as_ing__batch_6.tasteless_menu_code IS NOT NULL THEN 'MMFF'
            WHEN bs6_line.bi_code IS NOT NULL THEN 'BATCH'
            WHEN ims_batch_6.tasteless_code IS NOT NULL THEN 'IMFS'
            WHEN pi6.reference_number IS NOT NULL THEN 'PIMFS'
            WHEN pi_batch_6.reference_number IS NOT NULL THEN 'PIMFS'
            WHEN ni_batch_6.nwi_code IS NOT NULL THEN 'NEW'
            WHEN im_as_ing_6_line.tasteless_menu_code IS NOT NULL THEN 'MMFF'
            WHEN bas_ing_6.bi_code IS NOT NULL THEN 'BATCH'
            WHEN ims6.tasteless_code IS NOT NULL THEN 'IMFS'
            WHEN ni6.nwi_code IS NOT NULL THEN 'NEW'
            WHEN im_as_ing_6.tasteless_menu_code IS NOT NULL THEN 'MMFF'
            ELSE 'UNKNOWN'
        END AS sub_types_6,

        /* ---------- CODE ---------- */
        COALESCE(
            im_as_ing__batch_6.tasteless_menu_code,
            bs6_line.bi_code,
            ims_batch_6.tasteless_code,
            pi6.reference_number,
            pi_batch_6.reference_number,
            ni_batch_6.nwi_code,
            im_as_ing_6_line.tasteless_menu_code,
            bas_ing_6.bi_code,
            ims6.tasteless_code,
            ni6.nwi_code
        ) AS menu_item_ingredients_code_sub_6,

        /* ---------- DESCRIPTION ---------- */
        COALESCE(
            im_as_ing__batch_6.menu_item_description,
            bs6_line.ingredient_description,
            ims_batch_6.full_item_description,
            pi6.full_item_description,
            pi_batch_6.full_item_description,
            ni_batch_6.item_description,
            im_as_ing_6_line.menu_item_description,
            bas_ing_6.ingredient_description,
            ims6.full_item_description,
            ni6.item_description
        ) AS menu_item_ingredients_description_sub_6,

        /* ---------- PACKAGING ---------- */
        COALESCE(
            ims_batch_6.packaging_size,
            pi6.packaging_size,
            pi_batch_6.packaging_size,
            ni_batch_6.packaging_size,
            ims6.packaging_size,
            ni6.packaging_size,
            1
        ) sub_packaging_size_6,

        /* ---------- QTY ---------- */
        ROUND(
            COALESCE(sub_main_ingr_6.prep_qty, bs6.prep_qty)
            / ROUND((COALESCE(sub_main_ingr_6.yield, bs6.yield) / 100), 4),
            4
        ) AS sub_ingredient_qty_6,

        /* ---------- UOM SMALL UNIT ---------- */
        COALESCE(pack_sub_6.packaging_description, uom_sub_6.uom_description) AS uom_small_unit_sub_6,

        /* ---------- LANDED COST ---------- */
        COALESCE(
            im_as_ing__batch_6.ingredient_total_cost,
            bs6_line.ttp,
            ims_batch_6.landed_cost,
            pi6.landed_cost,
            pi_batch_6.landed_cost,
            ni_batch_6.ttp,
            im_as_ing_6_line.ingredient_total_cost,
            bas_ing_6.ttp,
            ims6.landed_cost,
            ni6.ttp,
            NULL
        ) AS landed_cost_sub_6,

        /* ---------- UOM LARGE UNIT ---------- */
        uom_sub_6.uom_description AS uom_large_unit_sub_6

    FROM m_s_5

    /* ===== Ingredients section ===== */

    /* ===== MENU SUBS ===== */
    LEFT JOIN menu_items im_as_ing_6
        ON im_as_ing_6.tasteless_menu_code = m_s_5.menu_item_ingredients_code_sub_5
       AND m_s_5.sub_types_5 = 'MMFF'

    LEFT JOIN ingredients sub_main_ingr_6
        ON im_as_ing_6.id = sub_main_ingr_6.menu_items_id

    LEFT JOIN menu_items im_as_ing_6_line
        ON im_as_ing_6_line.id = sub_main_ingr_6.menu_as_ingredient_id

    LEFT JOIN batching_ingredients bas_ing_6
        ON bas_ing_6.id = sub_main_ingr_6.batching_ingredients_id

    LEFT JOIN item_masters ims6
        ON ims6.id = sub_main_ingr_6.item_masters_id

    LEFT JOIN production_items pi6
        ON pi6.id = sub_main_ingr_6.production_items_id

    LEFT JOIN new_ingredients ni6
        ON ni6.id = sub_main_ingr_6.new_ingredients_id

    /* ===== BATCH SUBS ===== */
    LEFT JOIN batching_ingredients bs6_header
        ON bs6_header.bi_code = m_s_5.menu_item_ingredients_code_sub_5
       AND m_s_5.sub_types_5 = 'BATCH'

    LEFT JOIN batching_ingredients_details bs6
        ON bs6.batching_ingredients_id = bs6_header.id

    LEFT JOIN batching_ingredients bs6_line
        ON bs6_line.id = bs6.batching_as_ingredient_id

    LEFT JOIN ingredients sub_main_ing_batch_6
        ON sub_main_ing_batch_6.id = bs6.menu_as_ingredient_id

    LEFT JOIN menu_items im_as_ing__batch_6
        ON im_as_ing__batch_6.id = bs6.menu_as_ingredient_id

    LEFT JOIN item_masters ims_batch_6
        ON ims_batch_6.id = bs6.item_masters_id

    LEFT JOIN production_items pi_batch_6
        ON pi_batch_6.id = bs6.production_items_id

    LEFT JOIN new_ingredients ni_batch_6
        ON ni_batch_6.id = bs6.new_ingredients_id

    LEFT JOIN uoms AS uom_sub_6
        ON uom_sub_6.id = COALESCE(
            im_as_ing__batch_6.uoms_id,
            bs6_line.uoms_id,
            ims_batch_6.uoms_id,
            pi6.uoms_id,
            pi_batch_6.uoms_id,
            ni_batch_6.uoms_id,
            im_as_ing_6_line.uoms_id,
            bas_ing_6.uoms_id,
            ims6.uoms_id,
            ni6.uoms_id
        )

    LEFT JOIN packagings AS pack_sub_6
        ON pack_sub_6.id = COALESCE(
            ims_batch_6.packagings_id,
            pi_batch_6.packagings_id,
            ims6.packagings_id,
            pi6.packagings_id
        )
),

m_s_6 AS (
    SELECT
        b.*,
        ROUND((b.sub_ingredient_qty_6 / b.sub_packaging_size_6), 4) AS sku_converted_sub_6,
        ROUND(
            ROUND((b.sub_ingredient_qty_6 / b.sub_packaging_size_6), 4) * b.landed_cost_sub_6,
            4
        ) AS sub_unit_cost_6
    FROM m_s_6_base b
),

m_s_7_base AS (
    SELECT
        m_s_6.*,

        /* ---------- TYPE ---------- */
        CASE
            WHEN im_as_ing__batch_7.tasteless_menu_code IS NOT NULL THEN 'MMFF'
            WHEN bs7_line.bi_code IS NOT NULL THEN 'BATCH'
            WHEN ims_batch_7.tasteless_code IS NOT NULL THEN 'IMFS'
            WHEN pi7.reference_number IS NOT NULL THEN 'PIMFS'
            WHEN pi_batch_7.reference_number IS NOT NULL THEN 'PIMFS'
            WHEN ni_batch_7.nwi_code IS NOT NULL THEN 'NEW'
            WHEN im_as_ing_7_line.tasteless_menu_code IS NOT NULL THEN 'MMFF'
            WHEN bas_ing_7.bi_code IS NOT NULL THEN 'BATCH'
            WHEN ims7.tasteless_code IS NOT NULL THEN 'IMFS'
            WHEN ni7.nwi_code IS NOT NULL THEN 'NEW'
            WHEN im_as_ing_7.tasteless_menu_code IS NOT NULL THEN 'MMFF'
            ELSE 'UNKNOWN'
        END AS sub_types_7,

        /* ---------- CODE ---------- */
        COALESCE(
            im_as_ing__batch_7.tasteless_menu_code,
            bs7_line.bi_code,
            ims_batch_7.tasteless_code,
            pi7.reference_number,
            pi_batch_7.reference_number,
            ni_batch_7.nwi_code,
            im_as_ing_7_line.tasteless_menu_code,
            bas_ing_7.bi_code,
            ims7.tasteless_code,
            ni7.nwi_code
        ) AS menu_item_ingredients_code_sub_7,

        /* ---------- DESCRIPTION ---------- */
        COALESCE(
            im_as_ing__batch_7.menu_item_description,
            bs7_line.ingredient_description,
            ims_batch_7.full_item_description,
            pi7.full_item_description,
            pi_batch_7.full_item_description,
            ni_batch_7.item_description,
            im_as_ing_7_line.menu_item_description,
            bas_ing_7.ingredient_description,
            ims7.full_item_description,
            ni7.item_description
        ) AS menu_item_ingredients_description_sub_7,

        /* ---------- PACKAGING ---------- */
        COALESCE(
            ims_batch_7.packaging_size,
            pi7.packaging_size,
            pi_batch_7.packaging_size,
            ni_batch_7.packaging_size,
            ims7.packaging_size,
            ni7.packaging_size,
            1
        ) sub_packaging_size_7,

        /* ---------- QTY ---------- */
        ROUND(
            COALESCE(sub_main_ingr_7.prep_qty, bs7.prep_qty)
            / ROUND((COALESCE(sub_main_ingr_7.yield, bs7.yield) / 100), 4),
            4
        ) AS sub_ingredient_qty_7,

        /* ---------- UOM SMALL UNIT ---------- */
        COALESCE(pack_sub_7.packaging_description, uom_sub_7.uom_description) AS uom_small_unit_sub_7,

        /* ---------- LANDED COST ---------- */
        COALESCE(
            im_as_ing__batch_7.ingredient_total_cost,
            bs7_line.ttp,
            ims_batch_7.landed_cost,
            pi7.landed_cost,
            pi_batch_7.landed_cost,
            ni_batch_7.ttp,
            im_as_ing_7_line.ingredient_total_cost,
            bas_ing_7.ttp,
            ims7.landed_cost,
            ni7.ttp,
            NULL
        ) AS landed_cost_sub_7,

        /* ---------- UOM LARGE UNIT ---------- */
        uom_sub_7.uom_description AS uom_large_unit_sub_7

    FROM m_s_6

    /* ===== Ingredients section ===== */

    /* ===== MENU SUBS ===== */
    LEFT JOIN menu_items im_as_ing_7
        ON im_as_ing_7.tasteless_menu_code = m_s_6.menu_item_ingredients_code_sub_6
       AND m_s_6.sub_types_6 = 'MMFF'

    LEFT JOIN ingredients sub_main_ingr_7
        ON im_as_ing_7.id = sub_main_ingr_7.menu_items_id

    LEFT JOIN menu_items im_as_ing_7_line
        ON im_as_ing_7_line.id = sub_main_ingr_7.menu_as_ingredient_id

    LEFT JOIN batching_ingredients bas_ing_7
        ON bas_ing_7.id = sub_main_ingr_7.batching_ingredients_id

    LEFT JOIN item_masters ims7
        ON ims7.id = sub_main_ingr_7.item_masters_id

    LEFT JOIN production_items pi7
        ON pi7.id = sub_main_ingr_7.production_items_id

    LEFT JOIN new_ingredients ni7
        ON ni7.id = sub_main_ingr_7.new_ingredients_id

    /* ===== BATCH SUBS ===== */
    LEFT JOIN batching_ingredients bs7_header
        ON bs7_header.bi_code = m_s_6.menu_item_ingredients_code_sub_6
       AND m_s_6.sub_types_6 = 'BATCH'

    LEFT JOIN batching_ingredients_details bs7
        ON bs7.batching_ingredients_id = bs7_header.id

    LEFT JOIN batching_ingredients bs7_line
        ON bs7_line.id = bs7.batching_as_ingredient_id

    LEFT JOIN ingredients sub_main_ing_batch_7
        ON sub_main_ing_batch_7.id = bs7.menu_as_ingredient_id

    LEFT JOIN menu_items im_as_ing__batch_7
        ON im_as_ing__batch_7.id = bs7.menu_as_ingredient_id

    LEFT JOIN item_masters ims_batch_7
        ON ims_batch_7.id = bs7.item_masters_id

    LEFT JOIN production_items pi_batch_7
        ON pi_batch_7.id = bs7.production_items_id

    LEFT JOIN new_ingredients ni_batch_7
        ON ni_batch_7.id = bs7.new_ingredients_id

    LEFT JOIN uoms AS uom_sub_7
        ON uom_sub_7.id = COALESCE(
            im_as_ing__batch_7.uoms_id,
            bs7_line.uoms_id,
            ims_batch_7.uoms_id,
            pi7.uoms_id,
            pi_batch_7.uoms_id,
            ni_batch_7.uoms_id,
            im_as_ing_7_line.uoms_id,
            bas_ing_7.uoms_id,
            ims7.uoms_id,
            ni7.uoms_id
        )

    LEFT JOIN packagings AS pack_sub_7
        ON pack_sub_7.id = COALESCE(
            ims_batch_7.packagings_id,
            pi_batch_7.packagings_id,
            ims7.packagings_id,
            pi7.packagings_id
        )
),

m_s_7 AS (
    SELECT
        b.*,
        ROUND((b.sub_ingredient_qty_7 / b.sub_packaging_size_7), 4) AS sku_converted_sub_7,
        ROUND(
            ROUND((b.sub_ingredient_qty_7 / b.sub_packaging_size_7), 4) * b.landed_cost_sub_7,
            4
        ) AS sub_unit_cost_7
    FROM m_s_7_base b
),

m_s_8_base AS (
    SELECT
        m_s_7.*,

        /* ---------- TYPE ---------- */
        CASE
            WHEN im_as_ing__batch_8.tasteless_menu_code IS NOT NULL THEN 'MMFF'
            WHEN bs8_line.bi_code IS NOT NULL THEN 'BATCH'
            WHEN ims_batch_8.tasteless_code IS NOT NULL THEN 'IMFS'
            WHEN pi8.reference_number IS NOT NULL THEN 'PIMFS'
            WHEN pi_batch_8.reference_number IS NOT NULL THEN 'PIMFS'
            WHEN ni_batch_8.nwi_code IS NOT NULL THEN 'NEW'
            WHEN im_as_ing_8_line.tasteless_menu_code IS NOT NULL THEN 'MMFF'
            WHEN bas_ing_8.bi_code IS NOT NULL THEN 'BATCH'
            WHEN ims8.tasteless_code IS NOT NULL THEN 'IMFS'
            WHEN ni8.nwi_code IS NOT NULL THEN 'NEW'
            WHEN im_as_ing_8.tasteless_menu_code IS NOT NULL THEN 'MMFF'
            ELSE 'UNKNOWN'
        END AS sub_types_8,

        /* ---------- CODE ---------- */
        COALESCE(
            im_as_ing__batch_8.tasteless_menu_code,
            bs8_line.bi_code,
            ims_batch_8.tasteless_code,
            pi8.reference_number,
            pi_batch_8.reference_number,
            ni_batch_8.nwi_code,
            im_as_ing_8_line.tasteless_menu_code,
            bas_ing_8.bi_code,
            ims8.tasteless_code,
            ni8.nwi_code
        ) AS menu_item_ingredients_code_sub_8,

        /* ---------- DESCRIPTION ---------- */
        COALESCE(
            im_as_ing__batch_8.menu_item_description,
            bs8_line.ingredient_description,
            ims_batch_8.full_item_description,
            pi8.full_item_description,
            pi_batch_8.full_item_description,
            ni_batch_8.item_description,
            im_as_ing_8_line.menu_item_description,
            bas_ing_8.ingredient_description,
            ims8.full_item_description,
            ni8.item_description
        ) AS menu_item_ingredients_description_sub_8,

        /* ---------- PACKAGING ---------- */
        COALESCE(
            ims_batch_8.packaging_size,
            pi8.packaging_size,
            pi_batch_8.packaging_size,
            ni_batch_8.packaging_size,
            ims8.packaging_size,
            ni8.packaging_size,
            1
        ) sub_packaging_size_8,

        /* ---------- QTY ---------- */
        ROUND(
            COALESCE(sub_main_ingr_8.prep_qty, bs8.prep_qty)
            / ROUND((COALESCE(sub_main_ingr_8.yield, bs8.yield) / 100), 4),
            4
        ) AS sub_ingredient_qty_8,

        /* ---------- UOM SMALL UNIT ---------- */
        COALESCE(pack_sub_8.packaging_description, uom_sub_8.uom_description) AS uom_small_unit_sub_8,

        /* ---------- LANDED COST ---------- */
        COALESCE(
            im_as_ing__batch_8.ingredient_total_cost,
            bs8_line.ttp,
            ims_batch_8.landed_cost,
            pi8.landed_cost,
            pi_batch_8.landed_cost,
            ni_batch_8.ttp,
            im_as_ing_8_line.ingredient_total_cost,
            bas_ing_8.ttp,
            ims8.landed_cost,
            ni8.ttp,
            NULL
        ) AS landed_cost_sub_8,

        /* ---------- UOM LARGE UNIT ---------- */
        uom_sub_8.uom_description AS uom_large_unit_sub_8

    FROM m_s_7

    /* ===== Ingredients section ===== */

    /* ===== MENU SUBS ===== */
    LEFT JOIN menu_items im_as_ing_8
        ON im_as_ing_8.tasteless_menu_code = m_s_7.menu_item_ingredients_code_sub_7
       AND m_s_7.sub_types_7 = 'MMFF'

    LEFT JOIN ingredients sub_main_ingr_8
        ON im_as_ing_8.id = sub_main_ingr_8.menu_items_id

    LEFT JOIN menu_items im_as_ing_8_line
        ON im_as_ing_8_line.id = sub_main_ingr_8.menu_as_ingredient_id

    LEFT JOIN batching_ingredients bas_ing_8
        ON bas_ing_8.id = sub_main_ingr_8.batching_ingredients_id

    LEFT JOIN item_masters ims8
        ON ims8.id = sub_main_ingr_8.item_masters_id

    LEFT JOIN production_items pi8
        ON pi8.id = sub_main_ingr_8.production_items_id

    LEFT JOIN new_ingredients ni8
        ON ni8.id = sub_main_ingr_8.new_ingredients_id

    /* ===== BATCH SUBS ===== */
    LEFT JOIN batching_ingredients bs8_header
        ON bs8_header.bi_code = m_s_7.menu_item_ingredients_code_sub_7
       AND m_s_7.sub_types_7 = 'BATCH'

    LEFT JOIN batching_ingredients_details bs8
        ON bs8.batching_ingredients_id = bs8_header.id

    LEFT JOIN batching_ingredients bs8_line
        ON bs8_line.id = bs8.batching_as_ingredient_id

    LEFT JOIN ingredients sub_main_ing_batch_8
        ON sub_main_ing_batch_8.id = bs8.menu_as_ingredient_id

    LEFT JOIN menu_items im_as_ing__batch_8
        ON im_as_ing__batch_8.id = bs8.menu_as_ingredient_id

    LEFT JOIN item_masters ims_batch_8
        ON ims_batch_8.id = bs8.item_masters_id

    LEFT JOIN production_items pi_batch_8
        ON pi_batch_8.id = bs8.production_items_id

    LEFT JOIN new_ingredients ni_batch_8
        ON ni_batch_8.id = bs8.new_ingredients_id

    LEFT JOIN uoms AS uom_sub_8
        ON uom_sub_8.id = COALESCE(
            im_as_ing__batch_8.uoms_id,
            bs8_line.uoms_id,
            ims_batch_8.uoms_id,
            pi8.uoms_id,
            pi_batch_8.uoms_id,
            ni_batch_8.uoms_id,
            im_as_ing_8_line.uoms_id,
            bas_ing_8.uoms_id,
            ims8.uoms_id,
            ni8.uoms_id
        )

    LEFT JOIN packagings AS pack_sub_8
        ON pack_sub_8.id = COALESCE(
            ims_batch_8.packagings_id,
            pi_batch_8.packagings_id,
            ims8.packagings_id,
            pi8.packagings_id
        )
),

m_s_8 AS (
    SELECT
        b.*,
        ROUND((b.sub_ingredient_qty_8 / b.sub_packaging_size_8), 4) AS sku_converted_sub_8,
        ROUND(
            ROUND((b.sub_ingredient_qty_8 / b.sub_packaging_size_8), 4) * b.landed_cost_sub_8,
            4
        ) AS sub_unit_cost_8
    FROM m_s_8_base b
),

m_s_9_base AS (
    SELECT
        m_s_8.*,

        /* ---------- TYPE ---------- */
        CASE
            WHEN im_as_ing__batch_9.tasteless_menu_code IS NOT NULL THEN 'MMFF'
            WHEN bs9_line.bi_code IS NOT NULL THEN 'BATCH'
            WHEN ims_batch_9.tasteless_code IS NOT NULL THEN 'IMFS'
            WHEN pi9.reference_number IS NOT NULL THEN 'PIMFS'
            WHEN pi_batch_9.reference_number IS NOT NULL THEN 'PIMFS'
            WHEN ni_batch_9.nwi_code IS NOT NULL THEN 'NEW'
            WHEN im_as_ing_9_line.tasteless_menu_code IS NOT NULL THEN 'MMFF'
            WHEN bas_ing_9.bi_code IS NOT NULL THEN 'BATCH'
            WHEN ims9.tasteless_code IS NOT NULL THEN 'IMFS'
            WHEN ni9.nwi_code IS NOT NULL THEN 'NEW'
            WHEN im_as_ing_9.tasteless_menu_code IS NOT NULL THEN 'MMFF'
            ELSE 'UNKNOWN'
        END AS sub_types_9,

        /* ---------- CODE ---------- */
        COALESCE(
            im_as_ing__batch_9.tasteless_menu_code,
            bs9_line.bi_code,
            ims_batch_9.tasteless_code,
            pi9.reference_number,
            pi_batch_9.reference_number,
            ni_batch_9.nwi_code,
            im_as_ing_9_line.tasteless_menu_code,
            bas_ing_9.bi_code,
            ims9.tasteless_code,
            ni9.nwi_code
        ) AS menu_item_ingredients_code_sub_9,

        /* ---------- DESCRIPTION ---------- */
        COALESCE(
            im_as_ing__batch_9.menu_item_description,
            bs9_line.ingredient_description,
            ims_batch_9.full_item_description,
            pi9.full_item_description,
            pi_batch_9.full_item_description,
            ni_batch_9.item_description,
            im_as_ing_9_line.menu_item_description,
            bas_ing_9.ingredient_description,
            ims9.full_item_description,
            ni9.item_description
        ) AS menu_item_ingredients_description_sub_9,

        /* ---------- PACKAGING ---------- */
        COALESCE(
            ims_batch_9.packaging_size,
            pi9.packaging_size,
            pi_batch_9.packaging_size,
            ni_batch_9.packaging_size,
            ims9.packaging_size,
            ni9.packaging_size,
            1
        ) sub_packaging_size_9,

        /* ---------- QTY ---------- */
        ROUND(
            COALESCE(sub_main_ingr_9.prep_qty, bs9.prep_qty)
            / ROUND((COALESCE(sub_main_ingr_9.yield, bs9.yield) / 100), 4),
            4
        ) AS sub_ingredient_qty_9,

        /* ---------- UOM SMALL UNIT ---------- */
        COALESCE(pack_sub_9.packaging_description, uom_sub_9.uom_description) AS uom_small_unit_sub_9,

        /* ---------- LANDED COST ---------- */
        COALESCE(
            im_as_ing__batch_9.ingredient_total_cost,
            bs9_line.ttp,
            ims_batch_9.landed_cost,
            pi9.landed_cost,
            pi_batch_9.landed_cost,
            ni_batch_9.ttp,
            im_as_ing_9_line.ingredient_total_cost,
            bas_ing_9.ttp,
            ims9.landed_cost,
            ni9.ttp,
            NULL
        ) AS landed_cost_sub_9,

        /* ---------- UOM LARGE UNIT ---------- */
        uom_sub_9.uom_description AS uom_large_unit_sub_9

    FROM m_s_8

    /* ===== Ingredients section ===== */

    /* ===== MENU SUBS ===== */
    LEFT JOIN menu_items im_as_ing_9
        ON im_as_ing_9.tasteless_menu_code = m_s_8.menu_item_ingredients_code_sub_8
       AND m_s_8.sub_types_8 = 'MMFF'

    LEFT JOIN ingredients sub_main_ingr_9
        ON im_as_ing_9.id = sub_main_ingr_9.menu_items_id

    LEFT JOIN menu_items im_as_ing_9_line
        ON im_as_ing_9_line.id = sub_main_ingr_9.menu_as_ingredient_id

    LEFT JOIN batching_ingredients bas_ing_9
        ON bas_ing_9.id = sub_main_ingr_9.batching_ingredients_id

    LEFT JOIN item_masters ims9
        ON ims9.id = sub_main_ingr_9.item_masters_id

    LEFT JOIN production_items pi9
        ON pi9.id = sub_main_ingr_9.production_items_id

    LEFT JOIN new_ingredients ni9
        ON ni9.id = sub_main_ingr_9.new_ingredients_id

    /* ===== BATCH SUBS ===== */
    LEFT JOIN batching_ingredients bs9_header
        ON bs9_header.bi_code = m_s_8.menu_item_ingredients_code_sub_8
       AND m_s_8.sub_types_8 = 'BATCH'

    LEFT JOIN batching_ingredients_details bs9
        ON bs9.batching_ingredients_id = bs9_header.id

    LEFT JOIN batching_ingredients bs9_line
        ON bs9_line.id = bs9.batching_as_ingredient_id

    LEFT JOIN ingredients sub_main_ing_batch_9
        ON sub_main_ing_batch_9.id = bs9.menu_as_ingredient_id

    LEFT JOIN menu_items im_as_ing__batch_9
        ON im_as_ing__batch_9.id = bs9.menu_as_ingredient_id

    LEFT JOIN item_masters ims_batch_9
        ON ims_batch_9.id = bs9.item_masters_id

    LEFT JOIN production_items pi_batch_9
        ON pi_batch_9.id = bs9.production_items_id

    LEFT JOIN new_ingredients ni_batch_9
        ON ni_batch_9.id = bs9.new_ingredients_id

    LEFT JOIN uoms AS uom_sub_9
        ON uom_sub_9.id = COALESCE(
            im_as_ing__batch_9.uoms_id,
            bs9_line.uoms_id,
            ims_batch_9.uoms_id,
            pi9.uoms_id,
            pi_batch_9.uoms_id,
            ni_batch_9.uoms_id,
            im_as_ing_9_line.uoms_id,
            bas_ing_9.uoms_id,
            ims9.uoms_id,
            ni9.uoms_id
        )

    LEFT JOIN packagings AS pack_sub_9
        ON pack_sub_9.id = COALESCE(
            ims_batch_9.packagings_id,
            pi_batch_9.packagings_id,
            ims9.packagings_id,
            pi9.packagings_id
        )
),

m_s_9 AS (
    SELECT
        b.*,
        ROUND((b.sub_ingredient_qty_9 / b.sub_packaging_size_9), 4) AS sku_converted_sub_9,
        ROUND(
            ROUND((b.sub_ingredient_qty_9 / b.sub_packaging_size_9), 4) * b.landed_cost_sub_9,
            4
        ) AS sub_unit_cost_9
    FROM m_s_9_base b
),

m_s_10_base AS (
    SELECT
        m_s_9.*,

        /* ---------- TYPE ---------- */
        CASE
            WHEN im_as_ing__batch_10.tasteless_menu_code IS NOT NULL THEN 'MMFF'
            WHEN bs10_line.bi_code IS NOT NULL THEN 'BATCH'
            WHEN ims_batch_10.tasteless_code IS NOT NULL THEN 'IMFS'
            WHEN pi10.reference_number IS NOT NULL THEN 'PIMFS'
            WHEN pi_batch_10.reference_number IS NOT NULL THEN 'PIMFS'
            WHEN ni_batch_10.nwi_code IS NOT NULL THEN 'NEW'
            WHEN im_as_ing_10_line.tasteless_menu_code IS NOT NULL THEN 'MMFF'
            WHEN bas_ing_10.bi_code IS NOT NULL THEN 'BATCH'
            WHEN ims10.tasteless_code IS NOT NULL THEN 'IMFS'
            WHEN ni10.nwi_code IS NOT NULL THEN 'NEW'
            WHEN im_as_ing_10.tasteless_menu_code IS NOT NULL THEN 'MMFF'
            ELSE 'UNKNOWN'
        END AS sub_types_10,

        /* ---------- CODE ---------- */
        COALESCE(
            im_as_ing__batch_10.tasteless_menu_code,
            bs10_line.bi_code,
            ims_batch_10.tasteless_code,
            pi10.reference_number,
            pi_batch_10.reference_number,
            ni_batch_10.nwi_code,
            im_as_ing_10_line.tasteless_menu_code,
            bas_ing_10.bi_code,
            ims10.tasteless_code,
            ni10.nwi_code
        ) AS menu_item_ingredients_code_sub_10,

        /* ---------- DESCRIPTION ---------- */
        COALESCE(
            im_as_ing__batch_10.menu_item_description,
            bs10_line.ingredient_description,
            ims_batch_10.full_item_description,
            pi10.full_item_description,
            pi_batch_10.full_item_description,
            ni_batch_10.item_description,
            im_as_ing_10_line.menu_item_description,
            bas_ing_10.ingredient_description,
            ims10.full_item_description,
            ni10.item_description
        ) AS menu_item_ingredients_description_sub_10,

        /* ---------- PACKAGING ---------- */
        COALESCE(
            ims_batch_10.packaging_size,
            pi10.packaging_size,
            pi_batch_10.packaging_size,
            ni_batch_10.packaging_size,
            ims10.packaging_size,
            ni10.packaging_size,
            1
        ) sub_packaging_size_10,

        /* ---------- QTY ---------- */
        ROUND(
            COALESCE(sub_main_ingr_10.prep_qty, bs10.prep_qty)
            / ROUND((COALESCE(sub_main_ingr_10.yield, bs10.yield) / 100), 4),
            4
        ) AS sub_ingredient_qty_10,

        /* ---------- UOM SMALL UNIT ---------- */
        COALESCE(pack_sub_10.packaging_description, uom_sub_10.uom_description) AS uom_small_unit_sub_10,

        /* ---------- LANDED COST ---------- */
        COALESCE(
            im_as_ing__batch_10.ingredient_total_cost,
            bs10_line.ttp,
            ims_batch_10.landed_cost,
            pi10.landed_cost,
            pi_batch_10.landed_cost,
            ni_batch_10.ttp,
            im_as_ing_10_line.ingredient_total_cost,
            bas_ing_10.ttp,
            ims10.landed_cost,
            ni10.ttp,
            NULL
        ) AS landed_cost_sub_10,

        /* ---------- UOM LARGE UNIT ---------- */
        uom_sub_10.uom_description AS uom_large_unit_sub_10

    FROM m_s_9

    /* ===== Ingredients section ===== */

    /* ===== MENU SUBS ===== */
    LEFT JOIN menu_items im_as_ing_10
        ON im_as_ing_10.tasteless_menu_code = m_s_9.menu_item_ingredients_code_sub_9
       AND m_s_9.sub_types_9 = 'MMFF'

    LEFT JOIN ingredients sub_main_ingr_10
        ON im_as_ing_10.id = sub_main_ingr_10.menu_items_id

    LEFT JOIN menu_items im_as_ing_10_line
        ON im_as_ing_10_line.id = sub_main_ingr_10.menu_as_ingredient_id

    LEFT JOIN batching_ingredients bas_ing_10
        ON bas_ing_10.id = sub_main_ingr_10.batching_ingredients_id

    LEFT JOIN item_masters ims10
        ON ims10.id = sub_main_ingr_10.item_masters_id

    LEFT JOIN production_items pi10
        ON pi10.id = sub_main_ingr_10.production_items_id

    LEFT JOIN new_ingredients ni10
        ON ni10.id = sub_main_ingr_10.new_ingredients_id

    /* ===== BATCH SUBS ===== */
    LEFT JOIN batching_ingredients bs10_header
        ON bs10_header.bi_code = m_s_9.menu_item_ingredients_code_sub_9
       AND m_s_9.sub_types_9 = 'BATCH'

    LEFT JOIN batching_ingredients_details bs10
        ON bs10.batching_ingredients_id = bs10_header.id

    LEFT JOIN batching_ingredients bs10_line
        ON bs10_line.id = bs10.batching_as_ingredient_id

    LEFT JOIN ingredients sub_main_ing_batch_10
        ON sub_main_ing_batch_10.id = bs10.menu_as_ingredient_id

    LEFT JOIN menu_items im_as_ing__batch_10
        ON im_as_ing__batch_10.id = bs10.menu_as_ingredient_id

    LEFT JOIN item_masters ims_batch_10
        ON ims_batch_10.id = bs10.item_masters_id

    LEFT JOIN production_items pi_batch_10
        ON pi_batch_10.id = bs10.production_items_id

    LEFT JOIN new_ingredients ni_batch_10
        ON ni_batch_10.id = bs10.new_ingredients_id

    LEFT JOIN uoms AS uom_sub_10
        ON uom_sub_10.id = COALESCE(
            im_as_ing__batch_10.uoms_id,
            bs10_line.uoms_id,
            ims_batch_10.uoms_id,
            pi10.uoms_id,
            pi_batch_10.uoms_id,
            ni_batch_10.uoms_id,
            im_as_ing_10_line.uoms_id,
            bas_ing_10.uoms_id,
            ims10.uoms_id,
            ni10.uoms_id
        )

    LEFT JOIN packagings AS pack_sub_10
        ON pack_sub_10.id = COALESCE(
            ims_batch_10.packagings_id,
            pi_batch_10.packagings_id,
            ims10.packagings_id,
            pi10.packagings_id
        )
),

m_s_10 AS (
    SELECT
        b.*,
        ROUND((b.sub_ingredient_qty_10 / b.sub_packaging_size_10), 4) AS sku_converted_sub_10,
        ROUND(
            ROUND((b.sub_ingredient_qty_10 / b.sub_packaging_size_10), 4) * b.landed_cost_sub_10,
            4
        ) AS sub_unit_cost_10
    FROM m_s_10_base b
)

SELECT *
FROM m_s_10
-- WHERE m_s_10.menu_code = '6006056'
;