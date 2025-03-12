## Staging Layer Overview

The staging layer is responsible for extracting, cleaning, and normalizing our raw geo-data. This layer prepares the data for further transformation in the intermediate and final stages.

### **Key Staging Models**

- **stg_alkis**  
  - **Source:** Extracts data from the `parcel_test_west` table.  
  - **Processing:** Cleans the ALKIS parcel data and appends a `data_version` (using a dynamic date variable).  
  - **Outcome:** Provides standardized ALKIS parcel information for subsequent joins.

- **stg_lgb_union**  
  - **Source:** Combines multiple LGB tables (e.g., `verwaltungsvermoegen_gewaesser`, `landesbetriebe_gem_paragraph_26_lho`, etc.).  
  - **Processing:** Unions the various LGB datasets into a single view, ensuring consistent column naming and structure.  
  - **Outcome:** A unified LGB dataset ready for matching with ALKIS parcels.

- **stg_nutzung**  
  - **Source:** Reads from the `Nutzung_Flurstuecke` table.  
  - **Processing:** Normalizes the `nutzart` column by converting values to lowercase and cleaning extra whitespace (resulting in the column `clean_nutzart`).  
  - **Outcome:** Cleaned and standardized Nutzung data for reliable spatial joins.

### **Why This Approach?**

- **Consistency:** Each model standardizes its data, ensuring that downstream models work with clean, well-documented datasets.
- **Modularity:** Separating raw data ingestion and cleaning into dedicated models makes the pipeline easier to maintain and debug.
- **Reusability:** These staging models serve as a solid foundation for multiple intermediate and final transformations without reprocessing raw data each time.

This structured approach in the staging layer helps ensure that all raw data is ready for efficient and reliable transformation in later stages of the pipeline.

