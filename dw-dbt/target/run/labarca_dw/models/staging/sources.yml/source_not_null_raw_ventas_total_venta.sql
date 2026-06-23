
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select total_venta
from "labarca_dw"."raw"."ventas"
where total_venta is null



  
  
      
    ) dbt_internal_test