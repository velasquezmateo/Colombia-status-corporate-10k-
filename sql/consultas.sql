-- 1. ¿Cuáles son los 3 sectores en cada departamento que ofrecen el mayor ROE promedio?
select * from (select m.Macrosector as Sectores, g.departamento_domicilio as Departamentos, round(avg(f.ROE),2) as 'ROE(%)',
rank() over (partition by g.departamento_domicilio order by avg(f.ROE) desc) as Ranking
from tabla_hechos f
left join macrosector m on f.id_macrosector=m.id_macrosector
left join geografia g on f.id_ciudad=g.id_ciudad
where f.ROE!=0
GROUP BY g.departamento_domicilio, m.Macrosector
) as subconsulta
where Ranking <=3;

-- 2. ¿ Qué empresas que han tenido un crecimiento positivo en su ganancia durante todos los años registrados?
select empresa from 
(select e.empresa, f.Ganancia_perdida, a.Anio_de_corte,
lag(f.Ganancia_perdida) over (partition by e.empresa order by a.Anio_de_corte asc) as ganancia_anterior
from tabla_hechos f
left join empresas e on f.id_empresa=e.id_empresa
left join anio_corte a on f.id_anio=a.id_anio) as tabla
where Ganancia_perdida > ganancia_anterior
group by empresa
having count(*)>=3;

-- 3. ¿Qué empresas tienen Patrimonio negativo a lo largo de los años entre 2021-2024?
select empresa from
(select e.empresa,
f.Total_activos,
f.Total_pasivos,
f.Total_patrimonio,
a.Anio_de_corte,
lag(f.Total_patrimonio) over (partition by e.empresa order by a.Anio_de_corte asc) as patrimonio_anterior
from tabla_hechos f
left join empresas e on f.id_empresa=e.id_empresa
left join anio_corte a on f.id_anio=a.id_anio) as tabla
where (Total_patrimonio-patrimonio_anterior)<0
group by empresa
having count(*)>=3 ;

/* 4.Calcular el índice de endeudamiento promedio por departamento y clasificarlos en 
"Riesgo Alto" (>70%), "Medio" (40-70%) y "Bajo" (<40%) */

select g.departamento_domicilio, 
round(avg(f.indice_endeudamiento),2) as promedio_deuda,
case
	when round(avg(f.indice_endeudamiento),2) >70 then 'Riesgo Ato'
    when round(avg(f.indice_endeudamiento),2) between 40 and 70 then 'Medio'
    else 'Bajo'
    end as 'Categoría de endeudamiento'
from tabla_hechos f
join geografia g on f.id_ciudad=g.id_ciudad
join anio_corte a on f.id_anio=a.id_anio
where a.Anio_de_corte=2024
group by g.departamento_domicilio order by round(avg(f.indice_endeudamiento),2) desc limit 33;

/* 5. (Venture capital) Encontrar las empresas cuyos ingresos crecieron por encima del percentil 95 
en su respectivo macrosector (outliers).*/

with tabla1 as (
select e.empresa, 
m.Macrosector,
f.Ingresos_operacionales,
a.Anio_de_corte, 
lag(f.Ingresos_operacionales) over (partition by m.Macrosector, e.empresa order by a.Anio_de_corte) as Ingresos_año_anterior
from tabla_hechos f
join empresas e on f.id_empresa=e.id_empresa
join anio_corte a on f.id_anio=a.id_anio
join macrosector m on f.id_macrosector=m.id_macrosector
),
tabla2 as(
select empresa, Macrosector, ((Ingresos_operacionales-Ingresos_año_anterior)/Ingresos_año_anterior)*100 as 'Tasa crecimiento (%)', 
	Anio_de_corte,
	percent_rank() over (partition by Macrosector 
						 order by ((Ingresos_operacionales-Ingresos_año_anterior)/Ingresos_año_anterior)*100 desc) as Percentile
from tabla1
where a.Anio_de_corte=2024),
tabla3 as (
select * from tabla2
where Percentile <= 0.05)

select * from tabla3;

/* 6. Detección de "Empresas Estrella" (Matriz BCG - Inversión) */

with ingreso_empresas as (
select e.empresa, 
m.Macrosector,
f.Ingresos_operacionales,
lag(f.Ingresos_operacionales) over (partition by e.empresa order by a.Anio_de_corte asc) as ingresos_año_anterior, 
f.Total_patrimonio,
f.ROE,
a.Anio_de_corte
from tabla_hechos f  
join empresas e on f.id_empresa=e.id_empresa
join macrosector m on f.id_macrosector=m.id_macrosector
join anio_corte a on f.id_anio=a.id_anio),

