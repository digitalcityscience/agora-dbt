Below is a short README section for the intermediate stage:

---

# Intermediate Stage Overview

In the intermediate stage, we enrich our ALKIS parcel data by integrating additional datasets using spatial and attribute-based matching. The process is divided into two main parts:

- **LGB Matching:**  
  - We join the ALKIS parcels (from `stg_alkis` - raw alkis parcel data) with the unified LGB data (from `stg_lgb_union`, mergerd LGB dataset from masteportal) based on matching parcel identifiers (e.g., ZAE equals flurst) and spatial intersections.
  - We then aggregate distinct LGB classification fields (`art` and `typ`) for each parcel.

- **Nutzung Matching:**  
  - We join ALKIS parcels with the cleaned Nutzung data (from `stg_nutzung`) using spatial intersections.
  - Only intersections with an area greater than 1 m² are considered.
  - Unique normalized usage types are aggregated into an array per parcel.

This intermediate processing provides enriched datasets that capture both LGB and Nutzung information, serving as the foundation for our final output models.


```mermaid
graph LR;
    A["stg_alkis"] -- Extract Data --> B["alkis"]
    C["stg_lgb_union"] -- Extract Data --> D["lgb"]
    B -- "Join on ZAE = flurst and Spatial Intersects" --> E["intersected_data"]
    D -- "Join on ZAE = flurst and Spatial Intersects" --> E
    E -- Extract Unique Values --> F["distinct_values"]
    F -- Group by alkis_id and Aggregate --> G["matched_parcels"]
    G -- Final Output --> H["int_alkis_lgb_matched"]
    I["stg_alkis"] -- Extract Data --> J["alkis"]
    K["stg_nutzung"] -- Extract Data --> L["nutzung"]
    J -- Join using Spatial Intersects --> M["intersection_table"]
    L -- Join using Spatial Intersects --> M
    M -- Group by parcel_uuid and Aggregate Nutzart --> N["int_alkis_nutzung_matched"]
    style E fill:#AA00FF, color:#FFFFFF, stroke:#AA00FF
    style G fill:#00C853, color:#FFFFFF, stroke:#00C853
    style M fill:#2962FF, color:#FFFFFF, stroke:#2962FF
    style N fill:#D32F2F, color:#FFFFFF, stroke:#D32F2F
```
