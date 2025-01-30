# agora-dbt
This branch contains the initial logic for GRZ calculation performed in 2024. Due to certain shortcomings in this logic, the code has been updated. This branch was created to preserve previous calculations.

Please follow the MAIN branch for the latest updates.

## For documentation

dbt docs generate --target dev

dbt docs serve --port 8686
or
dbt docs serve --host IP --port 8686

dbt run --target dev or prod

## TO Do list

- calculate the center point of parcel
- get the xplannung_GRZ from xplan data
- create potential column within parcel dataset

## Methods

### Manage DB Table name with target

```
-- macros/get_table_name.sql

{% macro get_table_name(table_name) %}
    {% if target.name == 'prod' %}
        prod_{{ table_name }}
    {% else %}
        dev_{{ table_name }}
    {% endif %}
{% endmacro %}

```

for model

```
-- models/my_model.sql

select *
from {{ get_table_name('source_table') }}
```

### Delete dublicate

select _
from stage.alkis_parcel_grz apg
where apg.id IN (
select id from stage.alkis_parcel_grz
group by id
having count(_)=1
)

- we have a problem in building_list column. It is exported as varchar 255 but somehow it is longer than it. we should check it