tasa_crecimiento as (
select *,
round(((Ingresos_operacionales-ingresos_año_anterior)/ingresos_año_anterior)*100,2) as Tasa_crecimiento
from ingreso_empresas
where Anio_de_corte=2024),

matriz_bcg as (
select empresa,
Macrosector, 
ROE, 
Tasa_crecimiento,
case
/*Usar una tasa de crecimiento del 10% y un ROE del 15% coomo umbrales*/
	when Tasa_crecimiento >=10 and ROE >=15 then 'Estrella'
    when Tasa_crecimiento < 10 and ROE >=15 then 'Vaca lechera'
    when Tasa_crecimiento >=10 and ROE < 15 then 'Interrogante'
    else 'Perro'
    end as categoria_bcg
    from tasa_crecimiento)

select * from matriz_bcg;


/* 7. (Dominancia del mercado) En cada ciudad, ¿qué porcentaje de los ingresos totales de su sector captura la empresa líder?*/


(select *, round((Ingresos_2024/Ingresos_2024_region)*100,2) as 'Dominancia',
rank() over (partition by departamento_domicilio,Macrosector order by ((Ingresos_2024/Ingresos_2024_region)) desc) as 'Ranking' 
from
(select e.empresa, 
m.Macrosector,
f.Ingresos_operacionales as Ingresos_2024, 
g.departamento_domicilio,
sum(f.Ingresos_operacionales) over (partition by g.departamento_domicilio, m.Macrosector) as Ingresos_2024_region
from tabla_hechos f
join empresas e on f.id_empresa=e.id_empresa
join macrosector m on f.id_macrosector=m.id_macrosector
join anio_corte a on f.id_anio=a.id_anio
join geografia g on f.id_ciudad=g.id_ciudad
where a.Anio_de_corte=2024) as tabla) ;

/* 8. Rotación de activos totales ¿Qué tan productiva es la infraestructura de cada 
departamento en Colombia en el año 2024?. */

with tabla1 as (
select
g.departamento_domicilio,
round(sum(f.Ingresos_operacionales),2) as Total_ingresos,
round(sum(f.Total_activos),2) as Total_activos
from tabla_hechos f
join empresas e on f.id_empresa=e.id_empresa
join macrosector m on f.id_macrosector=m.id_macrosector
join geografia g on f.id_ciudad=g.id_ciudad
join anio_corte a on f.id_anio=a.id_anio
where a.Anio_de_corte=2024
group by departamento_domicilio
),
tabla2 as(
select departamento_domicilio,
Total_ingresos,
Total_activos,
Case
	when (Total_ingresos/Total_activos) > 1 then 'Alta productividad'
    when (Total_ingresos/Total_activos) between 0.5 and 1 then 'Productividad media'
    else 'Baja productividad'
    End as 'Rotación activos'
from tabla1 order by departamento_domicilio asc)
select * from tabla2;

/* 9. (Mapa de competitividad) Con base en la rotación de activos y la matriz BCG, ¿en qué departamentos de Colombia es más 
estratégico invertir según el macrosector económico? */
with tabla1 as (
select
g.departamento_domicilio,
m.Macrosector,
round(sum(f.Ingresos_operacionales),2) as Total_ingresos,
round(sum(f.Total_activos),2) as Total_activos
from tabla_hechos f
join empresas e on f.id_empresa=e.id_empresa
join macrosector m on f.id_macrosector=m.id_macrosector
join geografia g on f.id_ciudad=g.id_ciudad
join anio_corte a on f.id_anio=a.id_anio
where a.Anio_de_corte=2024
group by departamento_domicilio, Macrosector
),
tabla2 as(
select Macrosector,
departamento_domicilio,
round((Total_ingresos/Total_activos),2) as Rotacion_activos,
rank() over (partition by Macrosector order by (Total_ingresos/Total_activos) desc) as Puesto_competitivo,
Case
	when (Total_ingresos/Total_activos) > 1 then 'Alta productividad'
    when (Total_ingresos/Total_activos) between 0.5 and 1 then 'Productividad media'
    else 'Baja productividad'
    End as 'Productividad'
from tabla1)
select * from tabla2;


select Anio_de_corte from anio_corte
