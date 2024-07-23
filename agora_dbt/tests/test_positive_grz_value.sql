select *
from {{ ref('alkis_parcel_grz') }}
where grz_value < 0